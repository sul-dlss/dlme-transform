# dlme-transform
Transforms raw DLME metadata to DLME intermediate representation

## Docker
### Build Docker image
```
docker build . -t "suldlss/dlme-transform:latest"
```

### Run
Linking in local Traject configs and DLME data:
```
docker run --rm -v /Users/jlittman/data/dlme/dlme/lib:/opt/traject/lib -v /Users/jlittman/data/dlme/dlme-metadata:/opt/traject/dlme-metadata -v /Users/jlittman/data/dlme/dlme-transform/output:/opt/traject/output suldlss/dlme-transform:latest -c lib/traject/bnf_cealex_config.rb -s agg_provider=Stanford -s agg_data_provider=Stanford dlme-metadata/bnf/cealex/data/cealex-1.xml
```
Note that output will appear in STDOUT inside the container and be written to `/opt/traject/output`. (In this example, `/opt/traject/output` inside the container is mounted from `/Users/jlittman/data/dlme/dlme-transform/output` outside the container.)

To process a directory of files, use a wildcard in the input filepath. For example, `dlme-metadata/bnf/cealex/data/cealex-*.xml` instead of `dlme-metadata/bnf/cealex/data/cealex-1.xml`.

Getting Traject configs and DLME data from Github:
```
docker run --rm -e USE_GITHUB=true -v /Users/jlittman/data/dlme/dlme-transform/output:/opt/traject/output suldlss/dlme-transform:latest -c lib/traject/bnf_cealex_config.rb -s agg_provider=Stanford -s agg_data_provider=Stanford dlme-metadata/bnf/cealex/data/cealex-1.xml
```
