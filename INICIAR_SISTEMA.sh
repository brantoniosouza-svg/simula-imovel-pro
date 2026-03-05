#!/bin/bash

# SimulaImovel Pro - Inicializador para Linux/macOS
echo "======================================================"
echo "          SIMULAIMOVEL PRO - INICIALIZADOR"
echo "======================================================"
echo ""

# Verificando se o Docker esta rodando
docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[ERRO] O Docker Desktop não está aberto!"
    echo "Por favor, abra o Docker Desktop e tente novamente."
    exit 1
fi

echo "[1/3] Configurando ambiente..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Arquivo .env criado a partir do exemplo."
fi

echo "[2/3] Baixando e iniciando os bancos de dados..."
docker-compose up -d

echo "[3/3] Iniciando o sistema (Backend e Frontend)..."
echo ""
echo "O sistema está sendo preparado..."
echo "Aguarde cerca de 1 minuto até que tudo esteja pronto."
echo ""
echo "[LINK] Frontend: http://localhost:3001"
echo "[LINK] Backend:  http://localhost:3000"
echo ""
echo "Mantenha esta janela aberta enquanto estiver usando o sistema."
echo "Para encerrar, pressione Ctrl+C."
echo ""

# Tenta rodar o backend e frontend se o node estiver instalado
if command -v npm &> /dev/null; then
    echo "Iniciando servidores locais..."
    (cd backend && npm install && npm run dev) &
    (cd frontend && npm install && npm run dev) &
    wait
else
    echo "[AVISO] Node.js não encontrado."
    echo "Tentando iniciar via Docker de Produção..."
    docker-compose -f docker-compose.prod.yml up -d
    wait
fi
