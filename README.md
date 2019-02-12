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

### Run

Getting Traject configs and DLME data from Github:
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
container is mounted from `./output` outside the container.)


For developing the mapping, you may want to link in local Traject configs and
metadata. You can add a volume for the configs and for the metadata, and skip
fetching them from Github.

```
docker run --rm -e SKIP_FETCH_CONFIG=true \
                -e SKIP_FETCH_DATA=true \
                -v $(pwd)/config:/opt/traject/config \
                -v $(pwd)/data:/opt/traject/dlme-metadata \
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
