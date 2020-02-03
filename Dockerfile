FROM debian:buster-slim

MAINTAINER Richard Kojedzinszky <richard@kojedz.in>

ENV POSTGRES_MAJOR 11
# This must be a space delimited list
ENV POSTGRES_MODULES "ip4r prefix"

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN apt-get update && apt-get upgrade -y

# Create postgres user manually, with explicit uid/gid
# Arguments taken from /var/lib/dpkg/info/postgresql-common.postinst
RUN groupadd -g 15432 postgres && \
    useradd -g postgres -u 15432 -c "PostgreSQL administrator" -s /bin/bash \
    -d /var/lib/postgresql -M postgres

RUN apt-get install -y locales && sed -i -r -e '/en_US/s/^#[[:space:]]*//' /etc/locale.gen && locale-gen

RUN apt-get install --no-install-suggests --no-install-recommends -y postgresql-common && \
    sed -i -e '/create_main_cluster/s/^.*/create_main_cluster = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install --no-install-suggests --no-install-recommends -y python3 python3-six python3-psycopg2 \
        postgresql-${POSTGRES_MAJOR} $(for p in $POSTGRES_MODULES; do echo postgresql-${POSTGRES_MAJOR}-$p; done) && \
    apt-get install --no-install-suggests -y python3-pip && \
    pip3 install https://github.com/rkojedzinszky/patroni/archive/1.6.3-keepalive.zip kubernetes && \
    apt-get remove -y --autoremove --purge python3-pip && \
    rm -rf /var/lib/apt/ /var/cache/apt/

ADD entrypoint.sh /

ENV PATH "$PATH:/usr/lib/postgresql/${POSTGRES_MAJOR}/bin"

EXPOSE 5432 8008
USER postgres
WORKDIR /var/lib/postgresql

CMD ["/entrypoint.sh"]
