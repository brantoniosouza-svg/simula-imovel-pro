#!/bin/bash
# =============================================================================
# SimulaImóvel Pro - Script de Deploy Manual
# =============================================================================
# Uso:
#   ./scripts/deploy.sh [staging|production]
#
# Este script realiza o deploy completo da aplicação em um servidor,
# incluindo backup do banco, atualização de imagens e health check.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configurações
# ---------------------------------------------------------------------------
ENVIRONMENT="${1:-staging}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${PROJECT_DIR}/backups"
LOG_FILE="${PROJECT_DIR}/logs/deploy_${TIMESTAMP}.log"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Funções auxiliares
# ---------------------------------------------------------------------------
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${BLUE}${message}${NC}"
    echo "${message}" >> "${LOG_FILE}" 2>/dev/null || true
}

success() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1"
    echo -e "${GREEN}${message}${NC}"
    echo "${message}" >> "${LOG_FILE}" 2>/dev/null || true
}

warn() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1"
    echo -e "${YELLOW}${message}${NC}"
    echo "${message}" >> "${LOG_FILE}" 2>/dev/null || true
}

error() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1"
    echo -e "${RED}${message}${NC}"
    echo "${message}" >> "${LOG_FILE}" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Verificações iniciais
# ---------------------------------------------------------------------------
check_prerequisites() {
    log "Verificando pré-requisitos..."

    if ! command -v docker &> /dev/null; then
        error "Docker não encontrado. Instale o Docker primeiro."
        exit 1
    fi

    if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
        error "Docker Compose não encontrado. Instale o Docker Compose primeiro."
        exit 1
    fi

    if [ ! -f "${PROJECT_DIR}/.env" ]; then
        warn "Arquivo .env não encontrado. Copiando .env.example..."
        cp "${PROJECT_DIR}/.env.example" "${PROJECT_DIR}/.env"
        warn "Edite o arquivo .env com suas configurações antes de continuar."
    fi

    mkdir -p "${BACKUP_DIR}" "${PROJECT_DIR}/logs"
    success "Pré-requisitos verificados."
}

# ---------------------------------------------------------------------------
# Backup do banco de dados
# ---------------------------------------------------------------------------
backup_database() {
    log "Criando backup do banco de dados..."

    if docker compose ps postgres 2>/dev/null | grep -q "Up"; then
        docker compose exec -T postgres pg_dump \
            -U "${DB_USER:-simula_user}" \
            "${DB_NAME:-simula_imovel}" > "${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql" 2>/dev/null

        if [ $? -eq 0 ]; then
            success "Backup criado: ${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql"
        else
            warn "Falha ao criar backup. Continuando deploy..."
        fi
    else
        warn "PostgreSQL não está rodando. Pulando backup."
    fi
}

# ---------------------------------------------------------------------------
# Atualização das imagens
# ---------------------------------------------------------------------------
pull_images() {
    log "Atualizando imagens Docker..."

    local compose_file="docker-compose.yml"
    if [ "${ENVIRONMENT}" = "production" ]; then
        compose_file="docker-compose.prod.yml"
    fi

    docker compose -f "${PROJECT_DIR}/${compose_file}" pull
    success "Imagens atualizadas."
}

# ---------------------------------------------------------------------------
# Deploy dos serviços
# ---------------------------------------------------------------------------
deploy_services() {
    log "Iniciando deploy dos serviços (${ENVIRONMENT})..."

    local compose_file="docker-compose.yml"
    if [ "${ENVIRONMENT}" = "production" ]; then
        compose_file="docker-compose.prod.yml"
    fi

    docker compose -f "${PROJECT_DIR}/${compose_file}" up -d --remove-orphans
    success "Serviços iniciados."
}

# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------
health_check() {
    log "Executando health check..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
            success "Backend respondendo corretamente (tentativa ${attempt}/${max_attempts})."
            return 0
        fi

        log "Aguardando backend... (tentativa ${attempt}/${max_attempts})"
        sleep 2
        attempt=$((attempt + 1))
    done

    error "Health check falhou após ${max_attempts} tentativas."
    return 1
}

# ---------------------------------------------------------------------------
# Limpeza
# ---------------------------------------------------------------------------
cleanup() {
    log "Limpando recursos não utilizados..."
    docker image prune -f > /dev/null 2>&1
    success "Limpeza concluída."

    # Manter apenas os últimos 5 backups
    if [ -d "${BACKUP_DIR}" ]; then
        ls -t "${BACKUP_DIR}"/db_backup_*.sql 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
        success "Backups antigos removidos (mantidos os 5 mais recentes)."
    fi
}

# ---------------------------------------------------------------------------
# Rollback
# ---------------------------------------------------------------------------
rollback() {
    error "Deploy falhou! Executando rollback..."

    local latest_backup=$(ls -t "${BACKUP_DIR}"/db_backup_*.sql 2>/dev/null | head -1)

    docker compose down
    docker compose up -d --remove-orphans

    if [ -n "${latest_backup}" ]; then
        warn "Backup disponível para restauração: ${latest_backup}"
        warn "Para restaurar: cat ${latest_backup} | docker compose exec -T postgres psql -U simula_user simula_imovel"
    fi

    error "Rollback concluído. Verifique os logs para mais detalhes."
    exit 1
}

# ---------------------------------------------------------------------------
# Execução principal
# ---------------------------------------------------------------------------
main() {
    echo ""
    echo "============================================"
    echo "  SimulaImóvel Pro - Deploy (${ENVIRONMENT})"
    echo "============================================"
    echo ""

    check_prerequisites
    backup_database
    pull_images
    deploy_services

    if ! health_check; then
        rollback
    fi

    cleanup

    echo ""
    echo "============================================"
    success "Deploy concluído com sucesso!"
    echo ""
    echo "  Ambiente:  ${ENVIRONMENT}"
    echo "  Frontend:  http://localhost:3001"
    echo "  Backend:   http://localhost:3000"
    echo "  Health:    http://localhost:3000/health"
    echo ""
    echo "  Log: ${LOG_FILE}"
    echo "============================================"
    echo ""
}

main "$@"
