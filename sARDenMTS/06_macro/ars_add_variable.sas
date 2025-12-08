/*** HELP START ***//*

Purpose    : Register display variables for an output into ars.variable.  
               Supports multiple rows per call via pipe-delimited inputs.  

  Usage      : Call once per output to define BY/ROW/COL/STAT variables.  

  Parameters :  
    lib=         ARS library (default: ars).  
    output_id=   Output identifier to link variables (required).  
    vars=        Variable names, '|' delimited (required).  
    labels=      Variable labels, '|' delimited (required).  
    types=       num|char per variable, '|' delimited (required).  
    roles=       by|row|col|stat per variable, '|' delimited (required).  
    formats=     Optional SAS formats per variable, '|' delimited.  
    derivations= Optional derivation text per variable, '|' delimited.  

  Output     : Adds one row per variable to &lib..variable.  

  Notes      : Counts across vars/labels/types/roles must match.  

  Usage Example :  
    %ars_add_variable(  
      output_id=T14_1_1,  
      vars=TRTA|SEX|AGE,  
      labels=Treatment|Sex|Age (years),  
      types=char|char|num,  
      roles=by|by|row,  
      formats=$trt.|$sex.|8.1  
    );

*//*** HELP END ***/

%macro ars_add_variable(
  lib=ars,
  output_id=,
  vars=,
  labels=,
  types=,        /* num|char */
  roles=,        /* by|row|col|stat */
  formats=,
  derivations=
);
  %ars_init(lib=&lib);

  %_ars_req(output_id,output_id);
  %_ars_req(vars,vars);
  %_ars_req(labels,labels);
  %_ars_req(types,types);
  %_ars_req(roles,roles);

  %local n_var n_lab n_typ n_role n_fmt n_drv i;
  %let n_var=%sysfunc(countw(&vars,|,m));
  %let n_lab=%sysfunc(countw(&labels,|,m));
  %let n_typ=%sysfunc(countw(&types,|,m));
  %let n_role=%sysfunc(countw(&roles,|,m));
  %let n_fmt=%sysfunc(countw(&formats,|,m));
  %let n_drv=%sysfunc(countw(&derivations,|,m));

  %if &n_var ne &n_lab %then %_ars_error(vars and labels counts differ.);
  %if &n_var ne &n_typ %then %_ars_error(vars and types counts differ.);
  %if &n_var ne &n_role %then %_ars_error(vars and roles counts differ.);
  %if %superq(formats) ne %then %do;
    %if &n_var ne &n_fmt %then %_ars_error(vars and formats counts differ.);
  %end;
  %if %superq(derivations) ne %then %do;
    %if &n_var ne &n_drv %then %_ars_error(vars and derivations counts differ.);
  %end;

  %do i=1 %to &n_var;
    %_ars_enum(%scan(&types,&i,|,m), type, num|char);
    %_ars_enum(%scan(&roles,&i,|,m), role, by|row|col|stat);
  %end;

  data _ars_new;
    length output_id $40 var_name $32 label $200 type $8 role $12
           format $40 derivation $400;
    output_id="&output_id";
    %do i=1 %to &n_var;
      var_name="%scan(&vars,&i,|,m)";
      label="%scan(&labels,&i,|,m)";
      type="%scan(&types,&i,|,m)";
      role="%scan(&roles,&i,|,m)";
      format="%scan(&formats,&i,|,m)";
      derivation="%scan(&derivations,&i,|,m)";
      output;
    %end;
  run;

  proc append base=&lib..variable data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
