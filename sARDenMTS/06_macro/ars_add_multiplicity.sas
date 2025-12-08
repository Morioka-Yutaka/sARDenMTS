/*** HELP START ***//*

Purpose    : Register multiplicity adjustment definitions for an analysis  
               into ars.multiplicity. Supports multiple rows per call.  

  Usage      : Call once per analysis_id to define multiplicity families.  

  Parameters :  
    lib=              ARS library (default: ars).  
    analysis_id=      Analysis identifier (required).  
    family_ids=       Family IDs, '|' delimited (required).  
    endpoint_ids=     Endpoint IDs per family, '|' delimited (required).  
    methods=          Adjustment methods per family, '|' delimited (required).  
    alphas=           Alpha levels per family, '|' delimited (optional).  
    orders=           Testing order per family, '|' delimited (optional).  
    condition_exprs=  Gatekeeping/condition expressions, '|' delimited (required).  
    notes_list=       Notes per family, '|' delimited (required).  

  Output     : Adds one row per family to &lib..multiplicity.  

  Notes      : All lists must be the same length.  

  Usage Example :  
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

*//*** HELP END ***/

%macro ars_add_multiplicity(
  lib=ars,
  analysis_id=,
  family_ids=,
  endpoint_ids=,
  methods=,            /* NONE|Holm|Hochberg|Gatekeeping|ClosedTest|... */
  alphas=,
  orders=,
  condition_exprs=,
  notes_list=
);
  %ars_init(lib=&lib);

  %_ars_req(analysis_id,analysis_id);
  %_ars_req(family_ids,family_ids);
  %_ars_req(endpoint_ids,endpoint_ids);
  %_ars_req(methods,methods);

  %local n i;
  %let n=%sysfunc(countw(&family_ids,|,m));
  %if &n ne %sysfunc(countw(&endpoint_ids,|,m)) %then %_ars_error(family_ids/endpoint_ids counts differ.);
  %if &n ne %sysfunc(countw(&methods,|,m)) %then %_ars_error(family_ids/methods counts differ.);
  %if &n ne %sysfunc(countw(&alphas,|,m)) %then %_ars_error(family_ids/alphas counts differ.);
  %if &n ne %sysfunc(countw(&orders,|,m)) %then %_ars_error(family_ids/orders counts differ.);
  %if &n ne %sysfunc(countw(&condition_exprs,|,m)) %then %_ars_error(family_ids/condition_exprs counts differ.);
  %if &n ne %sysfunc(countw(&notes_list,|,m)) %then %_ars_error(family_ids/notes_list counts differ.);

  data _ars_new;
    length analysis_id $40 family_id $20 endpoint_id $40
           method $40 alpha 8 order 8
           condition_expr $200 notes $400;
    analysis_id="&analysis_id";
    %do i=1 %to &n;
      family_id="%scan(&family_ids,&i,|,m)";
      endpoint_id="%scan(&endpoint_ids,&i,|,m)";
      method="%scan(&methods,&i,|,m)";
      alpha=input("%scan(&alphas,&i,|,m)", best.);
      order=input("%scan(&orders,&i,|,m)", best.);
      condition_expr="%scan(&condition_exprs,&i,|,m)";
      notes="%scan(&notes_list,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..multiplicity data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
