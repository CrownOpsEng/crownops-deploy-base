# Repo Layout

This collection repo should stay clean and reusable.

## Recommended split

`000-vps-base/crownops-vps-base`
- shared collection repo
- no production inventory
- no secrets
- no provider-specific application roles

`00x-<environment>/<deployment-repo>`
- environment inventory
- vault files
- deployment wrappers
- provider/application-specific roles
- operator docs for that environment

## Why this split exists

- avoids leaking environment-specific data into the shared base layer
- keeps GitHub history clean
- lets multiple deployments consume the same hardened bootstrap role
- makes the base role safe to publish internally or externally later

## Consumption model

The deployment repo should:
1. install public collection dependencies
2. build/install this collection from the checked-out base repo
3. call the collection role by FQCN

Example FQCN:

```yaml
- role: crownops.vps_base.bootstrap_host
```
