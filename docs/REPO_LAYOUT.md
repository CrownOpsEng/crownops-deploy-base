# Repo Layout

This collection repo should stay clean and reusable.

## Recommended split

`VPS/crownops-deploy-base`
- shared collection repo
- no production inventory
- no secrets
- no feature-specific application roles
- reusable host capabilities such as bootstrap and staged network lockdown

`VPS/crownops-deploy-core`
- deployment playbooks
- feature orchestration
- operator docs

`VPS/crownops-deploy-services`
- shared service-stack collection repo
- reusable application and backup roles

`VPS/crownops-deploy-edge`
- separate deployment repo for edge-facing services

## Why this split exists

- avoids leaking environment-specific data into the shared base layer
- keeps GitHub history clean
- lets multiple deployments consume the same hardened bootstrap role
- lets multiple deployments consume the same post-join lockdown controls
- makes the base collection safe to publish independently

## Consumption model

The deployment repo should:
1. install public collection dependencies
2. install this collection from GitHub
3. call the collection role by FQCN

Example FQCN:

```yaml
- role: crownops.deploy_base.bootstrap_host
- role: crownops.deploy_base.network_lockdown
```
