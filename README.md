
# 🚀 Advanced CI/CD & Kubernetes Deployment

An end-to-end DevOps CI/CD project demonstrating automated application validation, testing, Docker image creation, Docker Hub publishing, Kubernetes deployment, rolling updates, controlled deployment failure, and rollback.

The project uses **GitHub, Jenkins, Docker, Docker Hub, Kubernetes (Kind), and AWS EC2 Ubuntu**.

---
# 🏗️ Architecture
<img width="1536" height="1024" alt="rooling back diagram" src="https://github.com/user-attachments/assets/1055324f-d870-4502-90d6-593c030a09da" />

## 📌 Project Overview

This project implements an automated CI/CD workflow:

```text
Developer
    │
    ▼
  GitHub
    │
    ▼
  Jenkins
    │
    ├── Checkout
    ├── Build Validation
    ├── Automated Test
    ├── Docker Build
    ├── Docker Push
    ├── Kubernetes Deploy
    └── Deployment Verify
            │
            ▼
       Docker Hub
            │
            ▼
    Kubernetes (Kind)
            │
       ┌────┴────┐
       ▼         ▼
  Deployment   Service
       │       NodePort
       │         │
       ▼         ▼
    3 Pods    Application
       │
       ▼
     NGINX
````

The project also demonstrates:

* CI/CD automation
* Docker containerization
* Kubernetes deployment
* Multiple application replicas
* Rolling updates
* Deployment monitoring
* Controlled deployment failure
* Kubernetes rollback
* Automated deployment verification

---

## 🎯 Objectives

The main objectives of this project are:

* Build an automated CI/CD pipeline using Jenkins.
* Store application source code in GitHub.
* Validate application files automatically.
* Execute automated application tests.
* Build Docker images using a Dockerfile.
* Push versioned Docker images to Docker Hub.
* Deploy the application to Kubernetes.
* Run three application replicas.
* Configure Kubernetes RollingUpdate deployment.
* Perform a controlled deployment failure.
* Investigate Kubernetes deployment issues.
* Roll back to a previous working version.
* Verify application availability after deployment.

---

## 🛠️ Technology Stack

| Category                | Technology          |
| ----------------------- | ------------------- |
| Source Control          | Git, GitHub         |
| CI/CD                   | Jenkins             |
| Containerization        | Docker              |
| Container Registry      | Docker Hub          |
| Orchestration           | Kubernetes          |
| Kubernetes Distribution | Kind                |
| Cloud Infrastructure    | AWS EC2 Ubuntu      |
| Web Server              | NGINX               |
| Deployment Strategy     | RollingUpdate       |
| Service Exposure        | Kubernetes NodePort |
| Automation              | Jenkins Pipeline    |
| Scripting               | Bash / Shell        |

---

## 📂 Project Structure

```text
advanced-cicd-deployment-k8s-rollback/
│
├── app/
│   ├── Dockerfile
│   ├── index.html
│   └── test.sh
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── Jenkinsfile
├── kind-config.yaml
├── README.md
└── .gitignore
```

---

# 🔄 CI/CD Pipeline

The Jenkins pipeline follows this workflow:

```text
GitHub
   │
   ▼
Checkout
   │
   ▼
Build Validation
   │
   ▼
Automated Test
   │
   ▼
Docker Build
   │
   ▼
Docker Push
   │
   ▼
Kubernetes Deploy
   │
   ▼
Deployment Verify
```

---

## 1️⃣ Checkout

Jenkins retrieves the application source code from the GitHub repository.

Repository:

```text
https://github.com/Mahendra0456/advanced-cicd-deployment-k8s-rollback.git
```

Branch:

```text
main
```

---

## 2️⃣ Build Validation

The Build stage validates that the required application files exist.

Example:

```bash
cd app
test -f index.html
```

If the required application file is present, the build validation succeeds.

> Note: This project does not contain a compiled programming language. Therefore, the Jenkins Build stage performs application validation rather than compilation.

---

## 3️⃣ Automated Testing

The pipeline executes the `test.sh` script.

Example checks:

```bash
test -f index.html
grep -q "Week 9 DevOps CI/CD Pipeline" index.html
```

The test script returns a successful result when the expected application content is present.

---

## 4️⃣ Docker Image Build

Jenkins builds the application into a Docker image using the Dockerfile.

Docker image format:

```text
mahendra46/week9-app:<BUILD_NUMBER>
```

For example:

```text
mahendra46/week9-app:3
```

The Jenkins build number is used as the image tag.

---

## 5️⃣ Docker Push

After the Docker image is successfully built, Jenkins authenticates with Docker Hub using Jenkins Credentials.

The image is then pushed to:

```text
mahendra46/week9-app
```

Docker credentials are **not stored directly inside the Jenkinsfile**.

---

## 6️⃣ Kubernetes Deployment

Jenkins deploys the Docker image to Kubernetes.

The Kubernetes Deployment uses:

* 3 replicas
* RollingUpdate strategy
* `maxUnavailable: 1`
* `maxSurge: 1`
* HTTP readiness probe

The image tag is dynamically replaced with the current Jenkins build number before deployment.

---

## 7️⃣ Deployment Verification

After deployment, Jenkins verifies the Kubernetes rollout:

```bash
kubectl rollout status deployment/week9-app --timeout=180s
```

It also checks:

```bash
kubectl get deployment week9-app
kubectl get pods -l app=week9-app
kubectl get service week9-app-service
```

---

# 🐳 Docker Configuration

The application uses NGINX Alpine as the base image.

### Dockerfile

```dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
```

Build locally:

```bash
docker build -t mahendra46/week9-app:1 ./app
```

Run locally:

```bash
docker run -d -p 8080:80 mahendra46/week9-app:1
```

Test:

```bash
curl http://localhost:8080
```

---

# ☸️ Kubernetes Deployment

The application is deployed using a Kubernetes Deployment.

Configuration:

```text
Replicas:        3
Strategy:        RollingUpdate
Max Unavailable: 1
Max Surge:       1
Readiness Probe: HTTP
```

Deployment configuration:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
```

Check deployment:

```bash
kubectl get deployment week9-app
```

Expected:

```text
NAME        READY   UP-TO-DATE   AVAILABLE
week9-app   3/3     3            3
```

Check Pods:

```bash
kubectl get pods -l app=week9-app
```

---

# 🌐 Kubernetes Service

The application is exposed through a Kubernetes NodePort Service.

```text
Service Port : 80
Target Port  : 80
NodePort     : 30080
```

Check the Service:

```bash
kubectl get svc week9-app-service
```

Expected:

```text
week9-app-service   NodePort   ...   80:30080/TCP
```

Application endpoint:

```text
http://<EC2-PUBLIC-IP>:30080
```

---

# 🔁 Rolling Deployment

The project demonstrates Kubernetes RollingUpdate.

### Initial Version

```text
Week 9 DevOps CI/CD Pipeline
Version 1
```

After modifying the application version, a new Jenkins build creates a new Docker image.

For example:

```text
mahendra46/week9-app:3
```

Kubernetes then gradually replaces the existing Pods according to the configured RollingUpdate strategy.

Monitor the deployment:

```bash
kubectl rollout status deployment/week9-app
```

Watch Pods:

```bash
kubectl get pods -l app=week9-app -w
```

Check rollout history:

```bash
kubectl rollout history deployment/week9-app
```

---

# ❌ Controlled Deployment Failure

A controlled deployment issue can be introduced by changing the Kubernetes deployment to reference an invalid Docker image tag.

Example:

```text
mahendra46/week9-app:invalid
```

After applying the faulty configuration, Kubernetes may show Pods in states such as:

```text
ImagePullBackOff
ErrImagePull
```

Check the Deployment:

```bash
kubectl get deployment week9-app
```

Check Pods:

```bash
kubectl get pods
```

Inspect the affected Pod:

```bash
kubectl describe pod <pod-name>
```

Check Deployment details:

```bash
kubectl describe deployment week9-app
```

The Events section can be used to identify the image-pull problem.

---

# ↩️ Kubernetes Rollback

Kubernetes maintains deployment revision history.

View the history:

```bash
kubectl rollout history deployment/week9-app
```

Rollback to the previous revision:

```bash
kubectl rollout undo deployment/week9-app
```

Monitor the rollback:

```bash
kubectl rollout status deployment/week9-app
```

Verify the Pods:

```bash
kubectl get pods -l app=week9-app
```

Verify the deployment image:

```bash
kubectl describe deployment week9-app | grep -i image
```

After the rollback completes, the application can be tested again through the NodePort endpoint.

---

# 🔐 Jenkins Docker Authentication

Docker Hub authentication is handled using Jenkins Credentials.

Credential ID used by the pipeline:

```text
dockerhub-creds
```

The Docker Hub Personal Access Token is stored inside Jenkins rather than being hard-coded in the repository.

The Jenkinsfile accesses the credentials through Jenkins' credential system.

> Never commit Docker Hub tokens, AWS credentials, `.pem` files, kubeconfig files, or other secrets to GitHub.

---

# 📜 Jenkinsfile

The pipeline is defined as code using a `Jenkinsfile`.

Major stages:

```text
Checkout
    ↓
Build
    ↓
Test
    ↓
Package
    ↓
Docker Push
    ↓
Deploy
    ↓
Verify
```

The Jenkinsfile is stored in the GitHub repository and Jenkins loads it using:

```text
Pipeline script from SCM
```

---

# 🔧 Environment Variables

The pipeline uses environment variables for reusable configuration.

Example:

```groovy
environment {
    DOCKER_IMAGE = "mahendra46/week9-app"
    DOCKER_CREDENTIALS = credentials('dockerhub-creds')
    IMAGE_TAG = "${BUILD_NUMBER}"
}
```

This allows the Docker image tag to automatically change with each Jenkins build.

Example:

```text
Build #1 → mahendra46/week9-app:1
Build #2 → mahendra46/week9-app:2
Build #3 → mahendra46/week9-app:3
```

---

# 🧪 Application Testing

## Kubernetes Service Test

The Kubernetes Service can be tested internally using a temporary curl Pod:

```bash
kubectl run test-curl \
  --rm -it \
  --image=curlimages/curl \
  --restart=Never \
  -- curl -v http://week9-app-service
```

A successful response returns the application HTML.

---

## External Application Test

The application can be accessed through:

```text
http://<EC2-PUBLIC-IP>:30080
```

The browser should display the Week 9 application page.

---

# 📊 Useful Verification Commands

### Kubernetes Nodes

```bash
kubectl get nodes
```

### Deployment

```bash
kubectl get deployment week9-app
```

### Pods

```bash
kubectl get pods -l app=week9-app
```

### Service

```bash
kubectl get svc week9-app-service
```

### Docker Image Used by Deployment

```bash
kubectl describe deployment week9-app | grep -i image
```

### Rollout Status

```bash
kubectl rollout status deployment/week9-app
```

### Rollout History

```bash
kubectl rollout history deployment/week9-app
```

### Deployment Details

```bash
kubectl describe deployment week9-app
```

---

# 📸 Project Screenshots

The following screenshots should be included as project evidence:

```text
01-Jenkins-Pipeline.png
02-Jenkins-Successful-Build.png
03-Docker-Image.png
04-GitHub-Repository.png
05-Kubernetes-Deployment.png
06-Successful-Application.png
07-Rolling-Deployment.png
08-Controlled-Deployment-Issue.png
09-Rollback.png
10-Pipeline-Architecture.png
```

### Screenshot Evidence

| Screenshot                           | Evidence                         |
| ------------------------------------ | -------------------------------- |
| `01-Jenkins-Pipeline.png`            | Jenkins pipeline stages          |
| `02-Jenkins-Successful-Build.png`    | Successful Jenkins execution     |
| `03-Docker-Image.png`                | Docker Hub image/tag             |
| `04-GitHub-Repository.png`           | GitHub repository and source     |
| `05-Kubernetes-Deployment.png`       | Deployment, Pods and Service     |
| `06-Successful-Application.png`      | Application running successfully |
| `07-Rolling-Deployment.png`          | Kubernetes rolling update        |
| `08-Controlled-Deployment-Issue.png` | Controlled deployment failure    |
| `09-Rollback.png`                    | Successful Kubernetes rollback   |
| `10-Pipeline-Architecture.png`       | End-to-end architecture          |


# 🔐 Security Considerations

The project follows basic CI/CD security practices:

* Docker Hub credentials are stored in Jenkins Credentials.
* Docker tokens are not hard-coded into the Jenkinsfile.
* Sensitive files such as `.pem` files are excluded through `.gitignore`.
* Environment files containing secrets should not be committed.
* Kubernetes credentials should be protected.
* Personal Access Tokens should never be uploaded to GitHub.

Example `.gitignore` entries:

```text
*.pem
.env
.kube/
*.log
```

---

# 🧠 Key DevOps Concepts Demonstrated

This project demonstrates practical knowledge of:

* CI/CD
* Git-based development workflow
* Jenkins Pipeline as Code
* Jenkins credentials
* Docker image creation
* Docker Hub registry
* Containerized applications
* Kubernetes Deployments
* Kubernetes Pods
* Kubernetes Services
* NodePort
* Readiness probes
* RollingUpdate
* Deployment revision history
* Kubernetes rollback
* Automated deployment verification
* AWS EC2
* Kind Kubernetes
* Bash scripting
* Troubleshooting deployment failures

---

# 📝 Implementation Summary

A complete CI/CD pipeline was implemented using **GitHub, Jenkins, Docker, Docker Hub, and Kubernetes**.

Jenkins automatically checks out the source code, validates the application, executes automated tests, builds a versioned Docker image, and pushes the image to Docker Hub.

The pipeline then deploys the new image to a Kubernetes Deployment running three replicas. Kubernetes performs a RollingUpdate to gradually replace the previous Pods.

The project also demonstrates a controlled deployment failure using an invalid image reference. The resulting Kubernetes failure is investigated using deployment and Pod inspection commands, followed by a rollback to the previous working revision using:

```bash
kubectl rollout undo deployment/week9-app
```

The application is then verified after recovery.

---

# 🎓 What This Project Demonstrates

The complete workflow is:

```text
Developer
    ↓
GitHub
    ↓
Jenkins
    ↓
Build Validation
    ↓
Automated Testing
    ↓
Docker Build
    ↓
Docker Hub
    ↓
Kubernetes Deployment
    ↓
Rolling Update
    ↓
Application Verification
    ↓
Controlled Failure
    ↓
Troubleshooting
    ↓
Rollback
    ↓
Application Recovery
```

This demonstrates an end-to-end automated software delivery and recovery workflow.

---

# 👨‍💻 Author

**Mahendra Swain**

Junior DevOps & Cloud Engineer

* GitHub: [https://github.com/Mahendra0456](https://github.com/Mahendra0456)
* LinkedIn: [https://linkedin.com/in/mahendra-swain](https://linkedin.com/in/mahendra-swain)

---

## ⭐ Project

If this project is useful for learning DevOps, CI/CD, Docker, Jenkins, and Kubernetes concepts, consider giving the repository a star.

```

### What I changed from the previous version

- Kept the **Claude README structure and technical content** as the foundation. :contentReference[oaicite:0]{index=0}
- Corrected the pipeline terminology to match your real Jenkinsfile: **Build = validation**, while Docker image creation happens in **Package**. :contentReference[oaicite:1]{index=1}
- Added your actual repository and Docker Hub naming.
- Added the actual Jenkins credential ID without exposing the secret.
- Added your real `BUILD_NUMBER` image-tagging approach.
- Added the actual **3-replica + RollingUpdate (`maxUnavailable: 1`, `maxSurge: 1`)** configuration.
- Clearly separated **rolling deployment, controlled failure, and rollback**.
- Did **not** claim Blue-Green deployment was implemented; the assignment material treats that as a separate concept.
- Added a cleaner recruiter-facing architecture and evidence section.
- Added security guidance around tokens, `.pem`, `.env`, and kubeconfig.
- Kept the screenshot list aligned with the project evidence requirements. 

**This is the version I would use as your final GitHub `README.md`.**
```
