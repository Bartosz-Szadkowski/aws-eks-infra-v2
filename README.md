# Project Overview

This project contains the infrastructure and Kubernetes configurations required to deploy various AWS resources and Kubernetes applications.

## Directory Structure

- `infrastructure/`: Terragrunt-based infrastructure for different environments (dev, prod, stage).
- `kubernetes/`: Kubernetes manifests and Helm charts for deploying applications via ArgoCD.
- `modules/`: Terraform modules for resources such as VPC, EKS, etc.
- `scripts/`: Helper scripts to automate deployments.

## How to Use This Repository

1. Run the helper scripts in the `./scripts` directory if you're running the project for the first time. Refer to the `README.md` file in that directory for more information.
2. Execute the `deploy_infrastructure` pipeline to deploy AWS infrastructure.
3. Execute the `deploy_argocd` pipeline to deploy the ArgoCD App of Apps, which will deploy all Kubernetes components defined in the `./kubernetes` directory.

For detailed instructions, refer to the individual `README.md` files in each directory.

# Terraform modules repo
https://github.com/Bartosz-Szadkowski/terraform-modules

# Application repo
https://github.com/Bartosz-Szadkowski/12-factor-python-app