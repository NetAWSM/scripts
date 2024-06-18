#!/bin/bash

export PG_ADM_US="log"
export PG_ADM_PW="pass"
export own="own"
export PG_HOST=127.0.0.1


for DB in $(cat db.list); do \
  echo "===================== ${DB} =======================";
  psql -qAt "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/postgres" -c "GRANT ALL PRIVILEGES ON DATABASE \"${DB}\" TO \"${own}\";";
  psql -qAt "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/${DB}" -c "ALTER DATABASE \"${DB}\" OWNER TO \"${own}\";";
  for SCHEMA in $(psql -qAt "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/${DB}" -c "SELECT SCHEMA_NAME FROM information_schema.schemata where schema_name not like 'pg_%' and schema_name not like 'information_%';"); do
    echo "===================== $SCHEMA "
    psql -qAt "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/${DB}" -c "ALTER SCHEMA \"${SCHEMA}\" OWNER TO \"${own}\";";
    for TABLE in $(psql -qAt "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/${DB}" -c "SELECT table_name FROM information_schema.tables where table_schema in ('${SCHEMA}');"); do
      echo "======= $TABLE"
      psql -qAt "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/${DB}" -c  "ALTER TABLE \"${SCHEMA}\".\"${TABLE}\" OWNER TO \"${own}\"";
    done;
  done;
done > fix_permissions.log 2>&1
