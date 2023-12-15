# References:
# > https://hub.docker.com/_/postgres/
#

FROM postgres:10.13

ENV \
    POSTGRES_DB=ehmdb \
    POSTGRES_USER=ehm \
    POSTGRES_PASSWORD=ehm \
    PGDATA=/var/lib/postgresql/data/pgdata

COPY initdb/ /docker-entrypoint-initdb.d/
