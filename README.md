# tf-gcp-infra
Repo to maintain terraform config

## Services Activated on GCP

- Compute Engine API
- VPC
- Firewall

## Current config

- region - ```us-east1```
- zone - ```us-east1-b```
- ip_cidr_range_webapp - ```69.4.20.0/24```
- ip_cidr_range_db - ```4.20.69.0/24```
- firewall rules to allow traffic to port - ```3000```
- create compute instance using custom image built using packer - current custom image -```webapp-centos-stream-8-a3-v5-20240221211859```

## Important things
- Firewall works on ```tags``` entirely
- update the the ```image path``` when running trying to build new infra
