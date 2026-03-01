- dashboard: chart_coverage
  title: "Chart & Filter Coverage"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Covers every Looker chart type and filter UI type not present in other dashboards. Used as a LookML concept reference."

  filters:

    # --- dropdown_menu (missing filter UI type) ---
    - name: plan_tier_dropdown
      title: "Plan Tier (Dropdown)"
      type: field_filter
      default_value: ""
      allow_multiple_values: false
      required: false
      ui_config:
        type: dropdown_menu
        display: inline
      explore: accounts
      field: accounts.plan_tier

    # --- advanced (text input — missing filter UI type) ---
    - name: industry_text
      title: "Industry (Text Input)"
      type: field_filter
      default_value: ""
      allow_multiple_values: false
      required: false
      ui_config:
        type: advanced
        display: popover
      explore: accounts
      field: accounts.industry

    # --- slider (number range — missing filter UI type) ---
    - name: seats_range
      title: "Seats (Range Slider)"
      type: field_filter
      default_value: ""
      allow_multiple_values: false
      required: false
      ui_config:
        type: slider
        display: inline
      explore: accounts
      field: accounts.seats

    # --- day_range_picker (missing filter UI type) ---
    - name: signup_date
      title: "Signup Date (Day Range Picker)"
      type: field_filter
      default_value: "90 days"
      allow_multiple_values: false
      required: false
      ui_config:
        type: day_range_picker
        display: inline
      explore: accounts
      field: accounts.signup_date

  elements:

    # ============================================================
    # looker_scatter — missing chart type
    # ============================================================
    - title: "MRR vs Subscription Length (Scatter)"
      name: scatter_mrr_length
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_scatter
      fields: [subscriptions.average_subscription_length_days, subscriptions.average_mrr, accounts.plan_tier, subscriptions.count]
      pivots: [accounts.plan_tier]
      sorts: [subscriptions.average_mrr desc]
      limit: 500
      x_axis_gridlines: true
      y_axis_gridlines: true
      row: 0
      col: 0
      width: 12
      height: 8

    # ============================================================
    # looker_map — missing chart type (uses country field)
    # ============================================================
    - title: "Accounts by Country (Map)"
      name: map_accounts_country
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_map
      fields: [accounts.country, accounts.count, accounts.churn_rate]
      sorts: [accounts.count desc]
      limit: 100
      map_plot_mode: points
      listen:
        plan_tier_dropdown: accounts.plan_tier
      row: 0
      col: 12
      width: 12
      height: 8

    # ============================================================
    # looker_waterfall — missing chart type
    # ============================================================
    - title: "MRR Waterfall by Plan Tier"
      name: waterfall_mrr
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_waterfall
      fields: [accounts.plan_tier, subscriptions.total_mrr, subscriptions.churned_mrr]
      sorts: [subscriptions.total_mrr desc]
      limit: 10
      listen:
        plan_tier_dropdown: accounts.plan_tier
      row: 8
      col: 0
      width: 12
      height: 8

    # ============================================================
    # looker_funnel — missing chart type
    # ============================================================
    - title: "Account Funnel (Trial → Active → Churned)"
      name: funnel_accounts
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_funnel
      fields: [accounts.count_trial, accounts.count_active, accounts.count_churned]
      limit: 1
      row: 8
      col: 12
      width: 12
      height: 8

    # ============================================================
    # looker_donut_multiples — missing chart type
    # ============================================================
    - title: "Churn Rate Donuts by Industry"
      name: donut_multiples_churn
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_donut_multiples
      fields: [accounts.industry, accounts.account_status, accounts.count]
      pivots: [accounts.account_status]
      sorts: [accounts.count desc]
      limit: 6
      row: 16
      col: 0
      width: 12
      height: 8

    # ============================================================
    # looker_boxplot — missing chart type
    # ============================================================
    - title: "Resolution Time Distribution by Priority (Box Plot)"
      name: boxplot_resolution
      model: saas_subscription_and_churn
      explore: support_tickets
      type: looker_boxplot
      fields: [support_tickets.priority, support_tickets.resolution_time_hours]
      sorts: [support_tickets.priority asc]
      limit: 500
      row: 16
      col: 12
      width: 12
      height: 8

    # ============================================================
    # table (plain data table) — missing chart type
    # ============================================================
    - title: "Account Detail Table"
      name: table_account_detail
      model: saas_subscription_and_churn
      explore: accounts
      type: table
      fields: [accounts.account_name, accounts.plan_tier_html, accounts.industry, accounts.country,
               accounts.signup_date, accounts.churn_flag_html, accounts.seats, subscriptions.total_mrr]
      sorts: [subscriptions.total_mrr desc]
      limit: 25
      listen:
        plan_tier_dropdown: accounts.plan_tier
        industry_text:      accounts.industry
        seats_range:        accounts.seats
        signup_date:        accounts.signup_date
      row: 24
      col: 0
      width: 24
      height: 10

    # ============================================================
    # looker_wordcloud — missing chart type
    # ============================================================
    - title: "Churn Feedback Word Cloud"
      name: wordcloud_churn
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_wordcloud
      fields: [churn_events.reason_code, churn_events.count]
      sorts: [churn_events.count desc]
      limit: 50
      row: 34
      col: 0
      width: 12
      height: 8

    # ============================================================
    # looker_timeline — missing chart type
    # ============================================================
    - title: "Subscription Cohort Timeline"
      name: timeline_cohorts
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_timeline
      fields: [subscriptions.start_date, subscriptions.end_date, accounts.plan_tier, subscriptions.count]
      sorts: [subscriptions.start_date asc]
      limit: 100
      row: 34
      col: 12
      width: 12
      height: 8

    # ============================================================
    # single_value with comparison (missing comparison feature)
    # ============================================================
    - title: "MRR vs Prior Period"
      name: single_value_mrr_comparison
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_mrr]
      comparison_type: change
      comparison_reverse_colors: false
      show_comparison_label: true
      row: 42
      col: 0
      width: 6
      height: 4

    - title: "Churn Rate vs Prior Period"
      name: single_value_churn_comparison
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.churn_rate]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      row: 42
      col: 6
      width: 6
      height: 4

    # ============================================================
    # Running total line chart
    # ============================================================
    - title: "Cumulative MRR Over Time (Running Total)"
      name: running_total_mrr_chart
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_line
      fields: [subscriptions.dynamic_start_date, subscriptions.running_total_mrr]
      sorts: [subscriptions.dynamic_start_date asc]
      limit: 500
      row: 42
      col: 12
      width: 12
      height: 8

    # ============================================================
    # Min/Max KPI tiles
    # ============================================================
    - title: "Earliest Signup"
      name: kpi_earliest_signup
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.earliest_signup]
      row: 46
      col: 0
      width: 4
      height: 3

    - title: "Latest Signup"
      name: kpi_latest_signup
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.latest_signup]
      row: 46
      col: 4
      width: 4
      height: 3

    - title: "Min MRR"
      name: kpi_min_mrr
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.min_mrr]
      row: 46
      col: 8
      width: 4
      height: 3

    - title: "Max MRR"
      name: kpi_max_mrr
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.max_mrr]
      row: 46
      col: 12
      width: 4
      height: 3

    - title: "Min Resolution Time"
      name: kpi_min_resolution
      model: saas_subscription_and_churn
      explore: support_tickets
      type: single_value
      fields: [support_tickets.min_resolution_hours]
      row: 46
      col: 16
      width: 4
      height: 3

    - title: "Max Resolution Time"
      name: kpi_max_resolution
      model: saas_subscription_and_churn
      explore: support_tickets
      type: single_value
      fields: [support_tickets.max_resolution_hours]
      row: 46
      col: 20
      width: 4
      height: 3
