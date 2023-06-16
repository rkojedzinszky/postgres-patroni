# rkojedzinszky/postgres-patroni

This is a Debian Bookworm based image containing [Patroni](https://github.com/zalando/patroni)
and PostgreSQL versions 11, 13 and 15.

Desired PostgreSQL major version must explicitly be set with `PG_VERSION` environment variable.

## Usage

Install with [patroni-postgres-chart](https://github.com/rkojedzinszky/patroni-postgres-chart).

## Supported Postgresql version policy

The image will contain PostgreSQL versions supported by stable Debian distributions.

PostgreSQL 15 was added on 20230616.
