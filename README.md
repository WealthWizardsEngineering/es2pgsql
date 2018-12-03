#A simple script to pull data from Elasticsearch and into Postgres. 

(Why? you might ask; becuase we're building a datawarehouse and Postgres is where that lives, therefore, we want data from all sources in the Postgres DBs)

The script relies on the elasticsearch experimantal SQL interface available in X-Pack. this allows you to query data using SQL queries, but also to display it as CSV, which is better for ETL work.

The script will pull down the data, clean it up to make it a more robust CSV format and then insert into Postgres

The script is intended to be run several times per day, attempting to insert the same data into Postgres. This is dirty and hacky, for for the time-being sufficient. 
To avoid duplicating the data, put some appropriate constraints on the columns in Postgres to make inserts unique. The script will then fail to create a duplicate record and move on to the next. 

The script could be refined to pull down the last update record and limit the ES query to avoid dupes if preferred. 

## Required Env Vars:
### the location of the ES cluster with x-pack installed. e.g.:
ES_URI=https://elasticsearch.local/_xpack/sql?format=csv
### the destination Postgres host
PGSQL_HOST=warehouse.rds.amazonaws.com
### destination Postgres username
PGSQL_USER=in
### destination Postgres database name
PGSQL_DB=warehouse
### the Postgres user password
PGPASSWORD=shoveyourdatahere
### this is a bit(!) hacky... ES indices often have a date in them. The bash script makes it difficult to evaluate the current data in the here file, so use a sed hack to replace with the correct index name
SED_ES_INDEX_STRING="mi-$(date +%Y.%m.%d)"
### the SQL query to make against the ES index. the INDEXNAME is replaced with the value in the SED_ES_INDEX_STRING var
QUERY_STRING=SELECT \"@timestamp\",things FROM \"INDEXNAME\" where wibble = false
### the string used to push data in to Postgres. The values are the tidied-up CSV data pulled down from ES (see data.sh for more info. )
INSERT_STRING=INSERT INTO public.logstash_mi("timestamp", things) VALUES
