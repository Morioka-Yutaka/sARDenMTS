/*** HELP START ***//*

Purpose    : Register grouping levels for an analysis into ars.group.  
               Supports multiple rows per call via pipe-delimited inputs.  

  Usage      : Call once per analysis_id to define group levels/order/filter.  

  Parameters :  
    lib=          ARS library (default: ars).  
    analysis_id=  Analysis identifier (required; scalar).  
    var_names=    Grouping variable names, '|' delimited (required).  
    level_values= Level values per row, '|' delimited (required).  
    level_labels= Level labels per row, '|' delimited (required).  
    level_orders= Level display order per row, '|' delimited (required).  
    level_filters=Optional row-level filters, '|' delimited.  

  Output     : Adds one row per level to &lib..group.  

  Notes      : All pipe-delimited lists must be the same length.  

  Usage Example :  
    %ars_add_group(  
      analysis_id=A0,  
      var_names=TRTA|TRTA,  
      level_values=DRUG|PBO,  
      level_labels=Drug|Placebo,  
      level_orders=1|2  
    );

*//*** HELP END ***/

%macro ars_add_group(
  lib=ars,
 analysis_id=,
  var_names=,
  level_values=,
  level_labels=,
  level_orders=,
  level_filters=
);
  %ars_init(lib=&lib);

  %_ars_req(analysis_id,analysis_id);
  %_ars_req(var_names,var_names);
  %_ars_req(level_values,level_values);
  %_ars_req(level_labels,level_labels);
  %_ars_req(level_orders,level_orders);

  %local n i;
  %let n=%sysfunc(countw(&var_names,|,m));

  %if &n ne %sysfunc(countw(&level_values,|,m)) %then %_ars_error(var_names/level_values counts differ.);
  %if &n ne %sysfunc(countw(&level_labels,|,m)) %then %_ars_error(var_names/level_labels counts differ.);
  %if &n ne %sysfunc(countw(&level_orders,|,m)) %then %_ars_error(var_names/level_orders counts differ.);
  %if %superq(level_filters) ne %then %do;
    %if &n ne %sysfunc(countw(&level_filters,|,m)) %then %_ars_error(var_names/level_filters counts differ.);
  %end;

  data _ars_new;
    length analysis_id $40
           var_name $32
           level_value $200 level_label $200
           level_order 8
           level_filter $400;

    analysis_id="&analysis_id";

    %do i=1 %to &n;
      var_name    ="%scan(&var_names,&i,|,m)";
      level_value ="%scan(&level_values,&i,|,m)";
      level_label ="%scan(&level_labels,&i,|,m)";
      level_order =input("%scan(&level_orders,&i,|,m)", best.);
      level_filter="%scan(&level_filters,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..group data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
