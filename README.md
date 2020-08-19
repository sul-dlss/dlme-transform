# dlme-transform
[![CircleCI](https://circleci.com/gh/sul-dlss/dlme-transform.svg?style=svg)](https://circleci.com/gh/sul-dlss/dlme-transform "continuous integration status")
[![Maintainability](https://api.codeclimate.com/v1/badges/5c6bcb444addcfdcba8b/maintainability)](https://codeclimate.com/github/sul-dlss/dlme-transform/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5c6bcb444addcfdcba8b/test_coverage)](https://codeclimate.com/github/sul-dlss/dlme-transform/test_coverage)
[![Docker Container](https://images.microbadger.com/badges/image/suldlss/dlme-transform.svg)](https://microbadger.com/images/suldlss/dlme-transform "docker container image")
[![Latest Commit](https://images.microbadger.com/badges/commit/suldlss/dlme-transform.svg)](http://microbadger.com/images/suldlss/dlme-transform "latest commit")

Transforms raw DLME metadata from https://github.com/sul-dlss/dlme-metadata and
uses transformations in `traject_configs/` to create [DLME intermediate
representation](https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md)
documents in S3.

You can read more about our data and related documentation in our [data
documentation](./docs/README.md).

## Docker

When there are commits to master, webhooks are set up for CircleCI to run tests, and if successful, build a docker image and publish that docker image to Docker Hub.

You can also do this manually (see below).  You only need the local docker image to run tranforms locally;  no need to publish the image to Docker Hub.

### Build image
```shell
docker build --build-arg VCS_REF=`git rev-parse --short HEAD` \
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
everything is update to date on the master branches):

```shell
docker run --rm -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest \
                stanford/maps/data/kj751hs0595.mods
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
docker run --rm -e SKIP_FETCH_DATA=true \
                -v $(pwd)/.:/opt/traject \
                -v $(pwd)/../dlme-metadata:/opt/traject/data \
                -v $(pwd)/output:/opt/traject/output \
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
docker run --rm -e SKIP_FETCH_DATA=true \
                -v $(pwd)/.:/opt/traject \
                -v $(pwd)/../dlme-metadata:/opt/traject/data \
                -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest \
                stanford/maps/data/kj751hs0595.mods \
                -w
```

Sending output to S3 bucket and publishing an SNS notification:
```shell
docker run --rm -e S3_BUCKET=dlme-metadata-development \
                -e AWS_ACCESS_KEY_ID=AKIAIJIZROPT5GQ \
                -e AWS_SECRET_ACCESS_KEY=oLNK4CF/5L/M6DXbM2JNmFrpGgbxcE5 \
                -e SNS_TOPIC_ARN=arn:aws:sns:us-west-2:418214828013:dlme-development \
                suldlss/dlme-transform:latest \
                stanford/maps
```
Note that actual S3 credentials are available from `shared_configs`.

For more information on traject, [read the documentation](https://github.com/traject/traject#Traject)

### Sending tranformation result to S3

```
docker run --rm -e PUSH_TO_AWS=true \
                -e S3_BUCKET=dlme-metadata-dev \
                -e DEV_ROLE_ARN=[DEVELOPERS ROLE ARN] \
                -e AWS_ACCESS_KEY_ID=[YOUR ACCESS KEY] \
                -e AWS_SECRET_ACCESS_KEY=[YOUR SECRET ACCESS KEY] \
                -e AWS_DEFAULT_REGION=us-west-2 \
                -e SNS_TOPIC_ARN=arn:aws:sns:us-west-2:418214828013:dlme-status \
                -e SKIP_FETCH_DATA=true \
                -v $(pwd)/../dlme-transform:/opt/traject \
                -v $(pwd)/../dlme-metadata:/opt/traject/data \
                -v $(pwd)/tmp/output:/opt/traject/output \
                --network="host" \
                suldlss/dlme-transform:latest \
                stanford/rumsey-maps/data/rumsey-maps-1.json
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

dlme-transform is "deployed" to AWS environments via terraform.

Using dlme-transform in the deployed environments requires a DLME account with ? admin ? access so you can get to, e.g. https://spotlight.dev.dlmenetwork.org/transform .

### DLSS Terraform for AWS

This is best explained by the README:  https://github.com/sul-dlss/terraform-aws

### Development environment

Terraform tells AWS to use the `latest` docker image of dlme-transform to use for the development environment.

In order to update dlme-transform in AWS, we need to use terraform to tell AWS to re-grab the (now new) latest image.

First:  ensure the latest image on Docker Hub has the changes you want.  CircleCI should automatically create a new latest image when new commits are pushed to master (i.e. merged PRs).  You can confirm this by looking for the successful "publish-latest" step completion https://circleci.com/gh/sul-dlss/dlme-transform or by looking for the timestamp on the latest image at Docker Hub:  https://hub.docker.com/r/suldlss/dlme-transform/tags.

In the case of this code base, dlme-transform, a PR to https://github.com/sul-dlss/terraform-aws must be made that updates the "DEPLOYED" environment variable.  We use a date_time format; for an example, see https://github.com/sul-dlss/terraform-aws/pull/525.

Some more info here https://github.com/sul-dlss/terraform-aws/blob/master/organizations/development/dlme/README.md

After this, terraform must be "applied" to the development environment by a developer or Ops.

### Stage and Production environments

We use tagged docker image releases for Stage and Prod environments.

#### Create a Tagged Docker Image

All you will need to do is publish a new release on github; a webhook will automatically trigger CircleCi to publish the tagged release to Docker Hub.

1. Draft a github release first to describe the changes since the last release in detail:
- https://github.com/sul-dlss/dlme-transform/releases hit "Draft a New Release" button in upper right
- following the format of other releases, fill in the form
- "Save Draft"  (NOT:  "Publish Release")

2. On your laptop, create a tag and push it to github

```
git tag 1.1.3
git push origin --tags
```

3.  Go to https://github.com/sul-dlss/dlme-transform/releases/new?tag=1.1.3 and "Publish Release".

4.  Confirm the new tagged release is available in Docker Hub. CircleCI should automatically create a new tagged image via a webhook.  You can confirm this by looking for the successful "publish-tag" step completion https://circleci.com/gh/sul-dlss/dlme-transform or by looking for the new tag at Docker Hub:  https://hub.docker.com/r/suldlss/dlme-transform/tags.

#### Deploy New Tagged Release to AWS

Terraform tells AWS which tagged image of dlme-transform to use for staging and production environments.

In the case of this code base, dlme-transform, a PR to https://github.com/sul-dlss/terraform-aws must be made that updates the "image" variable for dlme-transform, e.g. `"suldlss/dlme-transform:1.1.3"`.  For an example, see https://github.com/sul-dlss/terraform-aws/pull/525.

Some more info here https://github.com/sul-dlss/terraform-aws/blob/master/organizations/staging/dlme/README.md, https://github.com/sul-dlss/terraform-aws/tree/master/organizations/production/dlme

After this, terraform must be applied to the Stage and Prod environments.  Note that only Ops folks can update the Production environment.

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
