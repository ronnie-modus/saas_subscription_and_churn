view: active_accounts {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.active_accounts` ;;
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
  dimension: churn_flag {
    type: string
    sql: ${TABLE}.churn_flag ;;
  }
  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }
  dimension: industry {
    type: string
    sql: ${TABLE}.industry ;;
  }
  dimension: is_trial {
    type: string
    sql: ${TABLE}.is_trial ;;
  }
  dimension: plan_tier {
    type: string
    sql: ${TABLE}.plan_tier ;;
  }
  dimension: referral_source {
    type: string
    sql: ${TABLE}.referral_source ;;
  }
  dimension: seats {
    type: number
    sql: ${TABLE}.seats ;;
  }
  dimension: signup_date {
    type: string
    sql: ${TABLE}.signup_date ;;
  }
  measure: count {
    type: count
    drill_fields: [account_id, account_name]
  }
}
