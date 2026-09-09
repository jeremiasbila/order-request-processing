# Final Terraform stack

This is the deployable Week 4 source of truth. It provisions API Gateway, two Lambda functions, SQS main/DLQ, DynamoDB, CloudWatch observability, IAM, and a two-AZ VPC.

## Network resources

- VPC 10.20.0.0/16
- 2 public + 2 private subnets across the first two available AZs
- Internet Gateway and public route table
- private route tables without Internet default routes
- SQS Interface VPC Endpoint in both private subnets
- DynamoDB Gateway VPC Endpoint on both private route tables
- Lambda and SQS-endpoint security groups
- Producer and consumer Lambdas attached to both private subnets

No NAT Gateway is deployed in the prototype. This deliberately limits private Lambda egress to the AWS services reachable through configured endpoints and avoids NAT hourly/data-processing cost. Add NAT or additional interface endpoints only when the application requires outbound services.

## Commands

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output network_summary
```

For production, use remote state with S3 state locking, separate environment state/accounts, CI plan/apply controls, policy-as-code, security scanning, and `enable_pitr = true`.
