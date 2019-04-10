FROM alpine

MAINTAINER Richard Kojedzinszky <richard@kojedz.in>

RUN apk --no-cache add postgresql python3 && ln -s python3 /usr/bin/python && ln -s pip3 /usr/bin/pip

RUN apk --no-cache add -t .build-deps gcc postgresql-dev libc-dev linux-headers python3-dev libffi-dev && \
    pip install 'patroni[kubernetes]' && \
    apk del .build-deps

ADD entrypoint.sh /

EXPOSE 5432 8008
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
USER postgres
WORKDIR /var/lib/postgresql

CMD ["/entrypoint.sh"]
