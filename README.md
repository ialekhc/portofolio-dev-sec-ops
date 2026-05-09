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
- Code Quality: SonarCloud or SonarQube

## 3. Project Structure

```text
portfolio-devqaops/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── sonar.yml
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
- `SONAR_ORGANIZATION` (your SonarCloud organization key, optional for self-hosted SonarQube)
- `SONAR_HOST_URL` (optional; set this for self-hosted SonarQube, e.g. `https://sonar.example.com`)

## 8. CI/CD Workflow Explanation

Workflow files:
- `.github/workflows/ci.yml`
- `.github/workflows/sonar.yml`

### Trigger
- Push to `main`
- Pull request to `main`

### `sonar.yml` workflow
1. Checkout code.
2. Validate Sonar secrets.
3. Run static analysis using SonarCloud or SonarQube (depending on secrets).

### `ci.yml` workflow
1. Build Docker image `portfolio-devqaops:latest`.
2. Save image as `portfolio-devqaops.tar`.
3. Upload image artifact.
4. Deploy to EC2 on push to `main`.

### Deploy stage in `ci.yml` (only on push to `main`)
1. Download Docker image artifact.
2. Copy tar file to EC2 via SCP.
3. SSH into EC2 and run:
   - `docker load`
   - stop/remove existing `portfolio-container` if present
   - run updated container on port `80`
   - cleanup temporary files and unused Docker resources

## 9. Sonar Setup (Cloud or Self-hosted)

1. Create a SonarCloud project connected to your GitHub repository.
2. Copy project key and organization key.
3. Add `SONAR_TOKEN` and `SONAR_PROJECT_KEY` in GitHub Secrets.
4. Add `SONAR_ORGANIZATION` if you are using SonarCloud.
5. Add `SONAR_HOST_URL` only if you are using self-hosted SonarQube.
6. Keep `sonar-project.properties` in repository root.

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
2. `sonar.yml` runs static code analysis.
3. `ci.yml` builds the Docker image.
4. `ci.yml` transfers artifact to EC2 and redeploys automatically.

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
- Confirm `SONAR_TOKEN` and `SONAR_PROJECT_KEY` are correct.
- For SonarCloud, confirm `SONAR_ORGANIZATION` is correct.
- For self-hosted SonarQube, set `SONAR_HOST_URL` correctly.
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
