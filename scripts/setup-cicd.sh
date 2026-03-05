#!/bin/bash
# =============================================================================
# SimulaImóvel Pro - Configuração Inicial do CI/CD
# =============================================================================
# Uso:
#   ./scripts/setup-cicd.sh
#
# Configura os ambientes de staging e produção no GitHub,
# cria os secrets necessários e valida a configuração.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO="brantoniosouza-svg/simula-imovel-pro"

echo ""
echo "============================================"
echo "  SimulaImóvel Pro - Setup CI/CD"
echo "============================================"
echo ""

# ---------------------------------------------------------------------------
# Verificar GitHub CLI
# ---------------------------------------------------------------------------
echo -n "Verificando GitHub CLI... "
if ! command -v gh &> /dev/null; then
    echo -e "${RED}NÃO ENCONTRADO${NC}"
    echo "Instale o GitHub CLI: https://cli.github.com/"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

echo -n "Verificando autenticação... "
if ! gh auth status > /dev/null 2>&1; then
    echo -e "${RED}NÃO AUTENTICADO${NC}"
    echo "Execute: gh auth login"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

echo ""

# ---------------------------------------------------------------------------
# Criar Environments no GitHub
# ---------------------------------------------------------------------------
echo -e "${BLUE}Criando ambientes no GitHub...${NC}"

# Nota: GitHub CLI não suporta criação direta de environments via CLI,
# mas podemos usar a API do GitHub.

echo -e "${YELLOW}Os ambientes 'staging' e 'production' devem ser criados"
echo -e "manualmente em: https://github.com/${REPO}/settings/environments${NC}"
echo ""
echo "Configurações recomendadas:"
echo ""
echo "  STAGING:"
echo "    - Sem regras de proteção"
echo "    - Deploy automático na branch 'main'"
echo ""
echo "  PRODUCTION:"
echo "    - Revisores obrigatórios (adicione seu usuário)"
echo "    - Tempo de espera: 5 minutos"
echo "    - Deploy apenas da branch 'main' e tags 'v*'"
echo ""

# ---------------------------------------------------------------------------
# Configurar Secrets (interativo)
# ---------------------------------------------------------------------------
echo -e "${BLUE}Configuração de Secrets${NC}"
echo ""
echo "Os seguintes secrets podem ser configurados no GitHub:"
echo "  https://github.com/${REPO}/settings/secrets/actions"
echo ""
echo "Secrets opcionais para deploy remoto:"
echo "  STAGING_SSH_KEY       - Chave SSH privada do servidor de staging"
echo "  PRODUCTION_SSH_KEY    - Chave SSH privada do servidor de produção"
echo ""
echo "Variáveis de ambiente (Settings > Environments):"
echo ""
echo "  Staging:"
echo "    STAGING_HOST        - IP/hostname do servidor"
echo "    STAGING_USER        - Usuário SSH"
echo "    STAGING_PORT        - Porta SSH (padrão: 22)"
echo "    STAGING_PATH        - Caminho do projeto no servidor"
echo "    STAGING_URL         - URL pública do staging"
echo ""
echo "  Production:"
echo "    PRODUCTION_HOST     - IP/hostname do servidor"
echo "    PRODUCTION_USER     - Usuário SSH"
echo "    PRODUCTION_PORT     - Porta SSH (padrão: 22)"
echo "    PRODUCTION_PATH     - Caminho do projeto no servidor"
echo "    PRODUCTION_URL      - URL pública da produção"
echo ""

# ---------------------------------------------------------------------------
# Habilitar GitHub Actions
# ---------------------------------------------------------------------------
echo -e "${BLUE}Verificando GitHub Actions...${NC}"
echo ""
echo "As GitHub Actions são habilitadas por padrão em repositórios públicos."
echo "Verifique em: https://github.com/${REPO}/settings/actions"
echo ""

# ---------------------------------------------------------------------------
# Criar branch develop
# ---------------------------------------------------------------------------
echo -n "Criando branch develop... "
if git rev-parse --verify develop > /dev/null 2>&1; then
    echo -e "${YELLOW}já existe${NC}"
else
    git branch develop main 2>/dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${YELLOW}falhou (crie manualmente)${NC}"
fi

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
echo ""
echo "============================================"
echo -e "  ${GREEN}Setup CI/CD concluído!${NC}"
echo "============================================"
echo ""
echo "Próximos passos:"
echo "  1. Crie os ambientes 'staging' e 'production' no GitHub"
echo "  2. Configure os secrets de SSH (se usar deploy remoto)"
echo "  3. Faça um push para a branch 'main' para testar o pipeline"
echo "  4. Verifique os workflows em:"
echo "     https://github.com/${REPO}/actions"
echo ""
echo "============================================"
