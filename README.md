# rkojedzinszky/postgres-patroni

This is a Debian Bullseye based image containing PostgreSQL versions 11 and 13. patroni is installed with
dependencies to be used inside a Kubernetes cluster.

Desired PostgreSQL major version must explicitly be set with `PG_VERSION` environment variable.

## Usage

Install with [patroni-postgres-chart](https://github.com/rkojedzinszky/patroni-postgres-chart).
