# Alpine Linux Setup Instructions

If you are running in an Alpine-based environment (instead of the standard Ubuntu Codespace), use the following commands to install the required tools.

## 1. Install Dependencies
```bash
apk update
apk add curl unzip
```

## 2. Install Terraform
```bash
# Install from the community repository
apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
```

## 3. Install AWS CLI
```bash
apk add aws-cli
```

## 4. Install kubectl
```bash
apk add kubectl
```

## Verification
```bash
terraform version
aws --version
kubectl version
```
