project_name: "ravenstack_saas_analytics"

# Dataset credit: River @ Rivalytics
# https://rivalytics.medium.com

########################################
# MANIFEST CONSTANTS
########################################
# Constants are defined here and referenced anywhere in the project
# using the @{constant_name} syntax in sql:, html:, labels, and urls.
#
# Benefits:
#   - Single source of truth for environment-specific values
#   - No hardcoded strings scattered across view files
#   - Easy to swap datasets between dev / staging / prod
########################################

constant: project_id {
  value: "saas_subscription_and_churn_analytics_dataset_demo"
  export: override_optional   # other projects can override this value
}

constant: dataset {
  value: "saas_subscription_and_churn_analytics_dataset_demo"
  export: override_optional
}

constant: table_prefix {
  value: "ravenstack_"
  export: override_optional
}

constant: company_name {
  value: "RavenStack"
  export: none
}

constant: crm_base_url {
  value: "https://crm.ravenstack.io/accounts"
  export: none
}

constant: support_base_url {
  value: "https://support.ravenstack.io/tickets"
  export: none
}
