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
