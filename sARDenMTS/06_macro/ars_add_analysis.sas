/*** HELP START ***//*

Purpose    : Register analysis records linking outputs, estimands, and models  
               into ars.analysis. Supports multiple rows per call.  

  Usage      : Call once per output to define one or more analyses.  

  Parameters :  
    lib=          ARS library (default: ars).  
    output_id=    Output identifier to link analyses (required).  
    analysis_ids= Analysis IDs, '|' delimited (required).  
    estimand_ids= Estimand IDs per analysis, '|' delimited (required).  
    model_ids=    Model IDs per analysis, '|' delimited (required).  
    subset_ids=   Optional subset IDs per analysis, '|' delimited.  
    grouping_ids= Optional grouping IDs per analysis, '|' delimited.  
    labels=       Optional analysis labels, '|' delimited.  
    orders=       Optional analysis order, '|' delimited.  

  Output     : Adds one row per analysis to &lib..analysis.  

  Notes      : analysis_ids= length must match estimand_ids= and model_ids=.  

  Usage Example :  
    %ars_add_analysis(  
      output_id=T14_1_1,  
      analysis_ids=A0,  
      estimand_ids=E0,  
      model_ids=M0,  
      labels=%nrbquote(Baseline descriptive analysis),  
      orders=1  
    );

*//*** HELP END ***/

%macro ars_add_analysis(
  lib=ars,
  output_id=,
  analysis_ids=,
  estimand_ids=,
  model_ids=,
  subset_ids=,
  grouping_ids=,
  labels=,
  orders=
);
  %ars_init(lib=&lib);

  %_ars_req(output_id,output_id);
  %_ars_req(analysis_ids,analysis_ids);
  %_ars_req(estimand_ids,estimand_ids);
  %_ars_req(model_ids,model_ids);

  %local n i;
  %let n=%sysfunc(countw(&analysis_ids,|,m));

  %if &n ne %sysfunc(countw(&estimand_ids,|,m)) %then %_ars_error(analysis_ids/estimand_ids counts differ.);
  %if &n ne %sysfunc(countw(&model_ids,|,m)) %then %_ars_error(analysis_ids/model_ids counts differ.);

  %if %superq(subset_ids) ne %then %do;
    %if &n ne %sysfunc(countw(&subset_ids,|,m)) %then %_ars_error(analysis_ids/subset_ids counts differ.);
  %end;
  %if %superq(grouping_ids) ne %then %do;
    %if &n ne %sysfunc(countw(&grouping_ids,|,m)) %then %_ars_error(analysis_ids/grouping_ids counts differ.);
  %end;
  %if %superq(labels) ne %then %do;
    %if &n ne %sysfunc(countw(&labels,|,m)) %then %_ars_error(analysis_ids/labels counts differ.);
  %end;
  %if %superq(orders) ne %then %do;
    %if &n ne %sysfunc(countw(&orders,|,m)) %then %_ars_error(analysis_ids/orders counts differ.);
  %end;

  data _ars_new;
    length analysis_id $40 output_id $40
           estimand_id $20 model_id $20
           subset_id $20 grouping_id $20
           analysis_label $200
           analysis_order 8;

    output_id="&output_id";

    %do i=1 %to &n;
      analysis_id   ="%scan(&analysis_ids,&i,|,m)";
      estimand_id   ="%scan(&estimand_ids,&i,|,m)";
      model_id      ="%scan(&model_ids,&i,|,m)";
      subset_id     ="%scan(&subset_ids,&i,|,m)";
      grouping_id   ="%scan(&grouping_ids,&i,|,m)";
      analysis_label="%scan(&labels,&i,|,m)";
      analysis_order=input("%scan(&orders,&i,|,m)", best.);
      output;
    %end;
  run;

  proc append base=&lib..analysis data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
