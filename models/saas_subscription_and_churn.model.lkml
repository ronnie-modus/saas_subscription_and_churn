connection: "bq_saas_subscription_and_churn"

include: "/views/*.view.lkml"

########################################
# EXPLORES
########################################

# --- Primary Explore: Accounts (hub of the star schema) ---
explore: ravenstack_accounts {
  label:       "Accounts & Churn"
  description: "Customer accounts joined to subscriptions, churn events, and support tickets.
  Best for customer-level health, churn analysis, and revenue overview."

  join: ravenstack_subscriptions {
    type:         left_outer
    sql_on:       ${ravenstack_accounts.account_id} = ${ravenstack_subscriptions.account_id} ;;
    relationship: one_to_many
  }

  join: ravenstack_churn_events {
    type:         left_outer
    sql_on:       ${ravenstack_accounts.account_id} = ${ravenstack_churn_events.account_id} ;;
    relationship: one_to_many
  }

  join: ravenstack_support_tickets {
    type:         left_outer
    sql_on:       ${ravenstack_accounts.account_id} = ${ravenstack_support_tickets.account_id} ;;
    relationship: one_to_many
  }
}

# --- Feature Usage Explore ---
explore: ravenstack_feature_usage {
  label:       "Feature Usage"
  description: "Granular product engagement data.
  Best for feature adoption, beta tracking, error analysis, and usage trends."

  join: ravenstack_subscriptions {
    type:         left_outer
    sql_on:       ${ravenstack_feature_usage.subscription_id} = ${ravenstack_subscriptions.subscription_id} ;;
    relationship: many_to_one
  }

  join: ravenstack_accounts {
    type:         left_outer
    sql_on:       ${ravenstack_subscriptions.account_id} = ${ravenstack_accounts.account_id} ;;
    relationship: many_to_one
  }
}

# --- Support Explore ---
explore: ravenstack_support_tickets {
  label:       "Support Tickets"
  description: "Support load, resolution time, satisfaction, and escalation analysis."

  join: ravenstack_accounts {
    type:         left_outer
    sql_on:       ${ravenstack_support_tickets.account_id} = ${ravenstack_accounts.account_id} ;;
    relationship: many_to_one
  }

  join: ravenstack_churn_events {
    type:         left_outer
    sql_on:       ${ravenstack_accounts.account_id} = ${ravenstack_churn_events.account_id} ;;
    relationship: one_to_many
  }
}

# --- Revenue & Subscriptions Explore ---
explore: ravenstack_subscriptions {
  label:       "Subscriptions & MRR"
  description: "Subscription-level revenue, plan changes, billing, and cohort analysis."

  join: ravenstack_accounts {
    type:         left_outer
    sql_on:       ${ravenstack_subscriptions.account_id} = ${ravenstack_accounts.account_id} ;;
    relationship: many_to_one
  }

  join: ravenstack_feature_usage {
    type:         left_outer
    sql_on:       ${ravenstack_subscriptions.subscription_id} = ${ravenstack_feature_usage.subscription_id} ;;
    relationship: one_to_many
  }
}
