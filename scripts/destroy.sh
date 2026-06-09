#!/bin/bash

set -e
echo "Minecraft AWS Teardown"
cd terraform
terraform destroy -auto-approve