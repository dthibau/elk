#!/bin/bash

  index=$(echo "jboss-david-2016")
  documents=$(curl -XGET http://cluster:9200/${index}/_count 2>/dev/null | cut -f 2 -d : | cut -f 1 -d ',')
  # Dimensionnement du nombre de shard enn fonction du nbre de documents
  if [ $documents -lt 4000000 ]; then
    shards=1
  elif [ $documents -lt 5000000 ]; then
      shards=2
  else
      shards=$(( $documents / 5000000 + 1)) 
  fi
  
  new_version=$(( $(echo ${index} | cut -f 1 -d _) + 1)) 
  index_name=$(echo ${index} | cut -f 2 -d _)
  
  curl -XPUT http://cluster:9200/${new_version}${index_name} -d '{  
  "number_of_shards" : '${shards}' 
  }'
curl -XPOST http://cluster:9200/_reindex -d '{ 
  "source": {
    "index": "'${index}'"
  },
  "dest": {
    "index": "'${new_version}${index_name}'"
  }
}'

