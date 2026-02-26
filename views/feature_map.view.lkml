view: feature_map {
  # -------------------------------------------------------
  # INLINE DERIVED TABLE
  # This view embeds the feature_name → real name mapping
  # directly in LookML SQL. No additional BigQuery table needed.
  # To update names, edit the UNION ALL block below.
  # -------------------------------------------------------

  derived_table: {
    sql:
      SELECT 'feature_1'  AS feature_id, 'Kinetic Stream'       AS feature_display_name, 'Live developer activity and git event feed.'                             AS feature_description, 'Engineering Velocity'  AS feature_category
      UNION ALL SELECT 'feature_2',  'Flow Velocity',            'Average Cycle Time from start to finish.',                                                        'Engineering Velocity'
      UNION ALL SELECT 'feature_3',  'Bottleneck Beacon',        'Detection of tickets stuck in a specific status.',                                                'Engineering Velocity'
      UNION ALL SELECT 'feature_4',  'Push Cadence',             'Deployment frequency per day/week.',                                                              'Engineering Velocity'
      UNION ALL SELECT 'feature_5',  'Review Rhythm',            'Speed of the Pull Request review cycle.',                                                         'Engineering Velocity'
      UNION ALL SELECT 'feature_6',  'Latency Logic',            'Time work spends idle or waiting.',                                                               'Engineering Velocity'
      UNION ALL SELECT 'feature_7',  'Momentum Meter',           'Sprint velocity compared to historical rolling averages.',                                        'Engineering Velocity'
      UNION ALL SELECT 'feature_8',  'Throughput Threshold',     'Total volume of story points or PRs completed.',                                                  'Engineering Velocity'
      UNION ALL SELECT 'feature_9',  'Queue Depth',              'The size and age of the current backlog.',                                                        'Engineering Velocity'
      UNION ALL SELECT 'feature_10', 'Sprint Symmetry',          'Balance of planned work vs. walk-up unplanned work.',                                             'Engineering Velocity'
      UNION ALL SELECT 'feature_11', 'Resilience Rating',        'Change Failure Rate (Stability metric).',                                                         'Quality & Stability'
      UNION ALL SELECT 'feature_12', 'Recovery Radius',          'Mean Time to Recovery (MTTR) after an incident.',                                                 'Quality & Stability'
      UNION ALL SELECT 'feature_13', 'Churn Check',              'Percentage of code rewritten shortly after being merged.',                                        'Quality & Stability'
      UNION ALL SELECT 'feature_14', 'Technical Debt Dial',      'Allocation of effort toward bug fixes vs. features.',                                             'Quality & Stability'
      UNION ALL SELECT 'feature_15', 'Bug Horizon',              'Post-release defect density tracking.',                                                           'Quality & Stability'
      UNION ALL SELECT 'feature_16', 'Test Trench',              'Automated test coverage and reliability depth.',                                                  'Quality & Stability'
      UNION ALL SELECT 'feature_17', 'Stability Shield',         'Correlation between deployments and system uptime.',                                              'Quality & Stability'
      UNION ALL SELECT 'feature_18', 'Hotspot Heatmap',          'Identification of complex/fragile files with high change rates.',                                 'Quality & Stability'
      UNION ALL SELECT 'feature_19', 'Incident Echo',            'Frequency of recurring bugs in the same module.',                                                 'Quality & Stability'
      UNION ALL SELECT 'feature_20', 'Quality Quotient',         'A composite score of codebase health and linting standards.',                                     'Quality & Stability'
      UNION ALL SELECT 'feature_21', 'Vision Alignment',         'Roadmap progress vs. actual engineering hours.',                                                  'Strategic Planning'
      UNION ALL SELECT 'feature_22', 'Resource Radiogram',       'Distribution of engineers across various projects.',                                              'Strategic Planning'
      UNION ALL SELECT 'feature_23', 'Innovation Index',         'Hours spent on new feature development (R&D).',                                                   'Strategic Planning'
      UNION ALL SELECT 'feature_24', 'Support Sinkhole',         'Time lost to legacy maintenance and customer escalations.',                                       'Strategic Planning'
      UNION ALL SELECT 'feature_25', 'Growth Gradient',          'Rate of investment in new product categories.',                                                   'Strategic Planning'
      UNION ALL SELECT 'feature_26', 'Strategic Span',           'Measuring the breadth of focus across the entire org.',                                           'Strategic Planning'
      UNION ALL SELECT 'feature_27', 'Priority Pivot',           'Historical tracking of how often project goals change.',                                          'Strategic Planning'
      UNION ALL SELECT 'feature_28', 'ROI Radar',                'Cost per feature vs. actual business revenue impact.',                                            'Strategic Planning'
      UNION ALL SELECT 'feature_29', 'Feature Friction',         'Ratio of complexity to user adoption.',                                                           'Strategic Planning'
      UNION ALL SELECT 'feature_30', 'Portfolio Pulse',          'High-level executive summary of all business units.',                                             'Strategic Planning'
      UNION ALL SELECT 'feature_31', 'Maker Mode',               'Calculation of uninterrupted Deep Work hours.',                                                   'Team Health'
      UNION ALL SELECT 'feature_32', 'Collaboration Cross',      'Map of cross-team dependencies and blockers.',                                                    'Team Health'
      UNION ALL SELECT 'feature_33', 'Context Cost',             'The productivity tax of switching between too many tasks.',                                       'Team Health'
      UNION ALL SELECT 'feature_34', 'Knowledge Node',           'Bus Factor analysis — identifying single points of failure.',                                     'Team Health'
      UNION ALL SELECT 'feature_35', 'Burnout Buffer',           'Workload sustainability and over-capacity warnings.',                                             'Team Health'
      UNION ALL SELECT 'feature_36', 'Review Rapport',           'Qualitative analysis of peer review comments/feedback.',                                          'Team Health'
      UNION ALL SELECT 'feature_37', 'Team Tenure',              'Experience distribution and team maturity levels.',                                               'Team Health'
      UNION ALL SELECT 'feature_38', 'Onboarding Orbit',         'Time taken for new hires to reach full productivity.',                                            'Team Health'
      UNION ALL SELECT 'feature_39', 'Silo Smasher',             'Measuring integration and communication between sub-teams.',                                      'Team Health'
      UNION ALL SELECT 'feature_40', 'Cultural Core',            'Overall developer sentiment and health score.',                                                   'Team Health'
    ;;
  }

  # -------------------------------------------------------
  # JOIN KEY
  # -------------------------------------------------------

  dimension: feature_id {
    primary_key:  yes
    type:         string
    sql:          ${TABLE}.feature_id ;;
    label:        "Feature ID (Raw)"
    description:  "Internal feature ID (e.g. feature_1). Join key to feature_usage."
    hidden:       yes
  }

  # -------------------------------------------------------
  # DIMENSIONS
  # -------------------------------------------------------

  dimension: feature_display_name {
    type:        string
    sql:         ${TABLE}.feature_display_name ;;
    label:       "Feature Name"
    description: "Human-readable product feature name (e.g. 'Kinetic Stream')."
  }

  dimension: feature_description {
    type:        string
    sql:         ${TABLE}.feature_description ;;
    label:       "Feature Description"
    description: "What the feature measures or does."
  }

  dimension: feature_category {
    type:        string
    sql:         ${TABLE}.feature_category ;;
    label:       "Feature Category"
    description: "Product grouping: Engineering Velocity, Quality & Stability, Strategic Planning, or Team Health."
  }
}
