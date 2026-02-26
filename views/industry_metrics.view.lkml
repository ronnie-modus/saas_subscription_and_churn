view: industry_metrics {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.industry_metrics` ;;
  drill_fields: [industry]

  dimension: industry {
    primary_key: yes
    type: string
    sql: ${TABLE}.industry ;;
  }
  dimension: account_count {
    type: number
    sql: ${TABLE}.account_count ;;
  }
  dimension: avg_satisfaction {
    type: number
    sql: ${TABLE}.avg_satisfaction ;;
  }
  dimension: total_mrr {
    type: number
    sql: ${TABLE}.total_mrr ;;
  }
  measure: count {
    type: count
    drill_fields: [industry]
  }
}
