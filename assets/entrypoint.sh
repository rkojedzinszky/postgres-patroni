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

# append node-local tags
echo "tags:" >> patroni.yml
for var in nosync nofailover; do
	value=$(get_node_tag "$var")
	if [ -n "$value" ]; then
		echo "  $var: $value"
	fi
done >> patroni.yml

umask $_umask

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD
export KUBERNETES_NAMESPACE=$PATRONI_KUBERNETES_NAMESPACE
export POD_NAME=$PATRONI_NAME

exec patroni patroni.yml
