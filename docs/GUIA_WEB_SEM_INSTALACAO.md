# Guia: Como colocar o SimulaImóvel Pro no ar (Grátis e Sem Instalar Nada)

Para que você não precise instalar o Docker ou qualquer programa no seu computador, vamos usar a **Vercel** para hospedar o sistema na nuvem de graça.

## 🚀 Passo a Passo (5 Minutos)

### 1. Criar Contas Gratuitas (Se ainda não tem)
- **GitHub:** Onde o código está guardado.
- **Vercel:** Onde o site vai "viver" na internet ([vercel.com](https://vercel.com)).

### 2. Conectar o GitHub à Vercel
1. Acesse o site da **Vercel** e faça login com sua conta do GitHub.
2. Clique em **"Add New"** > **"Project"**.
3. Selecione o seu repositório `simula-imovel-pro`.

### 3. Configurar as Variáveis de Ambiente
Na tela de importação do projeto na Vercel, você verá uma seção chamada **"Environment Variables"**. Você deve adicionar as chaves que estão no arquivo `.env.example`. 

As mais importantes para o sistema funcionar são:
- `PORT`: 3000
- `NODE_ENV`: production
- `DATABASE_URL`: (Aqui você coloca o link do seu banco de dados na nuvem, como o Supabase)

### 4. Clicar em "Deploy"
Pronto! A Vercel vai ler o código e criar um link para você (exemplo: `simula-imovel-pro.vercel.app`).

---

## ☁️ Onde conseguir os Bancos de Dados Gratuitos?

Como agora o sistema está na web, ele precisa de bancos de dados que também estejam na web:

1. **Banco de Dados (Postgres):** Use o [Supabase](https://supabase.com) (Plano Gratuito).
2. **Banco de Dados (MongoDB):** Use o [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) (Plano Gratuito).
3. **Banco de Dados (Redis):** Use o [Upstash](https://upstash.com) (Plano Gratuito).

---

## ✅ Vantagens desta solução
- **Acesso de qualquer lugar:** Celular, Tablet ou Computador.
- **Zero Instalação:** Não ocupa espaço no seu computador.
- **Segurança:** Backups automáticos feitos pelas empresas de hospedagem.
- **Custo Zero:** Usando os planos gratuitos indicados, você não paga nada.
