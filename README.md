# Enterprise Cloud SaaS Platform (AWS EKS, Terraform & GitOps)

![Architecture Version](https://img.shields.io/badge/Architecture-Enterprise_Multi--AZ-blue)
![IaC](https://img.shields.io/badge/IaC-Terraform_v1.5+-purple)
![Orchestration](https://img.shields.io/badge/Kubernetes-EKS_v1.30+-orange)
![CD Strategy](https://img.shields.io/badge/GitOps-ArgoCD-green)

## 📌 Executive Summary
This project demonstrates an enterprise-grade cloud-native infrastructure and microservices deployment pipeline on **Amazon Web Services (AWS)** using **Terraform**, **Amazon EKS**, **ArgoCD**, **GitHub Actions**, and **Kube-Prometheus-Stack**.

Designed following **DevSecOps** and **FinOps** practices to ensure high availability, end-to-end security, and cost efficiency.

---

## 🏗️ Repository Architecture

```text
aws-eks-gitops-saas-platform/
├── .github/workflows/    # CI Pipelines (Gitleaks, Trivy, Docker Push)
├── gitops/               # ArgoCD Applications, Helm Charts & Kustomize Overlays
├── scripts/              # Automation and helper scripts
├── src/                  # Microservice Source Code (FastAPI/Node.js)
└── terraform/            # Infrastructure as Code (Modules & Multi-Env)
    ├── modules/          # Reusable modules (VPC, EKS, ECR, IAM)
    └── environments/     # Environment-specific declarations (Dev / Prod)
```

## 🚀 Key Architectural Features

1. Multi-Environment Isolation: Separate Terraform state backends and Kubernetes namespaces for dev and prod.
2. GitOps-Driven Continuous Deployment: Zero-manual deployments using ArgoCD tracking Git branches.
3. Automated DevSecOps Pipeline: Static code analysis, secret scanning (Gitleaks), and container vulnerability assessment (Trivy).
4. Full Observability & TLS: Native Prometheus metrics exposure, Grafana dashboards, and automated SSL certificates with Cert-Manager.

## 🛠️ Local Environment Requirements

- OS: WSL2 (Ubuntu 22.04) / Linux
- Tools: AWS CLI v2, Terraform, kubectl, Helm, Docker, Git, Gitleaks.

*Maintained by Miguel Amorós*
