Type : Package
Package : sARDenMTS
Title : sARDenMTS
Version : 0.1.0
Author : Yutaka Morioka(sasyupi@gmail.com)
Maintainer : Yutaka Morioka(sasyupi@gmail.com)
License : MIT
Encoding : UTF8
Required : "Base SAS Software", "yaml_writer"
ReqPackages :  

DESCRIPTION START:
A SAS-native authoring framework for CDISC Analysis Results Metadata Technical Specification (ARM-TS).
Users define ARS-compliant study, analysis, and output metadata via simple SAS macros that append to normalized metadata tables. The package validates key constraints and exports a hierarchical YAML ARM-TS file using yaml_writer.
Designed to integrate seamlessly with sARDen (ARD builder), with the longer-term goal of fully metadata-driven, reproducible TLF production. This integration layer is currently under active development.
DESCRIPTION END:
