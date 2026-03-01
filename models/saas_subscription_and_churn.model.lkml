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
