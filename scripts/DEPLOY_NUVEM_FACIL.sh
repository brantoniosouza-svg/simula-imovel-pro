#!/bin/bash

# SimulaImovel Pro - Deploy Facil na Nuvem
echo "======================================================"
echo "          SIMULAIMOVEL PRO - DEPLOY NA NUVEM"
echo "======================================================"
echo ""

# Verificar se o usuario tem o Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "[AVISO] Vercel CLI não encontrado. Instalando..."
    sudo npm install -g vercel
fi

echo "[1/3] Fazendo login na Vercel..."
vercel login

echo "[2/3] Configurando o projeto na nuvem..."
vercel link

echo "[3/3] Enviando arquivos para a nuvem..."
vercel --prod

echo ""
echo "======================================================"
echo "   PARABÉNS! SEU SISTEMA ESTÁ NO AR (NA NUVEM)"
echo "======================================================"
echo "Agora você pode acessar de qualquer lugar!"
echo ""
