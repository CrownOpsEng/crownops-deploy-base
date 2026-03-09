# Repo Layout

This collection repo should stay clean and reusable.

## Recommended split

`VPS/crownops-deploy-base`
- shared collection repo
- no production inventory
- no secrets
- no feature-specific application roles

`VPS/crownops-deploy-core`
- deployment playbooks
- feature orchestration
- operator docs

`VPS/crownops-deploy-edge`
- environment-specific inventory or secret overlays
- operator-only data that should not live in the published deployment repos

## Why this split exists

- avoids leaking environment-specific data into the shared base layer
- keeps GitHub history clean
- lets multiple deployments consume the same hardened bootstrap role
- makes the base collection safe to publish independently

## Consumption model

The deployment repo should:
1. install public collection dependencies
2. install this collection from GitHub
3. call the collection role by FQCN

Example FQCN:

```yaml
- role: crownops.deploy_base.bootstrap_host
```
