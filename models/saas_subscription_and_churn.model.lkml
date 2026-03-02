connection: "bq_saas_subscription_and_churn"

include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard"

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
    type:         left_outer
    sql_on:       ${feature_usage.subscription_id} = ${subscriptions.subscription_id} ;;
    relationship: many_to_one
  }

  join: accounts {
    type:         left_outer
    sql_on:       ${subscriptions.account_id} = ${accounts.account_id} ;;
    relationship: many_to_one
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
