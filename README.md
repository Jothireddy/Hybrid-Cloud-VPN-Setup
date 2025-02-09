# Hybrid Cloud VPN Setup

This project demonstrates how to establish a hybrid cloud VPN that connects an on-premises network to an AWS VPC using VPN technologies. You can choose to deploy either an **OpenVPN** or a **WireGuard** server on an EC2 instance provisioned within an AWS VPC. This solution enables secure, encrypted connectivity between your on-premises environment and cloud resources.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Deployment Instructions](#deployment-instructions)
  - [Step 1: Provision Infrastructure with Terraform](#step-1-provision-infrastructure-with-terraform)
  - [Step 2: Configure and Deploy the VPN Server](#step-2-configure-and-deploy-the-vpn-server)
- [VPN Server Configuration](#vpn-server-configuration)
  - [OpenVPN](#openvpn)
  - [WireGuard](#wireguard)
- [Testing the VPN Connection](#testing-the-vpn-connection)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This repository provides a complete solution for a hybrid cloud VPN setup using Terraform and VPN technologies. The solution provisions an AWS VPC and an EC2 instance that will host your VPN server. You can choose one of the two VPN solutions:

- **OpenVPN**: A widely adopted open-source VPN solution.
- **WireGuard**: A modern, high-performance VPN protocol.

On the on-premises side, configure your VPN client (using OpenVPN or WireGuard) to establish a secure tunnel to the cloud.

---

## Architecture

- **AWS VPC & Subnet:** A dedicated VPC with a public subnet is created for the VPN server.
- **EC2 VPN Server:** An EC2 instance is provisioned to run your VPN server using either OpenVPN (via a Docker container) or WireGuard.
- **Security Groups:** Firewall rules allow UDP traffic on port 1194 (OpenVPN) and/or 51820 (WireGuard).
- **On-Premises VPN Client:** Connects to the cloud via the VPN tunnel for secure, private communication.

---

## Project Structure

hybrid-vpn-setup/ ├── README.md ├── terraform/ │ ├── provider.tf │ ├── vpc.tf │ ├── instance.tf │ ├── security_groups.tf │ ├── variables.tf │ └── outputs.tf ├── vpn/ │ ├── openvpn/ │ │ ├── server.conf │ │ └── Dockerfile │ └── wireguard/ │ ├── wg0.conf.template │ └── generate_keys.sh └── scripts/ └── deploy_vpn.sh


---

## Prerequisites

- **AWS Account** with proper permissions.
- **Terraform** (v1.0+ recommended)
- **AWS CLI** configured with your credentials.
- **SSH access** to the EC2 instance (ensure your key pair is available).
- (Optional) **Docker** installed locally if you plan to build or test containers.
- For WireGuard: Linux tools such as `wg` for key generation.

---

## Deployment Instructions

### Step 1: Provision Infrastructure with Terraform

1. **Clone the repository:**

 ```bash
   git clone <repository_url>
 ```
Initialize and apply Terraform:
```
cd terraform
terraform init
terraform apply -auto-approve
```
Note the Outputs:
The public IP of the EC2 instance (VPN server) will be output by Terraform.

Step 2: Configure and Deploy the VPN Server
For OpenVPN:
Navigate to the vpn/openvpn directory.
Review and update server.conf as needed (ensure that you have generated and copied the required certificates and keys).
The provided Dockerfile uses the official kylemanna/openvpn image.
Deploy the OpenVPN server on the EC2 instance using the helper script.
For WireGuard:
Navigate to the vpn/wireguard directory.
Generate keys by running:
```
chmod +x generate_keys.sh
./generate_keys.sh
```
Edit wg0.conf.template to replace template variables (e.g., {{ PRIVATE_KEY }}, {{ PEER_PUBLIC_KEY }}, and {{ PEER_ENDPOINT }}) with your values.
Deploy WireGuard on the EC2 instance using the helper script.
Deploying via the Helper Script
Run the deployment script from the project root:
```
chmod +x scripts/deploy_vpn.sh
./scripts/deploy_vpn.sh <INSTANCE_PUBLIC_IP> <vpn_type>
```
Replace <INSTANCE_PUBLIC_IP> with the EC2 public IP from Terraform and <vpn_type> with either openvpn or wireguard.

The script will SSH into your EC2 instance, install Docker (or necessary packages), and deploy your selected VPN server.

VPN Server Configuration
OpenVPN
Configuration File: vpn/openvpn/server.conf
## Example:
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
Note: You must generate and provide the necessary certificates and keys (e.g., ca.crt, server.crt, server.key, dh2048.pem).

Dockerfile: vpn/openvpn/Dockerfile

```
FROM kylemanna/openvpn
```
This uses the official OpenVPN Docker image.

WireGuard
Configuration Template: vpn/wireguard/wg0.conf.template

[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = {{ PRIVATE_KEY }}

[Peer]
PublicKey = {{ PEER_PUBLIC_KEY }}
AllowedIPs = 10.0.0.2/32
Endpoint = {{ PEER_ENDPOINT }}:51820
Key Generation Script: vpn/wireguard/generate_keys.sh
```
#!/bin/bash
wg genkey | tee privatekey | wg pubkey > publickey
echo "WireGuard keys generated: privatekey and publickey"
```
Make sure to mark the script as executable.
Testing the VPN Connection
After deployment, configure your on-premises VPN client:

## OpenVPN Client: Use a compatible OpenVPN client along with a matching client configuration file.
WireGuard Client: Use the generated keys and update your client configuration to connect to the AWS instance’s public IP.
Test connectivity by pinging resources in the AWS VPC or by accessing secured internal resources.

## Troubleshooting
Terraform Issues: Ensure AWS credentials and permissions are correct.
VPN Server Errors: Check logs on the EC2 instance (e.g., Docker logs for OpenVPN or system logs for WireGuard).
Connectivity Problems: Verify that security groups permit UDP traffic on port 1194 (OpenVPN) or 51820 (WireGuard).
## Contributing
Contributions are welcome! Please fork this repository, make improvements, and open a pull request with your changes.

## License
This project is licensed under the MIT License.

Happy networking and secure hybrid connectivity!


