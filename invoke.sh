#!/bin/sh
set -e

traject -Ilib -w Traject::JsonWriter $@ | tee output/output.json
