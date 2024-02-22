# Terraform GCP Infrastructure

This repository is dedicated to maintaining Terraform configurations for deploying infrastructure on Google Cloud Platform (GCP).

## Services Activated on GCP

- Compute Engine API
- VPC
- Firewall

## Current Configuration

- **Region**: `us-east1`
- **IP CIDR Range for Web Application**: `69.4.20.0/24`
- **IP CIDR Range for Database**: `4.20.69.0/24`

## Steps to Follow

1. **Initialize Terraform**: Run `terraform init` to initialize the modules and prepare the working directory for use.

2. **Validate Configuration**: Use `terraform validate` to ensure that the Terraform configuration files are syntactically valid and internally consistent.

3. **Plan Infrastructure Changes**: Execute `terraform plan` to review the proposed changes that Terraform will make to the infrastructure. This step provides an overview of the actions Terraform will perform based on the current configuration.

4. **Apply Changes**: Finally, run `terraform apply` to apply the changes defined in the Terraform configuration files. This command will create or update resources on GCP according to the specified configuration.

- region - ```us-east1```
- zone - ```us-east1-b```
- ip_cidr_range_webapp - ```69.4.20.0/24```
- ip_cidr_range_db - ```4.20.69.0/24```
- firewall rules to allow traffic to port - ```3000```
- create compute instance using custom image built using packer - current custom image -```webapp-centos-stream-8-a3-v5-20240221211859```

## Important things
- Firewall works on ```tags``` entirely
- update the the ```image path``` when running trying to build new infra

Following these steps ensures a systematic and controlled approach to managing infrastructure with Terraform, helping to maintain consistency and reliability across deployments.