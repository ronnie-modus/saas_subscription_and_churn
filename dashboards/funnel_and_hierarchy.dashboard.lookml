- dashboard: funnel_and_hierarchy
  title: "Funnel & Hierarchy Drill"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Demonstrates conversion funnels with stage drop-off rates, and multi-level hierarchy drills using named LookML sets."

  filters:

    # string_filter is not bound to any explore, so it can be
    # listened to by both accounts.plan_tier AND conversion_funnel.plan_tier_filter
    - name: plan_tier
      title: "Plan Tier"
      type: string_filter
      default_value: ""
      allow_multiple_values: false
      required: false

    - name: industry
      title: "Industry"
      type: string_filter
      default_value: ""
      allow_multiple_values: false
      required: false

  elements:

    # ============================================================
    # REAL CONVERSION FUNNEL
    # ============================================================

    - title: "SaaS Conversion Funnel"
      name: real_funnel
      model: saas_subscription_and_churn
      explore: conversion_funnel
      type: looker_funnel
      fields: [conversion_funnel.stage_name, conversion_funnel.stage_count]
      sorts: [conversion_funnel.stage_name asc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Stages: Signed Up → Trial → Paid → Active 90d → Upgraded → Churned"
      listen:
        plan_tier: conversion_funnel.plan_tier_filter
        industry:  conversion_funnel.industry_filter
      row: 0
      col: 0
      width: 12
      height: 10

    - title: "Stage Conversion Rates"
      name: funnel_dropoff
      model: saas_subscription_and_churn
      explore: conversion_funnel
      type: looker_column
      fields: [conversion_funnel.stage_name, conversion_funnel.stage_count, conversion_funnel.conversion_rate]
      sorts: [conversion_funnel.stage_name asc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Conversion rate from the previous stage"
      listen:
        plan_tier: conversion_funnel.plan_tier_filter
        industry:  conversion_funnel.industry_filter
      row: 0
      col: 12
      width: 12
      height: 10

    # ============================================================
    # HIERARCHY DRILL
    # ============================================================

    - title: "Accounts by Plan Tier (Click to Drill Hierarchy)"
      name: hierarchy_plan_tier
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [accounts.plan_tier, accounts.count_with_hierarchy_drill, accounts.churn_rate_with_hierarchy_drill]
      sorts: [accounts.count_with_hierarchy_drill desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Click a bar → drills to Plan Tier + Industry breakdown → click again for account-level detail"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 10
      col: 0
      width: 12
      height: 8

    - title: "Churn Rate by Industry (Click to Drill Hierarchy)"
      name: hierarchy_industry
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_column
      fields: [accounts.industry, accounts.count_with_hierarchy_drill, accounts.churn_rate_with_hierarchy_drill]
      sorts: [accounts.churn_rate_with_hierarchy_drill desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Click a column → drills to Industry + Plan Tier breakdown → click again for account-level detail"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 10
      col: 12
      width: 12
      height: 8

    # ============================================================
    # FIELD GROUP DEMO
    # ============================================================

    - title: "Account Identity Groups (Field Grouping Demo)"
      name: field_groups_demo
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
      limit: 25
      note_state: expanded
      note_display: below
      note_text: "These dimensions use group_label/group_item_label — open the Explore to see them organised under 'Identity' and 'Plan & Status' headings in the field picker"
      listen:
        plan_tier: accounts.plan_tier
        industry:  accounts.industry
      row: 18
      col: 0
      width: 24
      height: 8

    # ============================================================
    # MINI-FUNNELS by segment
    # ============================================================

    - title: "Subscription Flow by Plan Tier"
      name: sub_funnel_plan
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [accounts.plan_tier, accounts.count, accounts.count_trial, accounts.count_churned]
      sorts: [accounts.count desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Total → Trial → Churned breakdown per plan"
      listen:
        industry: accounts.industry
      row: 26
      col: 0
      width: 12
      height: 8

    - title: "Subscription Flow by Industry"
      name: sub_funnel_industry
      model: saas_subscription_and_churn
      explore: accounts
      type: looker_bar
      fields: [accounts.industry, accounts.count, accounts.count_trial, accounts.count_churned]
      sorts: [accounts.count desc]
      limit: 10
      note_state: expanded
      note_display: below
      note_text: "Total → Trial → Churned breakdown per industry"
      listen:
        plan_tier: accounts.plan_tier
      row: 26
      col: 12
      width: 12
      height: 8
