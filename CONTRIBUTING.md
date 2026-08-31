# GitHub Contribution Guideline

## Branch model

`main` is the deployable branch. All changes should arrive through a pull request from a short-lived branch.

Branch naming:

- `feature/QC-123-add-api-validation`
- `fix/QC-124-dlq-alarm-threshold`
- `docs/update-runbook`
- `chore/provider-upgrade`

Avoid long-lived `develop` branches for this small project. Trunk-based development with short-lived branches reduces merge drift and keeps the workflow easy to explain.

## Commit convention

Use small commits with an imperative subject. Conventional Commit prefixes are recommended:

- `feat: add order submission lambda`
- `fix: return partial SQS batch failures`
- `docs: explain FIFO trade-off`
- `test: add duplicate order test`
- `infra: add DLQ alarm`

## Pull request checklist

- [ ] Change has a clear scope and description.
- [ ] No credentials, secrets, state files, or generated ZIPs are committed.
- [ ] `terraform fmt -check -recursive` passes.
- [ ] `terraform validate` passes after `terraform init -backend=false`.
- [ ] `pytest -q` passes.
- [ ] Architecture/docs updated if behavior changes.
- [ ] IAM changes remain least privilege.
- [ ] New failure modes have monitoring or a documented reason not to add it.
- [ ] Reviewer can reproduce the change.

## GitHub settings

For `main`, enable branch protection with:

1. Require pull requests before merging.
2. Require at least one approval for a team project.
3. Require status checks: `terraform` and `python-tests`.
4. Require conversation resolution.
5. Block force pushes and branch deletion.
6. Prefer squash merge to keep a concise history.

For an individual coursework repository, self-review can be documented in the pull request even if GitHub cannot enforce an independent approval.

## Releases

Tag demonstrable milestones:

- `v0.1.0` - queue and basic processing
- `v0.2.0` - retry, DLQ, monitoring
- `v1.0.0` - final documented project
