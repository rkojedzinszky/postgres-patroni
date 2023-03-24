# rkojedzinszky/postgres-patroni

This is a Debian Bullseye based image containing PostgreSQL versions 11 and 13. patroni is installed with
dependencies to be used inside a Kubernetes cluster.

Upon startup the image whill check for existing data directory, and will set up PATH according, so patroni will
use the right binaries. By default, new cluster will be initialized to PostgreSQL version 13. To force the image
to explicitly initialize version 11, you must pass the environment variable `FORCE_PG_VERSION=11`.

## Usage

Install with [patroni-postgres-chart](https://github.com/rkojedzinszky/patroni-postgres-chart).
