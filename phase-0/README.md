# Phase 0 · Foundations

## Overview
Establish Dragoncave baseline practices, prerequisites, and shared automation before deploying workloads.

## Scope
- Capture hardware, network, and naming decisions in `/docs`.
- Align baseline security expectations with `docs/SECURITY_BASELINES.md`.
- Validate tooling by running the shared preflight diagnostics.

## Definition of Done
- [ ] `docs/PHASES_OVERVIEW.md` updated with phase decisions.
- [ ] `make preflight` executes without errors.
- [ ] YAML manifests pass `yamllint`.
- [ ] Shell automation passes `shellcheck`.
- [ ] Dockerfiles pass `hadolint` (when present).
