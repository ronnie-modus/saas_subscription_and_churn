# ============================================================
# CONVERSION FUNNEL — derived table
# ============================================================
# Models the SaaS conversion journey:
#   Signed Up → Started Trial → Converted to Paid →
#   Active 90+ Days → Upgraded → Churned (exit)
#
# Each stage uses a subquery against the real tables so the
# funnel reflects actual data rather than hardcoded counts.
# ============================================================

view: conversion_funnel {

  derived_table: {
    sql:
      WITH
      -- Stage 1: All accounts that ever signed up
      signed_up AS (
        SELECT COUNT(DISTINCT account_id) AS n
        FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_accounts`
      ),

      -- Stage 2: Accounts that started a trial
      trialed AS (
      SELECT COUNT(DISTINCT account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_accounts`
      WHERE COALESCE(SAFE_CAST(is_trial AS BOOL), FALSE) = TRUE
      OR account_id IN (
      SELECT DISTINCT account_id
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions`
      WHERE COALESCE(SAFE_CAST(is_trial AS BOOL), FALSE) = TRUE
      )
      ),

      -- Stage 3: Accounts that converted to paid (at least one non-trial subscription)
      converted AS (
      SELECT COUNT(DISTINCT account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions`
      WHERE COALESCE(SAFE_CAST(is_trial AS BOOL), FALSE) = FALSE
      ),

      -- Stage 4: Accounts active 90+ days (subscription length >= 90 days)
      retained AS (
      SELECT COUNT(DISTINCT account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions`
      WHERE COALESCE(SAFE_CAST(is_trial AS BOOL), FALSE) = FALSE
      AND DATE_DIFF(
      COALESCE(SAFE_CAST(end_date AS DATE), CURRENT_DATE()),
      SAFE_CAST(start_date AS DATE),
      DAY
      ) >= 90
      ),

      -- Stage 5: Accounts that upgraded at any point
      upgraded AS (
      SELECT COUNT(DISTINCT account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_subscriptions`
      WHERE COALESCE(SAFE_CAST(upgrade_flag AS BOOL), FALSE) = TRUE
      ),

      -- Stage 6: Accounts that eventually churned
      churned AS (
      SELECT COUNT(DISTINCT account_id) AS n
      FROM `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_churn_events`
      )

      SELECT
      1                          AS stage_order,
      'Signed Up'                AS stage_name,
      signed_up.n                AS stage_count,
      1.0                        AS conversion_from_prev
      FROM signed_up

      UNION ALL SELECT 2, 'Started Trial',    trialed.n,   SAFE_DIVIDE(trialed.n,    signed_up.n)  FROM trialed,   signed_up
      UNION ALL SELECT 3, 'Converted to Paid', converted.n, SAFE_DIVIDE(converted.n, trialed.n)    FROM converted, trialed
      UNION ALL SELECT 4, 'Active 90+ Days',  retained.n,  SAFE_DIVIDE(retained.n,  converted.n)  FROM retained,  converted
      UNION ALL SELECT 5, 'Upgraded',         upgraded.n,  SAFE_DIVIDE(upgraded.n,  retained.n)   FROM upgraded,  retained
      UNION ALL SELECT 6, 'Churned',          churned.n,   SAFE_DIVIDE(churned.n,   converted.n)  FROM churned,   converted

      ORDER BY stage_order ;;
  }

  # -------------------------------------------------------
  # DIMENSIONS
  # -------------------------------------------------------

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

  # -------------------------------------------------------
  # MEASURES
  # -------------------------------------------------------

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
    description: "Percentage of accounts from the previous stage that reached this stage."
    value_format_name: percent_1
  }

  measure: drop_off_rate {
    type:        number
    sql:         1 - SAFE_DIVIDE(SUM(${TABLE}.stage_count), NULLIF(MAX(${TABLE}.stage_count), 0)) ;;
    label:       "Drop-off Rate"
    description: "Percentage of accounts that dropped off at each stage."
    value_format_name: percent_1
  }
}
