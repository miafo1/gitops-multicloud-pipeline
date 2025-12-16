# Alpine Linux Setup Instructions

If you are running in an Alpine-based environment (instead of the standard Ubuntu Codespace), use the following commands to install the required tools.

**Note:** You might need to use `sudo` if you are not the root user.

## 1. Install Dependencies
```bash
sudo apk update
sudo apk add curl unzip
```

## 2. Install Terraform
```bash
# Download the binary (more reliable than apk for this package)
# Check for latest version at https://developer.hashicorp.com/terraform/downloads
export TERRAFORM_VERSION="1.9.5"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Unzip and move to /usr/local/bin
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Clean up
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
```

## 3. Install AWS CLI
```bash
sudo apk add aws-cli
```

## 4. Install kubectl
```bash
sudo apk add kubectl
```

## 5. Install Python & Pip (Optional for local testing)
```bash
sudo apk add python3 py3-pip
# Create a virtual environment to avoid PEP 668 errors
python3 -m venv venv
source venv/bin/activate
# Now you can install requirements
pip install -r app/requirements.txt
```

## Verification
```bash
terraform version
aws --version
kubectl version
python3 --version
pip --version
```
