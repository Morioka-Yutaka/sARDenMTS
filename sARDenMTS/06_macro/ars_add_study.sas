/*** HELP START ***//*

Purpose    : Register study-level metadata into ars.study.  
               Appends one observation describing the study.  

  Usage      : Call once per study to seed ARM-TS study section.  

  Parameters :  
    lib=         ARS library (default: ars).  
    study_id=    Study identifier (required).  
    protocol_id= Protocol identifier (required).  
    title=       Study title (required).  
    version=     Metadata version label (required).  
    created_by=  Author/creator name (optional).  
    created_on=  Creation date (default: today in YYYY-MM-DD).  

  Output     : Adds one row to &lib..study.  

  Usage Example :  
    %ars_add_study(  
      lib=ars,  
      study_id=STUDY001,  
      protocol_id=ABC-123,  
      title=%nrstr(A Randomized, Double-blind Study of XYZ in Hypertension),  
      version=v1.0,  
      created_by=Yutaka Morioka  
    );

*//*** HELP END ***/

%macro ars_add_study(
  lib=ars,
  study_id=,
  protocol_id=,
  title=,
  version=,
  created_by=,  created_on=%sysfunc( putn(%sysfunc(today()), yymmdd10.) )

);
  %ars_init(lib=&lib);

  %_ars_req(study_id,study_id);
  %_ars_req(protocol_id,protocol_id);
  %_ars_req(title,title);
  %_ars_req(version,version);

  data _ars_new;
    length study_id $20 protocol_id $20 title $200 version $10
           created_by $80 created_on $20.;
    study_id="&study_id";
    protocol_id="&protocol_id";
    title="&title";
    version="&version";
    created_by="&created_by";
    created_on="&created_on";
  run;

  proc append base=&lib..study data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
