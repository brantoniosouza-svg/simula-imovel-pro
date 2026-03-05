# Guia de Execução - SimulaImóvel Pro

Este documento descreve como configurar e executar o sistema SimulaImóvel Pro em diferentes ambientes.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:
- **Docker** e **Docker Compose** (Recomendado)
- **Node.js 20+** e **npm** (Para execução local sem Docker)
- **Git**

---

## 🚀 Opção 1: Execução com Docker (Recomendado)

Esta é a forma mais rápida e segura de rodar o sistema completo, incluindo os bancos de dados.

### 1. Preparar o Ambiente
```bash
# Entrar na pasta do projeto
cd simula-imovel-pro

# Criar o arquivo de variáveis de ambiente
cp .env.example .env
```
> **Nota:** Edite o arquivo `.env` se precisar alterar senhas ou chaves de API.

### 2. Iniciar os Serviços
```bash
# Iniciar bancos de dados (Postgres, Redis, MongoDB)
docker-compose up -d
```

### 3. Executar Backend e Frontend
Você pode rodar o backend e frontend localmente enquanto os bancos rodam no Docker:

**Backend:**
```bash
cd backend
npm install
npm run dev
```
*O backend estará disponível em: `http://localhost:3000`*

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```
*O frontend estará disponível em: `http://localhost:3001`*

---

## 💻 Opção 2: Execução Local (Desenvolvimento)

Se você preferir rodar tudo manualmente sem Docker, precisará ter as instâncias de Postgres, Redis e MongoDB rodando em sua máquina.

### 1. Configurar Bancos de Dados
Certifique-se de que os serviços estão ativos e as URLs no `.env` estão corretas:
- Postgres: `localhost:5432`
- Redis: `localhost:6379`
- MongoDB: `localhost:27017`

### 2. Backend
```bash
cd backend
npm install
npm run build   # Para gerar a pasta dist
npm run dev     # Para desenvolvimento
```

### 3. Frontend
```bash
cd frontend
npm install
npm run dev
```

---

## 🏗️ Opção 3: Ambiente de Produção

Para implantar em um servidor de produção, utilize o arquivo de configuração otimizado:

```bash
# Executar com configurações de produção
docker-compose -f docker-compose.prod.yml up -d
```

### Scripts de Utilidade
Criamos scripts para facilitar a manutenção:
- **Verificar saúde do sistema:** `./scripts/health-check.sh`
- **Deploy manual:** `./scripts/deploy.sh production`
- **Configurar CI/CD:** `./scripts/setup-cicd.sh`

---

## 🛠️ Solução de Problemas

| Problema | Solução |
|----------|---------|
| Erro de conexão com banco | Verifique se os containers Docker estão rodando: `docker ps` |
| Porta 3000 ocupada | Altere a variável `PORT` no arquivo `.env` |
| Erro de permissão nos scripts | Execute `chmod +x scripts/*.sh` |
| Frontend não conecta na API | Verifique se o backend está rodando em `http://localhost:3000` |

---

## 📞 Suporte
Para dúvidas técnicas, entre em contato: **br.antoniosouza@gmail.com**
