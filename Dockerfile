ARG DEBIAN_DIST=bullseye

FROM debian:${DEBIAN_DIST}-slim

LABEL maintainer Richard Kojedzinszky <richard@kojedz.in>

ARG POSTGRES_MAJOR=13
# This must be a space delimited list
ARG POSTGRES_MODULES="ip4r prefix"

# Patroni version
ARG PATRONI_VERSION=2.1.4

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN apt-get update && apt-get upgrade -y && apt-get install -y locales-all

# Create postgres user manually, with explicit uid/gid
# Arguments taken from /var/lib/dpkg/info/postgresql-common.postinst
RUN groupadd -g 15432 postgres && \
    useradd -g postgres -u 15432 -c "PostgreSQL administrator" -s /bin/bash \
    -d /var/lib/postgresql -M postgres

RUN apt-get install --no-install-suggests --no-install-recommends -y postgresql-common && \
    sed -i -e '/create_main_cluster/s/^.*/create_main_cluster = false/' /etc/postgresql-common/createcluster.conf && \
    (test $(cut -d. -f 1 /etc/debian_version) -ge 11 && P_IS_P3=python-is-python3 || :) && \
    apt-get install --no-install-suggests --no-install-recommends -y ${P_IS_P3} python3-six \
    postgresql-${POSTGRES_MAJOR} $(for p in $POSTGRES_MODULES; do echo postgresql-${POSTGRES_MAJOR}-$p; done) && \
    apt-get install --no-install-suggests -y python3-pip libpq-dev && \
    pip3 install psycopg2 "patroni[kubernetes]==$PATRONI_VERSION" && \
    apt-get remove -y --autoremove --purge python3-pip libpq-dev && \
    rm -rf /var/lib/apt/ /var/cache/apt/ && \
    patroni --version

ADD entrypoint.sh /

ENV PATH "$PATH:/usr/lib/postgresql/${POSTGRES_MAJOR}/bin"

EXPOSE 5432 8008
USER 15432
WORKDIR /var/lib/postgresql

CMD ["/entrypoint.sh"]
