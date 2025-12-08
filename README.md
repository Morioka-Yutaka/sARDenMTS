# sARDenMTS

A SAS-native authoring framework for CDISC Analysis Results Metadata Technical Specification (ARM-TS).   
Users define ARS-compliant study, analysis, and output metadata via simple SAS macros that append to normalized metadata tables.   
The package validates key constraints and exports a hierarchical YAML ARM-TS file using yaml_writer.  
Designed to integrate seamlessly with sARDen (ARD builder), with the longer-term goal of fully metadata-driven, reproducible TLF production. This integration layer is currently under active development.

<img width="360" height="360" alt="sARDenMTS_small" src="https://github.com/user-attachments/assets/64c6b904-20aa-41d3-9780-f0afd219e187" />

> [!WARNING]
> This package uses the yaml_writer package to output ARS data in YAML format, so it is listed as a dependency.
If that package is not installed, %ars_write_yaml() will not work.
> [yaml_writer](https://github.com/PharmaForest/yaml_writer)
