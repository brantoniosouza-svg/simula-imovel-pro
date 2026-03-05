# SimulaImóvel Pro - Documentação CI/CD

## Visão Geral

O projeto SimulaImóvel Pro utiliza **GitHub Actions** para automação completa de Integração Contínua (CI) e Entrega Contínua (CD). O pipeline garante que todo código enviado ao repositório seja validado, testado e, quando aprovado, implantado automaticamente nos ambientes de staging e produção.

## Arquitetura do Pipeline

O fluxo de CI/CD é composto por dois workflows principais que se complementam para garantir a qualidade e a entrega automatizada do software.

```
Push/PR ──► CI Pipeline ──► Lint ──► Testes ──► Build ──► Docker Build
                                                              │
Merge main ──► CD Pipeline ──► Build GHCR ──► Staging (auto) ──► Produção (manual)
```

## Workflow de CI (Integração Contínua)

O workflow de CI é acionado automaticamente em todo push e pull request nas branches `main`, `develop` e `feature/**`. Ele executa os seguintes jobs em sequência para backend e frontend.

| Job | Descrição | Dependência |
|-----|-----------|-------------|
| **backend-lint** | ESLint e Prettier no código do backend | Nenhuma |
| **backend-test** | Testes unitários com Jest e relatório de cobertura | backend-lint |
| **backend-build** | Compilação TypeScript para produção | backend-test |
| **frontend-lint** | ESLint e Prettier no código do frontend | Nenhuma |
| **frontend-test** | Testes com Vitest e relatório de cobertura | frontend-lint |
| **frontend-build** | Build de produção com Vite | frontend-test |
| **security-audit** | Auditoria de vulnerabilidades nas dependências | Nenhuma |
| **docker-build** | Build da imagem Docker do backend (sem push) | backend-build, frontend-build |
| **ci-summary** | Resumo consolidado de todos os jobs | Todos |

## Workflow de CD (Entrega Contínua)

O workflow de CD é acionado automaticamente após merge na branch `main` ou criação de tags `v*.*.*`. Também pode ser disparado manualmente via `workflow_dispatch`.

| Job | Descrição | Dependência |
|-----|-----------|-------------|
| **build-backend** | Build e push da imagem Docker do backend para GHCR | Nenhuma |
| **build-frontend** | Build e push da imagem Docker do frontend para GHCR | Nenhuma |
| **deploy-staging** | Deploy automático no ambiente de staging | build-backend, build-frontend |
| **deploy-production** | Deploy no ambiente de produção (requer aprovação) | deploy-staging |
| **notify** | Notificação com resumo do deploy | deploy-staging, deploy-production |

## Ambientes

O projeto utiliza dois ambientes configurados no GitHub, cada um com suas próprias variáveis e regras de proteção.

### Staging

O ambiente de staging recebe deploys automáticos após cada merge na branch `main`. Ele serve como ambiente de validação antes da promoção para produção.

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `STAGING_HOST` | IP ou hostname do servidor | `staging.simulaimovel.com` |
| `STAGING_USER` | Usuário SSH | `deploy` |
| `STAGING_PORT` | Porta SSH | `22` |
| `STAGING_PATH` | Caminho do projeto no servidor | `/opt/simula-imovel-pro` |
| `STAGING_URL` | URL pública | `http://staging.simulaimovel.com` |

### Produção

O ambiente de produção requer aprovação manual de um revisor antes do deploy. Inclui backup automático do banco de dados e rollback em caso de falha no health check.

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `PRODUCTION_HOST` | IP ou hostname do servidor | `simulaimovel.com` |
| `PRODUCTION_USER` | Usuário SSH | `deploy` |
| `PRODUCTION_PORT` | Porta SSH | `22` |
| `PRODUCTION_PATH` | Caminho do projeto no servidor | `/opt/simula-imovel-pro` |
| `PRODUCTION_URL` | URL pública | `http://simulaimovel.com` |

### Secrets Necessários

Os seguintes secrets devem ser configurados em **Settings > Secrets and variables > Actions** no repositório GitHub.

| Secret | Ambiente | Descrição |
|--------|----------|-----------|
| `STAGING_SSH_KEY` | Staging | Chave SSH privada para acesso ao servidor de staging |
| `PRODUCTION_SSH_KEY` | Production | Chave SSH privada para acesso ao servidor de produção |

## Scripts Auxiliares

O diretório `scripts/` contém ferramentas para operações manuais e manutenção do pipeline.

### deploy.sh

Script de deploy manual que pode ser executado diretamente no servidor. Inclui backup automático, health check e rollback em caso de falha.

```bash
# Deploy em staging
./scripts/deploy.sh staging

# Deploy em produção
./scripts/deploy.sh production
```

### health-check.sh

Verifica a saúde de todos os serviços da aplicação, incluindo backend, frontend, PostgreSQL, Redis e MongoDB.

```bash
./scripts/health-check.sh
```

### setup-cicd.sh

Guia interativo para configuração inicial dos ambientes de CI/CD no GitHub.

```bash
./scripts/setup-cicd.sh
```

## Docker Compose

O projeto inclui dois arquivos Docker Compose para diferentes cenários de uso.

| Arquivo | Uso | Descrição |
|---------|-----|-----------|
| `docker-compose.yml` | Desenvolvimento e Staging | Configuração padrão com build local |
| `docker-compose.prod.yml` | Produção | Utiliza imagens do GHCR com limites de recursos |

## Fluxo de Trabalho Recomendado

O fluxo de trabalho recomendado para o desenvolvimento segue o modelo de branching simplificado, onde cada funcionalidade é desenvolvida em uma branch separada e integrada via pull request.

1. Criar uma branch a partir de `main` com o prefixo `feature/`
2. Desenvolver a funcionalidade e fazer commits regulares
3. Abrir um Pull Request para a branch `main`
4. O pipeline de CI executa automaticamente lint, testes e build
5. Após aprovação do PR e merge, o pipeline de CD inicia o deploy em staging
6. Validar o funcionamento em staging
7. Aprovar o deploy em produção no GitHub Actions

## Troubleshooting

### O pipeline de CI falhou no lint

Verifique se o código segue as regras do ESLint e Prettier. Execute localmente para identificar os problemas antes de fazer push.

```bash
cd backend && npm run lint && npm run format
cd frontend && npm run lint && npm run format
```

### O deploy falhou no health check

Verifique os logs do container do backend para identificar o problema. O script de deploy executa rollback automático quando o health check falha.

```bash
docker compose logs backend --tail 50
```

### As imagens Docker não foram publicadas no GHCR

Verifique se o token `GITHUB_TOKEN` tem permissão de escrita em packages. Isso é configurado automaticamente no workflow via `permissions: packages: write`.
