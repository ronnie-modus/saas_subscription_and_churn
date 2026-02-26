# RavenStack SaaS Analytics — LookML Project

**Dataset credit:** River @ Rivalytics — https://rivalytics.medium.com
**BigQuery connection:** `bq_saas_subscription_and_churn`

---

## Project Structure

```
ravenstack_saas_analytics/
├── manifest.lkml                         # Project definition
├── ravenstack_saas.model.lkml            # Model, connection, and explores
├── views/
│   ├── accounts.view.lkml                # 500 customer accounts
│   ├── subscriptions.view.lkml           # 5,000 subscription records + MRR/ARR
│   ├── feature_usage.view.lkml           # 25,000 feature usage events
│   ├── support_tickets.view.lkml         # 2,000 support tickets
│   └── churn_events.view.lkml            # 600 churn events
└── dashboards/
    └── ravenstack_dashboards.dashboard.lookml  # 4 pre-built dashboards
```

---

## Explores

| Explore | Best For |
|---|---|
| **Accounts & Churn** | Customer health, churn analysis, cross-table joins |
| **Subscriptions & MRR** | Revenue analysis, plan mix, cohorts, billing frequency |
| **Feature Usage** | Product engagement, adoption, beta tracking, error rates |
| **Support Tickets** | SLA performance, CSAT, escalations, workload forecasting |

---

## Pre-Built Dashboards

| Dashboard | Description |
|---|---|
| **Churn Overview** | Account & MRR churn rates, churn reasons, pre-churn signals |
| **Revenue & MRR Overview** | MRR/ARR totals, plan mix, upgrade/downgrade trends |
| **Feature Adoption & Engagement** | Top features, beta adoption, error-prone features |
| **Support Health** | Ticket volume, SLAs, CSAT scores, escalation rates |

---

## Setup Instructions

### 1. Verify BigQuery Table Names
The views assume your dataset is named `saas_subscription_and_churn_analytics`. Check your actual BigQuery dataset name and update the `sql_table_name` in each view file if it differs.

For example, in `accounts.view.lkml`:
```lookml
sql_table_name: `YOUR_PROJECT.YOUR_DATASET.accounts` ;;
```

Replace `YOUR_PROJECT` with your GCP project ID and `YOUR_DATASET` with your BigQuery dataset name.

### 2. Upload to Looker
- In Looker, go to **Develop → Manage LookML Projects**
- Create a new project named `ravenstack_saas_analytics`
- Upload all files maintaining the folder structure above
- Click **Validate LookML** and resolve any errors
- Click **Deploy to Production**

### 3. Test Explores
- Start with the **Accounts & Churn** explore
- Try: `accounts.count`, `accounts.churn_rate`, `accounts.plan_tier`, `churn_events.reason_code`

---

## Key Metrics Available

### Revenue
- Total MRR / ARR (active subscriptions only)
- Churned MRR & MRR Churn Rate
- MRR by Plan Tier, Billing Frequency, Cohort
- Avg MRR per subscription, auto-renew rate

### Churn
- Account churn rate & subscription churn rate
- Churn by reason code, industry, plan tier, referral source
- Pre-churn signals (downgrade-to-churn, upgrade-to-churn)
- Reactivation rate, refund rate, refund amounts

### Feature Engagement
- Usage events, distinct features, usage duration
- Beta vs GA feature adoption rates
- Error rate by feature
- Top features by usage volume

### Support
- Avg, median, and P90 resolution times
- First response time (average and median)
- CSAT score (avg, distribution, by priority)
- Escalation rate, CSAT response rate

---

## Advanced Analysis Ideas

- **Churn prediction signals:** Join `feature_usage` + `support_tickets` + `churn_events` via `accounts` to find low-usage / high-ticket accounts at risk
- **Revenue cohort analysis:** Use `start_cohort_month` on `subscriptions` to track MRR retention by cohort
- **Feature-to-churn correlation:** Compare feature adoption rates between churned and retained accounts
- **Support load forecasting:** Use `submitted_week` on `support_tickets` to project future ticket volume
- **Beta feature impact:** Compare churn rates for accounts using beta vs. GA features only
