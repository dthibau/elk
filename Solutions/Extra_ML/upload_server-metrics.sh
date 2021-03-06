#!/bin/bash

## To create with security disabled remove -u username:password to curl commands

HOST='localhost'
PORT=9200
INDEX_NAME='server-metrics'
URL="http://${HOST}:${PORT}"
USERNAME=elastic
PASSWORD=changeme
printf "\n== Script for creating index and uploading data == \n \n"
printf "\n== Deleting old index == \n\n"
curl -s  -X DELETE ${URL}/${INDEX_NAME}

printf "\n== Creating Index - ${INDEX_NAME} == \n\n"
curl -s -X PUT -H 'Content-Type: application/json' ${URL}/${INDEX_NAME} -d '{  
   "settings":{  
      "number_of_shards":1,
      "number_of_replicas":0
   },
   "mappings":{  
      "metric":{  
         "properties":{  
            "@timestamp":{  
               "type":"date"
            },
            "accept":{  
               "type":"long"
            },
            "deny":{  
               "type":"long"
            },
            "host":{  
               "type":"keyword"
            },
            "response":{  
               "type":"float"
            },
            "service":{  
               "type":"keyword"
            },
            "total":{  
               "type":"long"
            }
         }
      }
   }
}'

printf "\n== Bulk uploading data to index... \n"
curl -s -X POST -H "Content-Type: application/json" ${URL}/${INDEX_NAME}/_bulk --data-binary "@server-metrics_1.json"
printf "\nServer-metrics_1 uploaded"
curl -s -X POST -H "Content-Type: application/json" ${URL}/${INDEX_NAME}/_bulk --data-binary "@server-metrics_2.json"
printf "\nServer-metrics_2 uploaded"
curl -s -X POST -H "Content-Type: application/json" ${URL}/${INDEX_NAME}/_bulk --data-binary "@server-metrics_3.json"
printf "\nServer-metrics_3 uploaded"
curl -s -X POST -H "Content-Type: application/json" ${URL}/${INDEX_NAME}/_bulk --data-binary "@server-metrics_4.json"
printf "\nServer-metrics_4 uploaded\n"
