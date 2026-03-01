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
    sql:         SAFE_CAST(${TABLE}.signup_date AS DATE) ;;
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
    sql:         FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.signup_date AS DATE)) ;;
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
    sql:         SAFE_CAST(${TABLE}.seats AS INT64) ;;
    label:       "Seats"
    description: "Number of licensed user seats on the account."
  }

  dimension: seats_bucket {
    type:        string
    sql:         CASE
                   WHEN SAFE_CAST(${TABLE}.seats AS INT64) = 1                           THEN '1 seat'
                   WHEN SAFE_CAST(${TABLE}.seats AS INT64) BETWEEN 2 AND 5              THEN '2-5 seats'
                   WHEN SAFE_CAST(${TABLE}.seats AS INT64) BETWEEN 6 AND 20             THEN '6-20 seats'
                   WHEN SAFE_CAST(${TABLE}.seats AS INT64) BETWEEN 21 AND 100           THEN '21-100 seats'
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

  # -------------------------------------------------------
  # DYNAMIC PARAMETERS
  # -------------------------------------------------------

  parameter: breakdown_by {
    type:          string
    label:         "Break Down By"
    description:   "Switch the grouping dimension across all charts."
    default_value: "plantier"
    allowed_value: { label: "Plan Tier"       value: "plantier"       }
    allowed_value: { label: "Industry"        value: "industry"        }
    allowed_value: { label: "Referral Source" value: "referral" }
    allowed_value: { label: "Country"         value: "country"         }
    allowed_value: { label: "Account Status"  value: "status"  }
    allowed_value: { label: "Seats Bucket"    value: "seats"    }
  }

  dimension: dynamic_breakdown {
    type:                 string
    label:                "Dynamic Breakdown"
    description:          "Groups by whichever dimension is selected in the 'Break Down By' filter."
    label_from_parameter: breakdown_by
    sql:
      {% if breakdown_by._parameter_value == "'plantier'" %}        ${plan_tier}
      {% elsif breakdown_by._parameter_value == "'industry'" %}      ${industry}
      {% elsif breakdown_by._parameter_value == "'referral'" %} ${referral_source}
      {% elsif breakdown_by._parameter_value == "'country'" %}       ${country}
      {% elsif breakdown_by._parameter_value == "'status'" %} ${account_status}
      {% elsif breakdown_by._parameter_value == "'seats'" %}  ${seats_bucket}
      {% else %}                                                    ${plan_tier}
      {% endif %} ;;
  }

  parameter: date_granularity {
    type:          string
    label:         "Date Granularity"
    description:   "Switch the time axis between day, week, month, quarter, or year."
    default_value: "month"
    allowed_value: { label: "Day"     value: "day"     }
    allowed_value: { label: "Week"    value: "week"    }
    allowed_value: { label: "Month"   value: "month"   }
    allowed_value: { label: "Quarter" value: "quarter" }
    allowed_value: { label: "Year"    value: "year"    }
  }

  dimension: dynamic_signup_date {
    type:        string
    label:       "Signup Date (Dynamic)"
    description: "Signup date truncated to the chosen granularity."
    sql:
      {% if date_granularity._parameter_value == "'day'" %}
        CAST(SAFE_CAST(${TABLE}.signup_date AS DATE) AS STRING)
      {% elsif date_granularity._parameter_value == "'week'" %}
        CAST(DATE_TRUNC(SAFE_CAST(${TABLE}.signup_date AS DATE), WEEK) AS STRING)
      {% elsif date_granularity._parameter_value == "'month'" %}
        FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.signup_date AS DATE))
      {% elsif date_granularity._parameter_value == "'quarter'" %}
        CONCAT(CAST(EXTRACT(YEAR FROM SAFE_CAST(${TABLE}.signup_date AS DATE)) AS STRING), '-Q',
               CAST(EXTRACT(QUARTER FROM SAFE_CAST(${TABLE}.signup_date AS DATE)) AS STRING))
      {% elsif date_granularity._parameter_value == "'year'" %}
        CAST(EXTRACT(YEAR FROM SAFE_CAST(${TABLE}.signup_date AS DATE)) AS STRING)
      {% else %}
        FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.signup_date AS DATE))
      {% endif %} ;;
  }

  # -------------------------------------------------------
  # HTML DIMENSION (custom rendering)
  # -------------------------------------------------------

  dimension: churn_flag_html {
    type:        string
    sql:         ${TABLE}.churn_flag ;;
    label:       "Churn Status (Badge)"
    description: "Churn flag rendered as a color-coded HTML badge."
    html:
      {% if value == "true" or value == "1" %}
        <span style="background:#e74c3c;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">Churned</span>
      {% else %}
        <span style="background:#2ecc71;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">Active</span>
      {% endif %} ;;
  }

  dimension: plan_tier_html {
    type:        string
    sql:         ${TABLE}.plan_tier ;;
    label:       "Plan Tier (Badge)"
    description: "Plan tier rendered as a color-coded HTML badge."
    html:
      {% if value == "Enterprise" %}
        <span style="background:#8e44ad;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">{{ value }}</span>
      {% elsif value == "Pro" %}
        <span style="background:#2980b9;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">{{ value }}</span>
      {% else %}
        <span style="background:#7f8c8d;color:white;padding:2px 8px;border-radius:10px;font-size:11px;">{{ value }}</span>
      {% endif %} ;;
  }

  # -------------------------------------------------------
  # MISSING MEASURE TYPES: min, max, list, running_total
  # -------------------------------------------------------

  measure: earliest_signup {
    type:        min
    sql:         FORMAT_DATE('%Y-%m-%d', SAFE_CAST(${TABLE}.signup_date AS DATE)) ;;
    label:       "Earliest Signup Date"
    description: "The earliest account signup date in the result set."
  }

  measure: latest_signup {
    type:        max
    sql:         FORMAT_DATE('%Y-%m-%d', SAFE_CAST(${TABLE}.signup_date AS DATE)) ;;
    label:       "Latest Signup Date"
    description: "The most recent account signup date in the result set."
  }

  measure: industry_list {
    type:            list
    list_field:      industry
    label:           "Industries (List)"
    description:     "Comma-separated list of distinct industries in the result set."
    suggest_explore: accounts
    suggest_dimension: accounts.industry
  }

  # -------------------------------------------------------
  # REQUIRED FIELDS — force context dimensions
  # -------------------------------------------------------

  measure: count_with_required {
    type:           count
    label:          "Account Count (requires Plan Tier)"
    description:    "Account count — requires Plan Tier dimension to be in the query."
    required_fields: [plan_tier]
    hidden:         yes
  }

  # -------------------------------------------------------
  # ACTION — trigger a webhook from a data cell
  # -------------------------------------------------------

  measure: trigger_crm_sync {
    type:        count
    label:       "Trigger CRM Sync"
    description: "Demo data action — would trigger a CRM sync webhook in production."
    hidden:      yes
    action: {
      label: "Sync to CRM"
      url:   "https://example.com/crm-sync"
      form_param: {
        name:  "account_id"
        type:  string
        label: "Account ID"
      }
    }
  }

  # -------------------------------------------------------
  # FIELD GROUPING — group_label organises the field picker
  # -------------------------------------------------------

  dimension: group_identity_name {
    group_label:      "Identity"
    group_item_label: "Name"
    type:             string
    sql:              ${TABLE}.account_name ;;
    label:            "Account Name (Grouped)"
    hidden:           yes
  }

  dimension: group_identity_industry {
    group_label:      "Identity"
    group_item_label: "Industry"
    type:             string
    sql:              ${TABLE}.industry ;;
    label:            "Industry (Grouped)"
    hidden:           yes
  }

  dimension: group_identity_country {
    group_label:      "Identity"
    group_item_label: "Country"
    type:             string
    sql:              ${TABLE}.country ;;
    label:            "Country (Grouped)"
    hidden:           yes
  }

  dimension: group_plan_tier {
    group_label:      "Plan & Status"
    group_item_label: "Plan Tier"
    type:             string
    sql:              ${TABLE}.plan_tier ;;
    label:            "Plan Tier (Grouped)"
    hidden:           yes
  }

  dimension: group_status {
    group_label:      "Plan & Status"
    group_item_label: "Account Status"
    type:             string
    sql:              CASE
                        WHEN COALESCE(SAFE_CAST(${TABLE}.churn_flag AS BOOL), FALSE) THEN 'Churned'
                        WHEN COALESCE(SAFE_CAST(${TABLE}.is_trial AS BOOL), FALSE)   THEN 'Trial'
                        ELSE 'Active'
                      END ;;
    label:            "Account Status (Grouped)"
    hidden:           yes
  }

  # -------------------------------------------------------
  # NAMED SETS — reusable field lists for drill hierarchies
  # -------------------------------------------------------

  set: account_summary_fields {
    fields: [
      account_id,
      account_name,
      plan_tier,
      industry,
      country,
      account_status,
      seats
    ]
  }

  set: account_detail_fields {
    fields: [
      account_id,
      account_name,
      plan_tier,
      industry,
      country,
      signup_date,
      account_status,
      seats,
      referral_source,
      is_trial,
      churn_flag
    ]
  }

  # -------------------------------------------------------
  # MEASURES USING NAMED SETS FOR DRILL HIERARCHY
  # Level 1: click metric → account summary
  # Level 2: click account → account detail
  # -------------------------------------------------------

  measure: count_with_hierarchy_drill {
    type:        count
    label:       "Total Accounts (Hierarchy Drill)"
    description: "Click to drill: Plan Tier → Account Summary → Account Detail."
    drill_fields: [plan_tier, industry, count, churn_rate, account_summary_fields*]
  }

  measure: churn_rate_with_hierarchy_drill {
    type:        number
    sql:         SAFE_DIVIDE(${count_churned}, NULLIF(${count}, 0)) ;;
    label:       "Churn Rate (Hierarchy Drill)"
    description: "Click to drill: Industry → Account Summary → Account Detail."
    value_format_name: percent_2
    drill_fields: [industry, plan_tier, count_churned, count, account_summary_fields*]
  }
}
