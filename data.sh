#!/bin/sh

ES_URI=${ES_URI:-https://elasticsearch/_xpack/sql?format=csv}
PGSQL_HOST=${PGSQL_HOST:-localhost}
PGSQL_USER=${PGSQL_USER:-user}
PGSQL_DB=${PGSQL_DB:-metics}
QUERY_STRING=${QUERY_STRING:-"SELECT * FROM INDEX"}
INSERT_STRING=${INSERT_STRING:-'INSERT INTO TABLE x VALUES'}
SED_ES_INDEX_STRING="logstash-mi-$(date +%Y.%m.%d)"


cat << EOF > request.payload
{ "query": "${QUERY_STRING}" }
EOF

sed -i "s/INDEXNAME/${SED_ES_INDEX_STRING}/g" request.payload

function get_data {
  curl -s -X POST $ES_URI \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d @request.payload
}

DATA=$(get_data | tail -n +2 | sed -e "s|^|('|"  -e "s|,|','|g"  -e "s|.$|');|" -e "s|''|null|g" )
IFS=$(echo -en "\n\b")
for x in ${DATA} ; do echo $INSERT_STRING $x >> insert.script; done

psql -h ${PGSQL_HOST} -d ${PGSQL_DB} -U ${PGSQL_USER} -f insert.script

rm request.payload insert.script
