# SimulaImóvel Pro

[![CI - Integração Contínua](https://github.com/brantoniosouza-svg/simula-imovel-pro/actions/workflows/ci.yml/badge.svg)](https://github.com/brantoniosouza-svg/simula-imovel-pro/actions/workflows/ci.yml)
[![CD - Entrega Contínua](https://github.com/brantoniosouza-svg/simula-imovel-pro/actions/workflows/cd.yml/badge.svg)](https://github.com/brantoniosouza-svg/simula-imovel-pro/actions/workflows/cd.yml)

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

## CI/CD

O projeto utiliza GitHub Actions para automação completa de integração e entrega contínua.

| Pipeline | Trigger | Descrição |
|----------|---------|-----------|
| **CI** | Push / Pull Request | Lint, testes, build e auditoria de segurança |
| **CD** | Merge na main / Tags | Build Docker, deploy staging e produção |

Para mais detalhes, consulte a [documentação de CI/CD](docs/CICD.md).

### Scripts Auxiliares

```bash
# Deploy manual
./scripts/deploy.sh staging
./scripts/deploy.sh production

# Health check dos serviços
./scripts/health-check.sh

# Configuração inicial do CI/CD
./scripts/setup-cicd.sh
```

## Documentação

- [CI/CD Pipeline](docs/CICD.md)
- [Arquitetura](docs/architecture.md)
- [API Reference](docs/api-reference.md)

## Suporte

Email: br.antoniosouza@gmail.com
