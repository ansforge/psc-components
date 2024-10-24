# psc-components

A suite of deployment scripts for the many components (message broker, DBs, prometheus, alertmanager, etc..) that make up the ProSanteConnect ecosystem

## Test in dev instances

To avoid confusion, waypoint projects should be left to point to their environement branch.
However, to test a specific version in the dev instance, 
another reference may be deployed by adding `-remote-source=ref=<gitref>`
to the `waypoint up` command. For example, to test main in developement :

`waypoint up -local=false -remote-source=ref=main`

## Distribution history

This ecosystem uses many independant components, some of which live an independant life in distinct repositories.
For each release of sec-psc, the [DISTRIBUTION.md](./DISTRIBUTION.md) file will record all used component versions,
so that we can keep track of compatible component versions, and go back to a previous working distribution if need be.