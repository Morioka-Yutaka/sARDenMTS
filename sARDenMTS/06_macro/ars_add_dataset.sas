/*** HELP START ***//*

Purpose    : Register dataset usage for an output into ars.dataset.  
               Supports multiple rows per call via pipe-delimited inputs.  

  Usage      : Call once per output to define all contributing domains.  

  Parameters :  
    lib=        ARS library (default: ars).  
    output_id=  Output identifier to link datasets (required).  
    domains=    List of dataset/domain names, '|' delimited (required).  
    roles=      List of roles per domain, '|' delimited (required).  
               Allowed: analysis|input|ref.  
    filters=    Optional list of WHERE/filter expressions per domain,  
               '|' delimited. If provided, count must match domains=.  

  Output     : Adds one row per domain to &lib..dataset.  

  Notes      : domains= and roles= counts must match; filters= optional.  

  Usage Example :  
    %ars_add_dataset(  
      output_id=T14_1_1,  
      domains=ADSL|ADVS|ADLB,  
      roles=analysis|input|input,  
      filters=%nrbquote(SAFFL='Y'|PARAMCD='SYSBP'|PARAMCD='GLUC')  
    );

*//*** HELP END ***/

%macro ars_add_dataset(
  lib=ars,
  output_id=,
  domains=,
  roles=,          /* analysis|input|ref */
  filters=
);
  %ars_init(lib=&lib);

  %_ars_req(output_id,output_id);
  %_ars_req(domains,domains);
  %_ars_req(roles,roles);

  %local n_dom n_role n_fil i role;
  %let n_dom=%sysfunc(countw(&domains,|,m));
  %let n_role=%sysfunc(countw(&roles,|,m));
  %let n_fil=%sysfunc(countw(&filters,|,m));

  %if &n_dom ne &n_role %then %_ars_error(domains and roles counts differ.);
  %if %superq(filters) ne %then %do;
    %if &n_dom ne &n_fil %then %_ars_error(domains and filters counts differ.);
  %end;

  %do i=1 %to &n_dom;
    %let role=%scan(&roles,&i,|,m);
    %_ars_enum(&role, role, analysis|input|ref);
  %end;

  data _ars_new;
    length output_id $40 domain $32 role $12 filter_expr $400;
    output_id="&output_id";
    %do i=1 %to &n_dom;
      domain="%scan(&domains,&i,|,m)";
      role="%scan(&roles,&i,|,m)";
      filter_expr="%scan(&filters,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..dataset data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
