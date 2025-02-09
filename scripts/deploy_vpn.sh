#!/bin/bash
# Usage: ./deploy_vpn.sh <instance_public_ip> <vpn_type>
# vpn_type should be "openvpn" or "wireguard"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <instance_public_ip> <vpn_type>"
    exit 1
fi

INSTANCE_IP=$1
VPN_TYPE=$2

echo "Deploying $VPN_TYPE on VPN server at $INSTANCE_IP..."

# Define SSH user (adjust for your AMI; e.g., ec2-user for Amazon Linux, ubuntu for Ubuntu)
SSH_USER="ec2-user"

if [ "$VPN_TYPE" = "openvpn" ]; then
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${INSTANCE_IP} << 'EOF'
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
docker pull kylemanna/openvpn
# Additional steps:
# - Copy your OpenVPN configuration files (server.conf, certificates) to the instance.
# - Run the OpenVPN container (e.g., using: docker run -v /your/config:/etc/openvpn --rm -it kylemanna/openvpn ovpn_run).
EOF
elif [ "$VPN_TYPE" = "wireguard" ]; then
    ssh -o StrictHostKeyChecking=no ${SSH_USER}@${INSTANCE_IP} << 'EOF'
# Install WireGuard (for Amazon Linux 2; adjust as necessary)
sudo yum install -y epel-release
sudo yum install -y wireguard-tools
# Copy your WireGuard configuration to /etc/wireguard/wg0.conf and start the interface:
# sudo cp /your/path/wg0.conf /etc/wireguard/wg0.conf
# sudo wg-quick up wg0
EOF
else
    echo "Invalid VPN type. Choose 'openvpn' or 'wireguard'."
    exit 1
fi

echo "$VPN_TYPE deployment initiated on $INSTANCE_IP."
