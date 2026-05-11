# AWS Academy Deployment Guide (Step-by-Step)

This guide documents exactly how this project was deployed to AWS EC2 in a constrained AWS Academy Learner Lab environment.

## 1. Prerequisites

- AWS Academy Learner Lab started
- Temporary credentials available from **AWS Details**:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_SESSION_TOKEN`
- PEM key file available locally (example used):
  - `/Users/anex/Downloads/labsuser.pem`
- Docker Desktop running locally

## 2. Why `aws login` Was Not Used

In this environment, `aws login` returned a `403 Forbidden Request` due to missing `SignInLocalDevelopmentAccess` policy. 

Therefore, the deployment used **temporary environment credentials** from AWS Academy instead.

## 3. Export Temporary AWS Credentials

```bash
unset AWS_PROFILE
export AWS_ACCESS_KEY_ID="<LAB_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<LAB_SECRET_ACCESS_KEY>"
export AWS_SESSION_TOKEN="<LAB_SESSION_TOKEN>"
export AWS_DEFAULT_REGION="us-east-1"
```

Verify access:

```bash
aws sts get-caller-identity
aws ec2 describe-availability-zones --region us-east-1 --query "AvailabilityZones[0].ZoneName" --output text
```

## 4. Prepare Key Pair for EC2

Set strict permission on PEM:

```bash
chmod 400 /Users/anex/Downloads/labsuser.pem
```

If `labsuser` key pair does not exist in EC2, import it:

```bash
ssh-keygen -y -f /Users/anex/Downloads/labsuser.pem > /tmp/labsuser.pub
aws ec2 import-key-pair \
  --region us-east-1 \
  --key-name labsuser \
  --public-key-material fileb:///tmp/labsuser.pub
```

## 5. Deploy CloudFormation Stack

```bash
cd /Users/anex/Developer/portofolio-dev-sec-ops

aws cloudformation validate-template \
  --region us-east-1 \
  --template-body file://cloudformation.yaml

aws cloudformation create-stack \
  --region us-east-1 \
  --stack-name portfolio-devqaops-stack \
  --template-body file://cloudformation.yaml \
  --parameters \
    ParameterKey=KeyName,ParameterValue=labsuser \
    ParameterKey=InstanceType,ParameterValue=t2.micro \
    ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0

aws cloudformation wait stack-create-complete \
  --region us-east-1 \
  --stack-name portfolio-devqaops-stack
```

Fetch outputs:

```bash
aws cloudformation describe-stacks \
  --region us-east-1 \
  --stack-name portfolio-devqaops-stack \
  --query "Stacks[0].Outputs" \
  --output table
```

## 6. Build Docker Image for EC2 Architecture

Because the local machine is Apple Silicon and EC2 is x86_64, image must be built as `linux/amd64`.

```bash
cd /Users/anex/Developer/portofolio-dev-sec-ops

docker buildx build --platform linux/amd64 -t portfolio-devqaops:latest --load .
docker save portfolio-devqaops:latest -o portfolio-devqaops.tar
```

## 7. Upload Image to EC2 and Run Container

Replace `<EC2_PUBLIC_IP>` with your stack output:

```bash
export EC2_HOST="<EC2_PUBLIC_IP>"

scp -i /Users/anex/Downloads/labsuser.pem -o StrictHostKeyChecking=no \
  portfolio-devqaops.tar ec2-user@"$EC2_HOST":/home/ec2-user/

ssh -i /Users/anex/Downloads/labsuser.pem -o StrictHostKeyChecking=no ec2-user@"$EC2_HOST" <<'EOFSSH'
set -e
cd /home/ec2-user
sudo docker load -i portfolio-devqaops.tar
sudo docker stop portfolio-container || true
sudo docker rm portfolio-container || true
sudo docker run -d --name portfolio-container --restart unless-stopped -p 80:80 portfolio-devqaops:latest
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOFSSH
```

## 8. Validate Deployment

From local machine:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://$EC2_HOST
```

Expected: `200`

Then open in browser:

```text
http://<EC2_PUBLIC_IP>
```

## 9. Actual Deployment Result (Documented Run)

- Date: May 11, 2026
- Region: `us-east-1`
- Stack: `portfolio-devqaops-stack`
- Instance: `i-07e2a5d4017656c6f`
- Public IP: `54.198.41.101`
- Website: `http://54.198.41.101`
- Final external health check: HTTP `200`

## 10. Common Errors and Fixes

1. `aws login` 403 forbidden
- Cause: Missing `SignInLocalDevelopmentAccess`
- Fix: Use temporary credentials from lab details

2. `Your session has expired`
- Cause: Expired temporary credentials
- Fix: Re-copy and export fresh credentials

3. `Invalid endpoint: https://ec2..amazonaws.com`
- Cause: Empty region variable
- Fix: `export AWS_DEFAULT_REGION=us-east-1`

4. `Permissions 0644 for ...pem are too open`
- Cause: PEM file not restricted
- Fix: `chmod 400 <pem>`

5. `exec /docker-entrypoint.sh: exec format error`
- Cause: ARM image on AMD64 EC2
- Fix: Build with `docker buildx --platform linux/amd64`

## 11. Post-Deployment Actions for CI/CD

After manual success, configure GitHub secrets:

- `EC2_HOST`
- `EC2_USER`
- `EC2_SSH_KEY`
- `SONAR_TOKEN`
- `SONAR_PROJECT_KEY` (recommended)
- `SONAR_ORGANIZATION` (if SonarCloud)
- `SONAR_HOST_URL` (if self-hosted SonarQube)

Then push to `main` to trigger workflows.

## 12. Sonar Workflow Repair Checklist

To avoid old failing runs, keep only these workflow files:

- `.github/workflows/ci.yml`
- `.github/workflows/sonar.yml`

Ensure these old files are removed:

- `.github/workflows/build.yml`
- `.github/workflows/pipeline.yaml`

### Sonar secrets by mode

SonarCloud mode:

- `SONAR_TOKEN`
- `SONAR_ORGANIZATION`
- `SONAR_PROJECT_KEY` (recommended)

Self-hosted SonarQube mode:

- `SONAR_TOKEN`
- `SONAR_HOST_URL`
- `SONAR_PROJECT_KEY` (recommended)

### Validate Sonar after push

1. Push commit to `main`.
2. Open `Actions` tab in GitHub.
3. Confirm workflow `Sonar Analysis` is green.
4. Open Sonar dashboard and verify analysis time matches the latest commit.
