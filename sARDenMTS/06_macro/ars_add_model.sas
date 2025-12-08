/*** HELP START ***//*

Purpose    : Register model specifications for an analysis  
               into ars.model. Supports multiple rows per call.  

  Usage      : Call once per analysis_id to define one or more models.  
               For descriptive analyses, use model_type=DESCRIPTIVE.  

  Parameters :  
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

  Output     : Adds one row per model to &lib..model.  

  Notes      : model_ids= and model_types= counts must match.  

  Usage Example :  
    %ars_add_model(  
      analysis_id=A0,  
      model_ids=M0,  
      model_types=DESCRIPTIVE,  
      methods=No inferential model  
    );

*//*** HELP END ***/

%macro ars_add_model(
  lib=ars,
  analysis_id=,
  model_ids=,
  model_types=,     /* DESCRIPTIVE|ANCOVA|MMRM|LOGISTIC|COX|... (user-defined list allowed) */
  responses=,
  links=,
  dists=,
  fixed_effects_list=,
  covariates_list=,
  random_effects_list=,
  repeated_list=,
  cov_structures=,
  methods=
);
  %ars_init(lib=&lib);

  %_ars_req(analysis_id,analysis_id);
  %_ars_req(model_ids,model_ids);
  %_ars_req(model_types,model_types);

  %local n i;
  %let n=%sysfunc(countw(&model_ids,|,m));
  %if &n ne %sysfunc(countw(&model_types,|,m)) %then %_ars_error(model_ids/model_types counts differ.);

  data _ars_new;
    length analysis_id $40 model_id $20 model_type $30
           response $32 link $32 dist $32
           fixed_effects $200 covariates $200 random_effects $200
           repeated $200 cov_structure $80 method $200;
    analysis_id="&analysis_id";
    %do i=1 %to &n;
      model_id="%scan(&model_ids,&i,|,m)";
      model_type="%scan(&model_types,&i,|,m)";
      response="%scan(&responses,&i,|,m)";
      link="%scan(&links,&i,|,m)";
      dist="%scan(&dists,&i,|,m)";
      fixed_effects="%scan(&fixed_effects_list,&i,|,m)";
      covariates="%scan(&covariates_list,&i,|,m)";
      random_effects="%scan(&random_effects_list,&i,|,m)";
      repeated="%scan(&repeated_list,&i,|,m)";
      cov_structure="%scan(&cov_structures,&i,|,m)";
      method="%scan(&methods,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..model data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
