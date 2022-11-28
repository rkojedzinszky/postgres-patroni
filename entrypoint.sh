#!/bin/sh

: ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION:=scram-sha-256}

_umask=$(umask)
umask 077
cat > patroni.yml <<__EOF__
bootstrap:
  dcs:
    postgresql:
      parameters:
        password_encryption: ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}
      use_pg_rewind: true
  initdb:
  - auth-host: ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}
  - auth-local: trust
  - encoding: UTF8
  - locale: en_US.UTF-8
  - data-checksums
  pg_hba:
  - host all all 0.0.0.0/0 ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}
  - host replication ${PATRONI_REPLICATION_USERNAME} ${PATRONI_KUBERNETES_POD_IP}/16 ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}
restapi:
  connect_address: '${PATRONI_KUBERNETES_POD_IP}:8008'
postgresql:
  data_dir: /var/lib/postgresql/data
  connect_address: '${PATRONI_KUBERNETES_POD_IP}:5432'
  authentication:
    superuser:
      password: '${PATRONI_SUPERUSER_PASSWORD}'
    replication:
      password: '${PATRONI_REPLICATION_PASSWORD}'
__EOF__
umask $_umask

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD
export KUBERNETES_NAMESPACE=$PATRONI_KUBERNETES_NAMESPACE
export POD_NAME=$PATRONI_NAME

exec patroni patroni.yml
