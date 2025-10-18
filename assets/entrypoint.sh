#!/bin/sh

: ${PATRONI_INITIAL_SYNCHRONOUS_MODE:=false}
: ${PATRONI_INITIAL_SYNCHRONOUS_MODE_STRICT:=false}
: ${PATRONI_INITIAL_SYNCHRONOUS_NODE_COUNT:=1}
: ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION:=scram-sha-256}

PATRONI_NODE_TAG_ENV_PREFIX="PATRONI_NODE_$(echo "${PATRONI_NAME}" | sed -e "s/-/_/g")_TAG"
get_node_tag()
{
	local var="$1"

	eval echo "\$${PATRONI_NODE_TAG_ENV_PREFIX}_${var}"
}

if [ -z "$PG_VERSION" ]; then
  echo "[-] PG_VERSION not set. See https://github.com/rkojedzinszky/postgres-patroni#rkojedzinszkypostgres-patroni" >&2
  exit 1
fi

if ! test -d "/usr/lib/postgresql/$PG_VERSION/bin"; then
  echo "[-] Desired PostgreSQL version not supported ($PG_VERSION)" >&2
  exit 2
fi

export PATH="/usr/lib/postgresql/$PG_VERSION/bin:$PATH"
unset PG_VERSION

# generate bootstrap and tags configuration
_umask=$(umask)
umask 077
cat > patroni.yml <<__EOF__
bootstrap:
  dcs:
    synchronous_mode: ${PATRONI_INITIAL_SYNCHRONOUS_MODE}
    synchronous_mode_strict: ${PATRONI_INITIAL_SYNCHRONOUS_MODE_STRICT}
    synchronous_node_count: ${PATRONI_INITIAL_SYNCHRONOUS_NODE_COUNT}
    postgresql:
      parameters:
        password_encryption: ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}
      use_pg_rewind: true
  initdb:
  - auth-host: ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}
  - auth-local: trust
  - encoding: UTF8
  - locale: C
  - data-checksums
  pg_hba:
  - host all all 0.0.0.0/0 ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}
  - host replication ${PATRONI_REPLICATION_USERNAME} ${PATRONI_KUBERNETES_POD_IP}/16 ${POSTGRES_INITIAL_PASSWORD_ENCRYPTION}

tags:
__EOF__

for var in nosync nofailover; do
	value=$(get_node_tag "$var")
	if [ -n "$value" ]; then
		echo "  $var: $value"
	fi
done >> patroni.yml

umask $_umask

# configuration through environment, with defaults
: ${POSTGRESQL_PORT:=5432}

# patroni configuration set through environment, with defaults
: ${PATRONI_POSTGRESQL_DATA_DIR:=/var/lib/postgresql/data}
: ${PATRONI_POSTGRESQL_PGPASS:=/tmp/pgpass}
: ${PATRONI_POSTGRESQL_LISTEN:=0.0.0.0:${POSTGRESQL_PORT}}
: ${PATRONI_POSTGRESQL_CONNECT_ADDRESS:=${PATRONI_KUBERNETES_POD_IP}:${POSTGRESQL_PORT}}
: ${PATRONI_RESTAPI_LISTEN:=0.0.0.0:8008}
: ${PATRONI_RESTAPI_CONNECT_ADDRESS:=${PATRONI_KUBERNETES_POD_IP}:8008}

export PATRONI_POSTGRESQL_DATA_DIR PATRONI_POSTGRESQL_PGPASS PATRONI_POSTGRESQL_LISTEN PATRONI_POSTGRESQL_CONNECT_ADDRESS \
  PATRONI_RESTAPI_LISTEN PATRONI_RESTAPI_CONNECT_ADDRESS

exec patroni patroni.yml
