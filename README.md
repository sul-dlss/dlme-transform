# dlme-transform
[![CircleCI](https://circleci.com/gh/sul-dlss/dlme-transform.svg?style=svg)](https://circleci.com/gh/sul-dlss/dlme-transform "continuous integration status")
[![codecov](https://codecov.io/github/sul-dlss/dlme-transform/graph/badge.svg?token=WqpQpXvUMh)](https://codecov.io/github/sul-dlss/dlme-transform)

Transforms raw DLME metadata from https://github.com/sul-dlss/dlme-metadata and
uses transformations in `traject_configs/` to create [DLME intermediate
representation](https://github.com/sul-dlss/dlme/blob/main/docs/application_profile.md)
documents in S3.

You can read more about our data and related documentation in our [data
documentation](./docs/README.md).

## Docker

When there are commits to main, webhooks are set up for CircleCI to run tests, and if successful, build a docker image and publish that docker image to Docker Hub.

You can also do this manually (see below).  You only need the local docker image to run tranforms locally;  no need to publish the image to Docker Hub.

### Build image
```shell
docker build --no-cache \
             --build-arg VCS_REF=`git rev-parse --short HEAD` \
             --build-arg VCS_URL=`git config --get remote.origin.url` \
             --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
             . -t suldlss/dlme-transform:latest
```

### Publish Docker Image to Docker Hub
```shell
docker push suldlss/dlme-transform:latest
```

### Running Transforms

You can run transforms locally by getting DLME data from GitHub (assuming
everything is update to date on the main branches):

```shell
docker run --rm -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest \
                stanford/maps/data/kj751hs0595.mods
```

Optionally set the data dir in the environment:

```shell
docker run --rm -e DATA_PATH=stanford/maps/data/kj751hs0595.mods \
                -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest
```

The output will appear in STDOUT inside the container and be written to
`/opt/traject/output`. (In this example, `/opt/traject/output` inside the
container is mounted from `./output` outside the container, which will
correspond to the 'output' subfolder in your locally cloned dlme-transform
repo.)

For development purposes, instead of pulling harvested data to transform from
GitHub, you can pull it in locally. This may be useful as you test Traject
config changes before pushing them to GitHub. To do this, map in a local
directory using the `-v` switch. Similarly, you can pull in local macros and
translation maps.

Note: you should use your actual local directories in place of the two example
directories below specified with the `-v` switch for data and output. In the
example below, the `dlme-metadata` repository is cloned one directory up from
the `dlme-transform` repository we are running from. Output will be written to
the output subfolder of the `dlme-transform` repo (your current directory) as in
the GitHub example above.

Instead of specifying a directory relative to the current directory (as in the
example below), you could also specify an absolute path on your machine, like
`/Users/YourName/development/dlme-metadata`. Be sure to specify the root of the
checked out repositories in each case.

The traject configuration file used for a particular transform is triggered by
the specified data directory. See "Configuring transforms" below.

```shell
docker run --rm -v $(pwd)/.:/opt/traject \
                -v $(pwd)/../dlme-metadata:/opt/airflow/working \
                -v $(pwd)/output:/opt/traject/output \
                -v $(pwd)/output:/opt/airflow/metadata \
                suldlss/dlme-transform:latest \
                stanford/maps/data/kj751hs0595.mods
```

To process multiple files, specify a directory instead of a single file. For
example, `stanford/maps` instead of `stanford/maps/data/kj751hs0595.mods`. To
transform everything, specify nothing.

```shell
docker run --rm -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest
```

The `-w` switch can be used to debug transformations. It will stop the transform upon encountering an error.

```shell
docker run --rm -v $(pwd)/.:/opt/traject \
                -v $(pwd)/../dlme-metadata:/opt/airflow/working \
                -v $(pwd)/output:/opt/traject/output \
                -v $(pwd)/output:/opt/airflow/metadata \
                suldlss/dlme-transform:latest \
                stanford/maps/data/kj751hs0595.mods \
                -w
```

For more information on traject, [read the documentation](https://github.com/traject/traject#Traject)

Using dlme-transform in the deployed environments requires a DLME account with ? admin ? access so you can view the form here: https://spotlight.dev.dlmenetwork.org/transform .

### Sending tranformation result to the review and prod servers

There are three environments–dev, review, and prod. The review and prod VMs have the same datashare mounted. Pushing data to that datashare directory requires that you are configured to login to the server and have `kinit` setup properly. If you have any questions/issues with your `kinit` setup, please check with the ops team in the `#dlss-operations` slack channel.

The airflow dev server stores the intermediate representation in a shared `datashare` location between airflow and the web app. After you have `kinit`-ed your account, you can see what files are in the datashare with `ssh sunet@dlme-review-prod-a.stanford.edu` and `cd ../../opt/app/dlme/datashare`. Use `scp` to copy the file to the dlme-airflow-dev server:


```
scp [~/Path/To/NDJson/File] sunet@dlme-review-prod-a.stanford.edu:/opt/app/dlme/datashare
```

To copy the file to your local directory, use
```
scp sunet@dlme-airflow-dev.stanford.edu:/opt/app/dlme/dlme-airflow/shared/source_data/file_path .
```

To copy the file to your local directory, use
```
scp sunet@dlme-airflow-dev.stanford.edu:/opt/app/dlme/dlme-airflow/shared/source_data/file_path .
```

The server is load balanced so there are `-a` and `-b` VMs

If the need arises to transfer data to the dev environment, you can do so with:

```
scp [~/Path/To/NDJson/File] sunet@dlme-airflow-dev.stanford.edu:/opt/app/dlme/datashare
```

## Configuring transforms

Configuration for transforms is specified in `config/metadata_mapping.json`. For example:

```json
[
  {
    "trajects": [
        "mods_config.rb",
        "stanford_mods_config.rb"
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

This specifies that `mods_config.rb`, followed by `stanford_mods_config.rb` is
to be used for any files ending in `.mods` found in `stanford/maps`; multiple
Traject configs may be applied to source data. `settings` are provided to the
Traject indexer as additional settings.

`extension` is optional; the default is `.xml`.

Additional metadata mappings can be added to this file. In case a metadata file
matches more than one configuration, the first one wins.

### Sorting transform configs

To enhance readability of the transform configuration (`config/metadata_mapping.json`), a Rake task has been added. The task loads the contents of `config/metadata_mapping.json` into memory, sorts the array alphabetically (ascending, *i.e.*, A-Z) by the first value in the mapping's `paths` array. This way, the mappings for AIMS and AUC will appear before those for Stanford and Princeton and it ought to be easier to locate mappings within the file.

Invoke it like so:

```shell
$ rake mappings:sort
```

Note that this task modifies `config/metadata_mapping.json`, and you will need to commit and push this via version control to persist the changes.

## Deploying

dlme-transform is deployed by publishing an image to docker hub. CircleCI should automatically create a new latest image when new commits are pushed to main (i.e. merged PRs).
You can confirm this by looking for the successful "publish-latest" step completion https://circleci.com/gh/sul-dlss/dlme-transform or by looking for the timestamp on the latest image at Docker Hub:  https://hub.docker.com/r/suldlss/dlme-transform/tags.

Airflow uses the `latest` docker image of dlme-transform. As dlme-transform is run as a docker-in-docker task only and not a standlone service, the tagged `suldlss/dlme-transform:latest` is always pulled from docker hub on launch.

See the dlss Terraform README:  https://github.com/sul-dlss/terraform-aws

## API Documentation
https://www.rubydoc.info/github/sul-dlss/dlme-transform

## Transformation notes
### Unmapped languages
For the `cho_language` and `cho_edm_type` fields, setting a default of `NOT FOUND` will cause validation to fail when an
unmapped language is encountered. For example:

```ruby
to_field 'cho_language', extract_xpath("#{record}/dc:language", ns: NS), first_only,
         strip, translation_map('not_found', 'marc_languages')
```

## Testing

To run the code linter (Rubocop) and the test suite, including unit and integration tests, run:

In order to run the integration tests, you can clone the `dlme-metadata` repo into the `data` subfolder.
All of the files except for `.keep` are git ignored, so they should not be re-added to the `dlme-transform`
repo.

```shell
$ bundle exec rake
```

By default, test setup squelches any output that the code being tested sends to `STDOUT` and `STDERR`.  `DLME::Utils.logger` output is still printed.  This is because test output can be very verbose, especially when using all of `dlme-metadata` in the `data` dir, as is done for CI.  The default behavior can make debugging failing tests easier, especially in CircleCI, where there's a size limit on browser display of test output.

If `STDOUT` or `STDERR` would be useful, output to each from the tests can be allowed by using env vars (independently or together).
```sh
$ bundle exec rspec # default, just the logger output
$ NO_SQUELCH_STDERR=1 bundle exec rspec # allow tests to print to STDERR (plus logger output)
$ NO_SQUELCH_STDOUT=1 bundle exec rspec # allow tests to print to STDOUT (plus logger output), can be very noisy if run over all metadata
$ NO_SQUELCH_STDERR=1 NO_SQUELCH_STDOUT=1 bundle exec rspec # everything
```
