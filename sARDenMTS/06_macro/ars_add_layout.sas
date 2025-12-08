/*** HELP START ***//*

Purpose    : Register layout/section rules for an output  
               into ars.layout. Supports multiple rows per call.  

  Usage      : Call once per output to define header/body sections,  
               ordering, and split variables.  

  Parameters :  
    lib=        ARS library (default: ars).  
    output_id=  Output identifier (required).  
    sections=   Section names, '|' delimited (required).  
    row_orders= Row ordering per section, '|' delimited (required).  
    col_orders= Optional column ordering, '|' delimited.  
    headers=    Optional header expressions per section, '|' delimited.  
    split_vars= Optional split variable list per section, '|' delimited.  

  Output     : Adds one row per section to &lib..layout.  

  Notes      : sections= and row_orders= counts must match.  

  Usage Example :  
    %ars_add_layout(  
      output_id=T14_1_1,  
      sections=header|body_continuous,  
      row_orders=1|10,  
      headers=Treatment by Sex|Continuous variables,  
      split_vars=TRTA SEX|  
    );

*//*** HELP END ***/

%macro ars_add_layout(
  lib=ars,
  output_id=,
  sections=,
  row_orders=,
  col_orders=,
  headers=,
  split_vars=
);
  %ars_init(lib=&lib);

  %_ars_req(output_id,output_id);
  %_ars_req(sections,sections);
  %_ars_req(row_orders,row_orders);

  %local n i;
  %let n=%sysfunc(countw(&sections,|,m));
  %if &n ne %sysfunc(countw(&row_orders,|,m)) %then %_ars_error(sections/row_orders counts differ.);
  %if %superq(col_orders) ne %then %do;
    %if &n ne %sysfunc(countw(&col_orders,|,m)) %then %_ars_error(sections/col_orders counts differ.);
  %end;
  %if %superq(headers) ne %then %do;
    %if &n ne %sysfunc(countw(&headers,|,m)) %then %_ars_error(sections/headers counts differ.);
  %end;
  %if %superq(split_vars) ne %then %do;
    %if &n ne %sysfunc(countw(&split_vars,|,m)) %then %_ars_error(sections/split_vars counts differ.);
  %end;

  data _ars_new;
    length output_id $40 section $40 header_expr $200 split_var $200;
    length row_order col_order 8;
    output_id="&output_id";
    %do i=1 %to &n;
      section="%scan(&sections,&i,|,m)";
      row_order=input("%scan(&row_orders,&i,|,m)", best.);
      col_order=input("%scan(&col_orders,&i,|,m)", best.);
      header_expr="%scan(&headers,&i,|,m)";
      split_var="%scan(&split_vars,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..layout data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
