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
# Install from the community repository
sudo apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
```

## 3. Install AWS CLI
```bash
sudo apk add aws-cli
```

## 4. Install kubectl
```bash
sudo apk add kubectl
```

## Verification
```bash
terraform version
aws --version
kubectl version
```
