- dashboard: revenue_overview
  title: "Revenue & MRR Overview"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "MRR, ARR, plan mix, billing frequency, and upgrade/downgrade trends."

  filters:
    - name: subscription_start_date
      title: "Subscription Start Date"
      type: date_filter
      default_value: "12 months"
      allow_multiple_values: true
      required: false
      ui_config:
        type: relative_timeframes
        display: inline

    - name: plan_tier
      title: "Plan Tier"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: popover
      explore: subscriptions
      field: subscriptions.plan_tier

  elements:
    - title: "Total Active MRR"
      name: total_mrr
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_mrr]
      row: 0
      col: 0
      width: 6
      height: 3

    - title: "Total Active ARR"
      name: total_arr
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_arr]
      row: 0
      col: 6
      width: 6
      height: 3

    - title: "Avg MRR per Subscription"
      name: avg_mrr
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.average_mrr]
      row: 0
      col: 12
      width: 6
      height: 3

    - title: "Subscription Churn Rate"
      name: sub_churn_rate
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.churn_rate]
      row: 0
      col: 18
      width: 6
      height: 3

    - title: "MRR by Plan Tier"
      name: mrr_by_plan
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_pie
      fields: [subscriptions.plan_tier, subscriptions.total_mrr]
      sorts: [subscriptions.total_mrr desc]
      limit: 10
      row: 3
      col: 0
      width: 10
      height: 8

    - title: "MRR Growth Over Time (by Plan)"
      name: mrr_over_time
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_area
      fields: [subscriptions.start_month, subscriptions.plan_tier, subscriptions.total_mrr]
      pivots: [subscriptions.plan_tier]
      sorts: [subscriptions.start_month asc]
      limit: 36
      row: 3
      col: 10
      width: 14
      height: 8

    - title: "MRR by Billing Frequency"
      name: mrr_by_billing
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_column
      fields: [subscriptions.billing_frequency, subscriptions.total_mrr, subscriptions.count_active]
      sorts: [subscriptions.total_mrr desc]
      limit: 5
      row: 11
      col: 0
      width: 12
      height: 7

    - title: "Upgrades & Downgrades Over Time"
      name: plan_changes
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_line
      fields: [subscriptions.start_month, subscriptions.count_upgraded, subscriptions.count_downgraded]
      sorts: [subscriptions.start_month asc]
      limit: 36
      row: 11
      col: 12
      width: 12
      height: 7
