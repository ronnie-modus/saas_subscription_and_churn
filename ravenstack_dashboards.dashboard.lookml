- dashboard: churn_overview
  title: "Churn Overview"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "High-level churn KPIs: account churn rate, MRR lost, churn reasons, and pre-churn signals."

  filters:
    - name: signup_date
      title: "Signup Date"
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
      explore: accounts
      field: accounts.plan_tier

    - name: industry
      title: "Industry"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: tag_list
        display: popover
      explore: accounts
      field: accounts.industry

  elements:
    - title: "Total Accounts"
      name: total_accounts
      model: ravenstack_saas
      explore: accounts
      type: single_value
      fields: [accounts.count]
      note_state: expanded
      note_display: below
      note_text: "All accounts ever created"
      row: 0
      col: 0
      width: 4
      height: 3

    - title: "Churned Accounts"
      name: churned_accounts
      model: ravenstack_saas
      explore: accounts
      type: single_value
      fields: [accounts.count_churned]
      note_state: expanded
      note_display: below
      note_text: "Accounts with churn_flag = TRUE"
      row: 0
      col: 4
      width: 4
      height: 3

    - title: "Account Churn Rate"
      name: account_churn_rate
      model: ravenstack_saas
      explore: accounts
      type: single_value
      fields: [accounts.churn_rate]
      note_state: expanded
      note_display: below
      note_text: "Churned / Total Accounts"
      row: 0
      col: 8
      width: 4
      height: 3

    - title: "Churned MRR"
      name: churned_mrr
      model: ravenstack_saas
      explore: accounts
      type: single_value
      fields: [subscriptions.churned_mrr]
      note_state: expanded
      note_display: below
      note_text: "MRR on churned subscriptions"
      row: 0
      col: 12
      width: 4
      height: 3

    - title: "MRR Churn Rate"
      name: mrr_churn_rate
      model: ravenstack_saas
      explore: accounts
      type: single_value
      fields: [subscriptions.mrr_churn_rate]
      note_state: expanded
      note_display: below
      note_text: "Churned MRR / Total MRR"
      row: 0
      col: 16
      width: 4
      height: 3

    - title: "Total Refunds at Churn"
      name: total_refunds
      model: ravenstack_saas
      explore: accounts
      type: single_value
      fields: [churn_events.total_refund_amount]
      note_state: expanded
      note_display: below
      note_text: "USD refunded to churned accounts"
      row: 0
      col: 20
      width: 4
      height: 3

    - title: "Churn Events by Reason"
      name: churn_by_reason
      model: ravenstack_saas
      explore: accounts
      type: looker_pie
      fields: [churn_events.reason_code, churn_events.count]
      sorts: [churn_events.count desc]
      limit: 10
      row: 3
      col: 0
      width: 10
      height: 8

    - title: "Monthly Churn Events Over Time"
      name: churn_over_time
      model: ravenstack_saas
      explore: accounts
      type: looker_line
      fields: [churn_events.churn_month, churn_events.count]
      sorts: [churn_events.churn_month asc]
      limit: 36
      x_axis_gridlines: false
      y_axis_gridlines: true
      row: 3
      col: 10
      width: 14
      height: 8

    - title: "Churn Rate by Plan Tier"
      name: churn_by_plan
      model: ravenstack_saas
      explore: accounts
      type: looker_bar
      fields: [accounts.plan_tier, accounts.count, accounts.count_churned, accounts.churn_rate]
      sorts: [accounts.plan_tier_rank asc]
      limit: 10
      row: 11
      col: 0
      width: 12
      height: 7

    - title: "Churn Rate by Referral Source"
      name: churn_by_referral
      model: ravenstack_saas
      explore: accounts
      type: looker_bar
      fields: [accounts.referral_source, accounts.count, accounts.count_churned, accounts.churn_rate]
      sorts: [accounts.churn_rate desc]
      limit: 10
      row: 11
      col: 12
      width: 12
      height: 7

    - title: "Pre-Churn Plan Signal Distribution"
      name: pre_churn_signals
      model: ravenstack_saas
      explore: accounts
      type: looker_bar
      fields: [churn_events.pre_churn_signal, churn_events.count]
      sorts: [churn_events.count desc]
      limit: 10
      row: 18
      col: 0
      width: 12
      height: 7

    - title: "Churn Rate by Industry"
      name: churn_by_industry
      model: ravenstack_saas
      explore: accounts
      type: looker_bar
      fields: [accounts.industry, accounts.count_churned, accounts.churn_rate]
      sorts: [accounts.churn_rate desc]
      limit: 15
      row: 18
      col: 12
      width: 12
      height: 7

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
      model: ravenstack_saas
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_mrr]
      row: 0
      col: 0
      width: 6
      height: 3

    - title: "Total Active ARR"
      name: total_arr
      model: ravenstack_saas
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_arr]
      row: 0
      col: 6
      width: 6
      height: 3

    - title: "Avg MRR per Subscription"
      name: avg_mrr
      model: ravenstack_saas
      explore: subscriptions
      type: single_value
      fields: [subscriptions.average_mrr]
      row: 0
      col: 12
      width: 6
      height: 3

    - title: "Subscription Churn Rate"
      name: sub_churn_rate
      model: ravenstack_saas
      explore: subscriptions
      type: single_value
      fields: [subscriptions.churn_rate]
      row: 0
      col: 18
      width: 6
      height: 3

    - title: "MRR by Plan Tier"
      name: mrr_by_plan
      model: ravenstack_saas
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
      model: ravenstack_saas
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
      model: ravenstack_saas
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
      model: ravenstack_saas
      explore: subscriptions
      type: looker_line
      fields: [subscriptions.start_month, subscriptions.count_upgraded, subscriptions.count_downgraded]
      sorts: [subscriptions.start_month asc]
      limit: 36
      row: 11
      col: 12
      width: 12
      height: 7

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
      model: ravenstack_saas
      explore: feature_usage
      type: single_value
      fields: [feature_usage.count]
      row: 0
      col: 0
      width: 5
      height: 3

    - title: "Distinct Features Used"
      name: distinct_features
      model: ravenstack_saas
      explore: feature_usage
      type: single_value
      fields: [feature_usage.count_distinct_features]
      row: 0
      col: 5
      width: 5
      height: 3

    - title: "Avg Usage Duration (mins)"
      name: avg_duration
      model: ravenstack_saas
      explore: feature_usage
      type: single_value
      fields: [feature_usage.average_usage_duration_mins]
      row: 0
      col: 10
      width: 5
      height: 3

    - title: "Error Rate"
      name: error_rate
      model: ravenstack_saas
      explore: feature_usage
      type: single_value
      fields: [feature_usage.error_rate]
      row: 0
      col: 15
      width: 5
      height: 3

    - title: "Beta Adoption Rate"
      name: beta_rate
      model: ravenstack_saas
      explore: feature_usage
      type: single_value
      fields: [feature_usage.beta_adoption_rate]
      row: 0
      col: 20
      width: 4
      height: 3

    - title: "Top Features by Usage Events"
      name: top_features
      model: ravenstack_saas
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
      model: ravenstack_saas
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
      model: ravenstack_saas
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
      model: ravenstack_saas
      explore: feature_usage
      type: looker_pie
      fields: [feature_usage.feature_type, feature_usage.count]
      sorts: [feature_usage.count desc]
      limit: 2
      row: 13
      col: 14
      width: 10
      height: 8

- dashboard: support_health
  title: "Support Health"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Ticket volume, resolution SLAs, CSAT scores, and escalation trends."

  filters:
    - name: submitted_date
      title: "Submitted Date"
      type: date_filter
      default_value: "90 days"
      allow_multiple_values: true
      required: false
      ui_config:
        type: relative_timeframes
        display: inline

    - name: priority
      title: "Priority"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: popover
      explore: support_tickets
      field: support_tickets.priority

  elements:
    - title: "Total Tickets"
      name: total_tickets
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.count]
      row: 0
      col: 0
      width: 4
      height: 3

    - title: "Escalation Rate"
      name: escalation_rate
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.escalation_rate]
      row: 0
      col: 4
      width: 4
      height: 3

    - title: "Avg CSAT Score"
      name: avg_csat
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_satisfaction_score]
      row: 0
      col: 8
      width: 4
      height: 3

    - title: "Avg Resolution Time (hrs)"
      name: avg_resolution
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_resolution_time_hours]
      row: 0
      col: 12
      width: 4
      height: 3

    - title: "P90 Resolution Time (hrs)"
      name: p90_resolution
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.p90_resolution_time_hours]
      row: 0
      col: 16
      width: 4
      height: 3

    - title: "CSAT Response Rate"
      name: csat_response
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.csat_response_rate]
      row: 0
      col: 20
      width: 4
      height: 3

    - title: "Tickets by Priority Over Time"
      name: tickets_over_time
      model: ravenstack_saas
      explore: support_tickets
      type: looker_area
      fields: [support_tickets.submitted_week, support_tickets.priority, support_tickets.count]
      pivots: [support_tickets.priority]
      sorts: [support_tickets.submitted_week asc]
      limit: 52
      row: 3
      col: 0
      width: 14
      height: 8

    - title: "CSAT Score Distribution"
      name: csat_distribution
      model: ravenstack_saas
      explore: support_tickets
      type: looker_column
      fields: [support_tickets.satisfaction_tier, support_tickets.count]
      sorts: [support_tickets.satisfaction_score asc]
      limit: 6
      row: 3
      col: 14
      width: 10
      height: 8

    - title: "Resolution Time Distribution"
      name: resolution_dist
      model: ravenstack_saas
      explore: support_tickets
      type: looker_column
      fields: [support_tickets.resolution_time_bucket, support_tickets.count]
      sorts: [support_tickets.resolution_time_hours asc]
      limit: 10
      row: 11
      col: 0
      width: 12
      height: 7

    - title: "CSAT by Priority"
      name: csat_by_priority
      model: ravenstack_saas
      explore: support_tickets
      type: looker_column
      fields: [support_tickets.priority, support_tickets.average_satisfaction_score, support_tickets.escalation_rate]
      sorts: [support_tickets.priority_rank asc]
      limit: 10
      row: 11
      col: 12
      width: 12
      height: 7
