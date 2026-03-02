connection: "bq_saas_subscription_and_churn"

include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard"
include: "/tests.lkml"        # LookML data validation tests

########################################
# FISCAL CALENDAR & WEEK SETTINGS
########################################
# fiscal_month_offset: 3 means fiscal year starts in April (common in SaaS/enterprise)
# Change to 0 for calendar year, 1 for February start, etc.
fiscal_month_offset: 3

# week_start_day: monday aligns with ISO standard and most business reporting
week_start_day: monday

########################################
# NAMED VALUE FORMATS
########################################
# Define custom reusable formats here. Reference with value_format_name: <name>
# in any dimension or measure across the project.
# These formats add units/symbols not available in Looker's built-in formats.
named_value_format: saas_hours {
  value_format: "0.0\" hrs\""
  strict_value_format: no
}

named_value_format: saas_score {
  value_format: "0.0\"★\""
  strict_value_format: no
}

named_value_format: saas_k_usd {
  value_format: "$#,##0.0\"K\""
  strict_value_format: no
}



########################################
# DATAGROUP — cache policy
########################################

datagroup: daily_refresh {
  sql_trigger: "SELECT CURRENT_DATE()" ;;
  max_cache_age: "24 hours"
  description:   "Refreshes once per day. Used by all explores and aggregate tables."
}

########################################
# EXPLORES
########################################

# --- Primary Explore: Accounts (hub of the star schema) ---
explore: accounts {
  label:       "Accounts & Churn"
  description: "Customer accounts joined to subscriptions, churn events, and support tickets."

  # always_filter: forces a default filter that users can change but not remove
  always_filter: {
    filters: [accounts.churn_flag: "Yes,No"]
  }

  # access_filter: restricts rows based on a user attribute (demo — attribute may not exist)
  # access_filter: {
  #   field: accounts.plan_tier
  #   user_attribute: allowed_plan_tier
  # }

  join: subscriptions {
    type:         left_outer
    sql_on:       ${accounts.account_id} = ${subscriptions.account_id} ;;
    relationship: one_to_many
    # fields: whitelist — hide internal/raw fields from this join in this explore
    fields: [
      subscriptions.subscription_id,
      subscriptions.plan_tier,
      subscriptions.mrr_amount,
      subscriptions.total_mrr,
      subscriptions.average_mrr,
      subscriptions.total_arr,
      subscriptions.count,
      subscriptions.start_date,
      subscriptions.end_date,
      subscriptions.is_active,
      subscriptions.churn_flag,
      subscriptions.subscription_length_days,
      subscriptions.churn_rate,
      subscriptions.upgrade_flag,
      subscriptions.downgrade_flag,
      subscriptions.churned_mrr,
      subscriptions.mrr_churn_rate,
      subscriptions.dynamic_start_date,
      subscriptions.date_granularity,
      subscriptions.mrr_tier_html
    ]
  }

  join: churn_events {
    type:         left_outer
    sql_on:       ${accounts.account_id} = ${churn_events.account_id} ;;
    relationship: one_to_many
  }

  join: support_tickets {
    type:         left_outer
    sql_on:       ${accounts.account_id} = ${support_tickets.account_id} ;;
    relationship: one_to_many
  }

  join: base_account_data_view {
    type:         left_outer
    sql_on:       ${base_account_data_view.account_id} = ${accounts.account_id} ;;
    relationship: one_to_many
  }
}

# --- Feature Usage Explore ---
explore: feature_usage {
  label:       "Feature Usage"
  description: "Granular product engagement data."

  join: feature_map {
    type:         left_outer
    sql_on:       ${feature_usage.feature_name} = ${feature_map.feature_id} ;;
    relationship: many_to_one
  }

  join: subscriptions {
    type: left_outer
    sql_on: ${feature_usage.subscription_id} = ${subscriptions.subscription_id} ;;
    relationship: many_to_one
  }

  join: accounts {
    type: left_outer
    sql_on: ${subscriptions.account_id} = ${accounts.account_id} ;;
    relationship: many_to_one
    required_joins: [feature_map]
  }

  join: base_account_data_view {
    type:         left_outer
    sql_on:       ${base_account_data_view.account_id} = ${accounts.account_id} ;;
    relationship: one_to_many
  }
}

# --- Support Explore ---
explore: support_tickets {
  label:       "Support Tickets"
  description: "Support load, resolution time, satisfaction, and escalation analysis."

  join: accounts {
    type:         left_outer
    sql_on:       ${support_tickets.account_id} = ${accounts.account_id} ;;
    relationship: many_to_one
  }

  join: churn_events {
    type:         left_outer
    sql_on:       ${accounts.account_id} = ${churn_events.account_id} ;;
    relationship: one_to_many
  }
}

# --- Revenue & Subscriptions Explore ---
explore: subscriptions {
  label:       "Subscriptions & MRR"
  description: "Subscription-level revenue, plan changes, billing, and cohort analysis."

  join: accounts {
    type:         left_outer
    sql_on:       ${subscriptions.account_id} = ${accounts.account_id} ;;
    relationship: many_to_one
  }

  join: feature_usage {
    type:         left_outer
    sql_on:       ${subscriptions.subscription_id} = ${feature_usage.subscription_id} ;;
    relationship: one_to_many
  }

  join: feature_map {
    type:         left_outer
    sql_on:       ${feature_usage.feature_name} = ${feature_map.feature_id} ;;
    relationship: many_to_one
  }

  join: base_account_data_view {
    type:         left_outer
    sql_on:       ${base_account_data_view.account_id} = ${accounts.account_id} ;;
    relationship: one_to_many
  }
}

# --- Conversion Funnel Explore ---
explore: conversion_funnel {
  label:       "Conversion Funnel"
  description: "Staged conversion funnel from signup through trial, paid, retained, upgraded and churned."
}

# --- Native Derived Table Explore ---
explore: plan_tier_summary_ndt {
  label:       "Plan Tier Summary (NDT)"
  description: "Pre-aggregated plan tier KPIs built from an explore_source NDT. Fast, always in sync."
  persist_with: daily_refresh
}

# --- PDT Explores ---
explore: account_mrr_summary {
  label:       "Account MRR Summary (PDT)"
  description: "Pre-aggregated per-account MRR. Rebuilt daily via datagroup_trigger."
}

explore: monthly_cohort_retention {
  label:       "Monthly Cohort Retention (PDT)"
  description: "Cohort retention built from churn data. Rebuilt when churn data changes via sql_trigger_value."
}

explore: support_health_snapshot {
  label:       "Support Health Snapshot (PDT)"
  description: "Support KPIs pre-aggregated per account. Rebuilt every 6 hours via persist_for."

  join: accounts {
    type:         left_outer
    sql_on:       ${support_health_snapshot.account_id} = ${accounts.account_id} ;;
    relationship: many_to_one
  }
}

# --- Enterprise Accounts (Extension) Explore ---
explore: enterprise_accounts {
  label:       "Enterprise Accounts (Extension)"
  description: "Extends the base accounts view with enterprise-specific dimensions and measures."

  join: subscriptions {
    type:         left_outer
    sql_on:       ${enterprise_accounts.account_id} = ${subscriptions.account_id} ;;
    relationship: one_to_many
  }
}

# --- Advanced Liquid Demo Explore ---
explore: advanced_liquid_demo {
  label:       "Advanced Liquid Demo"
  description: "Demonstrates _in_query, _is_selected, _is_filtered, _user_attributes, manifest constants, and parameter combinations."

  # sql_always_where: invisible filter — users cannot see or override this.
  # Unlike always_filter (visible in UI), this is injected directly into SQL.
  # Use case: enforce data access rules that must never be bypassed.
  # Must reference fully-qualified fields (view.field), not ${TABLE}.column
  sql_always_where:
    ${advanced_liquid_demo.account_id} IS NOT NULL
    AND ${advanced_liquid_demo.plan_tier} IN ('Basic', 'Pro', 'Enterprise') ;;
}

########################################
# BASE EXPLORE — extension: required
########################################
# Abstract base that cannot be queried directly.
# Concrete explores inherit its joins via `extends:`.
# Use this pattern to share common joins without repeating them.
########################################

# Abstract explore: purely for metadata and shared filters
explore: base_account_data {
  extension: required
  label: "Abstract Base Account Explore"
  description: "Contains metadata, shared filters, etc. — not queryable"
}
# Concrete explore — must use a base view, not derived table
explore: active_accounts_only {
  extends: [base_account_data]
  from: accounts        # base table, NOT a derived table
  label: "Active Accounts"

  join: subscriptions {
    type: left_outer
    sql_on: ${active_accounts_only.account_id}.account_id} = ${subscriptions.account_id} ;;
    relationship: one_to_many
  }

  join: churn_events {
    type: left_outer
    sql_on: ${active_accounts_only.account_id}.account_id} = ${churn_events.account_id} ;;
    relationship: one_to_many
  }

  join: feature_usage {
    type: left_outer
    sql_on: ${subscriptions.subscription_id} = ${feature_usage.subscription_id} ;;
    relationship: many_to_one
  }

  always_filter: {
    filters: [active_accounts_only.churn_flag: "No"]   # filter must reference a joined view
  }
}

########################################
# from: ALIASING — join same view twice
########################################
# A contract can have both a billing contact and a technical contact,
# both sourced from the accounts view but under different aliases.
# This pattern uses from: to join the same view under two different names.
########################################

explore: churn_with_referral {
  label:       "Churn with Referral (from: alias)"
  description: "Demonstrates joining the accounts view twice: once as the churned account, once as the account that referred them."
  from:        accounts              # base explore uses accounts as the primary view

  join: referring_account {
    from:         accounts           # reuse the same accounts view under a different name
    type:         left_outer
    sql_on:       ${churn_with_referral.referral_source} = ${referring_account.account_name} ;;
    relationship: many_to_one
    view_label:   "Referring Account"   # how it appears in the field picker
    fields:       [referring_account.account_id, referring_account.account_name,
      referring_account.plan_tier, referring_account.industry]
  }

  join: churn_events {
    type:         left_outer
    sql_on:       ${churn_with_referral.account_id} = ${churn_events.account_id} ;;
    relationship: one_to_many
  }
}

########################################
# INCREMENTAL + OPTIMIZED PDT EXPLORES
########################################

explore: feature_events_incremental_pdt {
  label:       "Feature Events (Incremental PDT)"
  description: "Event-level feature usage pre-aggregated daily. Uses incremental rebuild — only processes new rows on each trigger."
}

explore: account_feature_summary_optimized_pdt {
  label:       "Account Feature Summary (BigQuery-Optimized PDT)"
  description: "Feature usage summarized per account/feature/day. Partitioned by date and clustered by account_id + feature_name for fast queries."

  join: accounts {
    type:         left_outer
    sql_on:       ${account_feature_summary_optimized_pdt.account_id} = ${accounts.account_id} ;;
    relationship: many_to_one
  }
}
