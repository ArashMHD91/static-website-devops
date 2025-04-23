# Static Website Deployment with CI/CD Pipeline

This repository contains code and configuration for a complete CI/CD pipeline that deploys a static website using Docker, Ansible, GitHub Actions, and AWS EC2.

## Overview

This project demonstrates how to:
- Create a simple static website
- Containerize it with Docker and Nginx
- Configure infrastructure with Ansible
- Implement CI/CD with GitHub Actions
- Deploy to AWS EC2

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│             │     │             │     │             │     │             │
│   GitHub    │────▶│   GitHub    │────▶│  Docker Hub │────▶│   AWS EC2   │
│ Repository  │     │   Actions   │     │             │     │             │
│             │     │             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

## Prerequisites

- GitHub account
- Docker Hub account
- AWS account (free tier is sufficient)
- Basic knowledge of Docker, Ansible, and GitHub Actions

## Step 1: Create a Simple Static Website

First, let's create a basic HTML site:

### Create a new directory for your project:
```bash
mkdir static-website-devops
cd static-website-devops
```

### Create an `index.html` file:
```bash
touch index.html
```

### Add some basic content to your `index.html`:
```html
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Demo Site</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f5f5f5;
        }
        .container {
            text-align: center;
            padding: 40px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello from DevOps!</h1>
        <p>This page is served via a complete CI/CD pipeline.</p>
    </div>
</body>
</html>
```

---

## Step 2: Initialize a GitHub Repository

### 🔧 Initialize a Git repository:
```bash
git init
```

### Create a `.gitignore` file:
```bash
touch .gitignore
```

### Add initial files to Git:
```bash
git add index.html .gitignore
git commit -m "Initial commit with basic website"
```

### ☁️ Create a new repository on GitHub

Then, link your local repo to the GitHub repo:
```bash
git remote add origin https://github.com/YOUR_USERNAME/static-website-devops.git
git branch -M main
git push -u origin main
```

---

## Step 3: Create a Dockerfile

### Create a `Dockerfile`:
```bash
touch Dockerfile
```

### Add the following content:
```Dockerfile
# Use the official Nginx image as base
FROM nginx:alpine

# Copy the static website to Nginx's default serving directory
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# The default command starts Nginx
CMD ["nginx", "-g", "daemon off;"]
```

### Commit and push this change:
```bash
git add Dockerfile
git commit -m "Add Dockerfile for Nginx container"
git push origin main
```

---

## Step 4: Configure AWS EC2

1. Create an EC2 instance:
   - Log in to the AWS Management Console
   - Navigate to EC2 Dashboard and click "Launch Instance"
   - Select Ubuntu Server (20.04 or 22.04 LTS)
   - Choose t2.micro (free tier eligible)
   - Configure Auto-assign Public IP to "Enable"
   - Configure security groups:
     - Allow SSH (port 22) from your IP
     - Allow HTTP (port 80) from anywhere (0.0.0.0/0)
   - Create or select a key pair (.pem file)
   - Launch the instance and note its public IP address

2. Ensure the key pair file (.pem) has the correct permissions:
   ```bash
   chmod 400 path/to/your-key.pem
   ```

## Step 5: Configure Your Local Environment

1. Install Ansible:
   ```bash
   # For Ubuntu/Debian
   sudo apt update
   sudo apt install ansible

   # For macOS
   brew install ansible

   # For Windows
   # Use WSL (Windows Subsystem for Linux) and install Ansible there
   ```

2. Modify the `ansible/inventory` file with your EC2 details:
   ```ini
   [webservers]
   web ansible_host=YOUR_EC2_PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=path/to/your-key.pem
   ```

3. Test your Ansible connection:
   ```bash
   ansible -i ansible/inventory webservers -m ping
   ```
   You should see a successful "pong" response.

## Step 6: Docker Hub Setup

1. Create an account at [Docker Hub](https://hub.docker.com) if you don't have one
2. Create a new repository named `static-website-devops`
3. Generate an access token:
   - Go to Account Settings > Security
   - Click "New Access Token"
   - Name it "GitHub Actions"
   - Select "Read & Write" permissions
   - Copy the token (you won't see it again!)

## Step 7: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following repository secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_TOKEN`: Your Docker Hub access token
   - `EC2_HOST`: Your EC2 instance public IP address 
   - `SSH_PRIVATE_KEY`: The entire content of your EC2 private key (.pem file)

## Step 8: GitHub Actions Workflow

The repository includes a GitHub Actions workflow in `.github/workflows/deploy.yml` that:
1. Builds a Docker image with your static website
2. Pushes the image to Docker Hub
3. Uses Ansible to deploy the container to EC2

No changes are needed to this file unless you want to customize the workflow.

## Step 9: Deployment

1. Commit and push changes to trigger the CI/CD pipeline:
   ```bash
   git add .
   git commit -m "Update website content"
   git push origin main
   ```

2. Monitor the workflow:
   - Go to the Actions tab in your GitHub repository
   - You should see the workflow running
   - Wait for it to complete successfully

3. Access your website:
   - Open a web browser and go to `http://YOUR_EC2_PUBLIC_IP`
   - You should see your static website!

## Troubleshooting

### EC2 Connection Issues
- Verify your security group allows SSH (port 22) and HTTP (port 80)
- Check that your key pair has the correct permissions (chmod 400)
- Try manually SSH'ing into your instance: `ssh -i path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP`

### GitHub Actions Failures
- Check the error messages in the Actions log
- Verify all secrets are correctly set with no extra spaces
- Ensure your Docker Hub credentials are valid

### Website Not Loading
- Check if the container is running on EC2: `ssh -i path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP 'docker ps'`
- Verify Nginx logs: `ssh -i path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP 'docker logs static-website'`
- Make sure you're using http:// not https:// when accessing the IP

## Project Structure

```
static-website-devops/
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions workflow
├── ansible/
│   ├── inventory             # Server inventory file
│   ├── playbook.yml          # Main Ansible playbook
│   └── roles/
│       ├── docker/           # Role to install Docker
│       └── deploy/           # Role to deploy container
├── Dockerfile                # Container configuration
├── index.html                # Static website content
└── README.md                 # Project documentation
```

## Next Steps

Consider enhancing this project with:
- HTTPS configuration using Let's Encrypt
- Custom domain name setup
- More complex website content
- Monitoring and alerting
- Infrastructure as Code (e.g., Terraform)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
