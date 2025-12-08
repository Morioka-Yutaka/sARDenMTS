/*** HELP START ***//*

Purpose    : Initialize the ARS metadata environment.  
               This macro assigns the ARS library, defines internal  
               utility macros for validation and error handling, and  
               creates empty ARS metadata tables if they do not exist.  
  Usage      : Call once at the start of a session or inside any ARS  
               authoring macro to guarantee required tables exist.  

  Parameters :  
    lib=      LIBREF for ARS metadata tables.  
              Default: ars.  
    libpath=  Physical path for the ARS library.  
              The directory is created if it does not exist.  

  Tables Created if Missing :  
    study        Study-level metadata.  
    output       Output/display definitions.  
    dataset      Input/analysis dataset references.  
    variable     Display variable roles and derivations.  
    statistic    Displayed statistics and formatting.  
    layout       Layout/sectioning rules.  
    meta_kv      Free key–value metadata.  
    model        Analysis model specifications.  
    estimand     Estimand definitions per analysis.  
    contrast     Contrast definitions per analysis.  
    multiplicity Multiplicity adjustment definitions.  
    analysis     Bridge linking outputs to analyses and core analysis info.  
    group        Grouping level definitions (ordering/labels).  

  Usage Example :  
    Set a permanent ARS library and initialize all metadata tables.  
      %ars_init(  
        lib=ars,  
        libpath=F:\project\metadata\ars  
      );  

  Notes      :  
    This macro is idempotent. Repeated calls re-assign the library  
    and only create tables that are absent.

*//*** HELP END ***/

%macro ars_init(lib=ars, libpath=);
libname &lib. "&libpath.";
  %macro _ars_error(msg);
    %put ERROR: [ARS] &msg;
    %abort cancel;
  %mend;
  %macro _ars_warn(msg);
    %put WARNING: [ARS] &msg;
  %mend;
  %macro _ars_req(param, name);
    %if %superq(&param)= %then %_ars_error(Required parameter missing: &name);
  %mend;
%macro _ars_enum(value, name, allowed);
  %local ok i token;
  %let ok=0;
  %do i=1 %to %sysfunc(countw(&allowed, |));
    %let token=%scan(&allowed, &i, |);
    %if %upcase(&value)=%upcase(&token) %then %let ok=1;
  %end;
  %if &ok=0 %then %_ars_error(Parameter &name=&value is invalid. Allowed: &allowed);
%mend;

  options dlcreatedir;
  libname &lib. "&libpath";
  options nodlcreatedir;


  %if %sysfunc(libref(&lib)) %then %_ars_error(Libref &lib is not assigned.);

  /* study */
  %if ^%sysfunc(exist(&lib..study)) %then %do;
    data &lib..study;
      length study_id $20 protocol_id $20 title $200 version $10
             created_by $80 created_on $20.;
      call missing(of _all_);
      stop;
    run;
  %end;

  /* output */
  %if ^%sysfunc(exist(&lib..output)) %then %do;
    data &lib..output;
      length output_id $40 label $200 type $20 purpose $200
             population $40 analysis_set $40;
      call missing(of _all_);
      stop;
    run;
  %end;

  /* dataset */
  %if ^%sysfunc(exist(&lib..dataset)) %then %do;
    data &lib..dataset;
      length output_id $40 domain $32 role $12 filter_expr $400;
      call missing(of _all_);
      stop;
    run;
  %end;

  /* variable */
  %if ^%sysfunc(exist(&lib..variable)) %then %do;
    data &lib..variable;
      length output_id $40 var_name $32 label $200 type $8 role $12
             format $40 derivation $400;
      call missing(of _all_);
      stop;
    run;
  %end;

  /* statistic */
  %if ^%sysfunc(exist(&lib..statistic)) %then %do;
    data &lib..statistic;
      length output_id $40 stat_name $40 label $80 method $200
             order 8 decimal 8 footnote_id $40;
      call missing(of _all_);
      stop;
    run;
  %end;

  /* layout */
  %if ^%sysfunc(exist(&lib..layout)) %then %do;
    data &lib..layout;
      length output_id $40 section $40 header_expr $200 split_var $200;
      length row_order col_order 8;
      call missing(of _all_);
      stop;
    run;
  %end;

  /* meta_kv */
  %if ^%sysfunc(exist(&lib..meta_kv)) %then %do;
    data &lib..meta_kv;
      length output_id $40 key $60 value $400;
      call missing(of _all_);
      stop;
    run;
  %end;

/*model*/
  %if ^%sysfunc(exist(&lib..model)) %then %do;
    data &lib..model;
      length analysis_id $40 model_id $20 model_type $30
             response $32 link $32 dist $32
             fixed_effects $200 covariates $200 random_effects $200
             repeated $200 cov_structure $80 method $200;
      call missing(of _all_);
      stop;
    run;
  %end;

/*estimand*/
  %if ^%sysfunc(exist(&lib..estimand)) %then %do;
    data &lib..estimand;
      length analysis_id $40 estimand_id $20
             population $80 variable $120 intercurrent $200
             summary_measure $120 analysis_method $200;
      call missing(of _all_);
      stop;
    run;
  %end;

/*contrast*/
  %if ^%sysfunc(exist(&lib..contrast)) %then %do;
    data &lib..contrast;
      length analysis_id $40 contrast_id $20
             type $20 numerator_group $40 denominator_group $40
             contrast_expr $400 label $200;
      call missing(of _all_);
      stop;
    run;
  %end;

/*multiplicity*/
  %if ^%sysfunc(exist(&lib..multiplicity)) %then %do;
    data &lib..multiplicity;
      length analysis_id $40 family_id $20 endpoint_id $40
             method $40 alpha 8 order 8
             condition_expr $200 notes $400;
      call missing(of _all_);
      stop;
    run;
  %end;


  /* analysis */
  %if ^%sysfunc(exist(&lib..analysis)) %then %do;
    data &lib..analysis;
      length analysis_id $40 output_id $40
             estimand_id $20 model_id $20
             subset_id $20 grouping_id $20
             analysis_label $200
             analysis_order 8;
      call missing(of _all_);
      stop;
    run;
  %end;

  /* group */
  %if ^%sysfunc(exist(&lib..group)) %then %do;
    data &lib..group;
      length analysis_id $40
             var_name $32
             level_value $200 level_label $200
             level_order 8
             level_filter $400;
      call missing(of _all_);
      stop;
    run;
  %end;


%mend;
