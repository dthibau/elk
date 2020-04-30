#!/bin/sh

coded=`cat DocumentAPI.pdf | perl -MMIME::Base64 -ne 'print encode_base64($_)'`
json="{\"data\":\"${coded}\"}"
echo "$json" > json.file
curl -X POST "localhost:9200/test/attachment/?pipeline=attachment" -d @json.file
