# Terraform Implementation

## Resource map

| File | Terraform objects |
|---|---|
| `versions.tf` | Terraform/provider version constraints |
| `providers.tf` | AWS provider and default tags |
| `variables.tf` | Region, names, retention, concurrency inputs |
| `locals.tf` | Shared name/tags |
| `sqs.tf` | Main queue, DLQ, redrive allow policy |
| `dynamodb.tf` | On-demand results/idempotency table |
| `package.tf` | Lambda ZIP packaging with `archive_file` |
| `iam.tf` | Producer/consumer roles and least-privilege policies |
| `lambda.tf` | Functions, log groups, SQS event source mapping |
| `api_gateway.tf` | HTTP API, POST route, integration, stage, invoke permission |
| `cloudwatch.tf` | Metric filter, alarms, dashboard |
| `outputs.tf` | API/queue/table/dashboard outputs |

## Commands

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## State

This sample intentionally uses local state for a small lab. Do not commit state to Git.

For a team/production environment, bootstrap remote state separately, for example with an S3 backend and state locking. Keep the state bootstrap outside this project's main state to avoid circular lifecycle management.

## Environments

For coursework, use variables (`environment=dev`) rather than duplicating modules prematurely. If the project grows to dev/stage/prod, move reusable resources into modules and create environment roots such as:

```text
terraform/
  modules/order-processing/
  environments/dev/
  environments/stage/
  environments/prod/
```

That refactor is justified when environments actually diverge or need separate states/permissions.
