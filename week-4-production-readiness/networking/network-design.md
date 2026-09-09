# Networking Design

## Region and Availability Zones

Default Region: **eu-central-1 (Frankfurt)**. Terraform queries available AZs and uses the first two, so physical AZ names may differ by account. The architecture spans two AZs so a single-AZ infrastructure failure does not remove all Lambda subnet placement options or the SQS interface endpoint.

## CIDR plan

| Layer | AZ | CIDR | Purpose |
|---|---|---|---|
| VPC | Regional | 10.20.0.0/16 | QuickCart network boundary |
| Public A | AZ 1 | 10.20.0.0/24 | Reserved public tier / future ALB or NAT |
| Public B | AZ 2 | 10.20.1.0/24 | Reserved public tier / future ALB or NAT |
| Private App A | AZ 1 | 10.20.10.0/24 | Lambda ENIs + SQS VPCE |
| Private App B | AZ 2 | 10.20.11.0/24 | Lambda ENIs + SQS VPCE |

The /16 leaves substantial space for future private data, integration, inspection, or shared-services subnet tiers without renumbering the current workload.

## Routing

Public route table: `0.0.0.0/0 -> Internet Gateway`. Private route tables have no default Internet route. A DynamoDB Gateway Endpoint injects the DynamoDB prefix-list route into both private route tables. SQS uses an Interface Endpoint with private DNS and ENIs in both private subnets.

## Security groups

Lambda SG has no ingress rule. The SQS endpoint SG accepts TCP/443 only from the Lambda SG. Lambda egress is allowed by the SG, but effective destinations are restricted by the private route tables and available endpoints because there is no NAT/default Internet route.

## Why public subnets exist when the prototype is serverless

The brief explicitly asks for public/private subnet design. Nothing in the current runtime requires a public-subnet workload: API Gateway is managed outside the VPC and Lambda belongs in private subnets. The public subnets are therefore **reserved expansion capacity** for services such as a public ALB or NAT Gateway if the architecture later needs them. Deploying an EC2 bastion only to “use” the public subnet would add attack surface without solving a requirement.

## Why no NAT Gateway

NAT Gateway provides general outbound Internet access but has fixed hourly and per-GB charges. The prototype needs only SQS and DynamoDB from the Lambda execution environments, so private endpoints are a more restrictive design. Note that SQS Interface Endpoints themselves have hourly/data-processing charges. For a tiny lab, a NAT Gateway can be more or less expensive depending on Region, AZ count and duration; destroy the lab after demonstration.

## API Gateway and VPC Link

API Gateway invokes Lambda through AWS's Lambda integration. A VPC Link is required for private HTTP backends such as an internal ALB/NLB/ECS service, not for a normal Lambda proxy integration.
