view: base_account_data_view {
  derived_table: {
    sql: SELECT
           a.account_id,
           s.subscription_id,
           c.churn_flag
         FROM accounts a
         LEFT JOIN subscriptions s
           ON a.account_id = s.account_id
         LEFT JOIN churn_events c
           ON a.account_id = c.account_id ;;
  }

  dimension: account_id { type: string sql: ${TABLE}.account_id ;; }
  dimension: subscription_id { type: string sql: ${TABLE}.subscription_id ;; }
  dimension: churn_flag { type: string sql: ${TABLE}.churn_flag ;; }
}
