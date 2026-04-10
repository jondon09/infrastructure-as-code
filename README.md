# High-Availability Web Application on AWS

Infrastructure as Code (IaC) project that deploys a production-grade, highly available web application on AWS using CloudFormation. The infrastructure spans multiple Availability Zones with auto scaling, load balancing, and network isolation following AWS Well-Architected Framework principles.

## Architecture

![AWS High-Availability Web Application Architecture](docs/architecture.png)

### Architecture Overview

| Layer | Components | Purpose |
|-------|-----------|---------|
| **Networking** | VPC, 2 Public Subnets, 2 Private Subnets | Network isolation across 2 AZs |
| **Internet Access** | Internet Gateway, 2 NAT Gateways, Elastic IPs | Inbound/outbound connectivity |
| **Load Balancing** | Application Load Balancer, Target Group, Listener | Traffic distribution and health checks |
| **Compute** | Auto Scaling Group, Launch Configuration (t3.medium) | Scalable application hosting |
| **Security** | Security Groups (ALB + Web Server), IAM Roles | Least-privilege access control |
| **Storage** | S3 Bucket | Application artifact delivery |

**Traffic Flow:** Users connect through the Internet Gateway to the Application Load Balancer in the public subnets. The ALB forwards requests to EC2 instances running Apache2 in the private subnets. NAT Gateways in each AZ provide outbound internet access for the private instances. Application content is pulled from S3 during instance bootstrap.

## Project Structure

```
.
├── templates/                      # CloudFormation templates
│   ├── network.yml                 # VPC, subnets, NAT gateways, route tables
│   └── application.yml             # ALB, ASG, security groups, IAM roles
├── parameters/                     # Stack parameters by environment
│   └── dev/
│       ├── network.json            # Network CIDR ranges and environment name
│       └── application.json        # Application environment configuration
├── scripts/                        # Deployment automation
│   ├── create-stack.sh             # Create stack (Linux/macOS)
│   ├── update-stack.sh             # Update stack (Linux/macOS)
│   ├── delete-stack.sh             # Delete stack (Linux/macOS)
│   ├── create-stack.bat            # Create stack (Windows)
│   ├── update-stack.bat            # Update stack (Windows)
│   └── delete-stack.bat            # Delete stack (Windows)
├── docs/                           # Documentation and diagrams
│   ├── architecture.png            # Architecture diagram (PNG)
│   └── architecture.svg            # Architecture diagram (SVG)
└── README.md
```

**Stack dependency:** The `network` stack must be deployed before `application`, as the application stack imports VPC and subnet references via CloudFormation cross-stack exports.

## Prerequisites

- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured
- AWS IAM credentials with permissions to create VPC, EC2, ELB, IAM, and CloudFormation resources
- An S3 bucket containing the application artifact (`travel-site.zip`)

## Deployment

### 1. Deploy the Network Stack

Creates the VPC, subnets, internet gateway, NAT gateways, and route tables.

```bash
./scripts/create-stack.sh dev-network templates/network.yml parameters/dev/network.json
```

### 2. Deploy the Application Stack

Creates the load balancer, auto scaling group, security groups, and IAM roles. This stack depends on the network stack outputs.

```bash
./scripts/create-stack.sh dev-webapp templates/application.yml parameters/dev/application.json
```

### 3. Access the Application

After deployment completes, retrieve the application URL from the stack outputs:

```bash
aws cloudformation describe-stacks \
  --stack-name dev-webapp \
  --query "Stacks[0].Outputs[?OutputKey=='WebUrl'].OutputValue" \
  --output text \
  --region us-east-1
```

## Updating Stacks

Modify the template or parameter files, then apply updates:

```bash
./scripts/update-stack.sh dev-network templates/network.yml parameters/dev/network.json
./scripts/update-stack.sh dev-webapp templates/application.yml parameters/dev/application.json
```

## Teardown

Delete stacks in reverse dependency order:

```bash
./scripts/delete-stack.sh dev-webapp
./scripts/delete-stack.sh dev-network
```

## Parameters

### Network Stack (`parameters/dev/network.json`)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ENV` | `Dev` | Environment prefix applied to all resource names and exports |
| `VpcCIDR` | `10.0.0.0/16` | CIDR block for the VPC |
| `PublicSubnet1CIDRBlock` | `10.0.0.0/24` | CIDR block for public subnet in AZ1 |
| `PublicSubnet2CIDRBlock` | `10.0.1.0/24` | CIDR block for public subnet in AZ2 |
| `PrivateSubnet1CIDRBlock` | `10.0.2.0/24` | CIDR block for private subnet in AZ1 |
| `PrivateSubnet2CIDRBlock` | `10.0.3.0/24` | CIDR block for private subnet in AZ2 |

### Application Stack (`parameters/dev/application.json`)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ENV` | `Dev` | Environment prefix (must match the network stack) |

## Cross-Stack References

The application stack consumes the following exports from the network stack:

| Export Name | Resource |
|-------------|----------|
| `${ENV}-VPCID` | VPC ID |
| `${ENV}-PUB-SUBNETS` | Public subnet IDs (comma-separated) |
| `${ENV}-PRIV-SUBNETS` | Private subnet IDs (comma-separated) |
| `${ENV}-PUBLIC-SUBNET1` | Public Subnet 1 ID |
| `${ENV}-PUBLIC-SUBNET2` | Public Subnet 2 ID |

## Built With

- [AWS CloudFormation](https://aws.amazon.com/cloudformation/) - Infrastructure as Code
- [AWS VPC](https://aws.amazon.com/vpc/) - Network isolation
- [Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/) - Application Load Balancer
- [Amazon EC2 Auto Scaling](https://aws.amazon.com/ec2/autoscaling/) - Compute scaling
- [Amazon S3](https://aws.amazon.com/s3/) - Artifact storage
