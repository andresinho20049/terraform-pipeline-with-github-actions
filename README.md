# AWS Infrastructure Pipeline with Terraform and GitHub Actions

[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](https://github.com/andresinho20049/terraform-pipeline-with-github-actions/blob/main/README.pt-br.md)

This project offers a robust solution for managing and provisioning infrastructure on Amazon Web Services (AWS) using Terraform, with an automated Continuous Integration/Continuous Deployment (CI/CD) pipeline through GitHub Actions.

## 🚀 Overview
The main objective of this repository is to allow you to define, provision, and update your AWS infrastructure in a declarative and automated way. When you perform a git push to this repository, GitHub Actions will take care of executing the Terraform commands, ensuring that your infrastructure on AWS is always synchronized with your configurations defined in the code.

## ✨ Main Functionalities
Infrastructure as Code (IaC) with Terraform: Define your AWS infrastructure using Terraform configuration files, ensuring reproducibility and versioning.

* **CI/CD Automation with GitHub Actions**: A pre-configured pipeline that automates the terraform plan and terraform apply process with each push to the repository.

* **Remote State Management in S3**: The Terraform statefile is securely stored in an S3 bucket, facilitating teamwork and disaster recovery.

* **State Locking with DynamoDB**: A DynamoDB table is used to guarantee statefile locking during Terraform operations, preventing conflicts and state corruption in collaborative environments.

* **Secure Integration with AWS**: Authentication between GitHub Actions and your AWS account is established through an identity provider (OIDC) and an IAM Role pre-configured in your AWS account, allowing the pipeline to assume the necessary permissions to manage your infrastructure.

## 🚀 How it Works

This project optimizes the deployment of your infrastructure and static website on AWS through an automated **CI/CD** pipeline. Here's how it works:

1. **Infrastructure Development:** You define or update your AWS infrastructure using **Terraform** in the `.tf` files located in the `infra/` directory of the repository.
2. **Commit and Push:** When you perform a `git commit` and `git push` to the main branch (or any branch configured to trigger the workflow), the GitHub Actions pipeline is automatically triggered.
3. **GitHub Actions Pipeline Execution:**
* The workflow starts, performing the **checkout** of your code.
* It assumes a specific **IAM Role** in your AWS account, ensuring secure access via **OIDC**. * Runs `terraform init`, which configures the **S3 backend** for storing the **statefile** and the **DynamoDB table** for **state locking**, preventing conflicts.
* Runs `terraform plan` to generate and display a summary of the proposed changes to your infrastructure.
* Runs `terraform apply --auto-approve` to apply these changes, provisioning or updating the resources in AWS.
* **Uploading Content:** After the infrastructure is provisioned, your static website files (located in `src/`) are synced to the **S3 bucket** using `aws s3 sync --delete`, ensuring that your website is always up-to-date and accessible.
4. **Infrastructure and Website Updated:** Your AWS infrastructure is provisioned or updated based on your Terraform configurations, and your static website is immediately available.

## 〰️ Provisioned Resources

Terraform is responsible for provisioning and configuring the following essential resources in your AWS account:

* **S3 Bucket for Static Website:** An Amazon S3 bucket configured specifically to host your static website.
* **Object Versioning:** Versioning is enabled on the S3 bucket, allowing you to roll back your website files to previous versions.
* **Public Access Policy:** An S3 bucket policy is attached to allow your website objects to be publicly accessible via the internet.
* **Website Hosting Configuration:** The bucket is configured to function as a static website, setting `index.html` as the default index document and `error.html` as the error document.
* **Lifecycle Management:** Lifecycle rules are applied to the S3 bucket to automatically manage outdated versions of objects. Specifically, **noncurrent versions of objects from version 4 onwards will be permanently deleted**, optimizing costs and version management.

The HTML, CSS, and other assets of your static site, such as `index.html` and `error.html`, are present in the repository's `src/` directory and are automatically uploaded to the S3 bucket during the pipeline process.

## 🎯 How to Run

This project uses **Terraform** to provision the infrastructure and **GitHub Actions** for CI/CD automation, ensuring a static website deployment on AWS. Follow the steps below to configure and run it in your environment:

### 1\. Prerequisites on AWS

Before starting, make sure your AWS account is configured with the following resources:

* **OIDC Provider for GitHub Actions:** Configure an identity provider (OIDC) in AWS IAM to allow GitHub Actions to assume an **IAM Role** securely. For a detailed guide, see the official AWS documentation: [Use IAM roles to connect GitHub Actions to actions in AWS](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/).

* **Dedicated IAM Role:** Create a specific IAM Role for GitHub Actions, with the necessary permission policies to manage resources in S3 (create/configure buckets, upload files), DynamoDB (create/access lock tables) and other services that your infrastructure may use.
* **S3 Bucket for Statefile:** Have a previously created S3 bucket dedicated to storing your **Terraform Statefile**. This bucket is crucial for managing the state of your infrastructure and must have **versioning enabled** to allow rollbacks.
* **DynamoDB Table for State Locking:** Create a table in DynamoDB to be used as a **state lock** mechanism by Terraform. This prevents multiple Terraform executions from corrupting the `statefile` in collaborative environments. The table must have a **Partition Key** called `LockID` of type `String`.

-----

### 2\. GitHub Repository Setup

After you set up your AWS account, you will need to configure secrets in your GitHub repository so that your GitHub Actions pipeline can interact with AWS.

Navigate to **Settings** \> **Secrets and variables** \> **Actions** in your GitHub repository and add the following secrets:

* `AWS_ROLE_ARN`: The ARN of the IAM role that GitHub Actions will assume (e.g. `arn:aws:iam::123456789012:role/github-actions-role`).

* `AWS_STATEFILE_S3_BUCKET`: The name of the S3 bucket where your Terraform Statefile will be stored.

* `AWS_LOCK_DYNAMODB_TABLE`: The name of the DynamoDB table configured for Terraform state locking.

-----

### 3\. Running the Pipeline

With the AWS prerequisites and GitHub secrets configured, you are ready to run the pipeline:

1. **Clone the Project:**

```bash
git clone https://github.com/andresinho20049/terraform-pipeline-with-github-actions.git
cd terraform-pipeline-with-github-actions
```

2. **Make a Change and Commit/Push:**
Make any changes to the project code (for example, to one of the HTML files in `src/` or to the Terraform configurations in `infra/`).

```bash
git add .
git commit -m "My commit message"
git push origin main
```

3. **Track the Pipeline:**

After the `git push`, the GitHub Actions pipeline will run automatically. You can track the progress in the **Actions** tab of your GitHub repository. The pipeline will provision or update the infrastructure on AWS and then upload your static site files to the configured S3 bucket.

With these steps, your infrastructure will be provisioned and your static site will be online on AWS, all automated via GitHub Actions!

## ©️ Copyright
**Developed by** [Andresinho20049](https://andresinho20049.com.br/) \
**Project**: *Automatic Infrastructure on AWS with IaC (Terraform)* \
**Description**: \
This project provides a robust Infrastructure as Code (IaC) and continuous CI/CD solution for static websites on AWS. Using Terraform, we provision and manage the infrastructure declaratively, including an S3 bucket for hosting the website and a DynamoDB table for state locking, ensuring the integrity of the Terraform Statefile in collaborative environments.

Automation is orchestrated via GitHub Actions, which executes a CI/CD pipeline, automatically executing terraform plan and apply on each push. Secure integration with AWS is done through IAM Roles and OIDC (OpenID Connect), eliminating the need for long-term credentials. In addition, the pipeline uses aws s3 sync for efficient upload of static content, keeping the S3 bucket always synchronized with the repository.

This approach optimizes the development workflow, ensures infrastructure reproducibility, and facilitates collaboration between teams, resulting in fast, consistent, and secure deployments.