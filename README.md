# Minecraft Server Deployment on AWS

This is a guide for creating a pipeline for a Minecraft Java Edition server on AWS. For this project, I used Terraform to build the server and Ansible for server configuration. The entire deployment runs from a couple script with no manual steps required after setup.

## Requirements

The following tools must be installed on your local machine before running the deployment. Version requirements are noted where applicable. 

NOTE: This was done on a MacBook, so installing tools may be different depending on the OS. EX. I use Homebrew to install these programs 

| Tool | Version | Purpose |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | Above 1.5 | Provisions AWS infrastructure |
| [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) | Above 2.14 | Configures the EC2 instance |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | Above 2.0 | Authenticates with AWS |
| [nmap](https://nmap.org/download) | Any | Verifies the Minecraft port is open |
| [netcat (`nc`)](https://netcat.sourceforge.net/) | Any | Checks SSH availability during deployment |

---

## Pipeline Overview

The deployment is broken into two distinct stages that run automatically when you execute `deploy.sh`:

### Stage 1 — Infrastructure Provisioning (Terraform)

Terraform creates all the AWS resources needed to host the server:

1. A **VPC** with a public subnet and internet gateway
2. A **security group** allowing inbound traffic on port `22` (SSH) and port `25565` (Minecraft)
3. An **EC2 `t3.small` instance** running Ubuntu 24.04 LTS — the AMI is discovered automatically using a data source so it always uses the latest image for the current region
4. Outputs the instance's **public IP address** for use in the next stage

### Stage 2 — Server Configuration (Ansible)

Once the EC2 instance is reachable over SSH, Ansible connects and configures it automatically:

1. Installs **Java 25** (required for the latest Minecraft release)
2. Creates a dedicated **`minecraft` system user** for security
3. Queries the **[Mojang version manifest API](https://launchermeta.mojang.com/mc/game/version_manifest.json)** to find the latest Minecraft release, then downloads the correct server JAR — no hardcoded URLs
4. Accepts the **EULA** and writes a `server.properties` file
5. Installs and starts a **systemd service** that manages the server process, including graceful shutdown via a `screen` session

### Verification

After deployment, `nmap` scans port `25565` to confirm the server is publicly reachable.

---

## Tutorial

### 1. Clone the Repository

```bash
git clone git@github.com:lucYang55/Minecraft_server.git
cd Minecraft_server
```
### 2. Install Required Tools

Follow the instructions in the [Requirements](#requirements) section for your operating system. Verify each tool is installed:

```bash
terraform -version
ansible --version
aws --version
nmap --version
```

### 3. Configure AWS Credentials

For this project to work correctly, you will need to pull credentials from  **AWS Learner Lab** each time you start a lab session. Since the credentials reset every time a new lab instance is created it you will need to look for them and enter them. The credentials only last a couple hours per session so if ay authentication errors do occur then that could be the main reason. 

1. Open your Learner Lab and click **AWS Details**
2. Click **Show** next to AWS CLI
3. Export the three values in your terminal:

```bash
export AWS_ACCESS_KEY_ID=YOUR_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
export AWS_SESSION_TOKEN=YOUR_SESSION_TOKEN
```

### 4. Create an SSH Key Pair

Ansible uses SSH to connect to and configure the EC2 instance. Create a key pair in AWS and save the private key locally or if you already have a key then just us that:
NOTE: Just remember the path of your key and enter that into the script
- If you save the key somewhere other than `~/minecraft-key.pem`, update the `KEY_FILE` variable near the top of `scripts/deploy.sh`:

```bash
aws ec2 create-key-pair \
  --key-name minecraft-key \
  --query 'KeyMaterial' \
  --output text > ~/minecraft-key.pem

chmod 400 ~/minecraft-key.pem
```

```bash
KEY_FILE="/your/custom/path/minecraft-key.pem"
```

### 5. Deploy the Server

Make the scripts executable, then run the deployment:

```bash
chmod +x scripts/deploy.sh scripts/destroy.sh
./scripts/deploy.sh
```

The script will walk through each stage and print progress as it goes. The full deployment typically takes **3–5 minutes**.

### 6. Verify the Server

At the end of the deployment, `nmap` automatically scans the server. A successful deployment looks like this:

```
PORT      STATE  SERVICE   VERSION
25565/tcp open   minecraft
```

You can also verify manually at any time:

```bash
nmap -sV -Pn -p T:25565 YOUR_SERVER_IP
```
NOTE: I could not test this step as I don't own Minecraft, but I encourage you to try 

To connect in Minecraft, open **Multiplayer → Add Server** and enter `YOUR_SERVER_IP:25565`.

### 7. Tear Down

To destroy all AWS resources created by Terraform and avoid incurring charges:

```bash
./scripts/destroy.sh
```

> **Important:** Always destroy resources when you are done. The Learner Lab has a credit limit if you don't destroy charges will build up.

---

## Resources and Sources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

  Additional Terraform Resources 

  - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#root_block_device 
  
  - http://cloud-images.ubuntu.com/locator/ec2/ 

  - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

- [Ansible Documentation](https://docs.ansible.com/)

  Additional Ansible Resources 

  - https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/set_fact_module.html 

  - https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/uri_module.html

  - https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/template_module.html 

- [Get Caller Identity command for Bash](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html)

- [Mojang Version Manifest API](https://launchermeta.mojang.com/mc/game/version_manifest.json) 

- [Minecraft Server Download](https://www.minecraft.net/en-us/download/server)

- [AWS EC2 Ubuntu AMIs — Canonical](https://ubuntu.com/server/docs/cloud-images/amazon-ec2)

- [Systemd Service Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)