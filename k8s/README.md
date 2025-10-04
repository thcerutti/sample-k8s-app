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
3. **Imagem Docker da API** disponível no Docker Hub: `thcerutti/sample-k8s-app-api`

## Preparação

docker build -t sample-k8s-api:latest ./api
### 1. (Agora) Usar imagem pública

Não é mais necessário construir localmente para deploy padrão. A imagem é publicada pelo pipeline CI em cada commit da `main`.

```
docker pull thcerutti/sample-k8s-app-api:latest
```

Tags imutáveis de commit também estão disponíveis (ex: `thcerutti/sample-k8s-app-api:<GIT_SHA>`). Prefira usá-las para ambientes de staging/produção.

## Deploy da Aplicação

### Opção 1: Deploy manual (passo a passo)

```bash
# 1. Aplicar ConfigMaps
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/frontend-configmap.yaml

# 2. Aplicar Deployments (API usa imagem pública)
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

Verifique conectividade com Docker Hub ou se a tag existe:

```bash
docker pull thcerutti/sample-k8s-app-api:latest
docker pull thcerutti/sample-k8s-app-api:<TAG>
```

Se quiser testar rapidamente uma tag específica, edite `api-deployment.yaml` alterando:

```yaml
image: thcerutti/sample-k8s-app-api:<TAG>
```
e aplique novamente:

```bash
kubectl apply -f k8s/api-deployment.yaml
kubectl rollout status deployment/api-deployment
```

Para automação de substituição de tag (Helm ou Kustomize) é recomendado padronizar via pipeline (ver sugestões no README raiz).

## Monitoramento

```bash
# Acompanhar logs em tempo real
kubectl logs -f -l app=sample-k8s-api
kubectl logs -f -l app=sample-k8s-frontend

# Status dos recursos
kubectl top pods
kubectl top nodes
```
