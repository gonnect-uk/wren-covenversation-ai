# Wren AI on GKE Autopilot

## What is Wren AI?

Wren AI is an advanced natural language to SQL conversion tool that revolutionizes database interactions. It allows users to:

- Query databases using plain English questions
- Automatically generate complex SQL queries
- Understand database schema and relationships
- Get instant query results with explanations

### Key Features

```mermaid
mindmap
  root((Wren AI))
    Natural Language Processing
      English to SQL
      Context Understanding
      Schema Awareness
    Database Integration
      PostgreSQL Support
      Schema Analysis
      Query Execution
    AI Capabilities
      GPT-4 Integration
      Vector Embeddings
      Query Optimization
    User Experience
      Web Interface
      Query History
      Result Visualization
```

### Conversational AI Capabilities

```mermaid
mindmap
  root((Natural Language<br/>Processing))
    Context Understanding
      Previous Queries History
      Schema Awareness
      Business Logic
    Query Enhancement
      Auto Corrections
      Query Suggestions
      Field Recommendations
    SQL Generation
      Complex Joins
      Aggregations
      Window Functions
    Results Processing
      Data Formatting
      Visual Suggestions
      Explanations
```

#### Natural Language Processing Features

1. **Context-Aware Queries**
   ```plaintext
   User: "Show me top-selling products"
   Wren: "I'll analyze the sales table. Would you like to see:
         - Top products by revenue
         - Top products by quantity
         - Top products by profit margin?"
   ```

2. **Schema Understanding**
   ```plaintext
   User: "What's our revenue?"
   Wren: "I notice multiple date fields. Would you like:
         - Total revenue to date
         - Revenue this month
         - Revenue by month?"
   ```

3. **Query Refinement**
   ```plaintext
   User: "Show customer orders"
   Wren: "To provide more specific information, please specify:
         - Time period
         - Order status
         - Specific customer(s)"
   ```

#### SQL Translation Examples

1. **Simple Query**
   ```plaintext
   User: "Show me sales from last month"
   SQL: 
   SELECT * FROM sales 
   WHERE sale_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
   AND sale_date < DATE_TRUNC('month', CURRENT_DATE);
   ```

2. **Complex Analytics**
   ```plaintext
   User: "What's the month-over-month growth in sales by category?"
   SQL:
   WITH monthly_sales AS (
     SELECT 
       DATE_TRUNC('month', sale_date) as month,
       category,
       SUM(amount) as sales
     FROM sales
     GROUP BY 1, 2
   )
   SELECT 
     month,
     category,
     sales,
     LAG(sales) OVER (PARTITION BY category ORDER BY month) as prev_month_sales,
     ((sales - LAG(sales) OVER (PARTITION BY category ORDER BY month)) / 
      LAG(sales) OVER (PARTITION BY category ORDER BY month) * 100) as growth_percent
   FROM monthly_sales
   ORDER BY month DESC, category;
   ```

3. **Multi-Table Analysis**
   ```plaintext
   User: "Show me customers who bought premium products but haven't ordered in 3 months"
   SQL:
   SELECT DISTINCT 
     c.customer_id,
     c.name,
     MAX(o.order_date) as last_order_date
   FROM customers c
   JOIN orders o ON c.customer_id = o.customer_id
   JOIN products p ON o.product_id = p.product_id
   WHERE p.category = 'premium'
   GROUP BY c.customer_id, c.name
   HAVING MAX(o.order_date) < CURRENT_DATE - INTERVAL '3 months';
   ```

#### Advanced Features

1. **Query Optimization**
   - Automatic index suggestions
   - Performance recommendations
   - Query execution plan analysis

2. **Data Visualization**
   - Automatic chart type selection
   - Interactive dashboards
   - Trend analysis

3. **Error Handling**
   - Syntax error correction
   - Missing join suggestions
   - Data type mismatch resolution

4. **Business Logic Integration**
   - Custom metric calculations
   - Business rule enforcement
   - Data access control

### Quick Setup Guide

1. Infrastructure: GKE Autopilot + Terraform
2. Core Components: UI, AI Service, Engine, Databases
3. Configuration: OpenAI API + PostgreSQL
4. Access: Web UI via LoadBalancer/Port-Forward

### Configuration Overview

```mermaid
flowchart TD
    A[Configuration Steps] --> B[OpenAI Setup]
    A --> C[Database Setup]
    A --> D[Model Config]
    A --> E[UI Access]
    
    B --> B1[API Key]
    B --> B2[Model Selection]
    
    C --> C1[PostgreSQL Init]
    C --> C2[Qdrant Vector DB]
    
    D --> D1[Embedding Model]
    D --> D2[LLM Model]
    
    E --> E1[Port Forward]
    E --> E2[LoadBalancer]
```

### Key Configuration Parameters

1. **OpenAI Models**:
   - LLM: `gpt-4o-mini-2024-07-18`
   - Embeddings: `text-embedding-3-large`
   - Dimension: `3072`

2. **Database**:
   - PostgreSQL Port: `5432`
   - Qdrant Port: `6333`
   - Default User: `wrenai`

3. **Services**:
   - UI Port: `3000`
   - AI Service Port: `5555`
   - Engine Port: `8080`

### Using Wren AI

1. **Database Connection**:
```sql
-- Example database setup
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    sale_date DATE,
    amount DECIMAL(10,2)
);
```

2. **Natural Language Queries**:
```plaintext
Example Queries:
- "Show total sales by product for last quarter"
- "Find top 5 products by revenue"
- "What was the average daily sales in December?"
```

3. **Best Practices**:
- Be specific with date ranges
- Mention table names when known
- Use business terms from schema
- Start with simple queries

This repository provides end-to-end instructions for deploying Wren AI on Google Kubernetes Engine (GKE) Autopilot.

## Detailed Architecture

### System Components Overview

```mermaid
graph TB
    subgraph GKE["GKE Autopilot Cluster"]
        subgraph Frontend["Frontend Layer"]
            UI["Wren UI Service|Port: 3000|Image: wren-ui:0.9.2"]
        end
        
        subgraph AILayer["AI Processing Layer"]
            AI["Wren AI Service|Port: 5555|Image: wren-ai-service:0.12.1"]
            Engine["Wren Engine|Port: 8080|Image: wren-engine:0.9.0"]
            Ibis["Ibis Server|Port: 8000|Image: ibis-server"]
        end
        
        subgraph DataLayer["Data Layer"]
            PG[("PostgreSQL|Port: 5432|PVC: postgresql-pvc")]
            Qdrant[("Qdrant Vector DB|Port: 6333|PVC: qdrant-pvc")]
        end
        
        subgraph ConfigLayer["Configuration"]
            Secrets["Kubernetes Secrets|OpenAI Keys|DB Credentials"]
            ConfigMaps["ConfigMaps|AI Models|Service Endpoints"]
        end
    end
    
    User((User)) --> UI
    UI --> AI
    UI --> Engine
    Engine --> Ibis
    Engine --> PG
    AI --> Qdrant
    
    Secrets -.- AI
    Secrets -.- Engine
    ConfigMaps -.- AI
    ConfigMaps -.- Engine
```

### Component Details

#### 1. Frontend Layer
- **Wren UI Service** (`wren-ui-svc`)
  - Purpose: Web interface for user interactions
  - Port: 3000
  - Image: `ghcr.io/canner/wren-ui:0.9.2`
  - Features:
    - Natural language query input
    - SQL query visualization
    - Results display
    - Query history

#### 2. AI Processing Layer
- **Wren AI Service** (`wren-ai-service-svc`)
  - Purpose: Natural language processing and SQL generation
  - Port: 5555
  - Image: `ghcr.io/canner/wren-ai-service:0.12.1`
  - Features:
    - OpenAI integration
    - Query vectorization
    - Context management

- **Wren Engine** (`wren-engine-svc`)
  - Purpose: Query processing and execution
  - Port: 8080
  - Image: `ghcr.io/canner/wren-engine:0.9.0`
  - Features:
    - SQL optimization
    - Database connection management
    - Result formatting

- **Ibis Server** (`wren-ibis-server-svc`)
  - Purpose: Database schema analysis
  - Port: 8000
  - Features:
    - Schema introspection
    - Metadata management
    - Type inference

#### 3. Data Layer
- **PostgreSQL** (`wren-postgresql`)
  - Purpose: Primary database for user data
  - Port: 5432
  - Storage: PersistentVolumeClaim
  - Credentials:
    - User: wrenai
    - Database: wrenai

- **Qdrant Vector DB** (`wren-qdrant`)
  - Purpose: Vector storage for AI embeddings
  - Port: 6333
  - Storage: PersistentVolumeClaim
  - Features:
    - Vector similarity search
    - Context storage

#### 4. Configuration Management
- **Kubernetes Secrets**
  - `wrenai-secrets`:
    - LLM_OPENAI_API_KEY
    - EMBEDDER_OPENAI_API_KEY
    - PG_USERNAME
    - PG_URL
    - USER_UUID
  - `wrenai-postgresql`:
    - postgres-password

- **ConfigMaps**
  - `wren-config`:
    - Service endpoints
    - Telemetry settings
    - Logging configuration
  - `wren-ai-service-config`:
    - LLM model settings
    - Embedder configuration

### Network Architecture

```mermaid
graph TB
    subgraph External["External Access"]
        LB["LoadBalancer|Ingress"]
        NAT["Cloud NAT"]
    end
    
    subgraph Network["Network Layer"]
        subgraph VPC["VPC: gke-vpc"]
            subgraph Subnet["Subnet: gke-subnet|172.16.0.0/20"]
                subgraph GKE["GKE Cluster"]
                    Master["Master|172.19.0.0/28"]
                    Pods["Pods|172.18.0.0/16"]
                    Services["Services|172.17.0.0/20"]
                end
            end
        end
    end
    
    Internet((Internet)) --> LB
    LB --> Services
    Pods --> NAT
    NAT --> Internet
```

### Data Flow

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Wren UI
    participant AI as AI Service
    participant E as Engine
    participant I as Ibis
    participant Q as Qdrant
    participant P as PostgreSQL

    U->>UI: Natural Language Query
    UI->>AI: Process Query
    AI->>Q: Get Similar Contexts
    Q-->>AI: Return Contexts
    AI->>E: Generate SQL
    E->>I: Validate Schema
    I-->>E: Schema Info
    E->>P: Execute Query
    P-->>E: Results
    E-->>UI: Formatted Results
    UI-->>U: Display Results
```

### Security Architecture

```mermaid
graph TB
    subgraph SecurityStack["Security Components"]
        subgraph NetworkSecurity["Network Layer"]
            Private["Private|GKE Cluster"]
            NAT["Cloud|NAT"]
            Master["Master|172.19.0.0/28"]
        end
        
        subgraph K8sSecurity["Kubernetes Layer"]
            NS["Namespace|Control"]
            Secrets["Secret|Management"]
            RBAC["RBAC|Policies"]
        end
        
        subgraph DataSecurity["Data Layer"]
            PVC["Volume|Encryption"]
            APIKeys["API|Security"]
            DBCreds["Database|Access"]
        end
    end

    Private --> NS
    NS --> Secrets
    Secrets --> APIKeys
    Secrets --> DBCreds
    NAT --> Private
    Master --> RBAC
    RBAC --> PVC
```

#### Security Components

1. **Network Security**
   - Private GKE cluster with public endpoint
   - Cloud NAT for outbound traffic
   - Network policies for pod communication
   - Private master access (172.19.0.0/28)

2. **Kubernetes Security**
   - Dedicated `wren` namespace
   - Secret management for sensitive data
   - Service accounts and RBAC
   - Pod security policies

3. **Data Security**
   - Encrypted persistent volumes
   - Secure API key management
   - Database credential rotation
   - TLS for service communication

### Monitoring and Logging

```mermaid
graph TB
    subgraph ObservabilityStack["Observability Stack"]
        subgraph MonitoringSection["Resource Monitoring"]
            CPU["CPU|Usage Trends"]
            Memory["Memory|Utilization"]
            Network["Network|Throughput"]
        end
        
        subgraph LoggingSection["System Logging"]
            AppLogs["App|Logs"]
            K8sLogs["K8s|Events"]
            AuditLogs["Audit|Trails"]
        end
        
        subgraph MetricsSection["Performance Metrics"]
            QPS["QPS|Throughput"]
            Latency["API|Response"]
            Success["Success|Rate"]
        end
    end

    CPU --> Latency
    Memory --> QPS
    Network --> Success
```

#### Monitoring Components

1. **Resource Monitoring**
   - CPU and memory utilization
   - Network throughput
   - Storage usage and IOPS
   - Pod health and status

2. **Application Monitoring**
   - Query response times
   - API endpoint latency
   - Error rates and types
   - User session metrics

3. **Infrastructure Logs**
   - Kubernetes cluster events
   - Container logs
   - Load balancer logs
   - Security audit logs

```mermaid
sequenceDiagram
    participant User
    participant UI as Wren UI
    participant Engine as Wren Engine
    participant AI as Wren AI Service
    participant DB as Databases

    User->>UI: Natural Language Query
    UI->>Engine: Process Query
    Engine->>AI: Convert to SQL
    AI->>DB: Execute SQL
    DB->>AI: Results
    AI->>Engine: Format Results
    Engine->>UI: Display Results
    UI->>User: Show Response
```

## Prerequisites

- Google Cloud SDK installed
- Terraform installed
- kubectl installed
- OpenAI API key
- Git

## Infrastructure Setup

### 1. GCP Project Configuration

```bash
# Login to GCP
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
```

### 2. Deploy GKE Autopilot Cluster

#### Infrastructure as Code (Terraform)

```mermaid
graph TB
    subgraph Network["Network Resources"]
        VPC["VPC: gke-vpc"]
        Subnet["Subnet: gke-subnet<br/>CIDR: 172.16.0.0/20"]
        Router["Cloud Router"]
        NAT["NAT Gateway"]
    end
    subgraph GKE["GKE Cluster"]
        Cluster["genai-autopilot-cluster"]
        Master["Master: 172.19.0.0/28"]
        Pods["Pods CIDR: 172.18.0.0/16"]
        Services["Services CIDR: 172.17.0.0/20"]
    end
    VPC --> Subnet
    Subnet --> Cluster
    VPC --> Router
    Router --> NAT
```

**Key Terraform Files:**

1. `provider.tf`: GCP Provider Configuration
```hcl
provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "us-central1"
}
```

2. `vpc.tf`: Network Setup
```hcl
# VPC with custom subnets
resource "google_compute_network" "gke_vpc" {
  name = "gke-vpc"
  auto_create_subnetworks = false
}

# Subnet with secondary ranges for pods and services
resource "google_compute_subnetwork" "gke_subnet" {
  name = "gke-subnet"
  ip_cidr_range = "172.16.0.0/20"
  network = google_compute_network.gke_vpc.id
  region = "us-central1"
  
  secondary_ip_range {
    range_name = "pod-ranges"
    ip_cidr_range = "172.18.0.0/16"
  }
  secondary_ip_range {
    range_name = "services-range"
    ip_cidr_range = "172.17.0.0/20"
  }
}
```

3. `gke.tf`: Autopilot Cluster
```hcl
resource "google_container_cluster" "autopilot" {
  name = "genai-autopilot-cluster"
  location = "us-central1"
  enable_autopilot = true
  
  network = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id
  
  private_cluster_config {
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.19.0.0/28"
  }
}
```

**Deploy Infrastructure:**
```bash
# Initialize Terraform
cd terraform
terraform init

# Deploy infrastructure
terraform plan
terraform apply

# Configure kubectl
gcloud container clusters get-credentials genai-autopilot-cluster --region us-central1 --project YOUR_PROJECT_ID
```

## Wren AI Deployment

### 1. Clone Wren AI Repository
```bash
git clone https://github.com/Canner/WrenAI.git
cd WrenAI
```

### 2. Create Kubernetes Namespace
```bash
kubectl create namespace wren
```

### 3. Configure Secrets

```bash
# Create OpenAI API key secret
kubectl create secret generic wrenai-secrets -n wren \
  --from-literal=LLM_OPENAI_API_KEY='your-openai-api-key' \
  --from-literal=EMBEDDER_OPENAI_API_KEY='your-openai-api-key' \
  --from-literal=PG_USERNAME='wrenai' \
  --from-literal=PG_URL='postgresql://wrenai:wrenai123@wren-postgresql:5432/wrenai' \
  --from-literal=USER_UUID='default-user' \
  --from-literal=POSTHOG_API_KEY='placeholder' \
  --from-literal=POSTHOG_HOST='https://app.posthog.com'

# Create PostgreSQL secret
kubectl create secret generic wrenai-postgresql -n wren \
  --from-literal=postgres-password='wrenai123'
```

### 4. Configure LLM Model Settings

Create a configuration file for the AI service:
```yaml
# config.yaml
type: llm
provider: litellm_llm
timeout: 120
models:
- model: gpt-4o-mini-2024-07-18
  api_base: https://api.openai.com/v1
  api_key_name: LLM_OPENAI_API_KEY
  kwargs:
    temperature: 0
    n: 1
    seed: 0
    max_tokens: 4096

---
type: embedder
provider: litellm_embedder
models:
- model: text-embedding-3-large
  api_base: https://api.openai.com/v1
  api_key_name: EMBEDDER_OPENAI_API_KEY
  timeout: 120
  dimension: 3072

# Additional configurations...
```

Apply the configuration:
```bash
kubectl create configmap wren-ai-service-config --from-file=config.yaml -n wren
```

### 5. Deploy Wren Components

```bash
# Apply Kubernetes manifests
kubectl apply -k deployment/kustomizations -n wren

# Verify deployments
kubectl get pods -n wren
```

### 6. Database Setup

```bash
# Initialize PostgreSQL database
kubectl exec -it -n wren wren-postgresql-0 -- env PGPASSWORD=wrenai123 psql -U postgres -c "CREATE USER wrenai WITH PASSWORD 'wrenai123';"
kubectl exec -it -n wren wren-postgresql-0 -- env PGPASSWORD=wrenai123 psql -U postgres -c "CREATE DATABASE wrenai OWNER wrenai;"
```

## Accessing Wren UI

### Option 1: Port Forwarding
```bash
kubectl port-forward -n wren svc/wren-ui-svc 3000:3000
```
Access the UI at: http://localhost:3000

### Option 2: LoadBalancer
```bash
kubectl patch service wren-ui-svc -n wren -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get service wren-ui-svc -n wren  # Get external IP
```
Access the UI at: http://EXTERNAL_IP:3000

## Component Architecture

```mermaid
graph LR
    subgraph Frontend
        UI[Wren UI
Port: 3000]
    end
    subgraph Backend
        AI[Wren AI Service
Port: 5555]
        Engine[Wren Engine
Port: 8080]
        Ibis[Ibis Server
Port: 8000]
    end
    subgraph Databases
        PG[(PostgreSQL
Port: 5432)]
        Qdrant[(Qdrant
Port: 6333)]
    end
    UI --> AI
    UI --> Engine
    Engine --> Ibis
    Engine --> PG
    AI --> Qdrant
```

## Troubleshooting

1. Check pod status:
```bash
kubectl get pods -n wren
kubectl describe pod POD_NAME -n wren
kubectl logs POD_NAME -n wren
```

2. Common issues:
- CreateContainerConfigError: Check secrets and configmaps
- CrashLoopBackOff: Check logs for application errors
- Pending: Check cluster resources

## Infrastructure Components

- VPC: genai-vpc
- Subnet: gke-subnet (10.0.0.0/20)
- GKE Autopilot Cluster: genai-autopilot-cluster (Private cluster with public endpoint)
- Master CIDR: 172.19.0.0/28
- Pods CIDR: 172.18.0.0/16
- Services CIDR: 172.17.0.0/20
- Kubernetes Services:
  - Wren UI
  - Wren AI Service
  - Wren Engine
  - Ibis Server
  - PostgreSQL
  - Qdrant Vector Database
