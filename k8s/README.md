# Deploy no Kubernetes

Este diretório contém os manifestos Kubernetes para fazer deploy da aplicação sample-k8s-app.

## Estrutura dos Arquivos

- `api-deployment.yaml` - Deployment da API Node.js/Express
- `api-service.yaml` - Service para expor a API internamente
- `frontend-deployment.yaml` - Deployment do frontend com nginx
- `frontend-service.yaml` - Service para expor o frontend
- `nginx-configmap.yaml` - Configuração do nginx (proxy para API)
- `frontend-configmap.yaml` - Arquivos estáticos do frontend
- `ingress.yaml` - Ingress para acesso externo (opcional)

## Pré-requisitos

1. **Cluster Kubernetes** funcionando (pode ser local com minikube, kind, k3s, etc.)
2. **kubectl** configurado para acessar o cluster
3. **Imagem Docker da API** construída e disponível no cluster

## Preparação

### 1. Construir a imagem Docker da API

```bash
# Na raiz do projeto
docker build -t sample-k8s-api:latest ./api
```

### 2. Carregar a imagem no cluster (se estiver usando minikube/kind)

**Para minikube:**
```bash
minikube image load sample-k8s-api:latest
```

**Para kind:**
```bash
kind load docker-image sample-k8s-api:latest
```

## Deploy da Aplicação

### Opção 1: Deploy manual (passo a passo)

```bash
# 1. Aplicar ConfigMaps
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/frontend-configmap.yaml

# 2. Aplicar Deployments
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# 3. Aplicar Services
kubectl apply -f k8s/api-service.yaml
kubectl apply -f k8s/frontend-service.yaml

# 4. (Opcional) Aplicar Ingress
kubectl apply -f k8s/ingress.yaml
```

### Opção 2: Deploy tudo de uma vez

```bash
kubectl apply -f k8s/
```

## Verificação do Deploy

```bash
# Verificar se os pods estão rodando
kubectl get pods

# Verificar os services
kubectl get services

# Verificar os deployments
kubectl get deployments

# Ver logs da API
kubectl logs -l app=sample-k8s-api

# Ver logs do frontend
kubectl logs -l app=sample-k8s-frontend
```

## Acesso à Aplicação

### Sem Ingress (usando port-forward)

```bash
# Acessar o frontend
kubectl port-forward service/frontend-service 8080:80

# Em outro terminal, acessar a API diretamente
kubectl port-forward service/api-service 3000:3000
```

Depois acesse:
- Frontend: http://localhost:8080
- API: http://localhost:3000

### Com Ingress (se habilitado)

1. **Instalar nginx-ingress-controller** (se não estiver instalado):

```bash
# Para minikube
minikube addons enable ingress

# Para outros clusters
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

2. **Configurar DNS local** (adicionar no `/etc/hosts`):

```bash
# Descobrir o IP do ingress
kubectl get ingress

# Adicionar ao /etc/hosts
echo "$(kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}') sample-k8s-app.local" | sudo tee -a /etc/hosts
```

3. **Acessar a aplicação**:
   - http://sample-k8s-app.local

## Limpeza

Para remover toda a aplicação:

```bash
kubectl delete -f k8s/
```

## Troubleshooting

### Pods não iniciam

```bash
# Ver eventos do cluster
kubectl get events

# Descrever um pod específico
kubectl describe pod <nome-do-pod>
```

### Problemas de rede

```bash
# Testar conectividade entre serviços
kubectl exec -it <pod-frontend> -- wget -qO- http://api-service:3000

# Verificar configuração do nginx
kubectl exec -it <pod-frontend> -- cat /etc/nginx/conf.d/default.conf
```

### Imagem não encontrada

Certifique-se de que a imagem foi carregada no cluster:

```bash
# Para minikube
minikube image ls | grep sample-k8s-api

# Para kind
docker exec -it <kind-node> crictl images | grep sample-k8s-api
```

## Monitoramento

```bash
# Acompanhar logs em tempo real
kubectl logs -f -l app=sample-k8s-api
kubectl logs -f -l app=sample-k8s-frontend

# Status dos recursos
kubectl top pods
kubectl top nodes
```
