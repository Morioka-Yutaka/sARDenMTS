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

<img width="504" height="254" alt="image" src="https://github.com/user-attachments/assets/b52a94da-c392-4c57-922c-e4f72bb6407f" />

<details>
<summary>Generated YAML file</summary>

```yaml
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
```

</details>

## `%ars_init()` macro <a name="arsinit-macro-14"></a> ######
#### Purpose    : 
               Initialize the ARS metadata environment.  
               This macro assigns the ARS library, defines internal  
               utility macros for validation and error handling, and  
               creates empty ARS metadata tables if they do not exist.  
####  Usage      : 
              　Call once at the start of a session or inside any ARS  
               authoring macro to guarantee required tables exist.  

#### Parameters :  
~~~text
    lib=      LIBREF for ARS metadata tables.  
              Default: ars.  
    libpath=  Physical path for the ARS library.  
              The directory is created if it does not exist.  
~~~

####  Tables Created if Missing :  
~~~text
    study        Study-level metadata.  
    output       Output/display definitions.  
    dataset      Input/analysis dataset references.  
    variable     Display variable roles and derivations.  
    statistic    Displayed statistics and formatting.  
    layout       Layout/sectioning rules.  
    meta_kv      Free key–value metadata.
    analysis     Bridge linking outputs to analyses and core analysis info.  
    model        Analysis model specifications.  
    estimand     Estimand definitions per analysis.  
    contrast     Contrast definitions per analysis.  
    multiplicity Multiplicity adjustment definitions.  
    group        Grouping level definitions (ordering/labels).  
~~~

####  Usage Example :  
~~~sas
    Set a permanent ARS library and initialize all metadata tables.  
      %ars_init(  
        lib=ars,  
        libpath=F:\project\metadata\ars  
      );  
~~~
####  Notes      :  
    This macro is idempotent. Repeated calls re-assign the library  
    and only create tables that are absent.

  
---
 
## `%ars_write_yaml()` macro <a name="arswriteyaml-macro-15"></a> ######
#### Purpose    : 
               Export ARS metadata tables into a hierarchical ARM-TS YAML file.  
               The macro gathers unique analyses and outputs, builds the  
               analysis–output relationship list, and emits YAML using  
               yaml_writer utilities.  

####  Usage      : 
              　Run after populating ars.* metadata tables (study, analysis,  
               estimand, model, contrast, multiplicity, group, output,  
               dataset, variable, statistic, meta_kv).  

####  Parameters :  
~~~sas
    lib=      ARS library containing normalized metadata tables  
              (default: ars).  
    outpath=  Output folder for the YAML file (required).  
    outfile=  Output YAML file name without extension (required).  
~~~

#### Required Supporting Package (Macros) :  
  [yaml_writer]
  https://github.com/PharmaForest/yaml_writer
    %yaml_start(outpath=, file=)  
    %yaml_end()  
    %dataset_export(ds=, wh=, cat=, varlist=, indent=, keyvar=)  

#### Output     : 
                Creates &outpath./&outfile..yaml and intermediate WORK tables.  

 #### Notes      :  
    - analyses are emitted as a YAML sequence under "analyses".  
    - outputs are emitted as a YAML sequence under "outputs".  
    - analysis_refs per output are derived from ars.analysis.  

####  Usage Example :  
~~~sas
    %ars_write_yaml(  
      lib=ars,  
      outpath=F:\project\metadata,  
      outfile=armts_metadata  
    );
~~~
  
---
## `%ars_add_study()` macro <a name="arsaddstudy-macro-12"></a> ######
#### Purpose    : 
               Register study-level metadata into ars.study.  
               Appends one observation describing the study.  

####  Usage      :
                Call once per study to seed ARM-TS study section.  

####  Parameters :  
~~~sas
    lib=         ARS library (default: ars).  
    study_id=    Study identifier (required).  
    protocol_id= Protocol identifier (required).  
    title=       Study title (required).  
    version=     Metadata version label (required).  
    created_by=  Author/creator name (optional).  
    created_on=  Creation date (default: today in YYYY-MM-DD).  
~~~

#### Output     : Adds one row to &lib..study.  

####  Usage Example :  
~~~sas
    %ars_add_study(  
      lib=ars,  
      study_id=STUDY001,  
      protocol_id=ABC-123,  
      title=%nrstr(A Randomized, Double-blind Study of XYZ in Hypertension),  
      version=v1.0,  
      created_by=Yutaka Morioka  
    );
~~~
  
---

## `%ars_add_dataset()` macro <a name="arsadddataset-macro-3"></a> ######
#### Purpose    : 
               Register dataset usage for an output into ars.dataset.  
               Supports multiple rows per call via pipe-delimited inputs.  

####  Usage      : 
                Call once per output to define all contributing domains.  

####  Parameters :  
~~~sas
    lib=        ARS library (default: ars).  
    output_id=  Output identifier to link datasets (required).  
    domains=    List of dataset/domain names, '|' delimited (required).  
    roles=      List of roles per domain, '|' delimited (required).  
               Allowed: analysis|input|ref.  
    filters=    Optional list of WHERE/filter expressions per domain,  
               '|' delimited. If provided, count must match domains=.  
~~~

####  Output     : 
                 Adds one row per domain to &lib..dataset.  

####  Notes      : 
                 domains= and roles= counts must match; filters= optional.  

####  Usage Example : 
~~~sas
    %ars_add_dataset(  
      output_id=T14_1_1,  
      domains=ADSL|ADVS|ADLB,  
      roles=analysis|input|input,  
      filters=%nrbquote(SAFFL='Y'|PARAMCD='SYSBP'|PARAMCD='GLUC')  
    );
~~~
  
---

## `%ars_add_variable()` macro <a name="arsaddvariable-macro-13"></a> ######
#### Purpose    :
                Register display variables for an output into ars.variable.  
               Supports multiple rows per call via pipe-delimited inputs.  

####  Usage      :
                Call once per output to define BY/ROW/COL/STAT variables.  

####  Parameters :  
~~~sas
    lib=         ARS library (default: ars).  
    output_id=   Output identifier to link variables (required).  
    vars=        Variable names, '|' delimited (required).  
    labels=      Variable labels, '|' delimited (required).  
    types=       num|char per variable, '|' delimited (required).  
    roles=       by|row|col|stat per variable, '|' delimited (required).  
    formats=     Optional SAS formats per variable, '|' delimited.  
    derivations= Optional derivation text per variable, '|' delimited.  
~~~

####  Output     : 
                 Adds one row per variable to &lib..variable.  

####  Notes      : 
                 Counts across vars/labels/types/roles must match.  

####  Usage Example :  
~~~sas
    %ars_add_variable(  
      output_id=T14_1_1,  
      vars=TRTA|SEX|AGE,  
      labels=Treatment|Sex|Age (years),  
      types=char|char|num,  
      roles=by|by|row,  
      formats=$trt.|$sex.|8.1  
    );
~~~
  
---

## `%ars_add_statistic()` macro <a name="arsaddstatistic-macro-11"></a> ######

#### Purpose    :
                Register statistics to be displayed for an output  
                into ars.statistic. Supports multiple rows per call.  
####  Usage      : 
                 Call once per output to define all required stats.  
####  Parameters :  
~~~sas
    lib=          ARS library (default: ars).  
    output_id=    Output identifier (required).  
    stats=        Statistic names, '|' delimited (required).  
    labels=       Display labels, '|' delimited (required).  
    methods=      Computation methods, '|' delimited (required).  
    orders=       Display order, '|' delimited (required).  
    decimals=     Decimal places, '|' delimited (required).  
    footnote_ids= Optional footnote IDs per statistic, '|' delimited.
~~~
####  Output     : 
                 Adds one row per statistic to &lib..statistic.  
####  Notes      : 
                  All provided lists must be the same length.  
####  Usage Example :  
~~~sas
    %ars_add_statistic(  
      output_id=T14_1_1,  
      stats=N|MEAN|SD,  
      labels=n|Mean|SD,  
      methods=COUNT|MEAN|STD,  
      orders=1|2|3,  
      decimals=0|1|1  
    );
~~~
  
---

## `%ars_add_layout()` macro <a name="arsaddlayout-macro-6"></a> ######
#### Purpose    :
                Register layout/section rules for an output  
                into ars.layout. Supports multiple rows per call.  

####  Usage      : 
                 Call once per output to define header/body sections,  
                 ordering, and split variables.  

####  Parameters : 
~~~sas
    lib=        ARS library (default: ars).  
    output_id=  Output identifier (required).  
    sections=   Section names, '|' delimited (required).  
    row_orders= Row ordering per section, '|' delimited (required).  
    col_orders= Optional column ordering, '|' delimited.  
    headers=    Optional header expressions per section, '|' delimited.  
    split_vars= Optional split variable list per section, '|' delimited.  
~~~

####  Output     : 
                  Adds one row per section to &lib..layout.  

####  Notes      :
                  sections= and row_orders= counts must match.  

####  Usage Example :  
~~~sas
    %ars_add_layout(  
      output_id=T14_1_1,  
      sections=header|body_continuous,  
      row_orders=1|10,  
      headers=Treatment by Sex|Continuous variables,  
      split_vars=TRTA SEX|  
    );
~~~
  
---

## `%ars_add_meta()` macro <a name="arsaddmeta-macro-7"></a> ######
#### Purpose    : 
               Add arbitrary key–value metadata for an output  
               into ars.meta_kv. Supports multiple rows per call.  

####  Usage      : 
                Use for free-form metadata not captured elsewhere.  

####  Parameters :  
~~~sas
    lib=        ARS library (default: ars).  
    output_id=  Output identifier (required).  
    keys=       Metadata keys, '|' delimited (required).  
    values=     Metadata values, '|' delimited (required).  
~~~

####  Output     : 
                 Adds one row per key to &lib..meta_kv.  

####  Notes      : 
                 keys= and values= counts must match.  

####  Usage Example :  
~~~sas
    %ars_add_meta(  
      output_id=T14_1_1,  
      keys=analysis_method|missing_display,  
      values=Descriptive only|Display missing as 'NA'  
    );
~~~
  
---

## `%ars_add_model()` macro <a name="arsaddmodel-macro-8"></a> ######
#### Purpose    : 
                Register model specifications for an analysis  
                into ars.model. Supports multiple rows per call.  
####  Usage     :
                Call once per analysis_id to define one or more models.  
                For descriptive analyses, use model_type=DESCRIPTIVE.  

####  Parameters :  
~~~sas
    lib=                ARS library (default: ars).  
    analysis_id=        Analysis identifier (required).  
    model_ids=          Model IDs, '|' delimited (required).  
    model_types=        Model types, '|' delimited (required).  
    responses=          Response variables, '|' delimited (optional).  
    links=              Link functions, '|' delimited (optional).  
    dists=              Distributions, '|' delimited (optional).  
    fixed_effects_list= Fixed effects, '|' delimited (optional).  
    covariates_list=    Covariates, '|' delimited (optional).  
    random_effects_list=Random effects, '|' delimited (optional).  
    repeated_list=      Repeated measures specs, '|' delimited (optional).  
    cov_structures=     Covariance structures, '|' delimited (optional).  
    methods=            Estimation methods, '|' delimited (optional).  
~~~

####  Output     : 
                 Adds one row per model to &lib..model.  

####  Notes      : 
                 model_ids= and model_types= counts must match.  

####  Usage Example :
~~~sas
    %ars_add_model(  
      analysis_id=A0,  
      model_ids=M0,  
      model_types=DESCRIPTIVE,  
      methods=No inferential model  
    );
~~~
  
---

## `%ars_add_estimand()` macro <a name="arsaddestimand-macro-4"></a> ######
#### Purpose    : 
                Register estimand definitions for an analysis  
                into ars.estimand. Supports multiple rows per call.  

####  Usage     : 
                Call once per analysis_id to define one or more estimands.  

####  Parameters :  
~~~sas
    lib=              ARS library (default: ars).  
    analysis_id=      Analysis identifier (required).  
    estimand_ids=     Estimand IDs, '|' delimited (required).  
    populations=      Populations per estimand, '|' delimited (required).  
    variables=        Target variables/endpoints, '|' delimited (required).  
    intercurrents=    Intercurrent event strategies, '|' delimited (optional).  
    summary_measures= Summary measures, '|' delimited (required).  
    analysis_methods= Analysis methods per estimand, '|' delimited (optional).  
~~~

####  Output     : 
                  Adds one row per estimand to &lib..estimand.  

####  Notes      :
                  Required lists must be the same length.  

####  Usage Example :  
~~~sas
    %ars_add_estimand(  
      analysis_id=A0,  
      estimand_ids=E0,  
      populations=ITT,  
      variables=Baseline demographics,  
      summary_measures=Descriptive summaries  
    );
~~~
  
---

## `%ars_add_contrast()` macro <a name="arsaddcontrast-macro-2"></a> ######
#### Purpose    :
               Register contrast definitions for an analysis  
               into ars.contrast. Supports multiple rows per call.  

####  Usage      : 
                 Call once per analysis_id to define one or more contrasts.  

####  Parameters :  
~~~sas
    lib=            ARS library (default: ars).  
    analysis_id=    Analysis identifier (required).  
    contrast_ids=   Contrast IDs, '|' delimited (required).  
    types=          Contrast types per contrast, '|' delimited (required).  
    numerators=     Numerator groups, '|' delimited (optional).  
    denominators=   Denominator groups, '|' delimited (optional).  
    contrast_exprs= Contrast expressions, '|' delimited (optional).  
    labels=         Contrast labels, '|' delimited (optional).  
~~~

####  Output     : 
                  Adds one row per contrast to &lib..contrast.  

####  Notes      :
                  contrast_ids= and types= counts must match.  

####  Usage Example :  
~~~sas
    %ars_add_contrast(  
      analysis_id=A0,  
      contrast_ids=C0,  
      types=NONE,  
      labels=No treatment comparison  
    );
~~~
  
---

## `%ars_add_multiplicity()` macro <a name="arsaddmultiplicity-macro-9"></a> ######
#### Purpose    :
                 Register multiplicity adjustment definitions for an analysis  
                 into ars.multiplicity. Supports multiple rows per call.  

####  Usage      :
                 Call once per analysis_id to define multiplicity families.  

####  Parameters :  
~~~sas
    lib=              ARS library (default: ars).  
    analysis_id=      Analysis identifier (required).  
    family_ids=       Family IDs, '|' delimited (required).  
    endpoint_ids=     Endpoint IDs per family, '|' delimited (required).  
    methods=          Adjustment methods per family, '|' delimited (required).  
    alphas=           Alpha levels per family, '|' delimited (optional).  
    orders=           Testing order per family, '|' delimited (optional).  
    condition_exprs=  Gatekeeping/condition expressions, '|' delimited (required).  
    notes_list=       Notes per family, '|' delimited (required).  
~~~

####  Output     : 
                 Adds one row per family to &lib..multiplicity.  

####  Notes      : 
                 All lists must be the same length.  

####  Usage Example : 
~~~sas
    %ars_add_multiplicity(  
      analysis_id=A0,  
      family_ids=F0,  
      endpoint_ids=BASELINE,  
      methods=NONE,  
      alphas=.,  
      orders=.,  
      condition_exprs=,  
      notes_list=Not applicable  
    );
~~~
  
---

## `%ars_add_group()` macro <a name="arsaddgroup-macro-5"></a> ######
#### Purpose    :
                Register grouping levels for an analysis into ars.group.  
               Supports multiple rows per call via pipe-delimited inputs.  

####  Usage      : 
                Call once per analysis_id to define group levels/order/filter.  

####  Parameters :  
~~~sas
    lib=          ARS library (default: ars).  
    analysis_id=  Analysis identifier (required; scalar).  
    var_names=    Grouping variable names, '|' delimited (required).  
    level_values= Level values per row, '|' delimited (required).  
    level_labels= Level labels per row, '|' delimited (required).  
    level_orders= Level display order per row, '|' delimited (required).  
    level_filters=Optional row-level filters, '|' delimited.  
~~~

####  Output     :
                 Adds one row per level to &lib..group.  

####  Notes      :
                 All pipe-delimited lists must be the same length.  

####  Usage Example :  
~~~sas
    %ars_add_group(  
      analysis_id=A0,  
      var_names=TRTA|TRTA,  
      level_values=DRUG|PBO,  
      level_labels=Drug|Placebo,  
      level_orders=1|2  
    );
~~~
  
---

## `%ars_add_layout()` macro <a name="arsaddlayout-macro-6"></a> ######
#### Purpose    :
                Register layout/section rules for an output  
               into ars.layout. Supports multiple rows per call.  

####  Usage      :
                 Call once per output to define header/body sections,  
                 ordering, and split variables.  

####  Parameters :  
~~~sas
    lib=        ARS library (default: ars).  
    output_id=  Output identifier (required).  
    sections=   Section names, '|' delimited (required).  
    row_orders= Row ordering per section, '|' delimited (required).  
    col_orders= Optional column ordering, '|' delimited.  
    headers=    Optional header expressions per section, '|' delimited.  
    split_vars= Optional split variable list per section, '|' delimited.  
~~~

####  Output     :
                  Adds one row per section to &lib..layout.  

####  Notes      :
                sections= and row_orders= counts must match.  

####  Usage Example :  
~~~sas
    %ars_add_layout(  
      output_id=T14_1_1,  
      sections=header|body_continuous,  
      row_orders=1|10,  
      headers=Treatment by Sex|Continuous variables,  
      split_vars=TRTA SEX|  
    );
~~~
  
---

## Notes on versions history

- 0.1.0(09December2025): Initial version.

---

## What is SAS Packages?

The package is built on top of **SAS Packages Framework(SPF)** developed by Bartosz Jablonski.

For more information about the framework, see [SAS Packages Framework](https://github.com/yabwon/SAS_PACKAGES).

You can also find more SAS Packages (SASPacs) in the [SAS Packages Archive(SASPAC)](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)

### 1. Set-up SAS Packages Framework

First, create a directory for your packages and assign a `packages` fileref to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "\path\to\your\packages";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Secondly, enable the SAS Packages Framework.
(If you don't have SAS Packages Framework installed, follow the instruction in 
[SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) 
to install SAS Packages Framework.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%include packages(SPFinit.sas)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2. Install SAS package

Install SAS package you want to use with the SPF's `%installPackage()` macro.

- For packages located in **SAS Packages Archive(SASPAC)** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located in **PharmaForest** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, mirror=PharmaForest)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located at some network location run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, sourcePath=https://some/internet/location/for/packages)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (e.g. `%installPackage(ABC, sourcePath=https://github.com/SomeRepo/ABC/raw/main/)`)


### 3. Load SAS package

Load SAS package you want to use with the SPF's `%loadPackage()` macro.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%loadPackage(packageName)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Enjoy!
