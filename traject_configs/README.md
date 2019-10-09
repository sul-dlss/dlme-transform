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

[Princeton MODS configuration / mapping](./mods_config.rb).

#### FGDC

[FGDC configuration / mapping](./fgdc_config.rb).

#### TEI

[TEI configuration / mapping](./tei_config.rb).

### Binary MARC


##### Example Configuration

```ruby
to_field 'id', extract_marc('001', first: true) do |_record, accumulator, _context|
  accumulator.collect! { |s| "penn_#{s}" }
end
to_field 'cho_alternative', extract_marc('130:240:246')
to_field 'cho_contributor', extract_role('700', 'contributor')
to_field 'cho_creator', extract_marc('100:110:111', trim_punctuation: true)
to_field 'cho_date', marc_publication_date, transform(&:to_s)
to_field 'cho_description', extract_marc('500:505:520')
to_field 'cho_edm_type', marc_type_to_edm
to_field 'cho_extent', extract_marc('300a', separator: nil, trim_punctuation: true)
to_field 'cho_format', marc_formats
to_field 'cho_has_type', extract_marc('651a', trim_punctuation: true)
to_field 'cho_identifier', extract_marc('001')
to_field 'cho_identifier', oclcnum
to_field 'cho_language', marc_languages
to_field 'cho_medium', extract_marc('300b', trim_punctuation: true)
to_field 'cho_publisher', extract_marc('260b:264b', trim_punctuation: true)
to_field 'cho_spatial', marc_geo_facet
to_field 'cho_subject', extract_marc('600:610:611:630:650:651:653:654:690:691:692')
to_field 'cho_temporal', marc_era_facet
to_field 'cho_title', extract_marc('245', trim_punctuation: true)
to_field 'cho_type', marc_type_to_edm

to_field 'agg_data_provider', data_provider, lang('en') # set in the settings.yml file
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab') # set in the settings.yml file
to_field 'agg_provider', provider, lang('en') # set in the settings.yml file
to_field 'agg_provider', provider_ar, lang('ar-Arab') # set in the settings.yml file
to_field 'agg_has_view' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => extract_marc('856u', first: true))
end
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
