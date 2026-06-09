#!/bin/bash

set -e
echo "Minecraft AWS Deployment"

for cmd in aws terraform ansible-playbook nmap nc; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' is not installed"
    exit 1
  fi
done

echo "Checking AWS credentials"
aws sts get-caller-identity >/dev/null
echo ""

echo "Provisioning infrastructure with Terraform"
echo ""

cd terraform
terraform init -upgrade
terraform apply -auto-approve
PUBLIC_IP=$(terraform output -raw public_ip)
AMI_USED=$(terraform output -raw ami_used)

cd ..
echo ""
echo "  Instance IP : $PUBLIC_IP"
echo "  AMI used    : $AMI_USED"
echo ""

echo "Waiting for SSH to become available"
echo ""

RETRIES=30
COUNT=0
until nc -z -w 5 "$PUBLIC_IP" 22 2>/dev/null; do
  COUNT=$((COUNT + 1))
  if [ "$COUNT" -ge "$RETRIES" ]; then
    echo "ERROR: SSH failed."
    exit 1
  fi
  sleep 10
done

# Buffer before Ansible connects
echo "SSH port open"
sleep 15
echo "Ready."
echo ""

echo "Writing Ansible inventory"
echo ""

KEY_FILE="/Users/lucyang/Documents/minecraft-key.pem"

if [ ! -f "$KEY_FILE" ]; then
  echo "ERROR: SSH key not found"
  exit 1
fi

cat > ansible/inventory.ini <<EOF
[minecraft]
$PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=$KEY_FILE ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "Configuring server with Ansible"
echo ""

ansible-playbook \
  -i ansible/inventory.ini \
  ansible/minecraft.yml
echo ""

echo "Waiting 45s for Minecraft to finish starting up..."
echo ""
sleep 45

echo "Verifying Minecraft port with nmap"
echo ""
nmap -sV -Pn -p T:25565 "$PUBLIC_IP"
