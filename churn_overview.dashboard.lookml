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
