#!/bin/bash
# =============================================================================
# SimulaImóvel Pro - Script de Health Check
# =============================================================================
# Uso:
#   ./scripts/health-check.sh
#
# Verifica a saúde de todos os serviços da aplicação.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================"
echo "  SimulaImóvel Pro - Health Check"
echo "============================================"
echo ""

ERRORS=0

# ---------------------------------------------------------------------------
# Verificar Backend
# ---------------------------------------------------------------------------
echo -n "  Backend (API)............. "
if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHOU${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ---------------------------------------------------------------------------
# Verificar Frontend
# ---------------------------------------------------------------------------
echo -n "  Frontend (React).......... "
if curl -sf http://localhost:3001 > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${YELLOW}INDISPONÍVEL${NC}"
fi

# ---------------------------------------------------------------------------
# Verificar PostgreSQL
# ---------------------------------------------------------------------------
echo -n "  PostgreSQL................ "
if docker compose exec -T postgres pg_isready -U simula_user > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHOU${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ---------------------------------------------------------------------------
# Verificar Redis
# ---------------------------------------------------------------------------
echo -n "  Redis..................... "
if docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHOU${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ---------------------------------------------------------------------------
# Verificar MongoDB
# ---------------------------------------------------------------------------
echo -n "  MongoDB................... "
if docker compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHOU${NC}"
    ERRORS=$((ERRORS + 1))
fi

# ---------------------------------------------------------------------------
# Verificar Docker Containers
# ---------------------------------------------------------------------------
echo ""
echo "  Containers Docker:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  (Docker Compose não disponível)"

# ---------------------------------------------------------------------------
# Resultado
# ---------------------------------------------------------------------------
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "  ${GREEN}✅ Todos os serviços estão saudáveis!${NC}"
else
    echo -e "  ${RED}❌ ${ERRORS} serviço(s) com problemas.${NC}"
fi
echo ""
echo "============================================"

exit $ERRORS
