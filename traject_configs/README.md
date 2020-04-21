# DLME Traject Configs

This directory contains Traject config files for different DLME data sources. The config files are written at the highest level possible which, in most cases, is that of the institution. Occasionally collection-specific config files need to be written in the case that there is significant variation across collection metadata from the same institution.

To learn about the core functionality of Traject and TrajectPlus see https://github.com/traject/traject and https://github.com/sul-dlss/traject_plus.

To run the Traject config files to transform data, see the [main README](https://github.com/sul-dlss/dlme-transform).

## Configuration Examples

The example configurations below are generic and considered kick-off examples in order to
provide a basis for getting started writing your own configurations.

### Source data formats

1. [Comma Separated Values](#comma-separated-values)
2. [XML](#xml)
3. [Binary MARC](#binary-marc)
4. [JSON](#json)

### Comma Separated Values

#### Example Source Data

```
id,title,thumbnail_url
1,Title of First Item,http://www.example.com/thumbs/1.jpg
2,Title of Second Item,http://www.example.com/thumbs/2.jpg
3,Title of Third Item,http://www.example.com/thumbs/3.jpg
```

#### Example Configuration

```
to_field('wr_id'), normalize_prefixed_id('id')
to_field('cho_title'), column('title')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('thumbnail_url')])
end
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
```

### XML

#### Generic XML

##### Example Source Data

```
<?xml version="1.0" encoding="UTF-8"?>
<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
  <titleInfo>
    <title>XML Item Title</title>
  </titleInfo>
  <thumbnail>
    <resource>http://www.example.com/thumbs/12345.jpg</resource>
  </thumbnail>
</mods>
```

##### Example Configuration

```
to_field('wr_id'), generate_mods_id
to_field('cho_title'), extract_mods('/*/mods:titleInfo/mods:title', )
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_mods('/*/mods:thumbnail/mods:resource')]
end
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
```

#### MODS

[Stanford MODS configuration / mapping](./stanford_mods_config.rb).

#### FGDC

[FGDC configuration / mapping](./fgdc_config.rb).

#### TEI

[TEI configuration / mapping](./tei_config.rb).

#### MARC XML

[Michigan configuration / mapping](./michigan_config.rb).

### Binary MARC

##### Example Configuration

```ruby
# frozen_string_literal: true

# NOTE: most of the fields are populated via marc_config (same for all MARC data)

settings do
  provide "reader_class_name", "MarcReader"
end

to_field 'id', extract_marc('001', first: true) do |_record, accumulator, _context|
  accumulator.collect! { |s| "penn_#{s}" }
end

# Cho Additional
to_field 'cho_dc_rights', literal('Public Domain'), lang('en')
to_field 'cho_description', extract_marc('500a:505agrtu:520abcu', :alternate_script => false), strip, gsub('Special Collections Library,', 'Special Collections Research Center')
lang('en')
to_field 'cho_description', extract_marc('500a:505agrtu:520abcu', :alternate_script => :only), strip, lang('ar-Arab')
to_field 'cho_has_type', literal('Manuscript'), lang('en')
to_field 'cho_has_type', literal('Manuscript'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', oclcnum

each_record convert_to_language_hash(
  'agg_data_provider',
  'agg_data_provider_country',
  'agg_provider',
  'agg_provider_country',
  'cho_alternative',
  'cho_contributor',
  'cho_coverage',
  'cho_creator',
  'cho_date',
  'cho_dc_rights',
  'cho_description',
  'cho_edm_type',
  'cho_extent',
  'cho_format',
  'cho_has_part',
  'cho_has_type',
  'cho_is_part_of',
  'cho_language',
  'cho_medium',
  'cho_provenance',
  'cho_publisher',
  'cho_relation',
  'cho_source',
  'cho_spatial',
  'cho_subject',
  'cho_temporal',
  'cho_title',
  'cho_type'
)
```

### JSON

#### Generic JSON

##### Example Source Data

```
{
	"title": "JSON Item Title",
	"thumbnail": {
		"resource": "http://www.example.com/thumbs/12345.jpg"
	}
}
```

##### Example Configuration

```
to_field('cho_title'), extract_json('.title', )
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.thumbnail.resource')]
end
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
```
