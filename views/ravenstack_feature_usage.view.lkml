view: ravenstack_feature_usage {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_feature_usage` ;;

  # -------------------------------------------------------
  # PRIMARY KEY
  # -------------------------------------------------------

  dimension: usage_id {
    primary_key:  yes
    type:         string
    sql:          ${TABLE}.usage_id ;;
    label:        "Usage ID"
    description:  "Unique identifier for each feature usage event."
    tags:         ["id"]
  }

  # -------------------------------------------------------
  # FOREIGN KEYS
  # -------------------------------------------------------

  dimension: subscription_id {
    type:        string
    sql:         ${TABLE}.subscription_id ;;
    label:       "Subscription ID"
    hidden:      yes
    tags:        ["id"]
  }

  # -------------------------------------------------------
  # DIMENSIONS — DATES
  # -------------------------------------------------------

  dimension_group: usage {
    type:       time
    timeframes: [raw, date, week, month, quarter, year, day_of_week, month_num]
    datatype:   date
    sql:        ${TABLE}.usage_date ;;
    label:      "Usage"
    description: "Date when this feature usage event occurred."
  }

  # -------------------------------------------------------
  # DIMENSIONS — FEATURE
  # -------------------------------------------------------

  dimension: feature_name {
    type:        string
    sql:         ${TABLE}.feature_name ;;
    label:       "Feature Name"
    description: "Name of the product feature used (pool of 40 features)."
  }

  dimension: is_beta_feature {
    type:        yesno
    sql:         ${TABLE}.is_beta_feature ;;
    label:       "Is Beta Feature?"
    description: "True if this feature is flagged as a beta feature (~10%)."
  }

  dimension: feature_type {
    type:        string
    sql:         CASE
                   WHEN ${TABLE}.is_beta_feature = TRUE THEN 'Beta'
                   ELSE 'GA'
                 END ;;
    label:       "Feature Type"
    description: "GA (generally available) or Beta."
  }

  # -------------------------------------------------------
  # DIMENSIONS — USAGE METRICS (for filtering/bucketing)
  # -------------------------------------------------------

  dimension: usage_count {
    type:        number
    sql:         ${TABLE}.usage_count ;;
    label:       "Usage Count"
    description: "Number of times this feature was triggered in the event."
  }

  dimension: usage_count_tier {
    type:        string
    sql:         CASE
                   WHEN ${TABLE}.usage_count = 0      THEN '0 (No Usage)'
                   WHEN ${TABLE}.usage_count BETWEEN 1 AND 5   THEN '1-5'
                   WHEN ${TABLE}.usage_count BETWEEN 6 AND 20  THEN '6-20'
                   WHEN ${TABLE}.usage_count BETWEEN 21 AND 100 THEN '21-100'
                   ELSE '100+'
                 END ;;
    label:       "Usage Count Tier"
    description: "Bucketed usage count."
  }

  dimension: usage_duration_secs {
    type:        number
    sql:         ${TABLE}.usage_duration_secs ;;
    label:       "Usage Duration (secs)"
    description: "Time spent on this feature in seconds."
    hidden:      yes
  }

  dimension: error_count {
    type:        number
    sql:         ${TABLE}.error_count ;;
    label:       "Error Count"
    description: "Number of errors logged during this usage event."
    hidden:      yes
  }

  dimension: has_errors {
    type:        yesno
    sql:         ${TABLE}.error_count > 0 ;;
    label:       "Has Errors?"
    description: "True if any errors were logged during this usage event."
  }

  # -------------------------------------------------------
  # MEASURES — VOLUME
  # -------------------------------------------------------

  measure: count {
    type:        count
    label:       "Usage Events"
    description: "Total number of feature usage events."
    drill_fields: [usage_id, feature_name, usage_date, usage_count, usage_duration_secs, error_count, is_beta_feature]
  }

  measure: count_beta_events {
    type:        count
    label:       "Beta Feature Events"
    description: "Number of usage events on beta features."
    filters:     [is_beta_feature: "Yes"]
  }

  measure: count_ga_events {
    type:        count
    label:       "GA Feature Events"
    description: "Number of usage events on generally available features."
    filters:     [is_beta_feature: "No"]
  }

  measure: count_distinct_features {
    type:        count_distinct
    sql:         ${feature_name} ;;
    label:       "Distinct Features Used"
    description: "Number of unique features used (breadth of adoption)."
  }

  measure: count_distinct_subscriptions {
    type:        count_distinct
    sql:         ${subscription_id} ;;
    label:       "Subscriptions with Usage"
    description: "Number of distinct subscriptions that generated usage events."
  }

  # -------------------------------------------------------
  # MEASURES — USAGE QUANTITY
  # -------------------------------------------------------

  measure: total_usage_count {
    type:        sum
    sql:         ${usage_count} ;;
    label:       "Total Usage Events (Summed)"
    description: "Sum of all usage_count values across events."
    value_format_name: decimal_0
  }

  measure: average_usage_count {
    type:        average
    sql:         ${usage_count} ;;
    label:       "Avg Usage Count per Event"
    description: "Average usage_count per usage event."
    value_format_name: decimal_1
  }

  measure: total_usage_duration_secs {
    type:        sum
    sql:         ${usage_duration_secs} ;;
    label:       "Total Usage Duration (secs)"
    description: "Total time spent across all feature usage events in seconds."
    value_format_name: decimal_0
  }

  measure: average_usage_duration_secs {
    type:        average
    sql:         ${usage_duration_secs} ;;
    label:       "Avg Usage Duration (secs)"
    description: "Average time spent per feature usage event."
    value_format_name: decimal_1
  }

  measure: average_usage_duration_mins {
    type:        number
    sql:         ${average_usage_duration_secs} / 60 ;;
    label:       "Avg Usage Duration (mins)"
    description: "Average time spent per feature usage event in minutes."
    value_format_name: decimal_2
  }

  # -------------------------------------------------------
  # MEASURES — ERRORS
  # -------------------------------------------------------

  measure: total_errors {
    type:        sum
    sql:         ${error_count} ;;
    label:       "Total Errors"
    description: "Sum of all errors logged across feature usage events."
    value_format_name: decimal_0
    drill_fields: [feature_name, usage_date, subscription_id, error_count]
  }

  measure: average_errors_per_event {
    type:        average
    sql:         ${error_count} ;;
    label:       "Avg Errors per Event"
    description: "Average number of errors per usage event."
    value_format_name: decimal_2
  }

  measure: error_rate {
    type:        number
    sql:         SAFE_DIVIDE(
                   COUNTIF(${TABLE}.error_count > 0),
                   NULLIF(COUNT(*), 0)
                 ) ;;
    label:       "Error Rate"
    description: "Percentage of usage events that had at least one error."
    value_format_name: percent_2
  }

  measure: beta_adoption_rate {
    type:        number
    sql:         SAFE_DIVIDE(${count_beta_events}, NULLIF(${count}, 0)) ;;
    label:       "Beta Feature Adoption Rate"
    description: "Percentage of usage events on beta features."
    value_format_name: percent_2
  }
}
