/*** HELP START ***//*

Purpose    : Register contrast definitions for an analysis  
               into ars.contrast. Supports multiple rows per call.  

  Usage      : Call once per analysis_id to define one or more contrasts.  

  Parameters :  
    lib=            ARS library (default: ars).  
    analysis_id=    Analysis identifier (required).  
    contrast_ids=   Contrast IDs, '|' delimited (required).  
    types=          Contrast types per contrast, '|' delimited (required).  
    numerators=     Numerator groups, '|' delimited (optional).  
    denominators=   Denominator groups, '|' delimited (optional).  
    contrast_exprs= Contrast expressions, '|' delimited (optional).  
    labels=         Contrast labels, '|' delimited (optional).  

  Output     : Adds one row per contrast to &lib..contrast.  

  Notes      : contrast_ids= and types= counts must match.  

  Usage Example :  
    %ars_add_contrast(  
      analysis_id=A0,  
      contrast_ids=C0,  
      types=NONE,  
      labels=No treatment comparison  
    );

*//*** HELP END ***/

%macro ars_add_contrast(
  lib=ars,
  analysis_id=,
  contrast_ids=,
  types=,               /* diff|ratio|logHR|NONE|... */
  numerators=,
  denominators=,
  contrast_exprs=,
  labels=
);
  %ars_init(lib=&lib);

  %_ars_req(analysis_id,analysis_id);
  %_ars_req(contrast_ids,contrast_ids);
  %_ars_req(types,types);

  %local n i;
  %let n=%sysfunc(countw(&contrast_ids,|,m));
  %if &n ne %sysfunc(countw(&types,|,m)) %then %_ars_error(contrast_ids/types counts differ.);

  data _ars_new;
    length analysis_id $40 contrast_id $20
           type $20 numerator_group $40 denominator_group $40
           contrast_expr $400 label $200;
    analysis_id="&analysis_id";
    %do i=1 %to &n;
      contrast_id="%scan(&contrast_ids,&i,|,m)";
      type="%scan(&types,&i,|,m)";
      numerator_group="%scan(&numerators,&i,|,m)";
      denominator_group="%scan(&denominators,&i,|,m)";
      contrast_expr="%scan(&contrast_exprs,&i,|,m)";
      label="%scan(&labels,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..contrast data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
