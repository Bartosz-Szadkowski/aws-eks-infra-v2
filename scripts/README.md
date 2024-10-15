# Scripts

This directory contains helper scripts for automating infrastructure tasks such as setting up Terraform remote state, deploying an OIDC provider, and configuring an IAM role for GitHub Actions using OIDC.

## Available Scripts
D
### 1. **deploy_remote_state.sh**

This script sets up remote state storage for Terraform in AWS using an S3 bucket and DynamoDB for state locking.

#### What It Does:

- Creates an S3 bucket for storing Terraform remote state.
- Creates a DynamoDB table for state locking and consistency.

#### Prerequisites:

- Ensure you have the necessary AWS credentials configured (either via environment variables or AWS CLI profile).
- aws cli installed locally.

### deploy_oidc_provider.sh

This script deploys an OpenID Connect (OIDC) provider in AWS, which allows secure authentication between GitHub Actions and AWS without needing long-term AWS credentials.

What It Does:

	•	Creates an OIDC identity provider in AWS linked to your GitHub repository.
	•	The provider allows GitHub Actions to authenticate via short-lived tokens.

Prerequisites:

	•	AWS credentials with permission to create an OIDC provider.
	•	The GitHub repository URL that will be linked to this provider.

This command will configure the OIDC provider for my-github-repo-url in the us-east-1 region.

3. deploy_oidc_role.sh

This script creates an IAM role that can be assumed by GitHub Actions using OIDC. The role allows secure access to AWS resources for specific tasks, like deploying infrastructure or managing services.

What It Does:

	•	Creates an IAM role with a trust policy allowing GitHub Actions to assume the role via OIDC.
	•	Attaches a specified policy to the role for access to AWS services.

Prerequisites:

	•	You need to have set up the OIDC provider in AWS before running this script.
	•	AWS credentials with IAM permissions to create roles and policies.
	•	The GitHub repository URL and the policy you want to attach to the role.


This command will create an IAM role linked to my-github-repo-url with the my-iam-policy policy attached in the us-east-1 region.

Prerequisites for All Scripts

Before running these scripts, ensure the following:

	•	You have AWS CLI configured with the correct credentials.
	•	You have the necessary IAM permissions to create and manage S3 buckets, DynamoDB tables, IAM roles, and OIDC providers.
	•	You have bash installed on your system.

Troubleshooting

	•	If you encounter permission errors, check your AWS IAM permissions and make sure you have the required roles/policies attached.
	•	Ensure that all required parameters (like bucket names, GitHub URLs, and region) are correctly passed to the scripts.
	•	You can enable debug logging by adding set -x at the top of any script to help diagnose issues.

Contributing

If you’d like to contribute improvements to these scripts, feel free to submit a pull request or open an issue.

License

This project is licensed under the MIT License. See the LICENSE file for details.

---

### Summary:

- **Each script** is clearly explained, including its purpose, usage, prerequisites, and an example of how to run it.
- **Prerequisites** are listed to ensure the user has everything set up before running the scripts.
- **Troubleshooting** is included to help users debug common issues.
- **Contributing and License** sections encourage collaboration and provide legal context for the project.

You can now copy this `README.md` file and place it in your `scripts` directory. Let me know if you need further adjustments! 😊