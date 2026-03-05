# SimulaImóvel Pro

Plataforma de simulação tributária e financeira para operações imobiliárias.

## Quick Start

### Pré-requisitos

- Node.js 20+
- Docker e Docker Compose
- Git

### Instalação

```bash
# Clonar repositório
git clone https://github.com/brantoniosouza-svg/simula-imovel-pro.git
cd simula-imovel-pro

# Copiar variáveis de ambiente
cp .env.example .env

# Iniciar stack com Docker
docker-compose up -d

# Aguardar inicialização (2-3 minutos)
docker-compose logs -f backend

# Acessar aplicação
# Frontend: http://localhost:3001
# Backend: http://localhost:3000
```

## Documentação

- [Arquitetura](docs/architecture.md)
- [API Reference](docs/api-reference.md)

## Suporte

Email: br.antoniosouza@gmail.com
