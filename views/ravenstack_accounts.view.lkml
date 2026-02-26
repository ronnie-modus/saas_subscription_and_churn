view: accounts {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_accounts` ;;

  # -------------------------------------------------------
  # PRIMARY KEY
  # -------------------------------------------------------

  dimension: account_id {
    primary_key:  yes
    type:         string
    sql:          ${TABLE}.account_id ;;
    label:        "Account ID"
    description:  "Unique identifier for each customer account."
    tags:         ["id"]
  }

  # -------------------------------------------------------
  # DIMENSIONS — IDENTITY
  # -------------------------------------------------------

  dimension: account_name {
    type:        string
    sql:         ${TABLE}.account_name ;;
    label:       "Account Name"
    description: "Fictional company name assigned to the account."
    link: {
      label: "Open Account Explore"
      url:   "/explore/ravenstack_saas/accounts?fields=accounts.account_name,accounts.industry,accounts.plan_tier,accounts.seats&f[accounts.account_id]={{ value }}"
    }
  }

  dimension: industry {
    type:        string
    sql:         ${TABLE}.industry ;;
    label:       "Industry"
    description: "SaaS vertical (e.g. DevTools, EdTech, FinTech)."
  }

  dimension: country {
    type:        string
    sql:         ${TABLE}.country ;;
    label:       "Country"
    map_layer_name: countries
    description: "ISO-2 country code of the account."
  }

  # -------------------------------------------------------
  # DIMENSIONS — DATES
  # -------------------------------------------------------

  dimension_group: signup {
    type:        time
    timeframes:  [raw, date, week, month, quarter, year, month_num, day_of_week]
    datatype:    date
    sql:         ${TABLE}.signup_date ;;
    label:       "Signup"
    description: "Date the account was created."
  }

  dimension: days_since_signup {
    type:        number
    sql:         DATE_DIFF(CURRENT_DATE(), ${signup_date}, DAY) ;;
    label:       "Days Since Signup"
    description: "Number of days from signup to today."
  }

  dimension: account_age_bucket {
    type:        string
    sql:         CASE
                   WHEN DATE_DIFF(CURRENT_DATE(), ${signup_date}, DAY) < 30   THEN '0-30 days'
                   WHEN DATE_DIFF(CURRENT_DATE(), ${signup_date}, DAY) < 90   THEN '31-90 days'
                   WHEN DATE_DIFF(CURRENT_DATE(), ${signup_date}, DAY) < 180  THEN '91-180 days'
                   WHEN DATE_DIFF(CURRENT_DATE(), ${signup_date}, DAY) < 365  THEN '181-365 days'
                   ELSE '365+ days'
                 END ;;
    label:       "Account Age Bucket"
    description: "Bucketed account age from signup to today."
    order_by_field: days_since_signup
  }

  dimension: signup_cohort_month {
    type:        string
    sql:         FORMAT_DATE('%Y-%m', ${signup_date}) ;;
    label:       "Signup Cohort (Month)"
    description: "YYYY-MM cohort based on signup date."
  }

  # -------------------------------------------------------
  # DIMENSIONS — PLAN & PRODUCT
  # -------------------------------------------------------

  dimension: plan_tier {
    type:        string
    sql:         ${TABLE}.plan_tier ;;
    label:       "Plan Tier"
    description: "Initial plan at account creation: Basic, Pro, or Enterprise."
  }

  dimension: plan_tier_rank {
    type:        number
    sql:         CASE ${TABLE}.plan_tier
                   WHEN 'Basic'      THEN 1
                   WHEN 'Pro'        THEN 2
                   WHEN 'Enterprise' THEN 3
                   ELSE 0
                 END ;;
    label:       "Plan Tier Rank"
    description: "Numeric sort order for plan tier (for charts)."
    hidden:      yes
  }

  dimension: seats {
    type:        number
    sql:         ${TABLE}.seats ;;
    label:       "Seats"
    description: "Number of licensed user seats on the account."
  }

  dimension: seats_bucket {
    type:        string
    sql:         CASE
                   WHEN ${TABLE}.seats = 1        THEN '1 seat'
                   WHEN ${TABLE}.seats BETWEEN 2 AND 5   THEN '2-5 seats'
                   WHEN ${TABLE}.seats BETWEEN 6 AND 20  THEN '6-20 seats'
                   WHEN ${TABLE}.seats BETWEEN 21 AND 100 THEN '21-100 seats'
                   ELSE '100+ seats'
                 END ;;
    label:       "Seats Bucket"
    description: "Bucketed seat count for distribution analysis."
  }

  # -------------------------------------------------------
  # DIMENSIONS — ACQUISITION
  # -------------------------------------------------------

  dimension: referral_source {
    type:        string
    sql:         ${TABLE}.referral_source ;;
    label:       "Referral Source"
    description: "How the account was acquired: organic, ads, event, partner, other."
  }

  # -------------------------------------------------------
  # DIMENSIONS — STATUS FLAGS
  # -------------------------------------------------------

  dimension: is_trial {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.is_trial AS BOOL), FALSE) ;;
    label:       "Is Trial?"
    description: "Whether the account is currently in a trial."
  }

  dimension: churn_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.churn_flag AS BOOL), FALSE) ;;
    label:       "Has Churned?"
    description: "True if this account has churned at any point."
  }

  dimension: account_status {
    type:        string
    sql:         CASE
                   WHEN COALESCE(SAFE_CAST(${TABLE}.churn_flag AS BOOL), FALSE) THEN 'Churned'
                   WHEN COALESCE(SAFE_CAST(${TABLE}.is_trial  AS BOOL), FALSE) THEN 'Trial'
                   ELSE 'Active'
                 END ;;
    label:       "Account Status"
    description: "Derived account status: Active, Trial, or Churned."
  }

  # -------------------------------------------------------
  # MEASURES
  # -------------------------------------------------------

  measure: count {
    type:        count
    label:       "Total Accounts"
    description: "Total number of customer accounts."
    drill_fields: [account_id, account_name, industry, country, plan_tier, signup_date, account_status]
  }

  measure: count_active {
    type:        count
    label:       "Active Accounts"
    description: "Number of accounts that have NOT churned and are not on trial."
    filters:     [churn_flag: "No", is_trial: "No"]
    drill_fields: [account_id, account_name, industry, plan_tier, signup_date]
  }

  measure: count_trial {
    type:        count
    label:       "Trial Accounts"
    description: "Number of accounts currently in trial."
    filters:     [is_trial: "Yes"]
    drill_fields: [account_id, account_name, industry, plan_tier, signup_date]
  }

  measure: count_churned {
    type:        count
    label:       "Churned Accounts"
    description: "Number of accounts that have churned."
    filters:     [churn_flag: "Yes"]
    drill_fields: [account_id, account_name, industry, plan_tier, signup_date]
  }

  measure: churn_rate {
    type:        number
    sql:         SAFE_DIVIDE(${count_churned}, NULLIF(${count}, 0)) ;;
    label:       "Account Churn Rate"
    description: "Percentage of all accounts that have churned."
    value_format_name: percent_2
  }

  measure: trial_conversion_rate {
    type:        number
    sql:         SAFE_DIVIDE(${count_active}, NULLIF(${count_trial} + ${count_active}, 0)) ;;
    label:       "Trial Conversion Rate"
    description: "Percentage of trial + active accounts that converted to paid."
    value_format_name: percent_2
  }

  measure: average_seats {
    type:        average
    sql:         ${seats} ;;
    label:       "Avg Seats"
    description: "Average number of seats per account."
    value_format_name: decimal_1
  }

  measure: total_seats {
    type:        sum
    sql:         ${seats} ;;
    label:       "Total Seats"
    description: "Sum of all licensed seats across accounts."
  }

  measure: count_by_referral_organic {
    type:        count
    label:       "Organic Accounts"
    description: "Accounts acquired via organic channels."
    filters:     [referral_source: "organic"]
    hidden:      yes
  }

  measure: count_by_referral_ads {
    type:        count
    label:       "Paid Ads Accounts"
    description: "Accounts acquired via paid ads."
    filters:     [referral_source: "ads"]
    hidden:      yes
  }
}
