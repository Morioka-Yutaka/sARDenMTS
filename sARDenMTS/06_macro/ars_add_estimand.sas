/*** HELP START ***//*

Purpose    : Register estimand definitions for an analysis  
               into ars.estimand. Supports multiple rows per call.  

  Usage      : Call once per analysis_id to define one or more estimands.  

  Parameters :  
    lib=              ARS library (default: ars).  
    analysis_id=      Analysis identifier (required).  
    estimand_ids=     Estimand IDs, '|' delimited (required).  
    populations=      Populations per estimand, '|' delimited (required).  
    variables=        Target variables/endpoints, '|' delimited (required).  
    intercurrents=    Intercurrent event strategies, '|' delimited (optional).  
    summary_measures= Summary measures, '|' delimited (required).  
    analysis_methods= Analysis methods per estimand, '|' delimited (optional).  

  Output     : Adds one row per estimand to &lib..estimand.  

  Notes      : Required lists must be the same length.  

  Usage Example :  
    %ars_add_estimand(  
      analysis_id=A0,  
      estimand_ids=E0,  
      populations=ITT,  
      variables=Baseline demographics,  
      summary_measures=Descriptive summaries  
    );

*//*** HELP END ***/

%macro ars_add_estimand(
  lib=ars,
  analysis_id=,
  estimand_ids=,
  populations=,
  variables=,
  intercurrents=,
  summary_measures=,
  analysis_methods=
);
  %ars_init(lib=&lib);

  %_ars_req(analysis_id,analysis_id);
  %_ars_req(estimand_ids,estimand_ids);
  %_ars_req(populations,populations);
  %_ars_req(variables,variables);
  %_ars_req(summary_measures,summary_measures);

  %local n i;
  %let n=%sysfunc(countw(&estimand_ids,|,m));
  %if &n ne %sysfunc(countw(&populations,|,m)) %then %_ars_error(estimand_ids/populations counts differ.);
  %if &n ne %sysfunc(countw(&variables,|,m)) %then %_ars_error(estimand_ids/variables counts differ.);
  %if &n ne %sysfunc(countw(&summary_measures,|,m)) %then %_ars_error(estimand_ids/summary_measures counts differ.);
  %if %superq(analysis_methods) ne %then %do;
    %if &n ne %sysfunc(countw(&analysis_methods,|,m)) %then %_ars_error(estimand_ids/analysis_methods counts differ.);
  %end;

  data _ars_new;
    length analysis_id $40 estimand_id $20
           population $80 variable $120 intercurrent $200
           summary_measure $120 analysis_method $200;
    analysis_id="&analysis_id";
    %do i=1 %to &n;
      estimand_id="%scan(&estimand_ids,&i,|,m)";
      population="%scan(&populations,&i,|,m)";
      variable="%scan(&variables,&i,|,m)";
      intercurrent="%scan(&intercurrents,&i,|,m)";
      summary_measure="%scan(&summary_measures,&i,|,m)";
      analysis_method="%scan(&analysis_methods,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..estimand data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
