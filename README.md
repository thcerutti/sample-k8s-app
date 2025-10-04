# Sample Kubernetes App

Uma aplicação simples com API em Node.js e frontend estático para demonstração de conceitos de containerização.

## Estrutura do Projeto

```
sample-k8s-app/
├── api/                 # Backend API em Node.js/Express
│   ├── Dockerfile      # Dockerfile para a API
│   ├── index.js        # Código principal da API
│   └── package.json    # Dependências da API
├── frontend/           # Frontend estático
│   ├── index.html      # Página principal
│   └── requests.js     # Scripts de requisições
└── docker-compose.yml  # Orquestração dos containers
```

## Como Executar com Docker Compose

### Pré-requisitos
- Docker
- Docker Compose

### Executar a aplicação

1. **Construir e iniciar os serviços:**
   ```bash
   docker-compose up --build
   ```

2. **Executar em background:**
   ```bash
   docker-compose up -d --build
   ```

3. **Parar os serviços:**
   ```bash
   docker-compose down
   ```

### Acessar a aplicação

- **API:** http://localhost:3000
  - Rota raiz: `GET /` retorna `{"message": "hello from api"}`

- **Frontend:** http://localhost:8080
  - Interface web estática

### Serviços

#### API Service
- **Container:** `sample-k8s-api`
- **Porta:** 3000
- **Base Image:** node:20-alpine
- **Build Context:** `./api`

#### Frontend Service
- **Container:** `sample-k8s-frontend`
- **Porta:** 8080 (mapeada para 80 interno)
- **Base Image:** nginx:alpine
- **Volumes:** `./frontend` montado em `/usr/share/nginx/html`

### Comandos Úteis

```bash
# Ver logs dos serviços
docker-compose logs

# Ver logs de um serviço específico
docker-compose logs api
docker-compose logs frontend

# Reconstruir apenas um serviço
docker-compose build api

# Executar comandos dentro de um container
docker-compose exec api sh
```

## Desenvolvimento

Para desenvolvimento local sem Docker, você pode executar a API diretamente:

```bash
cd api
npm install
npm start
```

A API estará disponível em http://localhost:3000

## Imagem Pública da API (CI/CD)

Uma imagem pública da API é construída automaticamente em cada commit na branch `main` via CircleCI.

Repositório Docker Hub:

```
docker pull thcerutti/sample-k8s-app-api:latest
```

Também é publicada uma tag com o SHA curto do commit (ex: `thcerutti/sample-k8s-app-api:abc1234`). Use essa tag para implantações imutáveis em produção.

Exemplo para rodar local só a API usando a imagem pública:

```bash
docker run --rm -p 3000:3000 thcerutti/sample-k8s-app-api:latest
```

## Deploy no Kubernetes (resumo)

### Deploy simplificado com Helm

Agora você pode instalar toda a aplicação com Helm:

```bash
helm install sample-k8s-app ./charts/sample-k8s-app -n sample-k8s-app --create-namespace
```

Para atualizar a imagem da API para uma tag específica:

```bash
helm upgrade sample-k8s-app ./charts/sample-k8s-app -n sample-k8s-app \
   --set api.tag=abc1234
```

Para ativar o Ingress e customizar o host:

```bash
helm upgrade sample-k8s-app ./charts/sample-k8s-app -n sample-k8s-app \
   --set ingress.enabled=true --set ingress.host=meusite.local
```

Para remover tudo:

```bash
helm uninstall sample-k8s-app -n sample-k8s-app
```

Consulte `charts/sample-k8s-app/values.yaml` para todos os parâmetros disponíveis.

### Como acessar localmente via port-forward

Após instalar o Helm chart, execute os comandos abaixo para expor as portas dos serviços no seu ambiente local:

```bash
# Frontend
kubectl -n sample-k8s-app port-forward service/frontend-service 8080:80

# API
kubectl -n sample-k8s-app port-forward service/api-service 3000:3000
```

Acesse:
- Frontend: http://localhost:8080
- API: http://localhost:3000

## Próximas Melhorias (sugestões)

- Substituir `latest` por tags de commit automaticamente no pipeline.
- Adicionar scan de vulnerabilidades (Trivy) antes do push.
- Publicar SBOM (Syft) e digest no summary do build.
- Adicionar Healthcheck no Dockerfile para melhor observabilidade.
