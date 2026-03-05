@echo off
title SimulaImovel Pro - Inicializador
echo ======================================================
echo           SIMULAIMOVEL PRO - INICIALIZADOR
echo ======================================================
echo.
echo Verificando se o Docker esta rodando...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] O Docker Desktop nao esta aberto! 
    echo Por favor, abra o Docker Desktop e tente novamente.
    pause
    exit /b
)

echo [1/3] Configurando ambiente...
if not exist .env (
    copy .env.example .env
    echo Arquivo .env criado a partir do exemplo.
)

echo [2/3] Baixando e iniciando os bancos de dados...
docker-compose up -d

echo [3/3] Iniciando o sistema (Backend e Frontend)...
echo.
echo O sistema esta sendo preparado... 
echo Aguarde cerca de 1 minuto ate que tudo esteja pronto.
echo.
echo [LINK] Frontend: http://localhost:3001
echo [LINK] Backend:  http://localhost:3000
echo.
echo Mantenha esta janela aberta enquanto estiver usando o sistema.
echo Para encerrar, feche esta janela ou pressione Ctrl+C.
echo.

:: Tenta rodar o backend e frontend se o node estiver instalado, 
:: caso contrario, avisa que o ideal e usar o Docker Compose de Producao
where npm >nul 2>&1
if %errorlevel% eq 0 (
    echo Iniciando servidores locais...
    start /b cmd /c "cd backend && npm install && npm run dev"
    start /b cmd /c "cd frontend && npm install && npm run dev"
) else (
    echo [AVISO] Node.js nao encontrado. 
    echo Tentando iniciar via Docker de Producao...
    docker-compose -f docker-compose.prod.yml up -d
)

pause
