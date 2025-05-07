# rkojedzinszky/postgres-patroni

This is a Debian based image containing [Patroni](https://github.com/zalando/patroni)
and multiple PostgreSQL versions.

Desired PostgreSQL major version must explicitly be set with `PG_VERSION` environment variable.

## Usage

Install with [patroni-postgres-chart](https://github.com/rkojedzinszky/patroni-postgres-chart).

Also [patroni-postges-operator](https://github.com/k-web-s/patroni-postgres-operator) can be used.

## Image tagging

Images are tagged by date. This represents the day when the image was built.

## Supported Postgresql version policy

The image will contain PostgreSQL versions supported by stable Debian distributions.

PostgreSQL 15 was added on 20230616.

## Supported versions

Postgresql Version | Tag version first appeared in | Tag version last appeared in
| - | - | -
11 | - | 20250316
13 | - | -
15 | 20230616 | -
