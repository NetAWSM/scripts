#!/bin/bash

export PG_ADM_US=login
export PG_ADM_PW=pass
export PG_HOST=127.0.0.1
export PG_PORT=5432

start=$(date +%s.%N)

date > restore.log
for DB in $(cat db.list); do \
  ls ${DB}.gz >/dev/null 2>&1 && \
  echo "===================== ${DB} =======================" && \
  echo "INFO: restore ${DB}" && \
  psql "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:${PG_PORT}/postgres" -c "DROP DATABASE IF EXISTS \"${DB}\";" && \
  psql "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:${PG_PORT}/postgres" -c "CREATE DATABASE \"${DB}\";" && \
  pg_restore -x -O --role="${PG_ADM_US}" -d "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:${PG_PORT}/${DB}" ${DB}.gz || \
  echo -e "\t\t\t\tERROR: ${DB}"
done >> restore.log 2>&1
date >> restore.log

end=$(date +%s.%N)
