# rkojedzinszky/postgres-patroni

This is a Debian Bookworm based image containing [Patroni](https://github.com/zalando/patroni)
and multiple PostgreSQL versions from PGDG.

Desired PostgreSQL major version must explicitly be set with `PG_VERSION` environment variable.

## Usage

Install with [patroni-postgres-chart](https://github.com/rkojedzinszky/patroni-postgres-chart).

Also [patroni-postges-operator](https://github.com/k-web-s/patroni-postgres-operator) can be used.

## Image tagging

Images are tagged by date. This represents the day when the image was built.

## Supported Postgresql version policy

The image will contain 2 versions of PostgreSQL from apt.postgresql.org (https://www.postgresql.org/download/linux/debian/).

## Supported versions

Postgresql Version | Tag version first appeared in | Tag version last appeared in
| - | - | -
11 | - | 20250316
13 | - | -
15 | 20230616 | -
