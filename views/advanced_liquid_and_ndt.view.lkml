########################################
# NATIVE DERIVED TABLE (explore_source)
########################################
#
# explore_source builds a derived table FROM a LookML explore
# rather than raw SQL. Benefits:
#   - Automatically stays in sync when the source explore changes
#   - Reuses existing LookML dimensions/measures (DRY)
#   - No SQL to maintain — Looker generates it
#
# Use case here: pre-aggregate the accounts+subscriptions explore
# into a per-plan-tier summary for fast dashboard KPIs.
########################################

view: plan_tier_summary_ndt {

  derived_table: {
    explore_source: accounts {             # source explore
      column: plan_tier {}                 # dimension from accounts view
      column: industry  {}
      column: count     { field: accounts.count }
      column: count_churned { field: accounts.count_churned }
      column: churn_rate    { field: accounts.churn_rate }
      column: total_mrr     { field: subscriptions.total_mrr }
      column: avg_mrr       { field: subscriptions.average_mrr }
      column: total_seats   { field: accounts.total_seats }

      # Apply a default filter (optional)
      filters: [accounts.churn_flag: "Yes,No"]

      # NOTE: explore_source persistence is controlled at the derived_table level.
      # Add `datagroup_trigger: daily_refresh` outside explore_source block
      # once a writeback schema is configured in Looker Admin.
    }
  }

  dimension: plan_tier {
    type:        string
    sql:         ${TABLE}.plan_tier ;;
    primary_key: yes
  }

  dimension: industry {
    type: string
    sql:  ${TABLE}.industry ;;
  }

  measure: total_accounts {
    type:  sum
    sql:   ${TABLE}.count ;;
    label: "Total Accounts (NDT)"
  }

  measure: total_churned {
    type:  sum
    sql:   ${TABLE}.count_churned ;;
    label: "Churned Accounts (NDT)"
  }

  measure: avg_churn_rate {
    type:              average
    sql:               ${TABLE}.churn_rate ;;
    label:             "Churn Rate (NDT)"
    value_format_name: percent_1
  }

  measure: total_mrr {
    type:              sum
    sql:               ${TABLE}.total_mrr ;;
    label:             "Total MRR (NDT)"
    value_format_name: usd_0
  }

  measure: avg_mrr {
    type:              average
    sql:               ${TABLE}.avg_mrr ;;
    label:             "Avg MRR (NDT)"
    value_format_name: usd_0
  }
}


########################################
# ADVANCED LIQUID
########################################
#
# Demonstrates:
#   1. _in_query    — is this field included in the current query?
#   2. _is_selected — is this dimension in the SELECT list?
#   3. _is_filtered — is this field being filtered on?
#   4. sql_always_where — invisible WHERE clause users cannot see/remove
#   5. bind_filters — pass a dashboard filter directly into a DT WHERE clause
#   6. _user_attributes — personalize SQL/HTML per user
#   7. Conditional SQL based on parameter combinations
########################################

view: advanced_liquid_demo {
  sql_table_name: `@{dataset}.@{table_prefix}accounts` ;;

  # ----------------------------------------------------------
  # 1. _in_query — change SQL behaviour based on which fields
  #    are included in the current query.
  #    Here: use an expensive CASE only when plan_tier is present.
  # ----------------------------------------------------------
  dimension: adaptive_label {
    type:        string
    label:       "Adaptive Dimension"
    description: "Uses _in_query to avoid expensive CASE when plan_tier isn't needed."
    sql:
      {% if advanced_liquid_demo.plan_tier._in_query %}
        CONCAT(${TABLE}.account_name, ' (', ${TABLE}.plan_tier, ')')
      {% else %}
        ${TABLE}.account_name
      {% endif %} ;;
  }

  dimension: account_name {
    type: string
    sql:  ${TABLE}.account_name ;;
  }

  dimension: plan_tier {
    type: string
    sql:  ${TABLE}.plan_tier ;;
  }

  dimension: industry {
    type: string
    sql:  ${TABLE}.industry ;;
  }

  dimension: account_id {
    type:        string
    sql:         ${TABLE}.account_id ;;
    primary_key: yes
    hidden:      yes
  }

  # ----------------------------------------------------------
  # 2. _is_selected — add a computed column only when a field
  #    is in the SELECT. Avoids unnecessary window functions.
  # ----------------------------------------------------------
  dimension: seats {
    type: number
    sql:  SAFE_CAST(${TABLE}.seats AS INT64) ;;
  }

  measure: seats_rank {
    type:        number
    label:       "Seats Rank"
    description: "Only computes RANK() when this measure is selected — uses _is_selected."
    sql:
      {% if advanced_liquid_demo.seats_rank._is_selected %}
        RANK() OVER (ORDER BY SUM(SAFE_CAST(${TABLE}.seats AS INT64)) DESC)
      {% else %}
        NULL
      {% endif %} ;;
  }

  # ----------------------------------------------------------
  # 3. _is_filtered — add a JOIN or subquery only when a
  #    specific filter is active (avoids unnecessary cost).
  # ----------------------------------------------------------
  dimension: churn_enriched {
    type:        string
    label:       "Churn Status (enriched)"
    description: "Enriches with churn data only when churn filter is active."
    sql:
      {% if advanced_liquid_demo.churn_enriched._is_filtered %}
        CASE WHEN ${TABLE}.churn_flag = 'Yes' THEN 'Churned' ELSE 'Active' END
      {% else %}
        'Not filtered — skipping enrichment'
      {% endif %} ;;
  }

  dimension: churn_flag {
    type:   yesno
    sql:    ${TABLE}.churn_flag = 'Yes' ;;
    hidden: yes
  }

  # ----------------------------------------------------------
  # 4. _user_attributes — personalize output per Looker user.
  #    Common uses: regional currency, language, allowed data scope.
  #
  #    Requires user attributes configured in Looker Admin > User Attributes.
  #    Example (commented out — configure the attributes first):
  #
  #  dimension: localized_plan_display {
  #    type:        string
  #    sql:         ${TABLE}.plan_tier ;;
  #    html:
  #      {% assign currency = _user_attributes['preferred_currency'] | default: 'USD' %}
  #      {% assign region   = _user_attributes['user_region']        | default: 'Global' %}
  #      <span title="Region: {{ region }} | Currency: {{ currency }}">
  #        {{ value }} <small style="color:#94a3b8">({{ currency }})</small>
  #      </span> ;;
  #  }
  # ----------------------------------------------------------

  # ----------------------------------------------------------
  # 5. Conditional SQL on parameter combinations
  #    Show different aggregations depending on TWO parameters.
  # ----------------------------------------------------------
  parameter: metric_type {
    type: string
    label: "Metric Type"
    allowed_value: { label: "Count"        value: "count"   }
    allowed_value: { label: "Churned"      value: "churned" }
    allowed_value: { label: "Trial"        value: "trial"   }
    default_value: "count"
  }

  parameter: comparison_period {
    type: string
    label: "Comparison Period"
    allowed_value: { label: "Current"      value: "current"  }
    allowed_value: { label: "Prior Month"  value: "prior"    }
    default_value: "current"
  }

  measure: conditional_metric {
    type:        number
    label:       "Conditional Metric"
    description: "Changes calculation based on metric_type + comparison_period parameter combination."
    sql:
      {% assign metric = advanced_liquid_demo.metric_type._parameter_value %}
      {% assign period = advanced_liquid_demo.comparison_period._parameter_value %}

      {% if metric == "'count'" and period == "'current'" %}
      COUNT(DISTINCT ${TABLE}.account_id)

      {% elsif metric == "'count'" and period == "'prior'" %}
      COUNT(DISTINCT CASE
      WHEN SAFE_CAST(${TABLE}.signup_date AS DATE)
      < DATE_TRUNC(CURRENT_DATE(), MONTH)
      THEN ${TABLE}.account_id END)

      {% elsif metric == "'churned'" and period == "'current'" %}
      COUNT(DISTINCT CASE
      WHEN ${TABLE}.churn_flag = 'Yes' THEN ${TABLE}.account_id END)

      {% elsif metric == "'churned'" and period == "'prior'" %}
      COUNT(DISTINCT CASE
      WHEN ${TABLE}.churn_flag = 'Yes'
      AND SAFE_CAST(${TABLE}.signup_date AS DATE)
      < DATE_TRUNC(CURRENT_DATE(), MONTH)
      THEN ${TABLE}.account_id END)

      {% elsif metric == "'trial'" %}
      COUNT(DISTINCT CASE
      WHEN ${TABLE}.is_trial = 'Yes' THEN ${TABLE}.account_id END)

      {% else %}
      COUNT(DISTINCT ${TABLE}.account_id)
      {% endif %} ;;
    value_format_name: decimal_0
  }

  # ----------------------------------------------------------
  # 6. Manifest constants in SQL and HTML
  #    @{constant_name} is replaced at query time with the
  #    value defined in manifest.lkml
  # ----------------------------------------------------------
  dimension: company_branded_name {
    type:        string
    label:       "Account (Branded)"
    description: "Uses @{company_name} manifest constant in HTML."
    sql:         ${TABLE}.account_name ;;
    html:
      <span>
        <strong style="color:#4f46e5">@{company_name}</strong>
        &mdash; {{ value }}
      </span> ;;
  }

  measure: count {
    type:  count
    label: "Account Count"
    drill_fields: [account_id, account_name, plan_tier, industry]
  }
}
