#!/bin/bash

# Script para deploy da aplicação no Kubernetes
set -e

echo "🚀 Iniciando deploy da aplicação sample-k8s-app no Kubernetes..."

# Verificar se kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl não encontrado. Instale kubectl primeiro."
    exit 1
fi

# Verificar se o cluster está acessível
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Não foi possível conectar ao cluster Kubernetes."
    echo "Verifique se o cluster está rodando e o kubectl está configurado."
    exit 1
fi

echo "✅ Conectado ao cluster Kubernetes"

# Construir imagem Docker da API
echo "🔨 Construindo imagem Docker da API..."
docker build -t sample-k8s-api:latest ./api

# Detectar o tipo de cluster e carregar a imagem
if kubectl config current-context | grep -q "minikube"; then
    echo "📦 Carregando imagem no Minikube..."
    minikube image load sample-k8s-api:latest
elif kubectl config current-context | grep -q "kind"; then
    echo "📦 Carregando imagem no Kind..."
    kind load docker-image sample-k8s-api:latest
else
    echo "⚠️  Cluster detectado: $(kubectl config current-context)"
    echo "   Certifique-se de que a imagem sample-k8s-api:latest está disponível no cluster"
fi

# Aplicar manifestos Kubernetes
echo "📋 Aplicando manifestos Kubernetes..."

NAMESPACE="sample-k8s-app"
echo "  • Namespace: $NAMESPACE"

# Criar o namespace se não existir
kubectl get namespace "$NAMESPACE" &> /dev/null || kubectl create namespace "$NAMESPACE"

echo "  • ConfigMaps..."
kubectl apply -n "$NAMESPACE" -f k8s/nginx-configmap.yaml
kubectl apply -n "$NAMESPACE" -f k8s/frontend-configmap.yaml

echo "  • Deployments..."
kubectl apply -n "$NAMESPACE" -f k8s/api-deployment.yaml
kubectl apply -n "$NAMESPACE" -f k8s/frontend-deployment.yaml

echo "  • Services..."
kubectl apply -n "$NAMESPACE" -f k8s/api-service.yaml
kubectl apply -n "$NAMESPACE" -f k8s/frontend-service.yaml

# Aguardar os deployments ficarem prontos
echo "⏳ Aguardando deployments ficarem prontos..."
kubectl rollout status -n "$NAMESPACE" deployment/api-deployment
kubectl rollout status -n "$NAMESPACE" deployment/frontend-deployment

echo "✅ Deploy concluído com sucesso!"

# Mostrar status
echo ""
echo "📊 Status da aplicação:"
kubectl get pods,services -n "$NAMESPACE" -l 'app in (sample-k8s-api,sample-k8s-frontend)'

echo ""
echo "🌐 Para acessar a aplicação:"
echo "   Frontend: kubectl -n $NAMESPACE port-forward service/frontend-service 8080:80"
echo "   API:      kubectl -n $NAMESPACE port-forward service/api-service 3000:3000"
echo ""
echo "📖 Para mais informações, veja k8s/README.md"
