########################################
# BASE ACCOUNT DATA VIEW
########################################
# A lightweight derived table joining the three core account tables.
# Used as a shared base for explores that need account + subscription + churn
# context without pulling in the full accounts view complexity.
########################################

view: base_account_data_view {
  derived_table: {
    sql:
      SELECT
        a.account_id,
        s.subscription_id,
        c.churn_flag
      FROM `@{dataset}.@{table_prefix}accounts` a
      LEFT JOIN `@{dataset}.@{table_prefix}subscriptions` s
        ON a.account_id = s.account_id
      LEFT JOIN `@{dataset}.@{table_prefix}churn_events` c
        ON a.account_id = c.account_id ;;
  }

  dimension: account_id {
    type:        string
    sql:         ${TABLE}.account_id ;;
    primary_key: yes
    hidden:      yes
  }

  dimension: subscription_id {
    type:   string
    sql:    ${TABLE}.subscription_id ;;
    hidden: yes
  }

  dimension: churn_flag {
    type:  string
    sql:   ${TABLE}.churn_flag ;;
    label: "Churn Flag (Base)"
  }
}
