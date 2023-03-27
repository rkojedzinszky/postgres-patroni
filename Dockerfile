FROM debian:bullseye-slim

LABEL maintainer Richard Kojedzinszky <richard@kojedz.in>

# This must be a space delimited list
ARG POSTGRES_MODULES="ip4r prefix"

# Patroni version
ARG PATRONI_VERSION=3.0.2

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

COPY assets/ /

RUN apt-get update && apt-get upgrade -y && apt-get install -y locales-all

# Create postgres user manually, with explicit uid/gid
# Arguments taken from /var/lib/dpkg/info/postgresql-common.postinst
RUN groupadd -g 15432 postgres && \
    useradd -g postgres -u 15432 -c "PostgreSQL administrator" -s /bin/bash \
    -d /var/lib/postgresql -M postgres

RUN apt-get install --no-install-suggests --no-install-recommends -y postgresql-common && \
    sed -i -e '/create_main_cluster/s/^.*/create_main_cluster = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install --no-install-suggests --no-install-recommends -y python-is-python3 python3-six \
    $(bash -c "echo postgresql-{11,13} postgresql-{11,13}-{$(echo ${POSTGRES_MODULES} | sed -e "s/ /,/g")}") && \
    apt-get install --no-install-suggests -y python3-pip libpq-dev && \
    pip3 install psycopg2 "patroni[kubernetes]==$PATRONI_VERSION" && \
    apt-get remove -y --autoremove --purge python3-pip libpq-dev && \
    rm -rf /var/lib/apt/ /var/cache/apt/ && \
    patroni --version

# Set default version, but entrypoint.sh overrides this
# based on existing database installation
ENV PATH "$PATH:/usr/lib/postgresql/13/bin"

EXPOSE 5432 8008
USER 15432
WORKDIR /var/lib/postgresql

CMD ["/entrypoint.sh"]
