# sARDenMTS

A SAS-native authoring framework for CDISC Analysis Results Metadata Technical Specification (ARM-TS).   
Users define ARS-compliant study, analysis, and output metadata via simple SAS macros that append to normalized metadata tables.   
The package validates key constraints and exports a hierarchical YAML ARM-TS file using yaml_writer.  
Designed to integrate seamlessly with sARDen (ARD builder), with the longer-term goal of fully metadata-driven, reproducible TLF production. This integration layer is currently under active development.

<img width="360" height="360" alt="sARDenMTS_small" src="https://github.com/user-attachments/assets/64c6b904-20aa-41d3-9780-f0afd219e187" />

> [!WARNING]
> This package uses the yaml_writer package to output ARS data in YAML format, so it is listed as a dependency.
If that package is not installed, %ars_write_yaml() will not work.
> [yaml_writer](https://github.com/PharmaForest/yaml_writer)


<details>

<summary>Tips for collapsed sections</summary>


study:
  study_id: STUDY001
  protocol_id: ABC-123
  title: A Randomized, Double-blind Study of XYZ in Hypertension
  version: v1.0
  created_by: Yutaka Morioka
  created_on: 2025-12-08

analyses:
  - analysis_id: A1
    analysis_label: Demographics descriptive analysis
    analysis_order: 1

    estimand:
      - estimand_id: E1
        population: ITT
        intercurrent: Not applicable at baseline
        summary_measure: Descriptive summaries by TRTA
        analysis_method: Descriptive

    model:
      - model_id: M1
        model_type: DESCRIPTIVE
        response: null
        link: null
        dist: null
        fixed_effects: null
        covariates: null
        random_effects: null
        repeated: null
        cov_structure: null
        method: No inferential model; summary stats only

    contrast:
      - contrast_id: C1
        type: NONE
        numerator_group: null
        denominator_group: null
        contrast_expr: null
        label: No treatment comparison for demographics

    multiplicity:
      - family_id: F1
        endpoint_id: DEMOG
        method: NONE
        alpha: .
        order: .
        condition_expr: null
        notes: Multiplicity not applicable for descriptive table

    grouping_levels:
      - var_name: TRTA
        level_value: DRUG
        level_label: Drug
        level_order: 1
      - var_name: TRTA
        level_value: PBO
        level_label: Placebo
        level_order: 2

  - analysis_id: A2
    analysis_label: MMRM efficacy analysis
    analysis_order: 1

    estimand:
      - estimand_id: E2
        population: ITT
        intercurrent: Treatment discontinuation handled by on-treatment strategy
        summary_measure: LS mean difference at each post-baseline visit
        analysis_method: MMRM

    model:
      - model_id: M2
        model_type: MMRM
        response: CHG
        link: IDENTITY
        dist: NORMAL
        fixed_effects: TRTA AVISITN TRTA*AVISITN BASE SEX
        covariates: null
        random_effects: null
        repeated: null
        cov_structure: UN
        method: REML

    contrast:
      - contrast_id: C2
        type: diff
        numerator_group: DRUG
        denominator_group: PBO
        contrast_expr: null
        label: Drug vs Placebo LS mean difference

    multiplicity:
      - family_id: F2
        endpoint_id: SYSBP
        method: NONE
        alpha: 0.05
        order: 1
        condition_expr: null
        notes: Single primary endpoint; no adjustment

    grouping_levels:
      - var_name: TRTA
        level_value: DRUG
        level_label: Drug
        level_order: 1
      - var_name: TRTA
        level_value: PBO
        level_label: Placebo
        level_order: 2

  - analysis_id: A3
    analysis_label: TEAE incidence descriptive analysis
    analysis_order: 1

    estimand:
      - estimand_id: E3
        population: SAF
        intercurrent: Post-treatment events excluded by TRTEMFL='Y'
        summary_measure: n and % of subjects with >=1 TEAE
        analysis_method: Descriptive

    model:
      - model_id: M3
        model_type: DESCRIPTIVE
        response: null
        link: null
        dist: null
        fixed_effects: null
        covariates: null
        random_effects: null
        repeated: null
        cov_structure: null
        method: Incidence summaries only

    contrast:
      - contrast_id: C3
        type: NONE
        numerator_group: null
        denominator_group: null
        contrast_expr: null
        label: No formal comparison for AE summary

    multiplicity:
      - family_id: F3
        endpoint_id: TEAE
        method: NONE
        alpha: .
        order: .
        condition_expr: null
        notes: Multiplicity not applicable for descriptive AE table

    grouping_levels:
      - var_name: TRTA
        level_value: DRUG
        level_label: Drug
        level_order: 1
      - var_name: TRTA
        level_value: PBO
        level_label: Placebo
        level_order: 2

outputs:
  - output_id: T14_1_2
    label: Demographics and baseline characteristics
    type: Table
    purpose: Describe baseline demographics by treatment group
    population: ITT
    analysis_set: ADSL

    analysis_refs: ["A1"]

    datasets:
      - domain: ADSL
        role: analysis
        filter_expr: SAFFL='Y' and ITTFL='Y'

    variables:
      by:
          - var_name: TRTA
            label: Treatment group
            type: char
            format: $trt.
            derivation: null
      row:
          - var_name: AGE
            label: Age (years)
            type: num
            format: 8.1
            derivation: null
          - var_name: SEX
            label: Sex
            type: char
            format: $sex.
            derivation: null
          - var_name: RACE
            label: Race, n (%)
            type: char
            format: $race.
            derivation: null
          - var_name: BMI
            label: BMI (kg/m^2)
            type: num
            format: 8.1
            derivation: BMI = WEIGHT/(HEIGHT/100)**2
      col:

    statistics:
      - stat_name: N
        label: n
        method: COUNT
        order: 1
        decimal: 0
        footnote_id: null
      - stat_name: MEAN
        label: Mean
        method: MEAN
        order: 2
        decimal: 1
        footnote_id: null
      - stat_name: SD
        label: SD
        method: STD
        order: 3
        decimal: 1
        footnote_id: null
      - stat_name: MEDIAN
        label: Median
        method: MEDIAN
        order: 4
        decimal: 1
        footnote_id: null
      - stat_name: MIN
        label: Min
        method: MIN
        order: 5
        decimal: 1
        footnote_id: null
      - stat_name: MAX
        label: Max
        method: MAX
        order: 6
        decimal: 1
        footnote_id: null

    meta:
      analysis_method: Descriptive statistics only
      missing_display: Display missing as 'NA'

  - output_id: T14_2_1
    label: Change from baseline in SBP over time (MMRM)
    type: Table
    purpose: Estimate treatment difference in change from baseline across visits
    population: ITT
    analysis_set: ADVS

    analysis_refs: ["A2"]

    datasets:
      - domain: ADSL
        role: ref
        filter_expr: SAFFL='Y' and ITTFL='Y'
      - domain: ADVS
        role: analysis
        filter_expr: PARAMCD='SYSBP' and ANL01FL='Y'

    variables:
      by:
          - var_name: TRTA
            label: Treatment group
            type: char
            format: $trt.
            derivation: null
          - var_name: SEX
            label: Sex
            type: char
            format: $sex.
            derivation: null
      row:
          - var_name: AVISITN
            label: Visit (num)
            type: num
            format: 8.
            derivation: null
      col:

    statistics:
      - stat_name: LSMEAN
        label: LS Mean
        method: LSMEAN
        order: 1
        decimal: 2
        footnote_id: null
      - stat_name: SE
        label: SE
        method: SE
        order: 2
        decimal: 2
        footnote_id: null
      - stat_name: DIFF
        label: Difference vs PBO
        method: TDIFF
        order: 3
        decimal: 2
        footnote_id: null
      - stat_name: CI95
        label: 95% CI
        method: CI95
        order: 4
        decimal: 2
        footnote_id: null

    meta:
      analysis_method: MMRM with unstructured covariance
      alpha: 0.05

  - output_id: T14_3_2
    label: Summary of adverse events by preferred term
    type: Table
    purpose: Summarize TEAEs by system organ class and preferred term
    population: SAF
    analysis_set: ADAE

    analysis_refs: ["A3"]

    datasets:
      - domain: ADSL
        role: ref
        filter_expr: SAFFL='Y'
      - domain: ADAE
        role: analysis
        filter_expr: TRTEMFL='Y'

    variables:
      by:
          - var_name: TRTA
            label: Treatment group
            type: char
            format: $trt.
            derivation: null
      row:
          - var_name: AESOC
            label: System organ class
            type: char
            format: $200.
            derivation: null
          - var_name: AEDECOD
            label: Preferred term
            type: char
            format: $200.
            derivation: null
          - var_name: AEREL
            label: Relatedness
            type: char
            format: $rel.
            derivation: null
          - var_name: AESEV
            label: Severity
            type: char
            format: $sev.
            derivation: null
      col:

    statistics:
      - stat_name: N_SUBJ
        label: n of subjects with event
        method: COUNT_SUBJ
        order: 1
        decimal: 0
        footnote_id: null
      - stat_name: PCT_SUBJ
        label: percent of subjects
        method: PCT_SUBJ
        order: 2
        decimal: 1
        footnote_id: null

    meta:
      analysis_method: Subject incidence; any occurrence counts once
      counting_rule: Count subjects, not events
</details>
