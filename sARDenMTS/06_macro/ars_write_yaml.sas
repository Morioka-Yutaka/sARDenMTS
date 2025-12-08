/*** HELP START ***//*

Purpose    : Export ARS metadata tables into a hierarchical ARM-TS YAML file.  
               The macro gathers unique analyses and outputs, builds the  
               analysis–output relationship list, and emits YAML using  
               yaml_writer utilities.  

  Usage      : Run after populating ars.* metadata tables (study, analysis,  
               estimand, model, contrast, multiplicity, group, output,  
               dataset, variable, statistic, meta_kv).  

  Parameters :  
    lib=      ARS library containing normalized metadata tables  
              (default: ars).  
    outpath=  Output folder for the YAML file (required).  
    outfile=  Output YAML file name without extension (required).  

  Required Supporting Package (Macros) :  
  [yaml_writer]
  https://github.com/PharmaForest/yaml_writer
    %yaml_start(outpath=, file=)  
    %yaml_end()  
    %dataset_export(ds=, wh=, cat=, varlist=, indent=, keyvar=)  

  Output     : Creates &outpath./&outfile..yaml and intermediate WORK tables.  

  Notes      :  
    - analyses are emitted as a YAML sequence under "analyses".  
    - outputs are emitted as a YAML sequence under "outputs".  
    - analysis_refs per output are derived from ars.analysis.  

  Usage Example :  
    %ars_write_yaml(  
      lib=ars,  
      outpath=F:\project\metadata,  
      outfile=armts_metadata  
    );

*//*** HELP END ***/

%macro ars_write_yaml(
  lib=ars,
  outpath=,
  outfile=
);

proc sort data=&lib..analysis(keep=analysis_id) out=_analysis_list nodupkey;
 by analysis_id;
run;
data _null_;
set _analysis_list end=eof;
call symputx(cats("analysis",_N_), analysis_id);
if eof then call symputx("analysis_obs", _N_);
run;
proc sort data=&lib..output(keep=output_id) out=_output_list nodupkey;
 by output_id;
run;
data _null_;
set _output_list end=eof;
call symputx(cats("output",_N_), output_id);
if eof then call symputx("output_obs", _N_);
run;

proc sort data=&lib..analysis(keep=analysis_id output_id) out=anl_out_rel nodupkey;
 by  output_id analysis_id;
run;
data anl_out_rel;
length _analysis_id $200.;
set anl_out_rel;
_analysis_id=quote(strip(analysis_id));
run;
proc transpose data=anl_out_rel out=anl_out_rel prefix=anl_;
 var _analysis_id;
 by  output_id ;
run;
data anl_out_rel;
set anl_out_rel;
analysis_refs= cats("[",catx(",",of anl_:),"]");
run;


%yaml_start(outpath=&outpath, file=&outfile)
&nw.;
study: &nw.;
%dataset_export(
   ds=&lib..study,
   cat=mapping,
   varlist=study_id protocol_id title version created_by created_on,
   indent=1
)
&nw.;
analyses: &nw.;
%do an_i = 1 %to &analysis_obs.;
%dataset_export(
   ds=&lib..analysis,
   wh=%nrbquote(analysis_id="&&analysis&an_i"),
   cat=mappingsequence,
   varlist=analysis_id analysis_label analysis_order,
   indent=1
)
&nw.;
    estimand:&nw.;
  %dataset_export(
     ds=&lib..estimand,
     wh=%nrbquote(analysis_id="&&analysis&an_i"),
     cat=mappingsequence,
     varlist=estimand_id population intercurrent summary_measure analysis_method,
     indent=3
  )
&nw.;
    model:&nw.;
  %dataset_export(
     ds=&lib..model,
     wh=%nrbquote(analysis_id="&&analysis&an_i"),
     cat=mappingsequence,
     varlist=model_id model_type response link dist fixed_effects covariates random_effects repeated cov_structure method,
     indent=3
  )
&nw.;
    contrast:&nw.;
  %dataset_export(
     ds=&lib..contrast,
     wh=%nrbquote(analysis_id="&&analysis&an_i"),
     cat=mappingsequence,
     varlist=contrast_id type numerator_group denominator_group contrast_expr label, 
     indent=3
  )
&nw.;
    multiplicity:&nw.;
  %dataset_export(
     ds=&lib..multiplicity,
     wh=%nrbquote(analysis_id="&&analysis&an_i"),
     cat=mappingsequence,
     varlist=family_id  endpoint_id method alpha order condition_expr notes,
     indent=3
  )
&nw.;
    grouping_levels:&nw.;
  %dataset_export(
     ds=&lib..group,
     wh=%nrbquote(analysis_id="&&analysis&an_i"),
     cat=mappingsequence,
     varlist=var_name level_value level_label level_order,
     indent=3
  )
&nw.;
%end;
outputs: &nw.;
%do ot_i = 1 %to &output_obs.;
%dataset_export(
   ds=&lib..output,
   wh=%nrbquote(output_id="&&output&ot_i"),
   cat=mappingsequence,
   varlist=output_id label type purpose population analysis_set,
   indent=1
)
&nw.;
%dataset_export(
   ds=Anl_out_rel,
   wh=%nrbquote(output_id="&&output&ot_i"),
   cat=mapping,
   varlist=analysis_refs,
   indent=2
)
&nw.;
    datasets:&nw.;
  %dataset_export(
     ds=&lib..dataset,
     wh=%nrbquote(output_id="&&output&ot_i"),
     cat=mappingsequence,
     varlist=domain role filter_expr,
     indent=3
  )
&nw.;
    variables:&nw.;
      by:&nw.;
    %dataset_export(
       ds=&lib..variable,
       wh=%nrbquote(output_id="&&output&ot_i" and lowcase(role)="by"),
       cat=mappingsequence,
       varlist=var_name label type format derivation,
       indent=5
    )
      row:&nw.;
    %dataset_export(
       ds=&lib..variable,
       wh=%nrbquote(output_id="&&output&ot_i" and lowcase(role)="row"),
       cat=mappingsequence,
       varlist=var_name label type format derivation,
       indent=5
    )
      col:&nw.;
    %dataset_export(
       ds=&lib..variable,
       wh=%nrbquote(output_id="&&output&ot_i" and lowcase(role)="col"),
       cat=mappingsequence,
       varlist=var_name label type format derivation,
       indent=5
    )
&nw.;
    statistics:&nw.;
  %dataset_export(
     ds=&lib..statistic,
     wh=%nrbquote(output_id="&&output&ot_i"),
     cat=mappingsequence,
     varlist=stat_name label method order decimal footnote_id,
     indent=3
  )
&nw.;
    meta:&nw.;
  %dataset_export(
     ds=&lib..meta_kv,
     wh=%nrbquote(output_id="&&output&ot_i"),
     cat=mapping,
     keyvar=key,
     varlist=value,
     indent=3
  )
&nw.;
%end;

 %yaml_end()

proc delete data= tmp;
run;
proc delete data= _analysis_list;
run;
proc delete data= _output_list;
run;


%mend;
