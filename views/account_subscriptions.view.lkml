view: account_subscriptions {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.account_subscriptions` ;;
  drill_fields: [account_id]

  dimension: account_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.account_id ;;
  }
  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }
  dimension: arr_amount {
    type: number
    sql: ${TABLE}.arr_amount ;;
  }
  dimension: mrr_amount {
    type: number
    sql: ${TABLE}.mrr_amount ;;
  }
  dimension: plan_tier {
    type: string
    sql: ${TABLE}.plan_tier ;;
  }
  measure: count {
    type: count
    drill_fields: [account_id, account_name]
  }
}
