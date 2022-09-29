# DLME Traject Configs

This directory contains Traject config files for different DLME data sources. The config files are written at the highest level possible which, in most cases, is that of the institution. Occasionally collection-specific config files need to be written in the case that there is significant variation across collection metadata from the same institution.

To learn about the core functionality of Traject and TrajectPlus see https://github.com/traject/traject and https://github.com/sul-dlss/traject_plus.

To run the Traject config files to transform data, see the [main README](https://github.com/sul-dlss/dlme-transform).

## Configuration Examples

The example configurations below are generic and considered kick-off examples in order to
provide a basis for getting started writing your own configurations.

### Source data formats

In most cases, data is harvested and converted to CSV with intake so the source data, for the purpose of writing a traject config, will most often be CSV. In some cases, it may be XML or Json.

For all CSV collections make a copy of the `template.rb` file to get started. For other cases, you will need to find a traject config that maps data from the same data format as a template.

For more details on the DLME data mapping process, consult the [DLME Data Mapping Guide](https://github.com/sul-dlss/dlme-transform/wiki/DLME-Metadata-Mapping-Guide)
