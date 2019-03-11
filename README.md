# dlme-transform
[![](https://images.microbadger.com/badges/image/suldlss/dlme-transform.svg)](https://microbadger.com/images/suldlss/dlme-transform "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/suldlss/dlme-transform.svg)](http://microbadger.com/images/suldlss/dlme-transform "Get your own commit badge on microbadger.com")

Transforms raw DLME metadata from https://github.com/sul-dlss/dlme-metadata and uses transformations in https://github.com/sul-dlss/dlme-traject to create [DLME intermediate representation](https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md) documents in S3.

You can read more about our data and related documentation in our [data documentation](./docs/README.md).

## Docker
### Build image
```
docker build --build-arg VCS_REF=`git rev-parse --short HEAD` \
             --build-arg VCS_URL=`git config --get remote.origin.url` \
             --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
             . -t suldlss/dlme-transform:latest
```

### Deploy
```
docker push suldlss/dlme-transform:latest
```

### Running Transforms

You can run transforms locally by getting the Traject configs and DLME data from Github (assuming
everything is update to date on the master branches):

```
docker run --rm -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest \
                stanford/maps/data/kj751hs0595.mods
```

The output will appear in STDOUT inside the container and be written to
`/opt/traject/output`. (In this example, `/opt/traject/output` inside the
container is mounted from `./output` outside the container, which will correspond
to the 'output' subfolder in your locally cloned dlme-transform repo.)

For development purposes, instead of pulling configs and harvested data to transform from Github,
you can pull them in locally. This may be useful as you test new traject configs before
pushing them to GitHub.  To do this, map in local directories using the -v switch. Similarly, you
can pull in local macros and translation maps.

Note: you should use your actual local directories in place of three example directories below
specified with the -v switch for configs, data, and output.  In the example below,
the `dlme-traject` and `dlme-metadata` repositories are cloned one directory up from the
`dlme-transform` repository we are running from.  Output will be written to the output
subfolder of the `dlme-transform` repo (your current directory) as in the Github example above.

Instead of specifying a directory relative to the current directory (as in the example below),
you could also specify an absolute path on your machine, like
`/Users/YourName/development/dlme-metadata`.  Be sure to specify the root of the
checked out repositories in each case.

The traject configuration file used for a particular transform is triggered by the specified data directory.
See "Configuring transforms" below.

```
docker run --rm -e SKIP_FETCH_CONFIG=true \
                -e SKIP_FETCH_DATA=true \
                -v $(pwd)/.:/opt/traject \
                -v $(pwd)/../dlme-traject:/opt/traject/config \
                -v $(pwd)/../dlme-metadata:/opt/traject/data \
                -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest \
                stanford/maps/data/kj751hs0595.mods
```

To process multiple files, specify a directory instead of a single file. For
example, `stanford/maps` instead of `stanford/maps/data/kj751hs0595.mods`. To transform everything, specify nothing.

```
docker run --rm -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest
```


Sending output to S3 bucket and publishing an SNS notification:
```
docker run --rm -e S3_BUCKET=dlme-metadata-development \
                -e AWS_ACCESS_KEY_ID=AKIAIJIZROPT5GQ \
                -e AWS_SECRET_ACCESS_KEY=oLNK4CF/5L/M6DXbM2JNmFrpGgbxcE5 \
                -e SNS_TOPIC_ARN=arn:aws:sns:us-west-2:418214828013:dlme-development \
                suldlss/dlme-transform:latest \
                stanford/maps
```
Note that actual S3 credentials are available from `shared_configs`.

For more information on traject, [read the documentation](https://github.com/traject/traject#Traject)

### Configuring transforms
Configuration for transforms is specified in `config/metadata_mappings.json`. For example:

```
[
  {
    "trajects": [
        "mods_config.rb"
    ],
    "paths": [
      "stanford/maps"
    ],
    "extension": ".mods",
    "settings": {
      "agg_provider": "Stanford Libraries",
      "agg_data_provider": "Stanford Libraries",
      "inst_id": "stanford"
    }
  }
]
```

This specifies that `mods_configs.rb` is to be used for any files ending in `.mods` found in `stanford/maps`. `settings`
are provide to the Traject indexer as additional settings.

`extension` is optional; the default is `.xml`.

Additional metadata mappings can be added to this file. In case a metadata file matches more than one configuration, the
first one wins.

## API Documentation
https://www.rubydoc.info/github/sul-dlss/dlme-transform

## Transformation notes
### Unmapped languages
For the `cho_language` and `cho_edm_type` fields, setting a default of `NOT FOUND` will cause validation to fail when an
unmapped language is encountered. For example:

```
to_field 'cho_language', extract_xpath("#{record}/dc:language", ns: NS), first_only,
         strip, translation_map('not_found', 'marc_languages')
```
