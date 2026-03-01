view: subscriptions {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions` ;;

  # -------------------------------------------------------
  # PRIMARY KEY
  # -------------------------------------------------------

  dimension: subscription_id {
    primary_key:  yes
    type:         string
    sql:          ${TABLE}.subscription_id ;;
    label:        "Subscription ID"
    description:  "Unique identifier for each subscription record."
    tags:         ["id"]
  }

  # -------------------------------------------------------
  # FOREIGN KEYS
  # -------------------------------------------------------

  dimension: account_id {
    type:        string
    sql:         ${TABLE}.account_id ;;
    label:       "Account ID"
    hidden:      yes
    tags:        ["id"]
  }

  # -------------------------------------------------------
  # DIMENSIONS — DATES
  # -------------------------------------------------------

  dimension_group: start {
    type:       time
    timeframes: [raw, date, week, month, quarter, year, month_num]
    datatype:   date
    sql:        SAFE_CAST(${TABLE}.start_date AS DATE) ;;
    label:      "Subscription Start"
    description: "Date the subscription began."
  }

  dimension_group: end {
    type:       time
    timeframes: [raw, date, week, month, quarter, year, month_num]
    datatype:   date
    sql:        SAFE_CAST(${TABLE}.end_date AS DATE) ;;
    label:      "Subscription End"
    description: "Date the subscription ended. NULL if still active."
  }

  dimension: is_active {
    type:        yesno
    sql:         ${TABLE}.end_date IS NULL ;;
    label:       "Is Active?"
    description: "True if the subscription has no end date (still active)."
  }

  dimension: subscription_length_days {
    type:        number
    sql:         DATE_DIFF(
                   COALESCE(SAFE_CAST(${TABLE}.end_date AS DATE), CURRENT_DATE()),
                   SAFE_CAST(${TABLE}.start_date AS DATE),
                   DAY
                 ) ;;
    label:       "Subscription Length (Days)"
    description: "Length of subscription in days. Uses today for active subscriptions."
  }

  dimension: subscription_length_bucket {
    type:        string
    sql:         CASE
                   WHEN ${subscription_length_days} < 30   THEN '< 30 days'
                   WHEN ${subscription_length_days} < 90   THEN '30-89 days'
                   WHEN ${subscription_length_days} < 180  THEN '90-179 days'
                   WHEN ${subscription_length_days} < 365  THEN '180-364 days'
                   ELSE '365+ days'
                 END ;;
    label:       "Subscription Length Bucket"
    description: "Bucketed subscription duration."
  }

  dimension: start_cohort_month {
    type:        string
    sql:         FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.start_date AS DATE)) ;;
    label:       "Start Cohort (Month)"
    description: "YYYY-MM cohort based on subscription start date."
  }

  # -------------------------------------------------------
  # DIMENSIONS — PLAN & SEATS
  # -------------------------------------------------------

  dimension: plan_tier {
    type:        string
    sql:         ${TABLE}.plan_tier ;;
    label:       "Plan Tier"
    description: "Plan tier at time of billing: Basic, Pro, or Enterprise."
  }

  dimension: plan_tier_rank {
    type:        number
    sql:         CASE ${TABLE}.plan_tier
                   WHEN 'Basic'      THEN 1
                   WHEN 'Pro'        THEN 2
                   WHEN 'Enterprise' THEN 3
                   ELSE 0
                 END ;;
    label:       "Plan Tier Rank"
    hidden:      yes
  }

  dimension: seats {
    type:        number
    sql:         SAFE_CAST(${TABLE}.seats AS INT64) ;;
    label:       "Seats"
    description: "Number of licensed seats on this subscription."
  }

  dimension: billing_frequency {
    type:        string
    sql:         ${TABLE}.billing_frequency ;;
    label:       "Billing Frequency"
    description: "monthly or annual."
  }

  # -------------------------------------------------------
  # DIMENSIONS — REVENUE
  # -------------------------------------------------------

  dimension: mrr_amount {
    type:        number
    sql:         SAFE_CAST(${TABLE}.mrr_amount AS FLOAT64) ;;
    label:       "MRR Amount"
    description: "Monthly Recurring Revenue for this subscription."
    value_format_name: usd
  }

  dimension: arr_amount {
    type:        number
    sql:         SAFE_CAST(${TABLE}.arr_amount AS FLOAT64) ;;
    label:       "ARR Amount"
    description: "Annual Recurring Revenue for this subscription."
    value_format_name: usd
  }

  dimension: mrr_tier {
    type:        string
    sql:         CASE
                   WHEN SAFE_CAST(${TABLE}.mrr_amount AS FLOAT64) < 100   THEN '$0-$99'
                   WHEN SAFE_CAST(${TABLE}.mrr_amount AS FLOAT64) < 500   THEN '$100-$499'
                   WHEN SAFE_CAST(${TABLE}.mrr_amount AS FLOAT64) < 1000  THEN '$500-$999'
                   WHEN SAFE_CAST(${TABLE}.mrr_amount AS FLOAT64) < 5000  THEN '$1k-$4.9k'
                   ELSE '$5k+'
                 END ;;
    label:       "MRR Tier"
    description: "Bucketed MRR for distribution analysis."
  }

  # -------------------------------------------------------
  # DIMENSIONS — FLAGS
  # -------------------------------------------------------

  dimension: is_trial {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.is_trial AS BOOL), FALSE) ;;
    label:       "Is Trial?"
    description: "Whether this subscription is a trial."
  }

  dimension: upgrade_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.upgrade_flag AS BOOL), FALSE) ;;
    label:       "Was Upgraded?"
    description: "Plan was upgraded mid-cycle."
  }

  dimension: downgrade_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.downgrade_flag AS BOOL), FALSE) ;;
    label:       "Was Downgraded?"
    description: "Plan was downgraded mid-cycle."
  }

  dimension: churn_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.churn_flag AS BOOL), FALSE) ;;
    label:       "Did Churn?"
    description: "True if this subscription ended (churned)."
  }

  dimension: auto_renew_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.auto_renew_flag AS BOOL), FALSE) ;;
    label:       "Auto-Renew Enabled?"
    description: "Whether auto-renewal is enabled (~80% true)."
  }

  dimension: plan_change_type {
    type:        string
    sql:         CASE
                   WHEN COALESCE(SAFE_CAST(${TABLE}.upgrade_flag   AS BOOL), FALSE) AND NOT COALESCE(SAFE_CAST(${TABLE}.downgrade_flag AS BOOL), FALSE) THEN 'Upgrade Only'
                   WHEN COALESCE(SAFE_CAST(${TABLE}.downgrade_flag AS BOOL), FALSE) AND NOT COALESCE(SAFE_CAST(${TABLE}.upgrade_flag   AS BOOL), FALSE) THEN 'Downgrade Only'
                   WHEN COALESCE(SAFE_CAST(${TABLE}.upgrade_flag   AS BOOL), FALSE) AND COALESCE(SAFE_CAST(${TABLE}.downgrade_flag     AS BOOL), FALSE) THEN 'Both'
                   ELSE 'No Change'
                 END ;;
    label:       "Plan Change Type"
    description: "Describes mid-cycle plan movement."
  }

  # -------------------------------------------------------
  # MEASURES — COUNTS
  # -------------------------------------------------------

  measure: count {
    type:        count
    label:       "Total Subscriptions"
    description: "Total number of subscription records."
    drill_fields: [subscription_id, account_id, plan_tier, billing_frequency, start_date, end_date, mrr_amount]
  }

  measure: count_active {
    type:        count
    label:       "Active Subscriptions"
    description: "Subscriptions that have not churned."
    filters:     [churn_flag: "No"]
    drill_fields: [subscription_id, account_id, plan_tier, billing_frequency, start_date, mrr_amount]
  }

  measure: count_churned {
    type:        count
    label:       "Churned Subscriptions"
    description: "Subscriptions that ended (churned)."
    filters:     [churn_flag: "Yes"]
    drill_fields: [subscription_id, account_id, plan_tier, end_date, mrr_amount]
  }

  measure: count_upgraded {
    type:        count
    label:       "Upgraded Subscriptions"
    description: "Subscriptions that were upgraded mid-cycle."
    filters:     [upgrade_flag: "Yes"]
  }

  measure: count_downgraded {
    type:        count
    label:       "Downgraded Subscriptions"
    description: "Subscriptions that were downgraded mid-cycle."
    filters:     [downgrade_flag: "Yes"]
  }

  measure: count_trial {
    type:        count
    label:       "Trial Subscriptions"
    description: "Subscriptions in trial status."
    filters:     [is_trial: "Yes"]
  }

  measure: churn_rate {
    type:        number
    sql:         SAFE_DIVIDE(${count_churned}, NULLIF(${count}, 0)) ;;
    label:       "Subscription Churn Rate"
    description: "Percentage of subscriptions that have churned."
    value_format_name: percent_2
  }

  # -------------------------------------------------------
  # MEASURES — REVENUE
  # -------------------------------------------------------

  measure: total_mrr {
    type:        sum
    sql:         ${mrr_amount} ;;
    label:       "Total MRR"
    description: "Sum of Monthly Recurring Revenue across all subscriptions."
    value_format_name: usd_0
    filters:     [churn_flag: "No"]
    drill_fields: [subscription_id, account_id, plan_tier, billing_frequency, mrr_amount]
  }

  measure: total_arr {
    type:        sum
    sql:         ${arr_amount} ;;
    label:       "Total ARR"
    description: "Sum of Annual Recurring Revenue across all subscriptions."
    value_format_name: usd_0
    filters:     [churn_flag: "No"]
    drill_fields: [subscription_id, account_id, plan_tier, arr_amount]
  }

  measure: average_mrr {
    type:        average
    sql:         ${mrr_amount} ;;
    label:       "Avg MRR per Subscription"
    description: "Average Monthly Recurring Revenue per subscription."
    value_format_name: usd
    filters:     [churn_flag: "No"]
  }

  measure: average_arr {
    type:        average
    sql:         ${arr_amount} ;;
    label:       "Avg ARR per Subscription"
    description: "Average Annual Recurring Revenue per subscription."
    value_format_name: usd
    filters:     [churn_flag: "No"]
  }

  measure: churned_mrr {
    type:        sum
    sql:         ${mrr_amount} ;;
    label:       "Churned MRR"
    description: "MRR lost to churn."
    value_format_name: usd_0
    filters:     [churn_flag: "Yes"]
  }

  measure: mrr_churn_rate {
    type:        number
    sql:         SAFE_DIVIDE(${churned_mrr}, NULLIF(${total_mrr} + ${churned_mrr}, 0)) ;;
    label:       "MRR Churn Rate"
    description: "Percentage of total MRR lost to churn."
    value_format_name: percent_2
  }

  measure: average_subscription_length_days {
    type:        average
    sql:         ${subscription_length_days} ;;
    label:       "Avg Subscription Length (Days)"
    description: "Average duration of subscriptions."
    value_format_name: decimal_0
  }

  measure: auto_renew_rate {
    type:        number
    sql:         SAFE_DIVIDE(
                   COUNTIF(COALESCE(SAFE_CAST(${TABLE}.auto_renew_flag AS BOOL), FALSE)),
                   NULLIF(COUNT(*), 0)
                 ) ;;
    label:       "Auto-Renew Rate"
    description: "Percentage of subscriptions with auto-renew enabled."
    value_format_name: percent_2
  }


# -------------------------------------------------------
# DYNAMIC PARAMETERS
# -------------------------------------------------------

parameter: date_granularity {
  type:          unquoted
  label:         "Date Granularity"
  description:   "Switch the time axis between day, week, month, quarter, or year."
  default_value: "month"
  allowed_value: { label: "Day"     value: "day"     }
  allowed_value: { label: "Week"    value: "week"    }
  allowed_value: { label: "Month"   value: "month"   }
  allowed_value: { label: "Quarter" value: "quarter" }
  allowed_value: { label: "Year"    value: "year"    }
}

dimension: dynamic_start_date {
  type:        string
  label:       "Start Date (Dynamic)"
  description: "Subscription start date truncated to the chosen granularity."
  sql:
      {% if date_granularity._parameter_value == 'day' %}
        CAST(SAFE_CAST(${TABLE}.start_date AS DATE) AS STRING)
      {% elsif date_granularity._parameter_value == 'week' %}
        CAST(DATE_TRUNC(SAFE_CAST(${TABLE}.start_date AS DATE), WEEK) AS STRING)
      {% elsif date_granularity._parameter_value == 'month' %}
        FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.start_date AS DATE))
      {% elsif date_granularity._parameter_value == 'quarter' %}
        CONCAT(CAST(EXTRACT(YEAR FROM SAFE_CAST(${TABLE}.start_date AS DATE)) AS STRING), '-Q',
               CAST(EXTRACT(QUARTER FROM SAFE_CAST(${TABLE}.start_date AS DATE)) AS STRING))
      {% elsif date_granularity._parameter_value == 'year' %}
        CAST(EXTRACT(YEAR FROM SAFE_CAST(${TABLE}.start_date AS DATE)) AS STRING)
      {% else %}
        FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.start_date AS DATE))
      {% endif %} ;;
}
}
