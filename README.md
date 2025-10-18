# postgres-patroni

> [!WARNING]
> Images built on or after `2025-10-17` have Patroni version 4 in place of version 3, which changes the default leader role from `master`
> to `primary`. This might result in service disruption if not handled properly.
> For more see [Version 4.0.0](https://patroni.readthedocs.io/en/latest/releases.html#version-4-0-0) release notes
> and [Customize role label](https://patroni.readthedocs.io/en/latest/kubernetes.html#kubernetes-role-values) sections.

This is a Debian Bookworm based image containing [Patroni](https://github.com/zalando/patroni) version 4
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

Postgresql Version | introduced in tag | last supporting tag
-|-|-
11 | - | 20250316
13 | - | 20251017
15 | 20230616 | -
17 | 20251018 | -
