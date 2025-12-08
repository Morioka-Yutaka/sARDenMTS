/*** HELP START ***//*

Purpose    : Add arbitrary key–value metadata for an output  
               into ars.meta_kv. Supports multiple rows per call.  

  Usage      : Use for free-form metadata not captured elsewhere.  

  Parameters :  
    lib=        ARS library (default: ars).  
    output_id=  Output identifier (required).  
    keys=       Metadata keys, '|' delimited (required).  
    values=     Metadata values, '|' delimited (required).  

  Output     : Adds one row per key to &lib..meta_kv.  

  Notes      : keys= and values= counts must match.  

  Usage Example :  
    %ars_add_meta(  
      output_id=T14_1_1,  
      keys=analysis_method|missing_display,  
      values=Descriptive only|Display missing as 'NA'  
    );

*//*** HELP END ***/

%macro ars_add_meta(
  lib=ars,
  output_id=,
  keys=,
  values=
);
  %ars_init(lib=&lib);

  %_ars_req(output_id,output_id);
  %_ars_req(keys,keys);
  %_ars_req(values,values);

  %local n i;
  %let n=%sysfunc(countw(&keys,|,m));
  %if &n ne %sysfunc(countw(&values,|,m)) %then %_ars_error(keys/values counts differ.);

  data _ars_new;
    length output_id $40 key $60 value $400;
    output_id="&output_id";
    %do i=1 %to &n;
      key="%scan(&keys,&i,|,m)";
      value="%scan(&values,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..meta_kv data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
