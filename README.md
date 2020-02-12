# AWS Scaling EC2 Module
 
Build high availability, fault tolerance and secured application by AutoScaling Group + Load Balancer

[![](https://img.shields.io/github/license/GeminiWind/terraform-aws-ec2-scaling)](https://github.com/GeminiWind/terraform-aws-ec2-scaling)
[![](https://img.shields.io/github/issues/GeminiWind/terraform-aws-ec2-scaling)](https://github.com/GeminiWind/terraform-aws-ec2-scaling)
[![](https://img.shields.io/github/issues-closed/GeminiWind/terraform-aws-ec2-scaling)](https://github.com/GeminiWind/terraform-aws-ec2-scaling)
[![](https://img.shields.io/github/languages/code-size/GeminiWind/terraform-aws-ec2-scaling)](https://github.com/GeminiWind/terraform-aws-ec2-scaling)
[![](https://img.shields.io/github/repo-size/GeminiWind/terraform-aws-ec2-scaling)](https://github.com/GeminiWind/terraform-aws-ec2-scaling)


## Features

- Provide ability to scale up/scale down application by your specified `CPUUsage` threshold metric
- High availability and fault tolerance by using AutoScaling Group + Application Load Balancer
- Retrieve email notification from AutoScaling Group through SNS Topic

## Prerequisites
- Make sure you're aws keys are set up in `~/.aws/credentials` to run AWS CLI
- After provisioning is successful, set the domain's nameservers in your DNS Management to point to the AWS nameservers listed in the hosted zone 

## Usage

```HCL
module "static-website" {
  source  = "GeminiWind/static-website/aws"
  version = "1.0.0"

  region            = "ap-southeast-1"
  app               = "YOUR_APP_NAME"
  stage             = "YOUR_DEPLOY_STAGE, E.G: <dev, staging, prod>"
  
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| region | AWS Deployed Region (i.e. `ap-southeast-1`) | string | - | yes |
| app | App name | string | - | yes |
| stage | Deployed stage (i.e `dev`, `staging`, `prod`) | string | `dev` | yes |
| image_id | An AMI ID | string | `dev` | yes |

## Outputs

| Name | Description |
|------|-------------|
| private_key | Private key to SSH through your EC2 instances |
| lb_dns | DNS Nam of Application Load Balancer |

## Todos
