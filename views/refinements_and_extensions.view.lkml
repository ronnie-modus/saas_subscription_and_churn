########################################
# REFINEMENTS & EXTENSIONS
########################################
#
# EXTENSIONS:   A view/explore that inherits all fields from a base
#               and can add or override specific ones.
#               Syntax: `extends: [base_view]`
#
# REFINEMENTS:  Modify an existing view WITHOUT touching its file.
#               Syntax: `view: +existing_view_name { ... }`
#               Great for: adding fields to marketplace blocks,
#               layering team-specific logic on shared views.
#
# NOTE: Refinement files must include the base view files they refine.
########################################

# Include base views that this file refines or extends
include: "/views/accounts.view.lkml"
include: "/views/support_tickets.view.lkml"
include: "/views/subscriptions.view.lkml"


# ============================================================
# EXTENSION EXAMPLE
# ============================================================
# enterprise_accounts extends accounts, inheriting everything,
# then adds enterprise-specific dimensions and overrides the
# count measure to include a note about the subset.
#
# Use case: You have a base `accounts` view for all tiers, but
# want a specialized view for Enterprise reporting that adds
# custom metrics without duplicating the base view file.
# ============================================================

view: enterprise_accounts {
  extends: [accounts]     # inherits ALL dimensions, measures, parameters

  # Override the label of the inherited count measure
  measure: count {
    label:       "Enterprise Account Count"
    description: "Count of Enterprise-tier accounts only. Apply plan_tier = Enterprise filter."
  }

  # Add enterprise-specific dimensions
  dimension: is_strategic {
    type:        yesno
    sql:         SAFE_CAST(${TABLE}.seats AS INT64) >= 500 ;;
    label:       "Is Strategic Account"
    description: "Accounts with 500+ seats are considered strategic."
    group_label:  "Enterprise"
  }

  dimension: enterprise_segment {
    type: string
    sql:
      CASE
        WHEN SAFE_CAST(${TABLE}.seats AS INT64) >= 1000 THEN 'Tier 1 — Global'
        WHEN SAFE_CAST(${TABLE}.seats AS INT64) >= 500  THEN 'Tier 2 — Enterprise'
        WHEN SAFE_CAST(${TABLE}.seats AS INT64) >= 100  THEN 'Tier 3 — Mid-Market'
        ELSE 'SMB'
      END ;;
    label:       "Enterprise Segment"
    group_label:  "Enterprise"
  }

  # Add enterprise-specific measure
  measure: count_strategic {
    type:        count
    filters:     [is_strategic: "Yes"]
    label:       "Strategic Account Count"
    description: "Accounts with 500+ seats."
    group_label:  "Enterprise"
  }

  # This measure lives here (not in +accounts refinement) because the filter
  # must reference the view name as it appears in the explore — enterprise_accounts.
  measure: count_high_value {
    type:        count
    filters:     [enterprise_accounts.plan_tier: "Enterprise"]
    label:       "Enterprise Account Count"
    description: "Counts only Enterprise-tier accounts."
    group_label:  "Enterprise"
  }

  measure: avg_seats {
    type:              average
    sql:               SAFE_CAST(${TABLE}.seats AS FLOAT64) ;;
    label:             "Avg Seats (Enterprise)"
    value_format_name: decimal_0
    group_label:        "Enterprise"
  }
}


# ============================================================
# REFINEMENT EXAMPLES
# ============================================================
# Refinements modify existing views using the `+` prefix.
# They are additive — original file is unchanged.
# ============================================================

# --- Refinement 1: Add CRM link to accounts ---
# Adds a dimension that links to an external CRM using the
# @{crm_base_url} manifest constant.
# In production this would link to Salesforce, HubSpot, etc.

view: +accounts {
  dimension: crm_link {
    type:        string
    sql:         ${TABLE}.account_id ;;
    label:       "CRM Link"
    group_label: "Identity"
    description: "Opens this account in the external CRM."
    html: <a href="@{crm_base_url}/{{ value }}" target="_blank">Open in CRM ↗</a> ;;
  }

  # NOTE: A measure with a plan_tier filter cannot live in +accounts refinement
  # because the filter view name depends on which explore the measure is used in.
  # Plan-tier-filtered measures are defined directly in the enterprise_accounts extension below.
}


# --- Refinement 2: Add support ticket external link ---
# Adds a link to an external ticketing system using a manifest constant.

view: +support_tickets {
  dimension: external_ticket_link {
    type:        string
    sql:         ${TABLE}.ticket_id ;;
    label:       "External Ticket Link"
    group_label: "References"
    description: "Opens this ticket in the external support portal."
    html: <a href="@{support_base_url}/{{ value }}" target="_blank">View Ticket ↗</a> ;;
  }

  # Refined measure: tickets with slow resolution (> 48h)
  measure: count_slow_resolution {
    type:        count
    filters:     [support_tickets.resolution_time_hours: ">48"]
    label:       "Slow Resolution Tickets (>48h)"
    description: "Tickets that took more than 48 hours to resolve. Added via refinement."
    group_label: "Refined Measures"
  }
}


# --- Refinement 3: Add subscription health tier ---
# Adds a dimension to subscriptions that classifies health
# based on upgrade/downgrade history.

view: +subscriptions {
  dimension: health_tier {
    type:        string
    sql:
      CASE
        WHEN COALESCE(SAFE_CAST(${TABLE}.upgrade_flag   AS BOOL), FALSE) = TRUE  THEN 'Growing'
        WHEN COALESCE(SAFE_CAST(${TABLE}.downgrade_flag AS BOOL), FALSE) = TRUE  THEN 'At Risk'
        WHEN COALESCE(SAFE_CAST(${TABLE}.churn_flag     AS BOOL), FALSE) = TRUE  THEN 'Churned'
        ELSE 'Stable'
      END ;;
    label:       "Subscription Health"
    description: "Derived health classification. Added via refinement."
    group_label: "Refined Dimensions"
  }

  measure: count_growing {
    type:    count
    filters: [subscriptions.upgrade_flag: "Yes", subscriptions.downgrade_flag: "No", subscriptions.churn_flag: "No"]
    label:   "Growing Subscriptions"
    group_label: "Refined Measures"
  }

  measure: count_at_risk {
    type:    count
    filters: [subscriptions.downgrade_flag: "Yes", subscriptions.churn_flag: "No"]
    label:   "At Risk Subscriptions"
    group_label: "Refined Measures"
  }
}
