/*** HELP START ***//*

Purpose    : Register statistics to be displayed for an output  
               into ars.statistic. Supports multiple rows per call.  
  Usage      : Call once per output to define all required stats.  
  Parameters :  
    lib=          ARS library (default: ars).  
    output_id=    Output identifier (required).  
    stats=        Statistic names, '|' delimited (required).  
    labels=       Display labels, '|' delimited (required).  
    methods=      Computation methods, '|' delimited (required).  
    orders=       Display order, '|' delimited (required).  
    decimals=     Decimal places, '|' delimited (required).  
    footnote_ids= Optional footnote IDs per statistic, '|' delimited.  
  Output     : Adds one row per statistic to &lib..statistic.  
  Notes      : All provided lists must be the same length.  
  Usage Example :  
    %ars_add_statistic(  
      output_id=T14_1_1,  
      stats=N|MEAN|SD,  
      labels=n|Mean|SD,  
      methods=COUNT|MEAN|STD,  
      orders=1|2|3,  
      decimals=0|1|1  
    );

*//*** HELP END ***/

%macro ars_add_statistic(
  lib=ars,
  output_id=,
  stats=,
  labels=,
  methods=,
  orders=,
  decimals=,
  footnote_ids=
);
  %ars_init(lib=&lib);

  %_ars_req(output_id,output_id);
  %_ars_req(stats,stats);
  %_ars_req(labels,labels);
  %_ars_req(methods,methods);
  %_ars_req(orders,orders);
  %_ars_req(decimals,decimals);

  %local n i;
  %let n=%sysfunc(countw(&stats,|,m));
  %if &n ne %sysfunc(countw(&labels,|,m)) %then %_ars_error(stats/labels counts differ.);
  %if &n ne %sysfunc(countw(&methods,|,m)) %then %_ars_error(stats/methods counts differ.);
  %if &n ne %sysfunc(countw(&orders,|,m)) %then %_ars_error(stats/orders counts differ.);
  %if &n ne %sysfunc(countw(&decimals,|,m)) %then %_ars_error(stats/decimals counts differ.);
  %if %superq(footnote_ids) ne %then %do;
    %if &n ne %sysfunc(countw(&footnote_ids,|,m)) %then %_ars_error(stats/footnote_ids counts differ.);
  %end;

  data _ars_new;
    length output_id $40 stat_name $40 label $80 method $200
           order 8 decimal 8 footnote_id $40;
    output_id="&output_id";
    %do i=1 %to &n;
      stat_name="%scan(&stats,&i,|,m)";
      label="%scan(&labels,&i,|,m)";
      method="%scan(&methods,&i,|,m)";
      order=input("%scan(&orders,&i,|,m)", best.);
      decimal=input("%scan(&decimals,&i,|,m)", best.);
      footnote_id="%scan(&footnote_ids,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..statistic data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
