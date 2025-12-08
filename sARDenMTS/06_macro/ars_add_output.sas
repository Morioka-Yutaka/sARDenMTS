/*** HELP START ***//*

Purpose    : Register an output (TLF) definition into ars.output.  
               The output represents a Table, Listing, or Figure.  

  Usage      : Call once per output to define high-level display metadata.  

  Parameters :  
    lib=         ARS library (default: ars).  
    output_id=   Unique output identifier (required).  
    label=       Output title/label (required).  
    type=        Output type (required; Table|Listing|Figure).  
    purpose=     Brief intent/description (optional).  
    population=  Target population (optional).  
    analysis_set=Primary analysis dataset (optional).  

  Output     : Adds one row to &lib..output.  

  Notes      : type= is validated against the allowed enumeration.  

  Usage Example :  
    %ars_add_output(  
      output_id=T14_1_1,  
      label=Baseline characteristics,  
      type=Table,  
      purpose=Describe baseline demographics by treatment and sex,  
      population=ITT,  
      analysis_set=ADSL  
    );

*//*** HELP END ***/

%macro ars_add_output(
  lib=ars,
  output_id=,
  label=,
  type=,            /* Table|Listing|Figure */
  purpose=,
  population=,
  analysis_set=
);
  %ars_init(lib=&lib);

  %_ars_req(output_id,output_id);
  %_ars_req(label,label);
  %_ars_req(type,type);

  %_ars_enum(&type, type, Table|Listing|Figure);

  data _ars_new;
    length output_id $40 label $200 type $20 purpose $200
           population $40 analysis_set $40;
    output_id="&output_id";
    label="&label";
    type="&type";
    purpose="&purpose";
    population="&population";
    analysis_set="&analysis_set";
  run;

  proc append base=&lib..output data=_ars_new force; run;
  proc datasets lib=work nolist; delete _ars_new; quit;
%mend;
