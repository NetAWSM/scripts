export PG_ADM_US=login
export PG_ADM_PW=pass
export PG_HOST=127.0.0.1

# get db.list
psql -qAt  "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/postgres" -c "select datname from pg_database;" | sort | uniq | grep -v "postgres\|template\|any_db" | grep -v "^$" > ./db.list && echo "=== CHECKING ===" && cat ./db.list

# get dumps
for DB in $(cat db.list); do \
  echo "INFO: dump ${DB}" && \
  pg_dump -Ft "postgres://${PG_ADM_US}:${PG_ADM_PW}@${PG_HOST}:5432/${DB}" -f ${DB}.gz
done
