# ============================================================
# CONVERSION FUNNEL — derived table
# ============================================================
# Supports plan_tier and industry parameters so dashboard
# filters actually affect the funnel calculations.
# ============================================================

view: conversion_funnel {

  # -------------------------------------------------------
  # PARAMETERS — drive Liquid SQL injection below
  # -------------------------------------------------------

  parameter: plan_tier_filter {
    type:          string
    label:         "Plan Tier"
    description:   "Filter funnel by plan tier."
    allowed_value: { label: "All"        value: "all"        }
    allowed_value: { label: "Basic"      value: "Basic"      }
    allowed_value: { label: "Pro"        value: "Pro"        }
    allowed_value: { label: "Enterprise" value: "Enterprise" }
    default_value: "all"
  }

  parameter: industry_filter {
    type:        string
    label:       "Industry"
    description: "Filter funnel by industry vertical."
    default_value: "all"
  }

  derived_table: {
    sql:
      {% assign pt  = conversion_funnel.plan_tier_filter._parameter_value %}
      {% assign ind = conversion_funnel.industry_filter._parameter_value  %}

      WITH
      eligible_accounts AS (
      SELECT account_id
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_accounts`
      WHERE 1=1
      {% if pt != "'all'" and pt != "" %}
      AND plan_tier = {{ pt }}
      {% endif %}
      {% if ind != "'all'" and ind != "" %}
      AND industry = {{ ind }}
      {% endif %}
      ),
      signed_up AS (
      SELECT COUNT(DISTINCT account_id) AS n FROM eligible_accounts
      ),
      trialed AS (
      SELECT COUNT(DISTINCT a.account_id) AS n
      FROM eligible_accounts a
      WHERE a.account_id IN (
      SELECT DISTINCT account_id
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions`
      WHERE COALESCE(SAFE_CAST(is_trial AS BOOL), FALSE) = TRUE
      )
      ),
      converted AS (
      SELECT COUNT(DISTINCT s.account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions` s
      INNER JOIN eligible_accounts ea ON s.account_id = ea.account_id
      WHERE COALESCE(SAFE_CAST(s.is_trial AS BOOL), FALSE) = FALSE
      ),
      retained AS (
      SELECT COUNT(DISTINCT s.account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions` s
      INNER JOIN eligible_accounts ea ON s.account_id = ea.account_id
      WHERE COALESCE(SAFE_CAST(s.is_trial AS BOOL), FALSE) = FALSE
      AND DATE_DIFF(
      COALESCE(SAFE_CAST(s.end_date AS DATE), CURRENT_DATE()),
      SAFE_CAST(s.start_date AS DATE), DAY
      ) >= 90
      ),
      upgraded AS (
      SELECT COUNT(DISTINCT s.account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions` s
      INNER JOIN eligible_accounts ea ON s.account_id = ea.account_id
      WHERE COALESCE(SAFE_CAST(s.upgrade_flag AS BOOL), FALSE) = TRUE
      ),
      churned AS (
      SELECT COUNT(DISTINCT c.account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_churn_events` c
      INNER JOIN eligible_accounts ea ON c.account_id = ea.account_id
      )

      SELECT 1 AS stage_order, 'Signed Up'           AS stage_name, signed_up.n   AS stage_count, 1.0                                         AS conversion_from_prev FROM signed_up
      UNION ALL SELECT 2, 'Started Trial',    trialed.n,    SAFE_DIVIDE(trialed.n,    signed_up.n)  FROM trialed,    signed_up
      UNION ALL SELECT 3, 'Converted to Paid', converted.n, SAFE_DIVIDE(converted.n,  trialed.n)   FROM converted,  trialed
      UNION ALL SELECT 4, 'Active 90+ Days',  retained.n,   SAFE_DIVIDE(retained.n,   converted.n) FROM retained,   converted
      UNION ALL SELECT 5, 'Upgraded',         upgraded.n,   SAFE_DIVIDE(upgraded.n,   retained.n)  FROM upgraded,   retained
      UNION ALL SELECT 6, 'Churned',          churned.n,    SAFE_DIVIDE(churned.n,    converted.n) FROM churned,    converted

      ORDER BY stage_order ;;
  }

  dimension: stage_order {
    type:        number
    sql:         ${TABLE}.stage_order ;;
    primary_key: yes
    hidden:      yes
  }

  dimension: stage_name {
    type:        string
    sql:         ${TABLE}.stage_name ;;
    label:       "Funnel Stage"
    description: "Name of the conversion funnel stage."
    order_by_field: stage_order
  }

  measure: stage_count {
    type:        sum
    sql:         ${TABLE}.stage_count ;;
    label:       "Accounts at Stage"
    description: "Number of accounts that reached this funnel stage."
    value_format_name: decimal_0
  }

  measure: conversion_rate {
    type:        average
    sql:         ${TABLE}.conversion_from_prev ;;
    label:       "Conversion Rate from Previous Stage"
    value_format_name: percent_1
  }

  measure: drop_off_rate {
    type:        number
    sql:         1 - SAFE_DIVIDE(SUM(${TABLE}.stage_count), NULLIF(MAX(${TABLE}.stage_count), 0)) ;;
    label:       "Drop-off Rate"
    value_format_name: percent_1
  }
}
