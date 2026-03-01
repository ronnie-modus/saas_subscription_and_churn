view: support_tickets {
  sql_table_name: `saas_subscription_and_churn_analytics_dataset_demo.ravenstack_support_tickets` ;;

  # -------------------------------------------------------
  # PRIMARY KEY
  # -------------------------------------------------------

  dimension: ticket_id {
    primary_key:  yes
    type:         string
    sql:          ${TABLE}.ticket_id ;;
    label:        "Ticket ID"
    description:  "Unique identifier for each support ticket."
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

  dimension_group: submitted {
    type:       time
    timeframes: [raw, time, date, week, month, quarter, year, hour_of_day, day_of_week]
    datatype:   datetime
    sql:        SAFE_CAST(${TABLE}.submitted_at AS DATETIME) ;;
    label:      "Submitted"
    description: "Date and time the ticket was opened."
  }

  dimension_group: closed {
    type:       time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype:   datetime
    sql:        SAFE_CAST(${TABLE}.closed_at AS DATETIME) ;;
    label:      "Closed"
    description: "Date and time the ticket was resolved."
  }

  dimension: is_open {
    type:        yesno
    sql:         ${TABLE}.closed_at IS NULL ;;
    label:       "Is Open?"
    description: "True if the ticket has not been closed."
  }

  # -------------------------------------------------------
  # DIMENSIONS — TICKET ATTRIBUTES
  # -------------------------------------------------------

  dimension: priority {
    type:        string
    sql:         ${TABLE}.priority ;;
    label:       "Priority"
    description: "Ticket priority: low, medium, high, urgent."
  }

  dimension: priority_rank {
    type:        number
    sql:         CASE ${TABLE}.priority
                   WHEN 'low'    THEN 1
                   WHEN 'medium' THEN 2
                   WHEN 'high'   THEN 3
                   WHEN 'urgent' THEN 4
                   ELSE 0
                 END ;;
    label:       "Priority Rank"
    description: "Numeric sort order for priority."
    hidden:      yes
  }

  dimension: escalation_flag {
    type:        yesno
    sql:         COALESCE(SAFE_CAST(${TABLE}.escalation_flag AS BOOL), FALSE) ;;
    label:       "Was Escalated?"
    description: "True if the ticket was escalated."
  }

  # -------------------------------------------------------
  # DIMENSIONS — SLA & PERFORMANCE
  # -------------------------------------------------------

  dimension: resolution_time_hours {
    type:        number
    sql:         SAFE_CAST(${TABLE}.resolution_time_hours AS FLOAT64) ;;
    label:       "Resolution Time (Hours)"
    description: "Total hours from open to close."
  }

  dimension: resolution_time_bucket {
    type:        string
    sql:         CASE
                   WHEN SAFE_CAST(${TABLE}.resolution_time_hours AS FLOAT64) < 1   THEN '< 1 hour'
                   WHEN SAFE_CAST(${TABLE}.resolution_time_hours AS FLOAT64) < 4   THEN '1-4 hours'
                   WHEN SAFE_CAST(${TABLE}.resolution_time_hours AS FLOAT64) < 24  THEN '4-24 hours'
                   WHEN SAFE_CAST(${TABLE}.resolution_time_hours AS FLOAT64) < 72  THEN '1-3 days'
                   WHEN SAFE_CAST(${TABLE}.resolution_time_hours AS FLOAT64) < 168 THEN '3-7 days'
                   ELSE '7+ days'
                 END ;;
    label:       "Resolution Time Bucket"
    description: "Bucketed resolution time for SLA reporting."
    order_by_field: resolution_time_hours
  }

  dimension: first_response_time_minutes {
    type:        number
    sql:         SAFE_CAST(${TABLE}.first_response_time_minutes AS INT64) ;;
    label:       "First Response Time (Mins)"
    description: "Minutes until the first agent response."
  }

  dimension: first_response_time_bucket {
    type:        string
    sql:         CASE
                   WHEN SAFE_CAST(${TABLE}.first_response_time_minutes AS INT64) < 5    THEN '< 5 mins'
                   WHEN SAFE_CAST(${TABLE}.first_response_time_minutes AS INT64) < 30   THEN '5-30 mins'
                   WHEN SAFE_CAST(${TABLE}.first_response_time_minutes AS INT64) < 60   THEN '30-60 mins'
                   WHEN SAFE_CAST(${TABLE}.first_response_time_minutes AS INT64) < 240  THEN '1-4 hours'
                   WHEN SAFE_CAST(${TABLE}.first_response_time_minutes AS INT64) < 1440 THEN '4-24 hours'
                   ELSE '24+ hours'
                 END ;;
    label:       "First Response Time Bucket"
    description: "Bucketed first response time for SLA analysis."
    order_by_field: first_response_time_minutes
  }

  # -------------------------------------------------------
  # DIMENSIONS — SATISFACTION
  # -------------------------------------------------------

  dimension: satisfaction_score {
    type:        number
    sql:         SAFE_CAST(${TABLE}.satisfaction_score AS INT64) ;;
    label:       "Satisfaction Score (1-5)"
    description: "Customer satisfaction rating 1-5. NULL if no response."
  }

  dimension: satisfaction_tier {
    type:        string
    sql:         CASE
                   WHEN SAFE_CAST(${TABLE}.satisfaction_score AS INT64) IS NULL THEN 'No Response'
                   WHEN SAFE_CAST(${TABLE}.satisfaction_score AS INT64) = 5     THEN '5 - Excellent'
                   WHEN SAFE_CAST(${TABLE}.satisfaction_score AS INT64) = 4     THEN '4 - Good'
                   WHEN SAFE_CAST(${TABLE}.satisfaction_score AS INT64) = 3     THEN '3 - Neutral'
                   WHEN SAFE_CAST(${TABLE}.satisfaction_score AS INT64) = 2     THEN '2 - Poor'
                   WHEN SAFE_CAST(${TABLE}.satisfaction_score AS INT64) = 1     THEN '1 - Very Poor'
                 END ;;
    label:       "Satisfaction Tier"
    description: "Labeled satisfaction score tier."
    order_by_field: satisfaction_score
  }

  dimension: is_satisfied {
    type:        yesno
    sql:         SAFE_CAST(${TABLE}.satisfaction_score AS INT64) >= 4 ;;
    label:       "Is Satisfied? (Score ≥ 4)"
    description: "True if satisfaction score is 4 or 5."
  }

  dimension: is_dissatisfied {
    type:        yesno
    sql:         SAFE_CAST(${TABLE}.satisfaction_score AS INT64) <= 2 ;;
    label:       "Is Dissatisfied? (Score ≤ 2)"
    description: "True if satisfaction score is 1 or 2."
  }

  # -------------------------------------------------------
  # MEASURES — VOLUME
  # -------------------------------------------------------

  measure: count {
    type:        count
    label:       "Total Tickets"
    description: "Total number of support tickets."
    drill_fields: [ticket_id, account_id, submitted_date, priority, resolution_time_hours, satisfaction_score, escalation_flag]
  }

  measure: count_open {
    type:        count
    label:       "Open Tickets"
    description: "Number of tickets not yet closed."
    filters:     [is_open: "Yes"]
  }

  measure: count_escalated {
    type:        count
    label:       "Escalated Tickets"
    description: "Number of tickets that were escalated."
    filters:     [escalation_flag: "Yes"]
    drill_fields: [ticket_id, account_id, submitted_date, priority, resolution_time_hours]
  }

  measure: count_urgent {
    type:        count
    label:       "Urgent Tickets"
    description: "Number of tickets with urgent priority."
    filters:     [priority: "urgent"]
  }

  measure: escalation_rate {
    type:        number
    sql:         SAFE_DIVIDE(
                   COUNTIF(COALESCE(SAFE_CAST(${TABLE}.escalation_flag AS BOOL), FALSE)),
                   NULLIF(COUNT(*), 0)
                 ) ;;
    label:       "Escalation Rate"
    description: "Percentage of tickets that were escalated."
    value_format_name: percent_2
  }

  # -------------------------------------------------------
  # MEASURES — RESOLUTION TIME
  # -------------------------------------------------------

  measure: average_resolution_time_hours {
    type:        average
    sql:         ${resolution_time_hours} ;;
    label:       "Avg Resolution Time (Hours)"
    description: "Average time from ticket open to close in hours."
    value_format_name: decimal_1
    drill_fields: [ticket_id, priority, resolution_time_hours, escalation_flag]
  }

  measure: median_resolution_time_hours {
    type:        percentile
    percentile:  50
    sql:         ${resolution_time_hours} ;;
    label:       "Median Resolution Time (Hours)"
    description: "Median resolution time (P50) in hours."
    value_format_name: decimal_1
  }

  measure: p90_resolution_time_hours {
    type:        percentile
    percentile:  90
    sql:         ${resolution_time_hours} ;;
    label:       "P90 Resolution Time (Hours)"
    description: "90th percentile resolution time in hours (SLA worst-case)."
    value_format_name: decimal_1
  }

  measure: average_first_response_time_minutes {
    type:        average
    sql:         ${first_response_time_minutes} ;;
    label:       "Avg First Response Time (Mins)"
    description: "Average time to first agent response in minutes."
    value_format_name: decimal_1
  }

  measure: median_first_response_time_minutes {
    type:        percentile
    percentile:  50
    sql:         ${first_response_time_minutes} ;;
    label:       "Median First Response Time (Mins)"
    description: "Median time to first agent response in minutes."
    value_format_name: decimal_1
  }

  # -------------------------------------------------------
  # MEASURES — SATISFACTION
  # -------------------------------------------------------

  measure: average_satisfaction_score {
    type:        average
    sql:         ${satisfaction_score} ;;
    label:       "Avg CSAT Score"
    description: "Average customer satisfaction score (1-5, excludes NULLs)."
    value_format_name: decimal_2
    drill_fields: [ticket_id, satisfaction_score, priority, escalation_flag, resolution_time_hours]
  }

  measure: csat_response_rate {
    type:        number
    sql:         SAFE_DIVIDE(
                   COUNTIF(${TABLE}.satisfaction_score IS NOT NULL),
                   NULLIF(COUNT(*), 0)
                 ) ;;
    label:       "CSAT Response Rate"
    description: "Percentage of closed tickets with a satisfaction score submitted."
    value_format_name: percent_2
  }

  measure: satisfied_ticket_rate {
    type:        number
    sql:         SAFE_DIVIDE(
                   COUNTIF(SAFE_CAST(${TABLE}.satisfaction_score AS INT64) >= 4),
                   NULLIF(COUNTIF(${TABLE}.satisfaction_score IS NOT NULL), 0)
                 ) ;;
    label:       "Satisfied Rate (Score ≥ 4)"
    description: "Of responded tickets, percentage scoring 4 or 5."
    value_format_name: percent_2
  }

  measure: dissatisfied_ticket_rate {
    type:        number
    sql:         SAFE_DIVIDE(
                   COUNTIF(SAFE_CAST(${TABLE}.satisfaction_score AS INT64) <= 2),
                   NULLIF(COUNTIF(${TABLE}.satisfaction_score IS NOT NULL), 0)
                 ) ;;
    label:       "Dissatisfied Rate (Score ≤ 2)"
    description: "Of responded tickets, percentage scoring 1 or 2."
    value_format_name: percent_2
  }

  measure: tickets_per_account {
    type:        number
    sql:         SAFE_DIVIDE(${count}, NULLIF(COUNT(DISTINCT ${account_id}), 0)) ;;
    label:       "Tickets per Account"
    description: "Average number of tickets submitted per account."
    value_format_name: decimal_1
  }

  # -------------------------------------------------------
  # DYNAMIC PARAMETERS
  # -------------------------------------------------------

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

  dimension: dynamic_submitted_date {
    type:        string
    label:       "Submitted Date (Dynamic)"
    description: "Ticket submitted date truncated to the chosen granularity."
    sql:
      {% if date_granularity._parameter_value == "'day'" %}
        CAST(SAFE_CAST(${TABLE}.submitted_at AS DATE) AS STRING)
      {% elsif date_granularity._parameter_value == "'week'" %}
        CAST(DATE_TRUNC(SAFE_CAST(${TABLE}.submitted_at AS DATE), WEEK) AS STRING)
      {% elsif date_granularity._parameter_value == "'month'" %}
        FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.submitted_at AS DATE))
      {% elsif date_granularity._parameter_value == "'quarter'" %}
        CONCAT(CAST(EXTRACT(YEAR FROM SAFE_CAST(${TABLE}.submitted_at AS DATE)) AS STRING), '-Q',
               CAST(EXTRACT(QUARTER FROM SAFE_CAST(${TABLE}.submitted_at AS DATE)) AS STRING))
      {% elsif date_granularity._parameter_value == "'year'" %}
        CAST(EXTRACT(YEAR FROM SAFE_CAST(${TABLE}.submitted_at AS DATE)) AS STRING)
      {% else %}
        FORMAT_DATE('%Y-%m', SAFE_CAST(${TABLE}.submitted_at AS DATE))
      {% endif %} ;;
  }
}
