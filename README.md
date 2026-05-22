# Distributed Inferencing Prototype Deployment

# AWS Architecture

```text
VPC (10.0.0.0/16)
│
├── Public Subnet (10.0.1.0/24)
│   ├── Internet Gateway
│   ├── NAT Gateway
│   └── API Gateway EC2 (Public IP)
│
└── Private Subnet (10.0.2.0/24)
    ├── Route via NAT Gateway
    ├── Caller Worker EC2
    └── Inference Worker EC2
```

---

# Distributed Deployment Architecture

```text
                Internet
                    |
                    v
          [ API Gateway VM ]
         (iii Engine + iii-http)
                    |
          WebSocket RPC (49134)
                    |
         -----------------------
         |                     |
 [ Caller Worker VM ]   [ Inference Worker VM ]
    TypeScript               Python
```

---

# Infrastructure Components

| Component | Purpose |
|---|---|
| VPC | Isolated AWS network |
| Public Subnet | Hosts API VM with public access |
| Private Subnet | Hosts internal workers |
| Internet Gateway | Public internet access |
| NAT Gateway | Outbound internet for private VMs |
| Security Groups | Restrict internal communication |
| API VM | Hosts iii engine and HTTP worker |
| Caller Worker VM | TypeScript RPC worker |
| Inference Worker VM | Python model inference worker |

---

# Security Design

- Only the API VM has a public IP address.
- Caller Worker and Inference Worker run inside a private subnet.
- Internal communication happens using iii WebSocket RPC.
- Security groups restrict traffic between workers.
- NAT Gateway allows private instances to download dependencies without exposing them publicly.

---

# Steps to Deploy From Scratch

## 1. Clone Repository

```bash
git clone https://github.com/Alchemyst-ai/hiring.git
cd hiring/may-2026/devops/quickstart
```

---

## 2. Configure AWS CLI

```bash
aws configure
```

Provide:
- AWS Access Key
- AWS Secret Key
- Region

Make sure the configured AWS region matches the Terraform variable file region.

---

## 3. Deploy Infrastructure

```bash
terraform init
terraform apply
```

Wait approximately 5–7 minutes for infrastructure provisioning.

---

# VM Installation Order

Deployment order:

```text
1. API VM
2. Caller Worker VM
3. Inference Worker VM
```

---

# Debugging Commands

Useful iii worker management commands:

```bash
iii worker start <name>
iii worker stop <name>
iii worker restart <name>

iii worker status <name>
iii worker logs <name>

iii worker exec <name> -- <command>
```

---

# API VM Setup

SSH into the API VM.

## Start iii Engine

```bash
iii --config config.yaml
```

Keep this terminal running.

The iii engine listens on:

```text
ws://0.0.0.0:49134
```

---

## Open New Terminal

Add HTTP worker:

```bash
iii worker add iii-http
```

---

# Caller Worker VM Setup

SSH into the Caller Worker VM.

## Connect to Remote iii Engine

```bash
export III_URL=ws://<API-PRIVATE-IP>:49134
```

---

## Start Caller Worker

```bash
iii worker add ./workers/caller-worker
```

---

# Inference Worker VM Setup

SSH into the Inference Worker VM.

---

## Create Python Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

---

## Install Dependencies

```bash
pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

pip install --no-cache-dir transformers

pip install -r requirements.txt
```

---

## Connect to Remote iii Engine

```bash
export III_URL=ws://<API-PRIVATE-IP>:49134
```

---

## Start Inference Worker

```bash
iii worker add ./workers/inference-worker
```

---

# API Testing

## Test Endpoint

```bash
curl -X POST http://PUBLIC-IP:3111/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{
  "messages": [
    {
      "role": "user",
      "content": "Hello"
    }
  ]
}'
```

---

# Sample Response

```json
{
  "response": "Hello! How can I help you today?"
}
```

---

# Production Hardening Considerations

Before deploying this system to production, additional improvements would be required to improve security, reliability, scalability, and observability.

Network security would be hardened further by restricting inbound traffic using stricter security group rules and private DNS-based communication. External traffic would be routed through HTTPS using TLS certificates managed by AWS Certificate Manager. An Application Load Balancer (ALB) would be placed in front of the API layer to improve scalability and availability.

Sensitive configuration values and secrets would be managed using AWS Secrets Manager or Parameter Store instead of plain environment variables. Logging and monitoring would be centralized using Prometheus, Grafana, CloudWatch, and Fluent Bit to improve operational visibility and debugging.

For deployment reliability, the system could be containerized using Docker and orchestrated using Kubernetes (EKS). GitOps workflows using ArgoCD would provide automated reconciliation, rollback, and zero-downtime deployments.

Additional production improvements would include:
- Auto scaling
- Rate limiting
- Authentication and authorization
- WAF protection
- Health checks
- Backup and disaster recovery
- CI/CD automation

---

# If the Model Were 100x Larger

If the model size increased significantly, the architecture would require major changes to support higher compute, memory, and throughput requirements.

The inference layer would move from CPU-based EC2 instances to GPU-enabled instances such as AWS g5 or p4 instances. Distributed inference techniques such as tensor parallelism, model sharding, and inference batching would be introduced to optimize latency and throughput.

Kubernetes with GPU node groups and autoscaling would become essential for managing dynamic workloads and scaling inference workers based on traffic demand. Model caching and asynchronous request processing would also help reduce server load and improve response times.

To control infrastructure costs, Reserved Instances or Spot Instances could be used alongside aggressive monitoring, billing alerts, optimized logging retention, and S3 lifecycle policies.

Queue-based architectures using Kafka or Amazon SQS could help manage high request concurrency and smooth traffic spikes. Observability would become even more important for tracking:
- GPU utilization
- Token throughput
- Memory consumption
- Inference latency
- Request failures

These optimizations would improve scalability, reliability, and cost efficiency for large-scale model serving environments.
