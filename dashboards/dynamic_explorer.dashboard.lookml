- dashboard: dynamic_explorer
  title: "Dynamic Explorer"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Fully interactive dashboard. Use 'Break Down By' to switch grouping dimensions and 'Date Granularity' to change the time axis across all charts."

  # ============================================================
  # GLOBAL FILTERS
  # ============================================================

  filters:

    # --- Breakdown Dimension Switcher ---
    - name: breakdown_by
      title: "🔀 Break Down By"
      type: field_filter
      default_value: "plantier"
      allow_multiple_values: false
      required: false
      ui_config:
        type: button_toggles
        display: inline
      explore: accounts
      field: accounts.breakdown_by

    # --- Date Granularity Switcher ---
    - name: date_granularity
      title: "📅 Date Granularity"
      type: field_filter
      default_value: "month"
      allow_multiple_values: false
      required: false
      ui_config:
        type: button_toggles
        display: inline
      explore: accounts
      field: accounts.date_granularity

    # --- Standard Date Range Filter ---
    - name: date_range
      title: "Date Range"
      type: date_filter
      default_value: "2 years"
      allow_multiple_values: false
      required: false
      ui_config:
        type: relative_timeframes
        display: inline

    # --- Plan Tier ---
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

    # --- Industry ---
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

  # ============================================================
  # KPI ROW
  # ============================================================

  elements:

    - title: "Total Accounts"
      name: kpi_total_accounts
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.count]
      note_state: expanded
      note_display: below
      note_text: "All accounts"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 0
      width: 4
      height: 3

    - title: "Churned Accounts"
      name: kpi_churned
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.count_churned]
      note_state: expanded
      note_display: below
      note_text: "Total churned"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 4
      width: 4
      height: 3

    - title: "Account Churn Rate"
      name: kpi_churn_rate
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.churn_rate]
      note_state: expanded
      note_display: below
      note_text: "Churned / Total"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 8
      width: 4
      height: 3

    - title: "Active MRR"
      name: kpi_mrr
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [subscriptions.total_mrr]
      note_state: expanded
      note_display: below
      note_text: "Active subscriptions only"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 12
      width: 4
      height: 3

    - title: "MRR Churn Rate"
      name: kpi_mrr_churn
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [subscriptions.mrr_churn_rate]
      note_state: expanded
      note_display: below
      note_text: "Churned MRR / Total MRR"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 16
      width: 4
      height: 3

    - title: "Avg CSAT Score"
      name: kpi_csat
      model: saas_subscription_and_churn
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_satisfaction_score]
      note_state: expanded
      note_display: below
      note_text: "1–5 scale"
      row: 0
      col: 20
      width: 4
      height: 3

  # ============================================================
  # ROW 1 — Dynamic Breakdown Charts
  # ============================================================

    - title: "Account Count by Breakdown"
      name: accounts_by_breakdown
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [accounts.dynamic_breakdown, accounts.count, accounts.count_churned]
      sorts: [accounts.count desc]
      limit: 15
      listen:
        breakdown_by: accounts.breakdown_by
        plan_tier:    accounts.plan_tier
        industry:     accounts.industry
      row: 3
      col: 0
      width: 12
      height: 8

    - title: "Churn Rate by Breakdown"
      name: churn_rate_by_breakdown
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_column
      fields: [accounts.dynamic_breakdown, accounts.churn_rate, accounts.count]
      sorts: [accounts.churn_rate desc]
      limit: 15
      listen:
        breakdown_by: accounts.breakdown_by
        plan_tier:    accounts.plan_tier
        industry:     accounts.industry
      row: 3
      col: 12
      width: 12
      height: 8

  # ============================================================
  # ROW 2 — Dynamic Date + Breakdown Over Time
  # ============================================================

    - title: "New Accounts Over Time (by Breakdown)"
      name: accounts_over_time
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_area
      fields: [accounts.dynamic_signup_date, accounts.dynamic_breakdown, accounts.count]
      pivots: [accounts.dynamic_breakdown]
      sorts: [accounts.dynamic_signup_date asc]
      limit: 500
      listen:
        breakdown_by:    accounts.breakdown_by
        date_granularity: accounts.date_granularity
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
      row: 11
      col: 0
      width: 24
      height: 8

  # ============================================================
  # ROW 3 — MRR Over Time + MRR by Breakdown
  # ============================================================

    - title: "MRR Over Time (by Breakdown)"
      name: mrr_over_time
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_line
      fields: [subscriptions.dynamic_start_date, accounts.dynamic_breakdown, subscriptions.total_mrr]
      pivots: [accounts.dynamic_breakdown]
      sorts: [subscriptions.dynamic_start_date asc]
      limit: 500
      listen:
        breakdown_by:     accounts.breakdown_by
        date_granularity: subscriptions.date_granularity
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
      row: 19
      col: 0
      width: 14
      height: 8

    - title: "MRR Distribution by Breakdown"
      name: mrr_by_breakdown
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_pie
      fields: [accounts.dynamic_breakdown, subscriptions.total_mrr]
      sorts: [subscriptions.total_mrr desc]
      limit: 15
      listen:
        breakdown_by: accounts.breakdown_by
        plan_tier:    accounts.plan_tier
        industry:     accounts.industry
      row: 19
      col: 14
      width: 10
      height: 8

  # ============================================================
  # ROW 4 — Churn Events Over Time + Churn by Breakdown
  # ============================================================

    - title: "Churn Events Over Time"
      name: churn_over_time
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_line
      fields: [churn_events.dynamic_churn_date, accounts.dynamic_breakdown, churn_events.count]
      pivots: [accounts.dynamic_breakdown]
      sorts: [churn_events.dynamic_churn_date asc]
      limit: 500
      listen:
        breakdown_by:     accounts.breakdown_by
        date_granularity: churn_events.date_granularity
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
      row: 27
      col: 0
      width: 14
      height: 8

    - title: "Churn Reason Breakdown"
      name: churn_reason_breakdown
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [churn_events.reason_code, accounts.dynamic_breakdown, churn_events.count]
      pivots: [accounts.dynamic_breakdown]
      sorts: [churn_events.count desc]
      limit: 10
      listen:
        breakdown_by: accounts.breakdown_by
        plan_tier:    accounts.plan_tier
        industry:     accounts.industry
      row: 27
      col: 14
      width: 10
      height: 8

  # ============================================================
  # ROW 5 — Support Tickets Over Time + CSAT by Breakdown
  # ============================================================

    - title: "Support Tickets Over Time (by Breakdown)"
      name: tickets_over_time
      model: saas_subscription_and_churn
      explore: support_tickets
      type: looker_line
      fields: [support_tickets.dynamic_submitted_date, accounts.dynamic_breakdown, support_tickets.count]
      pivots: [accounts.dynamic_breakdown]
      sorts: [support_tickets.dynamic_submitted_date asc]
      limit: 500
      listen:
        breakdown_by:     accounts.breakdown_by
        date_granularity: support_tickets.date_granularity
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
      row: 35
      col: 0
      width: 14
      height: 8

    - title: "Avg CSAT Score by Breakdown"
      name: csat_by_breakdown
      model: saas_subscription_and_churn
      explore: support_tickets
      type: looker_column
      fields: [accounts.dynamic_breakdown, support_tickets.average_satisfaction_score, support_tickets.count]
      sorts: [support_tickets.average_satisfaction_score desc]
      limit: 15
      listen:
        breakdown_by: accounts.breakdown_by
        plan_tier:    accounts.plan_tier
        industry:     accounts.industry
      row: 35
      col: 14
      width: 10
      height: 8

  # ============================================================
  # ROW 6 — Feature Usage Over Time + Top Features by Breakdown
  # ============================================================

    - title: "Feature Usage Over Time"
      name: usage_over_time
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_line
      fields: [feature_usage.dynamic_usage_date, feature_usage.count, feature_usage.total_errors]
      sorts: [feature_usage.dynamic_usage_date asc]
      limit: 500
      listen:
        date_granularity: feature_usage.date_granularity
      row: 43
      col: 0
      width: 14
      height: 8

    - title: "Top Features by Breakdown"
      name: top_features_breakdown
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_bar
      fields: [feature_map.feature_display_name, accounts.dynamic_breakdown, feature_usage.count]
      pivots: [accounts.dynamic_breakdown]
      sorts: [feature_usage.count desc]
      limit: 15
      listen:
        breakdown_by: accounts.breakdown_by
        plan_tier:    accounts.plan_tier
        industry:     accounts.industry
      row: 43
      col: 14
      width: 10
      height: 8
