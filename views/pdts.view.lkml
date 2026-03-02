########################################
# PERSISTENT DERIVED TABLES (PDTs)
########################################
#
# PDTs materialize query results as physical tables in the database,
# dramatically speeding up expensive aggregations.
#
# Three persistence strategies shown:
#   1. datagroup_trigger  — rebuild when the datagroup fires (data-aware)
#   2. sql_trigger_value  — rebuild when a SQL expression changes value
#   3. persist_for        — rebuild on a fixed time interval
#
# REQUIREMENT: PDTs need a PDT schema (writeback dataset) configured
# in Looker Admin > Connections. Without it, these will error.
# Uncomment `materialized_view: yes` to use BigQuery's native
# materialized views instead, which don't need writeback schema.
########################################

# ============================================================
# PDT 1: ACCOUNT MRR SUMMARY
# Strategy: datagroup_trigger — rebuilds when daily_refresh fires
# Use case: Pre-aggregate per-account MRR so account-level
#           revenue queries don't scan the full subscriptions table.
# ============================================================

view: account_mrr_summary {

  derived_table: {
    # PDT NOTE: To make this a true PDT, configure a writeback schema in
    # Looker Admin > Connections, then uncomment one of:
    #   datagroup_trigger: daily_refresh
    #   persist_for: "24 hours"
    # For BigQuery native materialized views, uncomment:
    #   materialized_view: yes
    sql:
      SELECT
        s.account_id,
        a.plan_tier,
        a.industry,
        a.country,
        COUNT(DISTINCT s.subscription_id)                    AS subscription_count,
        SUM(SAFE_CAST(s.mrr_amount   AS FLOAT64))            AS total_mrr,
        SUM(SAFE_CAST(s.arr_amount   AS FLOAT64))            AS total_arr,
        AVG(SAFE_CAST(s.mrr_amount   AS FLOAT64))            AS avg_mrr,
        MAX(SAFE_CAST(s.mrr_amount   AS FLOAT64))            AS max_mrr,
        MIN(SAFE_CAST(s.mrr_amount   AS FLOAT64))            AS min_mrr,
        SUM(CASE WHEN COALESCE(SAFE_CAST(s.upgrade_flag   AS BOOL), FALSE) THEN 1 ELSE 0 END) AS upgrade_count,
        SUM(CASE WHEN COALESCE(SAFE_CAST(s.downgrade_flag AS BOOL), FALSE) THEN 1 ELSE 0 END) AS downgrade_count,
        SUM(CASE WHEN COALESCE(SAFE_CAST(s.churn_flag     AS BOOL), FALSE) THEN
              SAFE_CAST(s.mrr_amount AS FLOAT64) ELSE 0 END)  AS churned_mrr,
        MIN(SAFE_CAST(s.start_date  AS DATE))                AS first_subscription_date,
        MAX(SAFE_CAST(s.start_date  AS DATE))                AS latest_subscription_date
      FROM `@{dataset}.@{table_prefix}subscriptions` s
      LEFT JOIN `@{dataset}.@{table_prefix}accounts`  a ON s.account_id = a.account_id
      GROUP BY 1, 2, 3, 4 ;;
  }

  dimension: account_id {
    type:        string
    sql:         ${TABLE}.account_id ;;
    primary_key: yes
    hidden:      yes
  }

  dimension: plan_tier {
    type: string
    sql:  ${TABLE}.plan_tier ;;
  }

  dimension: industry {
    type: string
    sql:  ${TABLE}.industry ;;
  }

  dimension: country {
    type: string
    sql:  ${TABLE}.country ;;
  }

  dimension: first_subscription_date {
    type: date
    sql:  ${TABLE}.first_subscription_date ;;
  }

  dimension: latest_subscription_date {
    type: date
    sql:  ${TABLE}.latest_subscription_date ;;
  }

  measure: total_mrr {
    type:             sum
    sql:              ${TABLE}.total_mrr ;;
    label:            "Total MRR (PDT)"
    description:      "Pre-aggregated from account_mrr_summary PDT — fast query."
    value_format_name: usd_0
  }

  measure: total_arr {
    type:             sum
    sql:              ${TABLE}.total_arr ;;
    label:            "Total ARR (PDT)"
    value_format_name: usd_0
  }

  measure: avg_mrr_per_account {
    type:             average
    sql:              ${TABLE}.avg_mrr ;;
    label:            "Avg MRR per Account (PDT)"
    value_format_name: usd_0
  }

  measure: total_churned_mrr {
    type:             sum
    sql:              ${TABLE}.churned_mrr ;;
    label:            "Churned MRR (PDT)"
    value_format_name: usd_0
  }

  measure: total_subscription_count {
    type:  sum
    sql:   ${TABLE}.subscription_count ;;
    label: "Subscriptions (PDT)"
  }

  measure: mrr_churn_rate {
    type:              number
    sql:               SAFE_DIVIDE(SUM(${TABLE}.churned_mrr), NULLIF(SUM(${TABLE}.total_mrr), 0)) ;;
    label:             "MRR Churn Rate (PDT)"
    value_format_name: percent_1
  }
}


# ============================================================
# PDT 2: MONTHLY COHORT RETENTION
# Strategy: sql_trigger_value — rebuilds when MAX(churn_date) changes
# Use case: Expensive cohort calculations that would timeout as
#           a regular derived table on large datasets.
# ============================================================

view: monthly_cohort_retention {

  derived_table: {
    # PDT NOTE: sql_trigger_value requires writeback schema in Looker Admin.
    # Uncomment when configured:
    #   sql_trigger_value: SELECT MAX(SAFE_CAST(churn_date AS DATE))
    #     FROM `@{dataset}.@{table_prefix}churn_events` ;;
    sql:
      WITH
      cohorts AS (
        SELECT
          account_id,
          FORMAT_DATE('%Y-%m', SAFE_CAST(signup_date AS DATE)) AS cohort_month,
          SAFE_CAST(signup_date AS DATE)                        AS signup_date
        FROM `@{dataset}.@{table_prefix}accounts`
      ),
      churn AS (
        SELECT
          account_id,
          MIN(SAFE_CAST(churn_date AS DATE)) AS churn_date
        FROM `@{dataset}.@{table_prefix}churn_events`
        GROUP BY 1
      ),
      retention AS (
        SELECT
          c.cohort_month,
          COUNT(DISTINCT c.account_id)                             AS cohort_size,
          COUNT(DISTINCT CASE WHEN ch.churn_date IS NULL THEN c.account_id END) AS still_active,
          COUNT(DISTINCT ch.account_id)                            AS churned_count,
          DATE_DIFF(CURRENT_DATE(), MIN(c.signup_date), MONTH)     AS cohort_age_months
        FROM cohorts c
        LEFT JOIN churn ch ON c.account_id = ch.account_id
        GROUP BY 1
      )
      SELECT
        cohort_month,
        cohort_size,
        still_active,
        churned_count,
        cohort_age_months,
        SAFE_DIVIDE(still_active, cohort_size) AS retention_rate,
        SAFE_DIVIDE(churned_count, cohort_size) AS churn_rate
      FROM retention
      ORDER BY cohort_month ;;
  }

  dimension: cohort_month {
    type:           string
    sql:            ${TABLE}.cohort_month ;;
    label:          "Cohort Month"
    description:    "Month the cohort signed up (YYYY-MM)."
  }

  dimension: cohort_age_months {
    type:        number
    sql:         ${TABLE}.cohort_age_months ;;
    label:       "Cohort Age (Months)"
  }

  measure: cohort_size {
    type:  sum
    sql:   ${TABLE}.cohort_size ;;
    label: "Cohort Size"
  }

  measure: still_active {
    type:  sum
    sql:   ${TABLE}.still_active ;;
    label: "Still Active"
  }

  measure: churned_count {
    type:  sum
    sql:   ${TABLE}.churned_count ;;
    label: "Churned from Cohort"
  }

  measure: avg_retention_rate {
    type:              average
    sql:               ${TABLE}.retention_rate ;;
    label:             "Avg Retention Rate"
    value_format_name: percent_1
  }

  measure: avg_churn_rate {
    type:              average
    sql:               ${TABLE}.churn_rate ;;
    label:             "Avg Cohort Churn Rate"
    value_format_name: percent_1
  }
}


# ============================================================
# PDT 3: SUPPORT HEALTH SNAPSHOT
# Strategy: persist_for — rebuild every 6 hours regardless of data
# Use case: Operational dashboard used by support team in real time;
#           acceptable to be slightly stale but must be fast.
# ============================================================

view: support_health_snapshot {

  derived_table: {
    # PDT NOTE: persist_for requires writeback schema in Looker Admin.
    # Uncomment when configured:
    #   persist_for: "6 hours"
    sql:
      SELECT
        t.account_id,
        a.plan_tier,
        a.industry,
        COUNT(DISTINCT t.ticket_id)                                        AS total_tickets,
        SUM(CASE WHEN LOWER(t.priority) = 'urgent' THEN 1 ELSE 0 END)     AS urgent_tickets,
        SUM(CASE WHEN COALESCE(SAFE_CAST(t.escalation_flag AS BOOL), FALSE) THEN 1 ELSE 0 END) AS escalated_tickets,
        AVG(SAFE_CAST(t.resolution_time_hours    AS FLOAT64))              AS avg_resolution_hours,
        AVG(SAFE_CAST(t.satisfaction_score       AS FLOAT64))              AS avg_csat,
        AVG(SAFE_CAST(t.first_response_time_minutes AS FLOAT64))           AS avg_first_response_minutes,
        SAFE_DIVIDE(
          SUM(CASE WHEN COALESCE(SAFE_CAST(t.escalation_flag AS BOOL), FALSE) THEN 1 ELSE 0 END),
          NULLIF(COUNT(DISTINCT t.ticket_id), 0)
        )                                                                   AS escalation_rate,
        SAFE_DIVIDE(
          SUM(CASE WHEN SAFE_CAST(t.satisfaction_score AS FLOAT64) >= 4 THEN 1 ELSE 0 END),
          NULLIF(COUNT(DISTINCT t.ticket_id), 0)
        )                                                                   AS satisfied_rate
      FROM `@{dataset}.@{table_prefix}support_tickets` t
      LEFT JOIN `@{dataset}.@{table_prefix}accounts` a ON t.account_id = a.account_id
      GROUP BY 1, 2, 3 ;;
  }

  dimension: account_id {
    type:        string
    sql:         ${TABLE}.account_id ;;
    primary_key: yes
    hidden:      yes
  }

  dimension: plan_tier {
    type: string
    sql:  ${TABLE}.plan_tier ;;
  }

  dimension: industry {
    type: string
    sql:  ${TABLE}.industry ;;
  }

  measure: total_tickets {
    type:  sum
    sql:   ${TABLE}.total_tickets ;;
    label: "Total Tickets (PDT)"
  }

  measure: total_urgent {
    type:  sum
    sql:   ${TABLE}.urgent_tickets ;;
    label: "Urgent Tickets (PDT)"
  }

  measure: avg_resolution_hours {
    type:              average
    sql:               ${TABLE}.avg_resolution_hours ;;
    label:             "Avg Resolution Time (PDT)"
    value_format_name: decimal_1
  }

  measure: avg_csat {
    type:              average
    sql:               ${TABLE}.avg_csat ;;
    label:             "Avg CSAT (PDT)"
    value_format_name: decimal_1
  }

  measure: avg_escalation_rate {
    type:              average
    sql:               ${TABLE}.escalation_rate ;;
    label:             "Avg Escalation Rate (PDT)"
    value_format_name: percent_1
  }

  measure: avg_satisfied_rate {
    type:              average
    sql:               ${TABLE}.satisfied_rate ;;
    label:             "Avg Satisfaction Rate (PDT)"
    value_format_name: percent_1
  }
}

########################################
# INCREMENTAL PDT
########################################
# Instead of rebuilding the entire table on every trigger, an incremental PDT
# only processes rows newer than the last build using {% incrementcondition %}.
# This is a major performance win for large event tables.
#
# Requirements:
#   - PDT writeback schema configured in Looker Admin
#   - Source table has a reliable, monotonically increasing date/timestamp column
#   - increment_offset: N reprocesses the last N periods to catch late-arriving rows
########################################

view: feature_events_incremental_pdt {
  derived_table: {
    # PDT NOTE: Requires writeback schema in Looker Admin > Connections.
    # Uncomment when configured:
    # datagroup_trigger: daily_refresh
    # increment_key: "event_date"
    # increment_offset: 3  # reprocess last 3 days to catch late-arriving events

    sql:
      SELECT
        DATE(event_timestamp)                       AS event_date,
        account_id,
        feature_name,
        COUNT(*)                                    AS event_count,
        SUM(usage_count)                            AS total_usage_count,
        SUM(usage_duration_secs)                    AS total_duration_secs,
        SUM(error_count)                            AS total_errors,
        COUNT(DISTINCT subscription_id)             AS distinct_subscriptions
      FROM `@{dataset}.@{table_prefix}feature_usage`
      -- When incremental key is enabled, Looker injects the date range filter here:
      -- WHERE {% incrementcondition %} event_timestamp {% endincrementcondition %}
      GROUP BY 1, 2, 3 ;;
  }

  dimension: pk {
    type:        string
    sql:         CONCAT(${TABLE}.event_date, '|', ${TABLE}.account_id, '|', ${TABLE}.feature_name) ;;
    primary_key: yes
    hidden:      yes
  }

  dimension: event_date {
    type: date
    sql:  ${TABLE}.event_date ;;
  }

  dimension: account_id {
    type:   string
    sql:    ${TABLE}.account_id ;;
    hidden: yes
  }

  dimension: feature_name {
    type:  string
    sql:   ${TABLE}.feature_name ;;
    label: "Feature"
  }

  measure: total_event_count {
    type:  sum
    sql:   ${TABLE}.event_count ;;
    label: "Total Events"
    value_format_name: decimal_0
  }

  measure: total_usage_count {
    type:  sum
    sql:   ${TABLE}.total_usage_count ;;
    label: "Total Usage Count"
    value_format_name: decimal_0
  }

  measure: total_duration_mins {
    type:  number
    sql:   SUM(${TABLE}.total_duration_secs) / 60 ;;
    label: "Total Usage Duration (mins)"
    value_format_name: decimal_1
  }

  measure: total_errors {
    type:  sum
    sql:   ${TABLE}.total_errors ;;
    label: "Total Errors"
    value_format_name: decimal_0
  }
}


########################################
# BIGQUERY-OPTIMIZED PDT
########################################
# partition_keys: reduces data scanned for date-filtered queries (BigQuery billing win)
# cluster_keys: further sorts within partitions for fast account/feature lookups
#
# Requires: BigQuery dialect + PDT writeback schema
########################################

view: account_feature_summary_optimized_pdt {
  derived_table: {
    # PDT NOTE: Requires writeback schema in Looker Admin > Connections.
    # Uncomment when configured:
    # datagroup_trigger: daily_refresh
    # partition_keys:  ["summary_date"]          # partition by date — reduces scan cost
    # cluster_keys:    ["account_id", "feature_name"]  # cluster within partition

    sql:
      SELECT
        DATE(event_timestamp)         AS summary_date,
        account_id,
        feature_name,
        COUNT(*)                      AS event_count,
        SUM(usage_count)              AS usage_count,
        SUM(error_count)              AS error_count,
        MAX(mrr_at_time)              AS mrr_snapshot,
        COUNT(DISTINCT subscription_id) AS subscription_count
      FROM `@{dataset}.@{table_prefix}feature_usage`
      GROUP BY 1, 2, 3 ;;
  }

  dimension: pk {
    type:        string
    sql:         CONCAT(${TABLE}.summary_date, '|', ${TABLE}.account_id, '|', ${TABLE}.feature_name) ;;
    primary_key: yes
    hidden:      yes
  }

  dimension: summary_date {
    type:        date
    sql:         ${TABLE}.summary_date ;;
    convert_tz:  no
    label:       "Summary Date"
  }

  dimension: account_id {
    type: string
    sql: ${TABLE}.account_id ;;
    hidden: yes
  }

  dimension: feature_name {
    type: string
    sql: ${TABLE}.feature_name ;;
    label: "Feature"
  }

  measure: total_events {
    type: sum
    sql: ${TABLE}.event_count ;;
    label: "Events"
    value_format_name: decimal_0
  }

  measure: total_usage {
    type: sum
    sql: ${TABLE}.usage_count ;;
    label: "Usage Count"
    value_format_name: decimal_0
  }

  measure: total_errors {
    type: sum
    sql: ${TABLE}.error_count ;;
    label: "Errors"
    value_format_name: decimal_0
  }

  measure: mrr_snapshot {
    type: sum
    sql: ${TABLE}.mrr_snapshot ;;
    label: "MRR Snapshot"
    value_format_name: usd_0
  }
}
