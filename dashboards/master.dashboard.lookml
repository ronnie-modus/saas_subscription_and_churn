- dashboard: master
  title: "SaaS Analytics — Master Dashboard"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Comprehensive SaaS analytics covering all LookML concepts across 5 tabs."

  filters:

    - name: date_range
      title: "Date Range"
      type: field_filter
      default_value: "365 days"
      allow_multiple_values: false
      required: false
      ui_config:
        type: relative_timeframes
        display: inline
      explore: accounts
      field: accounts.signup_date

    - name: plan_tier
      title: "Plan Tier"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: button_toggles
        display: inline
      explore: accounts
      field: accounts.plan_tier

    - name: industry
      title: "Industry"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: popover
      explore: accounts
      field: accounts.industry

    - name: breakdown_by
      title: "Break Down By"
      type: field_filter
      default_value: "plantier"
      allow_multiple_values: false
      required: false
      ui_config:
        type: radio_buttons
        display: inline
      explore: accounts
      field: accounts.breakdown_by

    - name: date_granularity
      title: "Date Granularity"
      type: field_filter
      default_value: "month"
      allow_multiple_values: false
      required: false
      ui_config:
        type: button_toggles
        display: inline
      explore: accounts
      field: accounts.date_granularity

    - name: funnel_plan_tier
      title: "Funnel — Plan Tier"
      type: string_filter
      default_value: ""
      allow_multiple_values: false
      required: false

    - name: funnel_industry
      title: "Funnel — Industry"
      type: string_filter
      default_value: ""
      allow_multiple_values: false
      required: false

  elements:

  # ============================================================
  # TAB 1: OVERVIEW
  # ============================================================

    - title: "Total Accounts"
      name: ov_total_accounts
      tab: overview
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.count]
      listen:
        plan_tier:  accounts.plan_tier
        industry:   accounts.industry
        date_range: accounts.signup_date
      row: 0
      col: 0
      width: 4
      height: 4

    - title: "Churn Rate"
      name: ov_churn_rate
      tab: overview
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.churn_rate]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier:  accounts.plan_tier
        industry:   accounts.industry
        date_range: accounts.signup_date
      row: 0
      col: 4
      width: 4
      height: 4

    - title: "Active MRR"
      name: ov_mrr
      tab: overview
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_mrr]
      filters:
        subscriptions.churn_flag: "No"
      comparison_type: change
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 8
      width: 4
      height: 4

    - title: "MRR Churn Rate"
      name: ov_mrr_churn
      tab: overview
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.mrr_churn_rate]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 12
      width: 4
      height: 4

    - title: "Avg CSAT"
      name: ov_csat
      tab: overview
      model: saas_subscription_and_churn
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_satisfaction_score]
      comparison_type: change
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 16
      width: 4
      height: 4

    - title: "Trial Conversion Rate"
      name: ov_trial_conv
      tab: overview
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.trial_conversion_rate]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 20
      width: 4
      height: 4

    - title: "New Accounts Over Time"
      name: ov_accounts_time
      tab: overview
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_area
      fields: [accounts.dynamic_signup_date, accounts.dynamic_breakdown, accounts.count]
      pivots: [accounts.dynamic_breakdown]
      sorts: [accounts.dynamic_signup_date asc]
      limit: 500
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_range:       accounts.signup_date
        breakdown_by:     accounts.breakdown_by
        date_granularity: accounts.date_granularity
      row: 4
      col: 0
      width: 14
      height: 8

    - title: "Account Status Distribution"
      name: ov_status_pie
      tab: overview
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_pie
      fields: [accounts.account_status, accounts.count]
      sorts: [accounts.count desc]
      limit: 10
      listen:
        plan_tier:  accounts.plan_tier
        industry:   accounts.industry
        date_range: accounts.signup_date
      row: 4
      col: 14
      width: 5
      height: 8

    - title: "Accounts by Breakdown"
      name: ov_accounts_breakdown
      tab: overview
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [accounts.dynamic_breakdown, accounts.count, accounts.churn_rate]
      sorts: [accounts.count desc]
      limit: 10
      listen:
        plan_tier:    accounts.plan_tier
        industry:     accounts.industry
        date_range:   accounts.signup_date
        breakdown_by: accounts.breakdown_by
      row: 4
      col: 19
      width: 5
      height: 8

    - title: "Accounts by Country (Map)"
      name: ov_map
      tab: overview
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_map
      fields: [accounts.country, accounts.count, accounts.churn_rate]
      sorts: [accounts.count desc]
      limit: 100
      listen:
        plan_tier:  accounts.plan_tier
        industry:   accounts.industry
        date_range: accounts.signup_date
      row: 12
      col: 0
      width: 12
      height: 8

    - title: "MRR Over Time by Plan"
      name: ov_mrr_time
      tab: overview
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_line
      fields: [subscriptions.dynamic_start_date, accounts.plan_tier, subscriptions.total_mrr]
      pivots: [accounts.plan_tier]
      sorts: [subscriptions.dynamic_start_date asc]
      limit: 500
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_granularity: accounts.date_granularity
      row: 12
      col: 12
      width: 12
      height: 8

  # ============================================================
  # TAB 2: REVENUE & MRR
  # ============================================================

    - title: "Total MRR"
      name: rev_total_mrr
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_mrr]
      filters:
        subscriptions.churn_flag: "No"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 0
      width: 4
      height: 4

    - title: "Churned MRR"
      name: rev_churned_mrr
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.churned_mrr]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 4
      width: 4
      height: 4

    - title: "Average MRR"
      name: rev_avg_mrr
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.average_mrr]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 8
      width: 4
      height: 4

    - title: "Total ARR"
      name: rev_total_arr
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.total_arr]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 12
      width: 4
      height: 4

    - title: "Min MRR"
      name: rev_min_mrr
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.min_mrr]
      row: 0
      col: 16
      width: 4
      height: 4

    - title: "Max MRR"
      name: rev_max_mrr
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: single_value
      fields: [subscriptions.max_mrr]
      row: 0
      col: 20
      width: 4
      height: 4

    - title: "MRR Over Time"
      name: rev_mrr_time
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_line
      fields: [subscriptions.dynamic_start_date, accounts.plan_tier, subscriptions.total_mrr]
      pivots: [accounts.plan_tier]
      sorts: [subscriptions.dynamic_start_date asc]
      limit: 500
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_granularity: accounts.date_granularity
      row: 4
      col: 0
      width: 14
      height: 8

    - title: "Cumulative MRR (Running Total)"
      name: rev_running_total
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_line
      fields: [subscriptions.dynamic_start_date, subscriptions.running_total_mrr]
      sorts: [subscriptions.dynamic_start_date asc]
      limit: 500
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_granularity: accounts.date_granularity
      row: 4
      col: 14
      width: 10
      height: 8

    - title: "MRR by Plan (with Drill Link)"
      name: rev_mrr_plan
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_column
      fields: [accounts.plan_tier, subscriptions.total_mrr_with_link, subscriptions.churned_mrr]
      sorts: [subscriptions.total_mrr_with_link desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "LookML concept: link: — click a value to open the linked Explore"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 12
      col: 0
      width: 8
      height: 8

    - title: "MRR Distribution by Billing Frequency"
      name: rev_billing_freq
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_pie
      fields: [subscriptions.billing_frequency, subscriptions.total_mrr]
      sorts: [subscriptions.total_mrr desc]
      limit: 10
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 12
      col: 8
      width: 8
      height: 8

    - title: "Auto-Renew Rate by Plan"
      name: rev_auto_renew
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_column
      fields: [accounts.plan_tier, subscriptions.auto_renew_rate, subscriptions.count_upgraded, subscriptions.count_downgraded]
      sorts: [subscriptions.auto_renew_rate desc]
      limit: 10
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 12
      col: 16
      width: 8
      height: 8

    - title: "Subscription Length Distribution"
      name: rev_sub_length
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_bar
      fields: [subscriptions.subscription_length_bucket, subscriptions.count, subscriptions.average_mrr]
      sorts: [subscriptions.count desc]
      limit: 10
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 20
      col: 0
      width: 12
      height: 8

    - title: "MRR Scatter — Avg MRR vs Subscription Length"
      name: rev_scatter
      tab: revenue
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_scatter
      fields: [subscriptions.average_subscription_length_days, subscriptions.average_mrr, accounts.plan_tier, subscriptions.count]
      pivots: [accounts.plan_tier]
      sorts: [subscriptions.average_mrr desc]
      limit: 500
      note_state: expanded
      note_display: below
      note_text: "Chart type: looker_scatter"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 20
      col: 12
      width: 12
      height: 8

  # ============================================================
  # TAB 3: CHURN & SUPPORT
  # ============================================================

    - title: "Churn Rate"
      name: cs_churn_rate
      tab: churn_support
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.churn_rate]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier:  accounts.plan_tier
        industry:   accounts.industry
        date_range: accounts.signup_date
      row: 0
      col: 0
      width: 4
      height: 4

    - title: "Churned Accounts"
      name: cs_churned
      tab: churn_support
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [accounts.count_churned]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier:  accounts.plan_tier
        industry:   accounts.industry
        date_range: accounts.signup_date
      row: 0
      col: 4
      width: 4
      height: 4

    - title: "Reactivations"
      name: cs_reactivations
      tab: churn_support
      model: saas_subscription_and_churn
      explore: accounts
      type: single_value
      fields: [churn_events.count_reactivations]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 8
      width: 4
      height: 4

    - title: "Avg Resolution Time (hrs)"
      name: cs_avg_res
      tab: churn_support
      model: saas_subscription_and_churn
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_resolution_time_hours]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 12
      width: 4
      height: 4

    - title: "Escalation Rate"
      name: cs_escalation
      tab: churn_support
      model: saas_subscription_and_churn
      explore: support_tickets
      type: single_value
      fields: [support_tickets.escalation_rate]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 16
      width: 4
      height: 4

    - title: "Avg CSAT"
      name: cs_csat
      tab: churn_support
      model: saas_subscription_and_churn
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_satisfaction_score]
      comparison_type: change
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 20
      width: 4
      height: 4

    - title: "Churn Rate Over Time"
      name: cs_churn_time
      tab: churn_support
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_line
      fields: [accounts.dynamic_signup_date, accounts.dynamic_breakdown, accounts.count_churned]
      pivots: [accounts.dynamic_breakdown]
      sorts: [accounts.dynamic_signup_date asc]
      limit: 500
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_range:       accounts.signup_date
        breakdown_by:     accounts.breakdown_by
        date_granularity: accounts.date_granularity
      row: 4
      col: 0
      width: 12
      height: 8

    - title: "Churn Reason Breakdown"
      name: cs_reason
      tab: churn_support
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [churn_events.reason_code, churn_events.count, churn_events.average_refund_amount]
      sorts: [churn_events.count desc]
      limit: 15
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 4
      col: 12
      width: 12
      height: 8

    - title: "Tickets Over Time by Priority"
      name: cs_tickets_time
      tab: churn_support
      model: saas_subscription_and_churn
      explore: support_tickets
      type: looker_area
      fields: [support_tickets.dynamic_submitted_date, support_tickets.priority, support_tickets.count]
      pivots: [support_tickets.priority]
      sorts: [support_tickets.dynamic_submitted_date asc]
      limit: 500
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_granularity: accounts.date_granularity
      row: 12
      col: 0
      width: 12
      height: 8

    - title: "Resolution Percentiles by Priority"
      name: cs_percentiles
      tab: churn_support
      model: saas_subscription_and_churn
      explore: support_tickets
      type: looker_column
      fields: [
        support_tickets.priority,
        support_tickets.min_resolution_hours,
        support_tickets.p25_resolution_time_hours,
        support_tickets.median_resolution_time_hours,
        support_tickets.p75_resolution_time_hours,
        support_tickets.max_resolution_hours
      ]
      sorts: [support_tickets.priority asc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "LookML concept: type: percentile — min/p25/p50/p75/max measures"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 12
      col: 12
      width: 12
      height: 8

    - title: "Account Detail Table (HTML Badges)"
      name: cs_account_table
      tab: churn_support
      model: saas_subscription_and_churn
      explore: accounts
      type: table
      fields: [
        accounts.account_name,
        accounts.plan_tier_html,
        accounts.industry,
        accounts.churn_flag_html,
        support_tickets.count,
        support_tickets.average_satisfaction_score,
        support_tickets.escalation_rate
      ]
      sorts: [support_tickets.count desc]
      limit: 25
      note_state: expanded
      note_display: below
      note_text: "LookML concept: html: — color-coded badges in table cells"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 20
      col: 0
      width: 24
      height: 10

  # ============================================================
  # TAB 4: FEATURES & FUNNEL
  # ============================================================

    - title: "Total Usage Events"
      name: ff_total_usage
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.total_usage_count]
      comparison_type: change
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 0
      width: 4
      height: 4

    - title: "Distinct Features Used"
      name: ff_distinct_features
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.count_distinct_features]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 4
      width: 4
      height: 4

    - title: "Beta Adoption Rate"
      name: ff_beta
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.beta_adoption_rate]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 8
      width: 4
      height: 4

    - title: "Error Rate"
      name: ff_error_rate
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.error_rate]
      comparison_type: change
      comparison_reverse_colors: true
      show_comparison_label: true
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 12
      width: 4
      height: 4

    - title: "Avg Usage Duration (mins)"
      name: ff_avg_duration
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.average_usage_duration_mins]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 16
      width: 4
      height: 4

    - title: "Avg Errors per Event"
      name: ff_avg_errors
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: single_value
      fields: [feature_usage.average_errors_per_event]
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 20
      width: 4
      height: 4

    - title: "Feature Usage Over Time"
      name: ff_usage_time
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_line
      fields: [feature_usage.dynamic_usage_date, feature_map.feature_display_name, feature_usage.total_usage_count]
      pivots: [feature_map.feature_display_name]
      sorts: [feature_usage.dynamic_usage_date asc]
      limit: 500
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_granularity: accounts.date_granularity
      row: 4
      col: 0
      width: 16
      height: 8

    - title: "Top Features by Usage"
      name: ff_top_features
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_bar
      fields: [feature_map.feature_display_name, feature_usage.total_usage_count, feature_usage.error_rate]
      sorts: [feature_usage.total_usage_count desc]
      limit: 15
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 4
      col: 16
      width: 8
      height: 8

    - title: "SaaS Conversion Funnel"
      name: ff_funnel
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: conversion_funnel
      type: looker_funnel
      fields: [conversion_funnel.stage_name, conversion_funnel.stage_count]
      sorts: [conversion_funnel.stage_name asc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Signed Up → Trial → Paid → Active 90d → Upgraded → Churned. Use Funnel filters above to segment."
      listen:
        funnel_plan_tier: conversion_funnel.plan_tier_filter
        funnel_industry:  conversion_funnel.industry_filter
      row: 12
      col: 0
      width: 12
      height: 10

    - title: "Stage Conversion Rates"
      name: ff_conversion
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: conversion_funnel
      type: looker_column
      fields: [conversion_funnel.stage_name, conversion_funnel.stage_count, conversion_funnel.conversion_rate]
      sorts: [conversion_funnel.stage_name asc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Conversion rate from previous stage — responds to Funnel filters"
      listen:
        funnel_plan_tier: conversion_funnel.plan_tier_filter
        funnel_industry:  conversion_funnel.industry_filter
      row: 12
      col: 12
      width: 12
      height: 10

    - title: "Feature Category Distribution"
      name: ff_category
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_pie
      fields: [feature_map.feature_category, feature_usage.total_usage_count]
      sorts: [feature_usage.total_usage_count desc]
      limit: 10
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 22
      col: 0
      width: 8
      height: 8

    - title: "Feature Usage by Plan Tier"
      name: ff_usage_plan
      tab: features_funnel
      model: saas_subscription_and_churn
      explore: feature_usage
      type: looker_column
      fields: [accounts.plan_tier, feature_usage.total_usage_count, feature_usage.average_usage_duration_mins, feature_usage.error_rate]
      sorts: [feature_usage.total_usage_count desc]
      limit: 10
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 22
      col: 8
      width: 16
      height: 8

  # ============================================================
  # TAB 5: LOOKML SHOWCASE
  # (one tile per LookML concept / chart type)
  # ============================================================

    - title: "Hierarchy Drill — Accounts by Plan"
      name: sh_hier_plan
      tab: showcase
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [accounts.plan_tier, accounts.count_with_hierarchy_drill, accounts.churn_rate_with_hierarchy_drill]
      sorts: [accounts.count_with_hierarchy_drill desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "LookML concept: named set + hierarchy drill_fields — click bar to drill, click again for detail"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 0
      width: 12
      height: 8

    - title: "HTML Badges — Plan Tier + Churn Status"
      name: sh_html
      tab: showcase
      model: saas_subscription_and_churn
      explore: accounts
      type: table
      fields: [
        accounts.account_name,
        accounts.plan_tier_html,
        accounts.churn_flag_html,
        subscriptions.mrr_tier_html,
        accounts.industry
      ]
      sorts: [accounts.account_name asc]
      limit: 20
      note_state: expanded
      note_display: below
      note_text: "LookML concept: html: — inline badge rendering in table cells"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 0
      col: 12
      width: 12
      height: 8

    - title: "Donut Multiples — Account Status by Industry"
      name: sh_donut
      tab: showcase
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_donut_multiples
      fields: [accounts.industry, accounts.account_status, accounts.count]
      pivots: [accounts.account_status]
      sorts: [accounts.count desc]
      limit: 6
      note_state: expanded
      note_display: below
      note_text: "Chart type: looker_donut_multiples"
      listen:
        plan_tier: accounts.plan_tier
      row: 8
      col: 0
      width: 12
      height: 8

    - title: "Scatter — Avg MRR vs Subscription Length"
      name: sh_scatter
      tab: showcase
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_scatter
      fields: [subscriptions.average_subscription_length_days, subscriptions.average_mrr, accounts.plan_tier, subscriptions.count]
      pivots: [accounts.plan_tier]
      sorts: [subscriptions.average_mrr desc]
      limit: 500
      note_state: expanded
      note_display: below
      note_text: "Chart type: looker_scatter"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 8
      col: 12
      width: 12
      height: 8

    - title: "Word Cloud — Churn Reason Codes"
      name: sh_wordcloud
      tab: showcase
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_wordcloud
      fields: [churn_events.reason_code, churn_events.count]
      sorts: [churn_events.count desc]
      limit: 50
      note_state: expanded
      note_display: below
      note_text: "Chart type: looker_wordcloud"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 16
      col: 0
      width: 12
      height: 8

    - title: "Map — Accounts by Country"
      name: sh_map
      tab: showcase
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_map
      fields: [accounts.country, accounts.count, accounts.churn_rate]
      sorts: [accounts.count desc]
      limit: 100
      note_state: expanded
      note_display: below
      note_text: "Chart type: looker_map"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 16
      col: 12
      width: 12
      height: 8

    - title: "Running Total MRR (type: running_total)"
      name: sh_running_total
      tab: showcase
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_line
      fields: [subscriptions.dynamic_start_date, subscriptions.running_total_mrr]
      sorts: [subscriptions.dynamic_start_date asc]
      limit: 500
      note_state: expanded
      note_display: below
      note_text: "LookML concept: type: running_total measure"
      listen:
        plan_tier:        accounts.plan_tier
        industry:         accounts.industry
        date_granularity: accounts.date_granularity
      row: 24
      col: 0
      width: 12
      height: 8

    - title: "Industry List per Plan (type: list)"
      name: sh_list
      tab: showcase
      model: saas_subscription_and_churn
      explore: accounts
      type: table
      fields: [accounts.plan_tier, accounts.industry_list, accounts.count]
      sorts: [accounts.count desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "LookML concept: type: list measure — concatenates distinct dimension values"
      listen:
        plan_tier: accounts.plan_tier
      row: 24
      col: 12
      width: 12
      height: 8

    - title: "Min / Max Dates (type: min / max)"
      name: sh_min_max
      tab: showcase
      model: saas_subscription_and_churn
      explore: subscriptions
      type: table
      fields: [accounts.plan_tier, subscriptions.min_start_date, subscriptions.max_start_date, subscriptions.min_mrr, subscriptions.max_mrr]
      sorts: [accounts.plan_tier asc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "LookML concept: type: min and type: max measures"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 32
      col: 0
      width: 12
      height: 8

    - title: "MRR with Drill Link (link: in measure)"
      name: sh_link
      tab: showcase
      model: saas_subscription_and_churn
      explore: subscriptions
      type: looker_column
      fields: [accounts.plan_tier, subscriptions.total_mrr_with_link]
      sorts: [subscriptions.total_mrr_with_link desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "LookML concept: link: — click a column value to open linked Explore or dashboard"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 32
      col: 12
      width: 12
      height: 8

    - title: "Field Groups Demo (group_label / group_item_label)"
      name: sh_field_groups
      tab: showcase
      model: saas_subscription_and_churn
      explore: accounts
      type: table
      fields: [
        accounts.group_identity_name,
        accounts.group_identity_industry,
        accounts.group_identity_country,
        accounts.group_plan_tier,
        accounts.group_status,
        accounts.count
      ]
      sorts: [accounts.count desc]
      limit: 20
      note_state: expanded
      note_display: below
      note_text: "LookML concept: group_label / group_item_label — open Explore to see fields grouped under 'Identity' and 'Plan & Status'"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 40
      col: 0
      width: 24
      height: 8
