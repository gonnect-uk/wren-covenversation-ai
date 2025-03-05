# LobeChat: Your Universal AI Assistant

> 🚀 Enterprise-grade AI chat platform with unmatched model flexibility and cost control

## Why LobeChat?

In the world of AI assistants, flexibility and cost-effectiveness are key. LobeChat stands out by offering:

```mermaid
graph TD
    A[Your Choice] --> B[Premium Models]
    A --> C[Open Source Models]
    A --> D[Custom Models]
    
    B --> E[OpenAI]
    B --> F[Anthropic]
    B --> G[Azure]
    
    C --> H[Llama 2]
    C --> I[Mistral]
    
    D --> J[Fine-tuned]
    D --> K[Domain Specific]
    
    style A fill:#f9f,stroke:#333,stroke-width:4px
```

### 💡 Key Benefits

1. **Cost Optimization**
   - Choose models based on task complexity
   - Use open-source models for routine work
   - Premium models only when needed
   - Up to 90% cost reduction vs ChatGPT Plus

2. **Model Flexibility**
   - OpenAI (GPT-4, GPT-3.5)
   - Anthropic (Claude)
   - Open Source (Llama, Mistral)
   - Custom Models

3. **Enterprise Features**
   - Secure authentication
   - Persistent chat history
   - File sharing & management
   - Team collaboration

4. **Developer Friendly**
   - Code completion
   - API documentation
   - Architecture discussions
   - Debug assistance
## Quick Start

```bash
# 1. Create namespace
kubectl create namespace lobechat

# 2. Copy OpenAI API key
kubectl get secret openai-api-key -n wren -o yaml | sed 's/namespace: wren/namespace: lobechat/' | kubectl apply -f -

# 3. Deploy LobeChat
kubectl apply -f k8s/lobechat/

# 4. Access via port forward
kubectl port-forward -n lobechat svc/lobechat 3210:80

# 5. Open in browser
# http://localhost:3210
# Access Code: wren2024
```

## Architecture

```mermaid
graph TD
    A[External Traffic] --> B[LoadBalancer Service]
    B --> C[LobeChat Pod]
    C --> D[PostgreSQL Pod]
    C --> E[OpenAI API]
    
    subgraph GKE Cluster
        subgraph lobechat namespace
            B
            C
            D
            F[PVC - PostgreSQL Data]
            G[ConfigMap - Agent Config]
            H[Secret - OpenAI API Key]
            D --> F
            C --> G
            C --> H
        end
    end
```
## Cost Comparison

| Model | Cost (Input) | Cost (Output) | Best For |
|-------|-------------|---------------|----------|
| GPT-4 | $30 | $60 | Complex reasoning |
| GPT-3.5 | $0.50 | $1.50 | General tasks |
| Claude | $11.02 | $32.68 | Long content |
| Llama 2 | Free* | Free* | High volume tasks |
| Mistral | Free* | Free* | Efficient tasks |

*Requires compute resources for hosting

## Model Configuration

### Using Different AI Providers

1. **OpenAI Configuration**
```yaml
env:
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: openai-api-key
      key: LLM_OPENAI_API_KEY
- name: OPENAI_API_ENDPOINT
  value: "https://api.openai.com/v1"
```

2. **Azure OpenAI Configuration**
```yaml
env:
- name: AZURE_API_KEY
  valueFrom:
    secretKeyRef:
      name: azure-api-key
      key: key
- name: AZURE_API_ENDPOINT
  value: "https://your-resource.openai.azure.com"
```

3. **Anthropic Configuration**
```yaml
env:
- name: ANTHROPIC_API_KEY
  valueFrom:
    secretKeyRef:
      name: anthropic-api-key
      key: key
```

4. **Local Model Configuration**
```yaml
env:
- name: LOCAL_MODEL_ENDPOINT
  value: "http://your-model-service:8080"
- name: LOCAL_MODEL_TYPE
  value: "llama2" # or mistral, custom
```
## Use Cases

### 1. Development Teams
- Code review and explanation
- API documentation generation
- Debugging assistance
- Architecture discussions

### 2. Business Analysis
- Data interpretation
- Report generation
- Market research
- Document summarization

### 3. Content Creation
- Marketing copy
- Documentation
- Image generation
- Content editing

### 4. Customer Support
- Query analysis
- Response drafting
- Knowledge base creation
- Training material generation
## Configuration Files

### 1. PostgreSQL (`postgres.yaml`)
```yaml
# Secret for database credentials
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: lobechat
type: Opaque
stringData:
  POSTGRES_USER: lobechat
  POSTGRES_PASSWORD: lobechat123
  POSTGRES_DB: lobechat

---
# PVC for persistent storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: lobechat
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard-rwo

---
# PostgreSQL Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: lobechat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_PASSWORD
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_DB
        - name: PGDATA
          value: "/var/lib/postgresql/data/pgdata"
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
          subPath: postgres
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc

---
# PostgreSQL Service
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: lobechat
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

### 2. LobeChat Agent Config (`agent-config.yaml`)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-config
  namespace: lobechat
data:
  agent.json: |
    {
      "enableFileUpload": true,
      "enableTextFileUpload": true,
      "enableImageUpload": true,
      "maxFileSize": 10485760,
      "allowedFileTypes": ["txt", "md", "json", "pdf", "png", "jpg", "jpeg"],
      "database": {
        "type": "postgres",
        "url": "postgresql://lobechat:lobechat123@postgres:5432/lobechat"
      }
    }
```

### 3. LobeChat Deployment (`deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lobechat
  namespace: lobechat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lobechat
  template:
    metadata:
      labels:
        app: lobechat
    spec:
      containers:
      - name: lobechat
        image: lobehub/lobe-chat:latest
        ports:
        - name: http
          containerPort: 3210
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: openai-api-key
              key: LLM_OPENAI_API_KEY
        - name: OPENAI_API_ENDPOINT
          value: "https://api.openai.com/v1"
        - name: ACCESS_CODE
          value: "wren2024"
        - name: DATABASE_URL
          value: "postgresql://lobechat:lobechat123@postgres:5432/lobechat"
        - name: DEPLOYMENT_MODE
          value: "server"
        - name: DEFAULT_AGENT_CONFIG_FILE
          value: "/app/config/agent.json"
        - name: NEXTAUTH_URL
          value: "http://localhost:3210"
        - name: NEXTAUTH_SECRET
          value: "your-nextauth-secret-key"
        volumeMounts:
        - name: agent-config
          mountPath: /app/config
      volumes:
      - name: agent-config
        configMap:
          name: agent-config
```

### 4. LobeChat Service (`service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: lobechat
  namespace: lobechat
spec:
  type: LoadBalancer
  selector:
    app: lobechat
  ports:
  - name: http
    port: 80
    targetPort: 3210
```

## Troubleshooting

### Common Issues

1. **PostgreSQL fails to start**
   - Ensure PVC is created with correct access mode
   - Check PGDATA environment variable is set
   - Verify storage class exists

2. **File uploads not working**
   - Confirm deployment mode is set to "server"
   - Check PostgreSQL connection
   - Verify agent config is mounted correctly

3. **Cannot access LobeChat**
   - Check LoadBalancer service status
   - Verify port forwarding is active
   - Ensure access code is correct

### Useful Commands

```bash
# Check pod status
kubectl get pods -n lobechat

# View LobeChat logs
kubectl logs -n lobechat deployment/lobechat

# View PostgreSQL logs
kubectl logs -n lobechat deployment/postgres

# Check service status
kubectl get svc -n lobechat

# Port forward for local access
kubectl port-forward -n lobechat svc/lobechat 3210:80
```

## Cleanup

### Before You Begin
- Save any important chat history or files
- Document any custom configurations
- Notify team members if it's a shared instance

### Step-by-Step Cleanup

1. **Stop Active Sessions**
```bash
# List and kill any port-forwarding sessions
pkill -f "kubectl port-forward.*lobechat"
```

2. **Delete Kubernetes Resources**
```bash
# Delete all LobeChat resources
kubectl delete -f k8s/lobechat/

# Verify resources are being deleted
kubectl get all -n lobechat
```

3. **Delete Persistent Data**
```bash
# Delete PVC (this will delete all persistent data)
kubectl delete pvc -n lobechat --all

# Verify PVC deletion
kubectl get pvc -n lobechat
```

4. **Delete Namespace**
```bash
# This will delete everything in the namespace
kubectl delete namespace lobechat

# Verify namespace is gone
kubectl get namespace lobechat
```

5. **Delete Secrets**
```bash
# Delete OpenAI API key
kubectl delete secret openai-api-key -n wren
```

### Quick Cleanup (All-in-One)
```bash
# Delete everything in one command
kubectl delete namespace lobechat && kubectl delete secret openai-api-key -n wren
```

> ⚠️ **Warning**
> - This will permanently delete all data
> - Persistent volumes will be deleted
> - All configurations will be lost
> - Make sure to backup any important information
   - Llama 2 (Meta)
   - Mistral
   - Custom model deployments

3. **Specialized Models**
   - DALL-E (image generation)
   - Stable Diffusion (local image generation)
   - Custom fine-tuned models

### Use Cases
1. **Development Teams**
   - Code review and explanation
   - API documentation generation
   - Debugging assistance
   - Architecture discussions

2. **Business Analysis**
   - Data interpretation
   - Report generation
   - Market research
   - Document summarization

3. **Content Creation**
   - Marketing copy
   - Documentation
   - Image generation
   - Content editing

4. **Customer Support**
   - Query analysis
   - Response drafting
   - Knowledge base creation
   - Training material generation

## Architecture

```mermaid
graph TD
    A[External Traffic] --> B[LoadBalancer Service]
    B --> C[LobeChat Pod]
    C --> D[PostgreSQL Pod]
    C --> E[OpenAI API]
    
    subgraph GKE Cluster
        subgraph lobechat namespace
            B
            C
            D
            F[PVC - PostgreSQL Data]
            G[ConfigMap - Agent Config]
            H[Secret - OpenAI API Key]
            D --> F
            C --> G
            C --> H
        end
    end
```

## Components

### 1. PostgreSQL Database
- Handles persistent storage for:
  - Chat history
  - File uploads
  - User preferences
- Uses PersistentVolumeClaim for data persistence
- Configured with secure credentials via Kubernetes Secret

### 2. LobeChat Server
- Runs in server mode for full functionality
- Connects to PostgreSQL for data persistence
- Configured via ConfigMap for agent settings
- Uses OpenAI API key from Kubernetes Secret

### 3. LoadBalancer Service
- Exposes LobeChat to external traffic
- Maps port 80 to container port 3210

## Quick Start

1. Create namespace:
```bash
kubectl create namespace lobechat
```

2. Copy OpenAI API key from existing secret:
```bash
kubectl get secret openai-api-key -n wren -o yaml | sed 's/namespace: wren/namespace: lobechat/' | kubectl apply -f -
```

3. Apply Kubernetes configurations:
```bash
kubectl apply -f k8s/lobechat/
```

4. Access via port forwarding:
```bash
kubectl port-forward -n lobechat svc/lobechat 3210:80
```

5. Open in browser: http://localhost:3210
   - Use access code: wren2024

## Model Configuration

### Using Different AI Providers

1. **OpenAI Configuration**
```yaml
env:
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: openai-api-key
      key: LLM_OPENAI_API_KEY
- name: OPENAI_API_ENDPOINT
  value: "https://api.openai.com/v1"
```

2. **Azure OpenAI Configuration**
```yaml
env:
- name: AZURE_API_KEY
  valueFrom:
    secretKeyRef:
      name: azure-api-key
      key: key
- name: AZURE_API_ENDPOINT
  value: "https://your-resource.openai.azure.com"
```

3. **Anthropic Configuration**
```yaml
env:
- name: ANTHROPIC_API_KEY
  valueFrom:
    secretKeyRef:
      name: anthropic-api-key
      key: key
```

4. **Local Model Configuration**
```yaml
env:
- name: LOCAL_MODEL_ENDPOINT
  value: "http://your-model-service:8080"
- name: LOCAL_MODEL_TYPE
  value: "llama2" # or mistral, custom
```

### Cost Optimization Tips
1. Use tiered approach:
   - GPT-3.5 for general queries (cheaper)
   - GPT-4 for complex tasks (premium)
   - Local models for repetitive tasks

2. Implement token quotas per user/team

3. Monitor usage patterns and adjust model selection

## Configuration Files

### 1. PostgreSQL (`postgres.yaml`)
```yaml
# Secret for database credentials
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: lobechat
type: Opaque
stringData:
  POSTGRES_USER: lobechat
  POSTGRES_PASSWORD: lobechat123
  POSTGRES_DB: lobechat

---
# PVC for persistent storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: lobechat
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard-rwo

---
# PostgreSQL Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: lobechat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_PASSWORD
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_DB
        - name: PGDATA
          value: "/var/lib/postgresql/data/pgdata"
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
          subPath: postgres
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc

---
# PostgreSQL Service
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: lobechat
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

### 2. LobeChat Agent Config (`agent-config.yaml`)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-config
  namespace: lobechat
data:
  agent.json: |
    {
      "enableFileUpload": true,
      "enableTextFileUpload": true,
      "enableImageUpload": true,
      "maxFileSize": 10485760,
      "allowedFileTypes": ["txt", "md", "json", "pdf", "png", "jpg", "jpeg"],
      "database": {
        "type": "postgres",
        "url": "postgresql://lobechat:lobechat123@postgres:5432/lobechat"
      }
    }
```

### 3. LobeChat Deployment (`deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lobechat
  namespace: lobechat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lobechat
  template:
    metadata:
      labels:
        app: lobechat
    spec:
      containers:
      - name: lobechat
        image: lobehub/lobe-chat:latest
        ports:
        - name: http
          containerPort: 3210
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: openai-api-key
              key: LLM_OPENAI_API_KEY
        - name: OPENAI_API_ENDPOINT
          value: "https://api.openai.com/v1"
        - name: ACCESS_CODE
          value: "wren2024"
        - name: DATABASE_URL
          value: "postgresql://lobechat:lobechat123@postgres:5432/lobechat"
        - name: DEPLOYMENT_MODE
          value: "server"
        - name: DEFAULT_AGENT_CONFIG_FILE
          value: "/app/config/agent.json"
        - name: NEXTAUTH_URL
          value: "http://localhost:3210"
        - name: NEXTAUTH_SECRET
          value: "your-nextauth-secret-key"
        volumeMounts:
        - name: agent-config
          mountPath: /app/config
      volumes:
      - name: agent-config
        configMap:
          name: agent-config
```

### 4. LobeChat Service (`service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: lobechat
  namespace: lobechat
spec:
  type: LoadBalancer
  selector:
    app: lobechat
  ports:
  - name: http
    port: 80
    targetPort: 3210
```

## Features
- **File Upload Support**: Upload and share various file types including text, PDFs, and images
- **Persistent Storage**: Chat history and files are stored in PostgreSQL
- **Secure Access**: Protected by access code
- **OpenAI Integration**: Direct connection to OpenAI API for AI capabilities

## Troubleshooting

1. Check pod status:
```bash
kubectl get pods -n lobechat
```

2. View LobeChat logs:
```bash
kubectl logs -n lobechat deployment/lobechat
```

3. View PostgreSQL logs:
```bash
kubectl logs -n lobechat deployment/postgres
```

4. Check service status:
```bash
kubectl get svc -n lobechat
```

## Common Issues

1. **PostgreSQL fails to start**
   - Ensure PVC is created with correct access mode
   - Check PGDATA environment variable is set
   - Verify storage class exists

2. **File uploads not working**
   - Confirm deployment mode is set to "server"
   - Check PostgreSQL connection
   - Verify agent config is mounted correctly

3. **Cannot access LobeChat**
   - Check LoadBalancer service status
   - Verify port forwarding is active
   - Ensure access code is correct
