########################################
# LOOKML DATA TESTS
########################################
# Validate model logic — not just syntax, but actual data assumptions.
# Run from: Looker IDE → Project Health → Run LookML Tests
#
# Each test:
#   1. Runs a small explore_source query
#   2. Evaluates an assert expression on every row
#   3. FAILS if the expression returns `no` for ANY row, or if the query errors
#
# Expression syntax = Looker table calculation syntax (not SQL)
# Use these to catch: rate overflows, NULL primary keys, broken derived measures,
# impossible date ranges, referential integrity violations, etc.
########################################

# -------------------------------------------------------
# ACCOUNTS
# -------------------------------------------------------

test: churn_rate_between_0_and_100 {
  explore_source: accounts {
    column: churn_rate { field: accounts.churn_rate }
  }
  assert: churn_rate_is_valid_percentage {
    # churn_rate is stored as a decimal (0.0–1.0), multiply by 100 to get %
    expression: ${accounts.churn_rate} >= 0 AND ${accounts.churn_rate} <= 1.0 ;;
  }
}

test: trial_conversion_rate_is_valid {
  explore_source: accounts {
    column: trial_conversion_rate { field: accounts.trial_conversion_rate }
  }
  assert: trial_conversion_is_between_0_and_1 {
    expression: is_null(${accounts.trial_conversion_rate}) OR
                (${accounts.trial_conversion_rate} >= 0 AND ${accounts.trial_conversion_rate} <= 1.0) ;;
  }
}

test: account_count_is_positive {
  explore_source: accounts {
    column: count { field: accounts.count }
  }
  assert: at_least_one_account_exists {
    expression: ${accounts.count} > 0 ;;
  }
}

# -------------------------------------------------------
# SUBSCRIPTIONS
# -------------------------------------------------------

test: mrr_is_non_negative {
  explore_source: subscriptions {
    column: total_mrr { field: subscriptions.total_mrr }
    filters: [subscriptions.is_active: "Yes"]
  }
  assert: active_subscriptions_have_positive_mrr {
    expression: is_null(${subscriptions.total_mrr}) OR ${subscriptions.total_mrr} >= 0 ;;
  }
}

test: average_mrr_is_reasonable {
  explore_source: subscriptions {
    column: average_mrr { field: subscriptions.average_mrr }
  }
  assert: average_mrr_not_absurdly_large {
    # Flag if average MRR exceeds $1M — likely a data error
    expression: is_null(${subscriptions.average_mrr}) OR ${subscriptions.average_mrr} < 1000000 ;;
  }
}

# -------------------------------------------------------
# CHURN EVENTS
# -------------------------------------------------------

test: churn_rate_not_exceeding_100_pct {
  explore_source: accounts {
    column: churn_rate         { field: accounts.churn_rate }
    column: count              { field: accounts.count }
    column: count_churned      { field: accounts.count_churned }
  }
  assert: churned_count_not_exceeding_total_count {
    # count_churned can never exceed the total account count
    expression: ${accounts.count_churned} <= ${accounts.count} ;;
  }
}

# -------------------------------------------------------
# SUPPORT TICKETS
# -------------------------------------------------------

test: csat_score_in_valid_range {
  explore_source: support_tickets {
    column: average_csat_score { field: support_tickets.average_csat_score }
  }
  assert: csat_is_between_1_and_5 {
    # CSAT score is on a 1–5 scale
    expression: is_null(${support_tickets.average_csat_score}) OR
                (${support_tickets.average_csat_score} >= 1 AND
                 ${support_tickets.average_csat_score} <= 5) ;;
  }
}

test: resolution_time_is_non_negative {
  explore_source: support_tickets {
    column: average_resolution_hours { field: support_tickets.average_resolution_hours }
    filters: [support_tickets.is_resolved: "Yes"]
  }
  assert: resolved_tickets_have_positive_resolution_time {
    expression: is_null(${support_tickets.average_resolution_hours}) OR
                ${support_tickets.average_resolution_hours} >= 0 ;;
  }
}

# -------------------------------------------------------
# FEATURE USAGE
# -------------------------------------------------------

test: error_rate_is_valid_percentage {
  explore_source: feature_usage {
    column: error_rate { field: feature_usage.error_rate }
  }
  assert: error_rate_between_0_and_1 {
    expression: is_null(${feature_usage.error_rate}) OR
                (${feature_usage.error_rate} >= 0 AND ${feature_usage.error_rate} <= 1.0) ;;
  }
}

test: beta_adoption_rate_is_valid {
  explore_source: feature_usage {
    column: beta_adoption_rate { field: feature_usage.beta_adoption_rate }
  }
  assert: beta_adoption_between_0_and_1 {
    expression: is_null(${feature_usage.beta_adoption_rate}) OR
                (${feature_usage.beta_adoption_rate} >= 0 AND
                 ${feature_usage.beta_adoption_rate} <= 1.0) ;;
  }
}
