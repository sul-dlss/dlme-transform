# dlme-transform
[![](https://images.microbadger.com/badges/image/suldlss/dlme-transform.svg)](https://microbadger.com/images/suldlss/dlme-transform "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/suldlss/dlme-transform.svg)](http://microbadger.com/images/suldlss/dlme-transform "Get your own commit badge on microbadger.com")

Transforms raw DLME metadata to DLME intermediate representation

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
                -c config/mods_config.rb \
                -s agg_provider=Stanford \
                -s agg_data_provider=Stanford \
                dlme-metadata/stanford/maps/data/kj751hs0595.mods
```

The output will appear in STDOUT inside the container and be written to
`/opt/traject/output`. (In this example, `/opt/traject/output` inside the
container is mounted from `./output` outside the container, which will correspond
to the 'output' subfolder in your locally cloned dlme-transform repo.)

For development purposes, instead of pulling configs and harvested data to transform from Github,
you can pull them in locally. This may be useful as you test new traject configs before
pushing them to GitHub.  To do this, map in local directories using the -v switch.

Note: you should use your actual local directories in place of three example directories below
specified with the -v switch for configs, data, and output.  In the example below,
the `dlme-traject` and `dlme-metadata` repositories are cloned one directory up from the
`dlme-transform` repository we are running from.  Output will be written to the output
subfolder of the `dlme-transform` repo (your current directory) as in the Github example above.

Instead of specifying a directory relative to the current directory (as in the example below),
you could also specify an absolute path on your machine, like
`/Users/YourName/development/dlme-metadata`.  Be sure to specify the root of the
checked out repositories in each case.

Specify the Traject config file to use with the -c switch as shown below (e.g. `-c config/traject_config_file.rb`)


```
docker run --rm -e SKIP_FETCH_CONFIG=true \
                -e SKIP_FETCH_DATA=true \
                -v $(pwd)/../dlme-traject:/opt/traject/config \
                -v $(pwd)/../dlme-metadata:/opt/traject/dlme-metadata \
                -v $(pwd)/output:/opt/traject/output \
                suldlss/dlme-transform:latest \
                -c config/mods_config.rb \
                -s agg_provider=Stanford \
                -s agg_data_provider=Stanford \
                dlme-metadata/stanford/maps/data/kj751hs0595.mods
```

To process a directory of files, use a wildcard in the input filepath. For
example, `dlme-metadata/stanford/maps/data/*.mods` instead of
`dlme-metadata/stanford/maps/data/kj751hs0595.mods`.


Sending output to S3 bucket:
```
docker run --rm -e S3_BUCKET=s3://dlme-metadata-development \
                -e AWS_ACCESS_KEY_ID=AKIAIJIZROPT5GQ \
                -e AWS_SECRET_ACCESS_KEY=oLNK4CF/5L/M6DXbM2JNmFrpGgbxcE5 \
                suldlss/dlme-transform:latest \
                -c config/mods_config.rb \
                -s agg_provider=Stanford \
                -s agg_data_provider=Stanford \
                dlme-metadata/stanford/maps/data/kj751hs0595.mods
```
Note that actual S3 credentials are available from `shared_configs`.
