view: churn_events {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_churn_events` ;;

  # -------------------------------------------------------
  # PRIMARY KEY
  # -------------------------------------------------------

  dimension: churn_event_id {
    primary_key:  yes
    type:         string
    sql:          ${TABLE}.churn_event_id ;;
    label:        "Churn Event ID"
    description:  "Unique identifier for each churn event."
    tags:         ["id"]
  }

  # -------------------------------------------------------
  # FOREIGN KEYS
  # -------------------------------------------------------

  dimension: account_id {
    type:        string
    sql:         ${TABLE}.account_id ;;
    label:       "Account ID"
    hidden:      yes
    tags:        ["id"]
  }

  # -------------------------------------------------------
  # DIMENSIONS — DATES
  # -------------------------------------------------------

  dimension_group: churn {
    type:       time
    timeframes: [raw, date, week, month, quarter, year, month_num]
    datatype:   date
    sql:        ${TABLE}.churn_date ;;
    label:      "Churn"
    description: "Date the account churned."
  }

  dimension: churn_cohort_month {
    type:        string
    sql:         FORMAT_DATE('%Y-%m', ${TABLE}.churn_date) ;;
    label:       "Churn Cohort (Month)"
    description: "YYYY-MM cohort of the churn date."
  }

  # -------------------------------------------------------
  # DIMENSIONS — CHURN REASON
  # -------------------------------------------------------

  dimension: reason_code {
    type:        string
    sql:         ${TABLE}.reason_code ;;
    label:       "Churn Reason Code"
    description: "Categorized reason for churn: pricing, support, features, etc."
  }

  dimension: reason_category {
    type:        string
    sql:         CASE ${TABLE}.reason_code
                   WHEN 'pricing'  THEN '💰 Pricing'
                   WHEN 'support'  THEN '🎧 Support'
                   WHEN 'features' THEN '🔧 Missing Features'
                   WHEN 'competitor' THEN '⚔️ Switched to Competitor'
                   WHEN 'budget'   THEN '📉 Budget Cuts'
                   WHEN 'shutdown' THEN '🏢 Company Shutdown'
                   WHEN 'other'    THEN '❓ Other'
                   ELSE COALESCE(${TABLE}.reason_code, '❓ Unknown')
                 END ;;
    label:       "Churn Reason (Labeled)"
    description: "Human-readable churn reason with emoji labels for dashboards."
  }

  dimension: feedback_text {
    type:        string
    sql:         ${TABLE}.feedback_text ;;
    label:       "Customer Feedback"
    description: "Optional free-text customer comment about why they left."
  }

  dimension: has_feedback {
    type:        yesno
    sql:         ${TABLE}.feedback_text IS NOT NULL AND TRIM(${TABLE}.feedback_text) != '' ;;
    label:       "Has Feedback?"
    description: "True if the churned customer left written feedback."
  }

  # -------------------------------------------------------
  # DIMENSIONS — REFUNDS
  # -------------------------------------------------------

  dimension: refund_amount_usd {
    type:        number
    sql:         ${TABLE}.refund_amount_usd ;;
    label:       "Refund Amount (USD)"
    description: "Refund or credit issued at churn. $0 for most (~75%)."
    value_format_name: usd
  }

  dimension: was_refunded {
    type:        yesno
    sql:         ${TABLE}.refund_amount_usd > 0 ;;
    label:       "Was Refunded?"
    description: "True if a refund or credit was issued (~25% of churn events)."
  }

  dimension: refund_tier {
    type:        string
    sql:         CASE
                   WHEN ${TABLE}.refund_amount_usd = 0                  THEN 'No Refund'
                   WHEN ${TABLE}.refund_amount_usd BETWEEN 0.01 AND 99  THEN '$1-$99'
                   WHEN ${TABLE}.refund_amount_usd BETWEEN 100 AND 499  THEN '$100-$499'
                   WHEN ${TABLE}.refund_amount_usd >= 500               THEN '$500+'
                 END ;;
    label:       "Refund Tier"
    description: "Bucketed refund amount."
  }

  # -------------------------------------------------------
  # DIMENSIONS — PRE-CHURN SIGNALS
  # -------------------------------------------------------

  dimension: preceding_upgrade_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.preceding_upgrade_flag AS BOOL), FALSE) ;;
    label:       "Upgrade Before Churn?"
    description: "True if account upgraded within 90 days before churning."
  }

  dimension: preceding_downgrade_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.preceding_downgrade_flag AS BOOL), FALSE) ;;
    label:       "Downgrade Before Churn?"
    description: "True if account downgraded within 90 days before churning — a strong churn signal."
  }

  dimension: pre_churn_signal {
    type:        string
    sql:         CASE
                   WHEN COALESCE(SAFE_CAST(${TABLE}.preceding_downgrade_flag AS BOOL), FALSE) AND NOT COALESCE(SAFE_CAST(${TABLE}.preceding_upgrade_flag AS BOOL), FALSE)
                     THEN 'Downgrade → Churn'
                   WHEN COALESCE(SAFE_CAST(${TABLE}.preceding_upgrade_flag AS BOOL), FALSE) AND NOT COALESCE(SAFE_CAST(${TABLE}.preceding_downgrade_flag AS BOOL), FALSE)
                     THEN 'Upgrade → Churn'
                   WHEN COALESCE(SAFE_CAST(${TABLE}.preceding_upgrade_flag AS BOOL), FALSE) AND COALESCE(SAFE_CAST(${TABLE}.preceding_downgrade_flag AS BOOL), FALSE)
                     THEN 'Both Changes → Churn'
                   ELSE 'No Plan Change Before Churn'
                 END ;;
    label:       "Pre-Churn Plan Signal"
    description: "Describes plan change activity in the 90 days before churn."
  }

  dimension: is_reactivation {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.is_reactivation AS BOOL), FALSE) ;;
    label:       "Was Reactivation?"
    description: "True if this churn event was from an account that had previously churned and reactivated (~10%)."
  }

  # -------------------------------------------------------
  # MEASURES — COUNTS
  # -------------------------------------------------------

  measure: count {
    type:        count
    label:       "Total Churn Events"
    description: "Total number of churn events."
    drill_fields: [churn_event_id, account_id, churn_date, reason_code, refund_amount_usd, is_reactivation, preceding_downgrade_flag]
  }

  measure: count_with_refund {
    type:        count
    label:       "Churn Events with Refund"
    description: "Churn events where a refund or credit was issued."
    filters:     [was_refunded: "Yes"]
  }

  measure: count_reactivations {
    type:        count
    label:       "Churn Events (Reactivated Accounts)"
    description: "Churn events from accounts that had previously returned."
    filters:     [is_reactivation: "Yes"]
  }

  measure: count_downgrade_to_churn {
    type:        count
    label:       "Downgrade-to-Churn Events"
    description: "Churn events preceded by a downgrade within 90 days."
    filters:     [preceding_downgrade_flag: "Yes"]
  }

  measure: reactivation_rate {
    type:        number
    sql:         SAFE_DIVIDE(${count_reactivations}, NULLIF(${count}, 0)) ;;
    label:       "Reactivation Churn Rate"
    description: "Percentage of churn events from reactivated (previously churned) accounts."
    value_format_name: percent_2
  }

  measure: refund_rate {
    type:        number
    sql:         SAFE_DIVIDE(${count_with_refund}, NULLIF(${count}, 0)) ;;
    label:       "Refund Rate at Churn"
    description: "Percentage of churn events that resulted in a refund or credit."
    value_format_name: percent_2
  }

  measure: downgrade_to_churn_rate {
    type:        number
    sql:         SAFE_DIVIDE(${count_downgrade_to_churn}, NULLIF(${count}, 0)) ;;
    label:       "Downgrade-to-Churn Rate"
    description: "Percentage of churn events preceded by a downgrade (high-risk signal)."
    value_format_name: percent_2
  }

  # -------------------------------------------------------
  # MEASURES — REFUND VALUE
  # -------------------------------------------------------

  measure: total_refund_amount {
    type:        sum
    sql:         ${refund_amount_usd} ;;
    label:       "Total Refunds Issued (USD)"
    description: "Total dollar value of all refunds and credits issued at churn."
    value_format_name: usd_0
    drill_fields: [churn_event_id, account_id, churn_date, reason_code, refund_amount_usd]
  }

  measure: average_refund_amount {
    type:        average
    sql:         ${refund_amount_usd} ;;
    label:       "Avg Refund Amount"
    description: "Average refund/credit amount across all churn events (including $0)."
    value_format_name: usd
  }

  measure: average_refund_when_issued {
    type:        average
    sql:         ${refund_amount_usd} ;;
    label:       "Avg Refund When Issued"
    description: "Average refund amount for churn events where a refund was issued."
    filters:     [was_refunded: "Yes"]
    value_format_name: usd
  }

  # -------------------------------------------------------
  # MEASURES — FEEDBACK
  # -------------------------------------------------------

  measure: feedback_response_rate {
    type:        number
    sql:         SAFE_DIVIDE(
                   COUNTIF(${TABLE}.feedback_text IS NOT NULL AND TRIM(${TABLE}.feedback_text) != ''),
                   NULLIF(COUNT(*), 0)
                 ) ;;
    label:       "Feedback Response Rate"
    description: "Percentage of churned accounts that left written feedback."
    value_format_name: percent_2
  }
}
