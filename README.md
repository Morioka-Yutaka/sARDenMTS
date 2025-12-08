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

## Over View

<details>
<summary>An example SAS Code of exporting ARS definitions to a folder as SAS datasets and simultaneously outputting them as a YAML file.</summary>

```sas
/*----------------------------------------------------------
  1) Initialize ARS library
----------------------------------------------------------*/
%let arslib  = ars;
%let arspath = xxxxxx;

%ars_init(lib=&arslib, libpath=&arspath);


/*----------------------------------------------------------
  2) Study-level metadata
----------------------------------------------------------*/
%ars_add_study(
  lib=&arslib,
  study_id=STUDY001,
  protocol_id=ABC-123,
  title=%nrstr(A Randomized, Double-blind Study of XYZ in Hypertension),
  version=v1.0,
  created_by=Yutaka Morioka
);


/*==========================================================
  OUTPUT 1: T14_1_2 Demographics table (descriptive)
==========================================================*/

/* 2-1) Output */
%ars_add_output(
  lib=&arslib,
  output_id=T14_1_2,
  label=Demographics and baseline characteristics,
  type=Table,
  purpose=Describe baseline demographics by treatment group,
  population=ITT,
  analysis_set=ADSL
);

/* 2-2) Dataset(s) */
%ars_add_dataset(
  lib=&arslib,
  output_id=T14_1_2,
  domains=ADSL,
  roles=analysis,
  filters=%nrbquote(SAFFL='Y' and ITTFL='Y')
);

/* 2-3) Variables */
%ars_add_variable(
  lib=&arslib,
  output_id=T14_1_2,
  vars=TRTA|AGE|SEX|RACE|BMI,
  labels=%nrbquote(Treatment group|Age (years)|Sex|Race, n (%)|BMI (kg/m^2)),
  types=char|num|char|char|num,
  roles=by|row|row|row|row,
  formats=$trt.|8.1|$sex.|$race.|8.1,
  derivations=%nrbquote(||||BMI = WEIGHT/(HEIGHT/100)**2)
);

/* 2-4) Statistics */
%ars_add_statistic(
  lib=&arslib,
  output_id=T14_1_2,
  stats=N|MEAN|SD|MEDIAN|MIN|MAX,
  labels=n|Mean|SD|Median|Min|Max,
  methods=COUNT|MEAN|STD|MEDIAN|MIN|MAX,
  orders=1|2|3|4|5|6,
  decimals=0|1|1|1|1|1
);

/* 2-5) Layout */
%ars_add_layout(
  lib=&arslib,
  output_id=T14_1_2,
  sections=header|body,
  row_orders=1|10,
  col_orders=.|.,
  headers=Treatment group (TRTA)|Demographics / baseline,
  split_vars=TRTA|
);

/* 2-6) Meta */
%ars_add_meta(
  lib=&arslib,
  output_id=T14_1_2,
  keys=analysis_method|missing_display,
  values=Descriptive statistics only|Display missing as 'NA'
);

/* 2-7) Analysis / Model / Estimand / Contrast / Multiplicity / Grouping */
%ars_add_model(
  lib=&arslib,
  analysis_id=A1,
  model_ids=M1,
  model_types=DESCRIPTIVE,
  methods=No inferential model; summary stats only
);

%ars_add_estimand(
  lib=&arslib,
  analysis_id=A1,
  estimand_ids=E1,
  populations=ITT,
  variables=Baseline demographics,
  intercurrents=Not applicable at baseline,
  summary_measures=Descriptive summaries by TRTA,
  analysis_methods=Descriptive
);

%ars_add_contrast(
  lib=&arslib,
  analysis_id=A1,
  contrast_ids=C1,
  types=NONE,
  labels=No treatment comparison for demographics
);

%ars_add_multiplicity(
  lib=&arslib,
  analysis_id=A1,
  family_ids=F1,
  endpoint_ids=DEMOG,
  methods=NONE,
  alphas=.,
  orders=.,
  condition_exprs=,
  notes_list=Multiplicity not applicable for descriptive table
);

%ars_add_group(
  lib=&arslib,
  analysis_id=A1,
  var_names=TRTA|TRTA,
  level_values=DRUG|PBO,
  level_labels=Drug|Placebo,
  level_orders=1|2,
  level_filters=|
);

%ars_add_analysis(
  lib=&arslib,
  output_id=T14_1_2,
  analysis_ids=A1,
  estimand_ids=E1,
  model_ids=M1,
  labels=%nrbquote(Demographics descriptive analysis),
  orders=1
);


/*==========================================================
  OUTPUT 2: T14_2_1 MMRM table (inferential)
==========================================================*/

/* 3-1) Output */
%ars_add_output(
  lib=&arslib,
  output_id=T14_2_1,
  label=Change from baseline in SBP over time (MMRM),
  type=Table,
  purpose=Estimate treatment difference in change from baseline across visits,
  population=ITT,
  analysis_set=ADVS
);

/* 3-2) Datasets */
%ars_add_dataset(
  lib=&arslib,
  output_id=T14_2_1,
  domains=ADSL|ADVS,
  roles=ref|analysis,
  filters=%nrbquote(SAFFL='Y' and ITTFL='Y'|PARAMCD='SYSBP' and ANL01FL='Y')
);

/* 3-3) Variables */
%ars_add_variable(
  lib=&arslib,
  output_id=T14_2_1,
  vars=TRTA|AVISITN|CHG|BASE|SEX,
  labels=%nrbquote(Treatment group|Visit (num)|Change from baseline|Baseline value|Sex),
  types=char|num|num|num|char,
  roles=by|row|stat|stat|by,
  formats=$trt.|8.|8.2|8.2|$sex.,
  derivations=%nrbquote(||||)
);

/* 3-4) Statistics (LS means / diff) */
%ars_add_statistic(
  lib=&arslib,
  output_id=T14_2_1,
  stats=LSMEAN|SE|DIFF|CI95,
  labels=LS Mean|SE|Difference vs PBO|95% CI,
  methods=LSMEAN|SE|TDIFF|CI95,
  orders=1|2|3|4,
  decimals=2|2|2|2
);

/* 3-5) Layout */
%ars_add_layout(
  lib=&arslib,
  output_id=T14_2_1,
  sections=header|body,
  row_orders=1|10,
  headers=%nrbquote(MMRM for CHG by visit)|Results,
  split_vars=TRTA AVISITN|
);

/* 3-6) Meta */
%ars_add_meta(
  lib=&arslib,
  output_id=T14_2_1,
  keys=analysis_method|alpha,
  values=MMRM with unstructured covariance|0.05
);

/* 3-7) Model / Estimand / Contrast / Multiplicity / Analysis / Grouping */
%ars_add_model(
  lib=&arslib,
  analysis_id=A2,
  model_ids=M2,
  model_types=MMRM,
  responses=CHG,
  links=IDENTITY,
  dists=NORMAL,
  fixed_effects_list=%nrbquote(TRTA AVISITN TRTA*AVISITN BASE SEX),
  cov_structures=UN,
  methods=REML
);

%ars_add_estimand(
  lib=&arslib,
  analysis_id=A2,
  estimand_ids=E2,
  populations=ITT,
  variables=Change from baseline in SYSBP,
  intercurrents=%nrbquote(Treatment discontinuation handled by on-treatment strategy),
  summary_measures=%nrbquote(LS mean difference at each post-baseline visit),
  analysis_methods=MMRM
);

%ars_add_contrast(
  lib=&arslib,
  analysis_id=A2,
  contrast_ids=C2,
  types=diff,
  numerators=DRUG,
  denominators=PBO,
  labels=Drug vs Placebo LS mean difference
);

%ars_add_multiplicity(
  lib=&arslib,
  analysis_id=A2,
  family_ids=F2,
  endpoint_ids=SYSBP,
  methods=NONE,
  alphas=0.05,
  orders=1,
  condition_exprs=,
  notes_list=Single primary endpoint; no adjustment
);

%ars_add_group(
  lib=&arslib,
  analysis_id=A2,
  var_names=TRTA|TRTA,
  level_values=DRUG|PBO,
  level_labels=Drug|Placebo,
  level_orders=1|2,
  level_filters=|
);

%ars_add_analysis(
  lib=&arslib,
  output_id=T14_2_1,
  analysis_ids=A2,
  estimand_ids=E2,
  model_ids=M2,
  labels=%nrbquote(MMRM efficacy analysis),
  orders=1
);


/*==========================================================
  OUTPUT 3: T14_3_2 AE summary by event (descriptive)
==========================================================*/

/* 4-1) Output */
%ars_add_output(
  lib=&arslib,
  output_id=T14_3_2,
  label=Summary of adverse events by preferred term,
  type=Table,
  purpose=Summarize TEAEs by system organ class and preferred term,
  population=SAF,
  analysis_set=ADAE
);

/* 4-2) Datasets */
%ars_add_dataset(
  lib=&arslib,
  output_id=T14_3_2,
  domains=ADSL|ADAE,
  roles=ref|analysis,
  filters=%nrbquote(SAFFL='Y'|TRTEMFL='Y')
);

/* 4-3) Variables */
%ars_add_variable(
  lib=&arslib,
  output_id=T14_3_2,
  vars=TRTA|AESOC|AEDECOD|AEREL|AESEV,
  labels=%nrbquote(Treatment group|System organ class|Preferred term|Relatedness|Severity),
  types=char|char|char|char|char,
  roles=by|row|row|row|row,
  formats=$trt.|$200.|$200.|$rel.|$sev.,
  derivations=%nrbquote(||||)
);

/* 4-4) Statistics */
%ars_add_statistic(
  lib=&arslib,
  output_id=T14_3_2,
  stats=N_SUBJ|PCT_SUBJ,
  labels=%nrbquote(n of subjects with event|percent of subjects),
  methods=COUNT_SUBJ|PCT_SUBJ,
  orders=1|2,
  decimals=0|1
);

/* 4-5) Layout */
%ars_add_layout(
  lib=&arslib,
  output_id=T14_3_2,
  sections=header|body,
  row_orders=1|10,
  headers=Treatment group (TRTA)|TEAEs by SOC/PT,
  split_vars=TRTA AESOC AEDECOD|
);

/* 4-6) Meta */
%ars_add_meta(
  lib=&arslib,
  output_id=T14_3_2,
  keys=analysis_method|counting_rule,
  values=%nrbquote(Subject incidence; any occurrence counts once)|%nrbquote(Count subjects, not events)
);

/* 4-7) Analysis / Model / Estimand / Contrast / Multiplicity / Group */
%ars_add_model(
  lib=&arslib,
  analysis_id=A3,
  model_ids=M3,
  model_types=DESCRIPTIVE,
  methods=Incidence summaries only
);

%ars_add_estimand(
  lib=&arslib,
  analysis_id=A3,
  estimand_ids=E3,
  populations=SAF,
  variables=TEAE incidence by SOC/PT,
  intercurrents=%nrbquote(Post-treatment events excluded by TRTEMFL='Y'),
  summary_measures=%nrbquote(n and % of subjects with >=1 TEAE),
  analysis_methods=Descriptive
);

%ars_add_contrast(
  lib=&arslib,
  analysis_id=A3,
  contrast_ids=C3,
  types=NONE,
  labels=No formal comparison for AE summary
);

%ars_add_multiplicity(
  lib=&arslib,
  analysis_id=A3,
  family_ids=F3,
  endpoint_ids=TEAE,
  methods=NONE,
  alphas=.,
  orders=.,
  condition_exprs=,
  notes_list=Multiplicity not applicable for descriptive AE table
);

%ars_add_group(
  lib=&arslib,
  analysis_id=A3,
  var_names=TRTA|TRTA,
  level_values=DRUG|PBO,
  level_labels=Drug|Placebo,
  level_orders=1|2,
  level_filters=|
);

%ars_add_analysis(
  lib=&arslib,
  output_id=T14_3_2,
  analysis_ids=A3,
  estimand_ids=E3,
  model_ids=M3,
  labels=%nrbquote(TEAE incidence descriptive analysis),
  orders=1
);


/*----------------------------------------------------------
  5) Export all ARS metadata into ARM-TS YAML
----------------------------------------------------------*/
%ars_write_yaml(
  lib=&arslib,
  outpath=&arspath,
  outfile=armts_example_3tables
);
```

</details>

~~~yaml
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
~~~


