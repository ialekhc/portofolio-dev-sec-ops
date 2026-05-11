# Portfolio DevQAOps Project

Coursework repository for **CC7010NI Development, Quality Assurance and Operations**.

This project demonstrates a complete **Development + QA + Operations** workflow for a static personal portfolio website:

- Build frontend with plain HTML/CSS/JavaScript
- Containerize with Docker and Nginx
- Provision AWS infrastructure with CloudFormation
- Deploy container to AWS EC2
- Automate quality checks and deployment with GitHub Actions
- Run static analysis with SonarCloud/SonarQube

## 1. Module and Objective

**Module:** CC7010NI Development, Quality Assurance and Operations

**Objective:** Deliver a simple but professional portfolio website with a clear, demonstrable DevQAOps lifecycle suitable for academic presentation.

## 2. Architecture Overview

1. Static website files are served by Nginx inside Docker.
2. AWS CloudFormation provisions an EC2 instance and security group.
3. GitHub Actions builds Docker image and deploys to EC2 on push to `main`.
4. SonarQube static analysis runs on push/PR as part of CI/CD.

## 3. Technology Stack

- Frontend: HTML5, CSS3, JavaScript (Vanilla)
- Containerization: Docker
- Web server: Nginx (`nginx:alpine`)
- Infrastructure as Code: AWS CloudFormation
- Cloud runtime: AWS EC2 (Amazon Linux)
- CI/CD: GitHub Actions
- Code quality: SonarCloud / SonarQube

## 4. Repository Structure

```text
portfolio-devqaops/
├── .github/
│   └── workflows/
│       ├── build.yml
│       ├── ci.yml
│       ├── pipeline.yaml
│       └── sonar.yml
├── assets/
│   └── alekh-chaudhary.jpg
├── docs/
│   └── DEPLOYMENT_AWS_ACADEMY.md
├── cloudformation.yaml
├── default.conf
├── Dockerfile
├── index.html
├── nginx.conf
├── script.js
├── sonar-project.properties
├── styles.css
└── README.md
```

## 5. Local Execution

Run directly:

```bash
cd /Users/anex/Developer/portofolio-dev-sec-ops
python3 -m http.server 8080
```

Open `http://localhost:8080`

## 6. Docker Execution (Local)

Build:

```bash
cd /Users/anex/Developer/portofolio-dev-sec-ops
docker build -t portfolio-devqaops:latest .
```

Run:

```bash
docker run -d --name portfolio-container -p 8081:8080 portfolio-devqaops:latest
```

Open `http://localhost:8081`

Note: container listens on internal port `8080` as a non-root user, so use host mapping like `8081:8080`.

Cleanup:

```bash
docker stop portfolio-container
docker rm portfolio-container
```

## 7. AWS Deployment Summary

Detailed step-by-step deployment guide:
- [docs/DEPLOYMENT_AWS_ACADEMY.md](docs/DEPLOYMENT_AWS_ACADEMY.md)

Documented successful run:

- Date: May 11, 2026
- Region: `us-east-1`
- Stack: `portfolio-devqaops-stack`
- Instance ID: `i-07e2a5d4017656c6f`
- Public IP: `54.198.41.101`
- URL: `http://54.198.41.101`

Note: Learner Lab resources are temporary and can reset.

## 8. GitHub Actions Workflows

### 8.1 `ci.yml`

Trigger:

- `push` to `main`
- `pull_request` to `main`

Flow:

1. Checkout repository
2. Run SonarQube/SonarCloud static analysis
3. Build Docker image (`portfolio-devqaops:latest`)
4. Save image to `portfolio-devqaops.tar`
5. Upload artifact
6. On push to `main`, deploy to EC2 by SCP + SSH

Deployment on EC2:

- `docker load`
- stop/remove old `portfolio-container`
- run new container on host port `80` mapped to container port `8080`
- clean temporary tar and unused layers

### 8.2 `sonar.yml`

Trigger:

- `workflow_dispatch` (manual)
- `workflow_call` (reusable)

Flow:

1. Checkout repository (full history)
2. Validate required Sonar secrets
3. Resolve Sonar host
4. Run one of the scan modes:
   - SonarCloud mode when `SONAR_ORGANIZATION` is set
   - Self-hosted SonarQube mode when `SONAR_ORGANIZATION` is empty and `SONAR_HOST_URL` is set

## 9. Sonar Setup (Fixed and Detailed)

This repository now uses a clean Sonar config with:

- Valid `sonar-project.properties`
- A dedicated Sonar workflow with explicit secret validation
- Clear fallback logic for SonarCloud vs SonarQube

### 9.1 Required Secrets

Always required:

- `SONAR_TOKEN`

Recommended:

- `SONAR_PROJECT_KEY` (optional; workflow auto-generates one from repo name if missing)

For SonarCloud:

- `SONAR_ORGANIZATION`

For self-hosted SonarQube:

- `SONAR_HOST_URL` (example: `https://sonar.example.com`)

### 9.2 SonarCloud Mode

Set these secrets:

- `SONAR_TOKEN`
- `SONAR_ORGANIZATION`
- `SONAR_PROJECT_KEY` (recommended)

`SONAR_HOST_URL` can be left empty; workflow defaults to `https://sonarcloud.io`.

### 9.3 Self-hosted SonarQube Mode

Set these secrets:

- `SONAR_TOKEN`
- `SONAR_HOST_URL`
- `SONAR_PROJECT_KEY` (recommended)

Leave `SONAR_ORGANIZATION` empty.

### 9.4 Verification

1. Push a commit to `main`.
2. Open GitHub Actions.
3. Confirm `CI/CD -> Sonar Scan` passes on push/PR.
4. Optional: run `Sonar Analysis` manually from Actions.
5. Open Sonar dashboard and verify new analysis appears.

## 10. GitHub Secrets for Full CI/CD

Deployment:

- `EC2_HOST`
- `EC2_USER`
- `EC2_SSH_KEY`

Sonar:

- `SONAR_TOKEN`
- `SONAR_PROJECT_KEY` (recommended)
- `SONAR_ORGANIZATION` (SonarCloud only)
- `SONAR_HOST_URL` (self-hosted only)

## 11. Manual vs Automated Process

Manual deployment:

1. Build image locally
2. Save image as tar
3. SCP tar to EC2
4. SSH and run container

Automated deployment:

1. Push to `main`
2. CI builds and uploads artifact
3. Deploy job updates EC2 container
4. Sonar workflow checks code quality

## 12. Troubleshooting

### Sonar scan fails immediately

- Check `SONAR_TOKEN` plus one mode secret:
  - `SONAR_HOST_URL` (self-hosted SonarQube), or
  - `SONAR_ORGANIZATION` (SonarCloud)
- `SONAR_PROJECT_KEY` is recommended but optional in this repo
- For SonarCloud: ensure `SONAR_ORGANIZATION` is correct
- For self-hosted: ensure `SONAR_HOST_URL` is correct and reachable

### Duplicate workflows execute

- Keep automatic trigger on `.github/workflows/ci.yml`
- Keep companion mandatory workflow files:
  - `.github/workflows/build.yml`
  - `.github/workflows/pipeline.yaml`
  - `.github/workflows/sonar.yml`

### Docker container restarts on EC2 with `exec format error`

- Build with target platform:
  - `docker buildx build --platform linux/amd64 -t portfolio-devqaops:latest --load .`

### EC2 deployment succeeds but site not reachable

- Verify security group inbound:
  - TCP 22 (SSH)
  - TCP 80 (HTTP)
- Check EC2 container:
  - `sudo docker ps`

## 13. Security Notes

- Never commit AWS credentials or PEM files
- Use GitHub Secrets for tokens/keys
- Keep PEM permission strict: `chmod 400 <pem>`
- Rotate credentials immediately if exposed

## 14. Demo Checklist (Viva)

- [ ] Show local web run
- [ ] Show Docker local run
- [ ] Show CloudFormation template and stack
- [ ] Show EC2 public URL live
- [ ] Show `build.yml`, `ci.yml`, `pipeline.yaml`, and `sonar.yml`
- [ ] Show successful Sonar run
- [ ] Explain manual vs automated deployment

## 15. Screenshots Placeholder

Add screenshots before final submission:

1. `screenshots/local-website.png`
2. `screenshots/docker-running.png`
3. `screenshots/cloudformation-stack.png`
4. `screenshots/github-actions-ci-success.png`
5. `screenshots/github-actions-sonar-success.png`
6. `screenshots/live-ec2-url.png`
