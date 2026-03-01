- dashboard: feature_adoption
  title: "Feature Adoption & Engagement"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Feature usage, beta adoption, error tracking, and engagement depth."

  filters:
    - name: usage_date
      title: "Usage Date"
      type: date_filter
      default_value: "90 days"
      allow_multiple_values: true
      required: false
      ui_config:
        type: relative_timeframes
        display: inline

    - name: is_beta
      title: "Beta Features Only"
      type: field_filter
      default_value: ""
      allow_multiple_values: false
      required: false
      ui_config:
        type: radio_buttons
        display: inline
      explore: feature_usage
      field: feature_usage.is_beta_feature

  elements:
    - title: "Total Usage Events"
      name: total_events
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.count]
      row: 0
      col: 0
      width: 5
      height: 3

    - title: "Distinct Features Used"
      name: distinct_features
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.count_distinct_features]
      row: 0
      col: 5
      width: 5
      height: 3

    - title: "Avg Usage Duration (mins)"
      name: avg_duration
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.average_usage_duration_mins]
      row: 0
      col: 10
      width: 5
      height: 3

    - title: "Error Rate"
      name: error_rate
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.error_rate]
      row: 0
      col: 15
      width: 5
      height: 3

    - title: "Beta Adoption Rate"
      name: beta_rate
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.beta_adoption_rate]
      row: 0
      col: 20
      width: 4
      height: 3

    - title: "Top Features by Usage Events"
      name: top_features
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_bar
      fields: [feature_usage.feature_name, feature_usage.count, feature_usage.total_errors]
      sorts: [feature_usage.count desc]
      limit: 15
      row: 3
      col: 0
      width: 14
      height: 10

    - title: "Usage Events Over Time"
      name: usage_over_time
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_line
      fields: [feature_usage.usage_week, feature_usage.count, feature_usage.total_errors]
      sorts: [feature_usage.usage_week asc]
      limit: 52
      row: 3
      col: 14
      width: 10
      height: 10

    - title: "Top Error-Prone Features"
      name: error_features
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_bar
      fields: [feature_usage.feature_name, feature_usage.total_errors, feature_usage.error_rate]
      sorts: [feature_usage.total_errors desc]
      limit: 15
      row: 13
      col: 0
      width: 14
      height: 8

    - title: "Beta vs GA Usage Split"
      name: beta_vs_ga
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_pie
      fields: [feature_usage.feature_type, feature_usage.count]
      sorts: [feature_usage.count desc]
      limit: 2
      row: 13
      col: 14
      width: 10
      height: 8
