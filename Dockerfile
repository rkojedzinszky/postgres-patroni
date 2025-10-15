FROM debian:bookworm-slim

LABEL maintainer Richard Kojedzinszky <richard@kojedz.in>

# This must be a space delimited list
ARG POSTGRES_MODULES="ip4r prefix"

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

COPY assets/ /

RUN apt-get update && apt-get upgrade -y && apt-get install -y locales-all jq rsync netcat-openbsd

# Create postgres user manually, with explicit uid/gid
# Arguments taken from /var/lib/dpkg/info/postgresql-common.postinst
RUN groupadd -g 15432 postgres && \
    useradd -g postgres -u 15432 -c "PostgreSQL administrator" -s /bin/bash \
    -d /var/lib/postgresql -M postgres

RUN apt-get install --no-install-suggests --no-install-recommends -y postgresql-common ca-certificates && \
    sed -i -e '/create_main_cluster/s/^.*/create_main_cluster = false/' /etc/postgresql-common/createcluster.conf && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    apt-get install --no-install-suggests --no-install-recommends -y patroni/bookworm \
    $(bash -c 'eval echo postgresql-{13,15} postgresql-{13,15}-{${POSTGRES_MODULES// /,}}') && \
    rm -rf /var/lib/apt/ /var/cache/apt/ && \
    patroni --version

EXPOSE 5432 8008
USER 15432
WORKDIR /var/lib/postgresql

CMD ["/entrypoint.sh"]
