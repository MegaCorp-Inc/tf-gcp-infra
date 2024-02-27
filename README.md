# Terraform GCP Infrastructure

This repository is dedicated to maintaining Terraform configurations for deploying infrastructure on Google Cloud Platform (GCP).

## Services Activated on GCP

- Compute Engine API
- VPC
- Firewall
- Service Networking API

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
- firewall rules to allow traffic to port - ```6969```
- create compute instance using custom image built using packer - current custom image -```webapp-centos-stream-8-a4-v1-20240227204431```


## Key Takeaways from Assignment 5

During Assignment 5, I learned several important concepts related to networking and database management in the Google Cloud Platform (GCP). Here are the key takeaways:

1. **Cloud SQL Instance with Private IP**: I configured a Cloud SQL instance to use a private IP address instead of a public IP. This enhanced security by ensuring that the database instance is not accessible directly from the internet.

2. **Connectivity Options for Cloud SQL Instance**:
   - **Private Service Access (PSA)**: I explored PSA, which allows accessing a private resource, such as a Cloud SQL instance, from within the same VPC network using Private Service Connect (PSC). It provides a secure and private connection without exposing the resource to the public internet.
   - **VPC Peering**: VPC peering enables connecting two different VPC networks within GCP. Although it wasn't directly used for connecting to the Cloud SQL instance within the same GCP project's VPC, it's a valuable networking feature for interconnecting VPC networks when needed.

3. **Private Service Connect (PSC)**: PSC is a service provided by Google Cloud that facilitates private connectivity between services within the same VPC network. By configuring PSC on the Cloud SQL instance and assigning it to an IP from a custom subnet, I ensured secure access to the database instance from within the VPC.

4. **VPC Peering**: While not directly used for accessing the Cloud SQL instance within the same GCP project's VPC, I learned about VPC peering's utility in establishing connections between different VPC networks, which can be beneficial for various networking scenarios.

By leveraging these networking features and best practices, I enhanced the security and reliability of database access within the Google Cloud Platform. These concepts are crucial for designing and implementing robust network architectures in cloud environments.

## Important things
- Firewall works on ```tags``` entirely
- update the the ```image path``` when running trying to build new infra

Following these steps ensures a systematic and controlled approach to managing infrastructure with Terraform, helping to maintain consistency and reliability across deployments.
