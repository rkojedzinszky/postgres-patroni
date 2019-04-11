FROM debian:buster-slim

MAINTAINER Richard Kojedzinszky <richard@kojedz.in>

ENV POSTGRES_MAJOR 11

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y locales && sed -i -r -e '/en_US/s/^#[[:space:]]*//' /etc/locale.gen && locale-gen

RUN apt-get install --no-install-suggests --no-install-recommends -y postgresql-common && \
    sed -i -e '/create_main_cluster/s/^.*/create_main_cluster = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install --no-install-suggests --no-install-recommends -y postgresql-${POSTGRES_MAJOR} patroni python3-kubernetes

ADD entrypoint.sh /

ENV PATH "$PATH:/usr/lib/postgresql/${POSTGRES_MAJOR}/bin"

EXPOSE 5432 8008
USER postgres
WORKDIR /var/lib/postgresql

CMD ["/entrypoint.sh"]
