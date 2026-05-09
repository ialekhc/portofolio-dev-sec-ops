# Portfolio DevQAOps Project

A coursework-ready personal portfolio website project that demonstrates Development, Quality Assurance, and Operations practices using Docker, AWS CloudFormation, GitHub Actions CI/CD, and SonarCloud static analysis.

**Module:** CC7010NI Development, Quality Assurance and Operations

## 1. Project Overview

This repository contains:
- A responsive personal portfolio website built with plain HTML, CSS, and JavaScript.
- Docker containerization using a custom image based on `nginx:alpine`.
- Infrastructure provisioning on AWS EC2 using CloudFormation.
- Automated CI/CD pipeline using GitHub Actions.
- Static code analysis integration with SonarCloud.

The design is intentionally lightweight and beginner-friendly so it can be clearly explained during viva.

## 2. Technology Stack

- Frontend: HTML5, CSS3, JavaScript (Vanilla)
- Containerization: Docker
- Web Server: Nginx (Alpine)
- Cloud Infrastructure: AWS EC2 + AWS CloudFormation
- CI/CD: GitHub Actions
- Code Quality: SonarCloud (or SonarQube Cloud)

## 3. Project Structure

```text
portfolio-devqaops/
├── .github/
│   └── workflows/
│       └── pipeline.yaml
├── assets/
│   └── alekh-chaudhary.jpg
├── cloudformation.yaml
├── Dockerfile
├── index.html
├── README.md
├── script.js
├── sonar-project.properties
└── styles.css
```

## 4. Local Run Instructions

### Option A: Open directly
1. Open `index.html` in a browser.

### Option B: Run local static server (recommended)
```bash
python3 -m http.server 8080
```
Then open:
- `http://localhost:8080`

## 5. Docker Build and Run

### Build image
```bash
docker build -t portfolio-devqaops:latest .
```

### Run container
```bash
docker run -d --name portfolio-container -p 8080:80 portfolio-devqaops:latest
```

### Test in browser
- `http://localhost:8080`

### Stop and remove
```bash
docker stop portfolio-container
docker rm portfolio-container
```

## 6. CloudFormation Deployment (AWS EC2)

### Prerequisites
- AWS account
- AWS CLI configured (`aws configure`)
- Existing EC2 key pair in your target region

### Create stack
```bash
aws cloudformation create-stack \
  --stack-name portfolio-devqaops-stack \
  --template-body file://cloudformation.yaml \
  --parameters \
    ParameterKey=KeyName,ParameterValue=<YOUR_KEYPAIR_NAME> \
    ParameterKey=InstanceType,ParameterValue=t2.micro \
    ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0
```

### Check stack status
```bash
aws cloudformation describe-stacks --stack-name portfolio-devqaops-stack
```

### Get outputs (InstanceId, PublicIP, WebsiteURL)
```bash
aws cloudformation describe-stacks \
  --stack-name portfolio-devqaops-stack \
  --query "Stacks[0].Outputs"
```

## 7. Required GitHub Secrets

Add these secrets in **GitHub Repository > Settings > Secrets and variables > Actions**:

- `EC2_HOST` (EC2 public IP or DNS)
- `EC2_USER` (usually `ec2-user` for Amazon Linux)
- `EC2_SSH_KEY` (private key content for your EC2 key pair)
- `SONAR_TOKEN` (SonarCloud token)
- `SONAR_PROJECT_KEY` (your SonarCloud project key)
- `SONAR_ORGANIZATION` (your SonarCloud organization key)

## 8. CI/CD Workflow Explanation

The workflow file is `.github/workflows/pipeline.yaml`.

### Trigger
- Push to `main`
- Pull request to `main`

### Job 1: `quality-and-build`
1. Checkout code.
2. Run SonarCloud static analysis.
3. Build Docker image `portfolio-devqaops:latest`.
4. Save image as `portfolio-devqaops.tar`.
5. Upload tar artifact (for deploy step on push to `main`).

### Job 2: `deploy` (only on push to `main`)
1. Download Docker image artifact.
2. Copy tar file to EC2 via SCP.
3. SSH into EC2 and run:
   - `docker load`
   - stop/remove existing `portfolio-container` if present
   - run updated container on port `80`
   - cleanup temporary files and unused Docker resources

## 9. SonarCloud Setup

1. Create a SonarCloud project connected to your GitHub repository.
2. Copy project key and organization key.
3. Add `SONAR_TOKEN`, `SONAR_PROJECT_KEY`, and `SONAR_ORGANIZATION` in GitHub Secrets.
4. Keep `sonar-project.properties` in repository root.

Note:
- Do not hardcode tokens in source files.
- The token is securely read from GitHub Secrets during pipeline execution.

## 10. Manual vs Automated Process

### Manual deployment (without CI/CD)
1. Build Docker image locally.
2. Export image tar.
3. SCP file to EC2.
4. SSH to EC2.
5. Load image, stop old container, run new container.

### Automated deployment (with CI/CD)
1. Push code to `main`.
2. GitHub Actions runs quality checks and image build.
3. Pipeline transfers artifact to EC2.
4. Pipeline deploys and restarts container automatically.

## 11. Demonstration Checklist (Viva)

- [ ] Show portfolio website UI locally.
- [ ] Show Docker image build command.
- [ ] Show running container and browser output.
- [ ] Show `cloudformation.yaml` resources and parameters.
- [ ] Show CloudFormation stack outputs (PublicIP, WebsiteURL).
- [ ] Show GitHub Actions workflow file.
- [ ] Push a small change to `main` and show pipeline execution.
- [ ] Show SonarCloud analysis dashboard.
- [ ] Show container redeployment on EC2.
- [ ] Open EC2 public IP in browser to prove live hosting.

## 12. Screenshots (Placeholders)

Add screenshots before submission:

1. `screenshots/local-website.png` - local browser view
2. `screenshots/docker-running.png` - `docker ps` output
3. `screenshots/cloudformation-stack.png` - stack create success
4. `screenshots/github-actions-success.png` - pipeline success
5. `screenshots/sonarcloud-report.png` - static analysis report
6. `screenshots/ec2-live-url.png` - website via EC2 public IP

## 13. Troubleshooting

### Pipeline fails at SonarCloud step
- Confirm `SONAR_TOKEN`, `SONAR_PROJECT_KEY`, and `SONAR_ORGANIZATION` are correct.
- Ensure SonarCloud project exists and is linked to repository.

### SCP/SSH deployment fails
- Verify `EC2_HOST`, `EC2_USER`, and `EC2_SSH_KEY` secrets.
- Ensure EC2 security group allows SSH (22) from your runner IP range.

### Website not opening on EC2 public IP
- Check security group HTTP rule (port 80 open).
- Confirm container is running on EC2:
  ```bash
  docker ps
  ```

### Port conflict on EC2
- Another service may already use port 80.
- Stop conflicting service/container, then redeploy.

## 14. Academic Notes

This implementation prioritizes DevQAOps learning outcomes:
- Infrastructure as Code (CloudFormation)
- Container-based deployment (Docker)
- Continuous Integration and Continuous Deployment (GitHub Actions)
- Continuous code quality checks (SonarCloud)

It intentionally avoids unnecessary frameworks and backend complexity for clear understanding and demonstration.
