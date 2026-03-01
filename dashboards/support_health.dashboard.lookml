- dashboard: support_health
  title: "Support Health"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Ticket volume, resolution SLAs, CSAT scores, and escalation trends."

  filters:
    - name: submitted_date
      title: "Submitted Date"
      type: date_filter
      default_value: "90 days"
      allow_multiple_values: true
      required: false
      ui_config:
        type: relative_timeframes
        display: inline

    - name: priority
      title: "Priority"
      type: field_filter
      default_value: ""
      allow_multiple_values: true
      required: false
      ui_config:
        type: checkboxes
        display: popover
      explore: support_tickets
      field: support_tickets.priority

  elements:
    - title: "Total Tickets"
      name: total_tickets
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.count]
      row: 0
      col: 0
      width: 4
      height: 3

    - title: "Escalation Rate"
      name: escalation_rate
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.escalation_rate]
      row: 0
      col: 4
      width: 4
      height: 3

    - title: "Avg CSAT Score"
      name: avg_csat
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_satisfaction_score]
      row: 0
      col: 8
      width: 4
      height: 3

    - title: "Avg Resolution Time (hrs)"
      name: avg_resolution
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.average_resolution_time_hours]
      row: 0
      col: 12
      width: 4
      height: 3

    - title: "P90 Resolution Time (hrs)"
      name: p90_resolution
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.p90_resolution_time_hours]
      row: 0
      col: 16
      width: 4
      height: 3

    - title: "CSAT Response Rate"
      name: csat_response
      model: ravenstack_saas
      explore: support_tickets
      type: single_value
      fields: [support_tickets.csat_response_rate]
      row: 0
      col: 20
      width: 4
      height: 3

    - title: "Tickets by Priority Over Time"
      name: tickets_over_time
      model: ravenstack_saas
      explore: support_tickets
      type: looker_area
      fields: [support_tickets.submitted_week, support_tickets.priority, support_tickets.count]
      pivots: [support_tickets.priority]
      sorts: [support_tickets.submitted_week asc]
      limit: 52
      row: 3
      col: 0
      width: 14
      height: 8

    - title: "CSAT Score Distribution"
      name: csat_distribution
      model: ravenstack_saas
      explore: support_tickets
      type: looker_column
      fields: [support_tickets.satisfaction_tier, support_tickets.count]
      sorts: [support_tickets.satisfaction_score asc]
      limit: 6
      row: 3
      col: 14
      width: 10
      height: 8

    - title: "Resolution Time Distribution"
      name: resolution_dist
      model: ravenstack_saas
      explore: support_tickets
      type: looker_column
      fields: [support_tickets.resolution_time_bucket, support_tickets.count]
      sorts: [support_tickets.resolution_time_hours asc]
      limit: 10
      row: 11
      col: 0
      width: 12
      height: 7

    - title: "CSAT by Priority"
      name: csat_by_priority
      model: ravenstack_saas
      explore: support_tickets
      type: looker_column
      fields: [support_tickets.priority, support_tickets.average_satisfaction_score, support_tickets.escalation_rate]
      sorts: [support_tickets.priority_rank asc]
      limit: 10
      row: 11
      col: 12
      width: 12
      height: 7
