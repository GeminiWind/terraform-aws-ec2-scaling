# AWS Scaling EC2 Module
 
Build high availability, fault tolerance and secured application by AutoScaling Group + Load Balancer

## Features

- Provide ability to scale up/scale down application by `CPUUsage` metrics
- High availability and fault tolerance by using AutoScaling Group + Application Load Balancer
- TLS with `ACM`
- Integrate with Route53

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

## Outputs

| Name | Description |
|------|-------------|
| website_url | Website URL |

## Todos
