#!/bin/sh

coded=`cat fn6742.pdf | perl -MMIME::Base64 -ne 'print encode_base64($_)'`
json="{\"file\":\"${coded}\"}"
echo "$json" > json.file
curl -X POST "localhost:9200/test/attachment/" -d @json.file