import app from './app';
import config from './config/env';

const startServer = async () => {
  try {
    console.log('✅ Banco de dados conectado');

    app.listen(config.PORT, () => {
      console.log(`🚀 Servidor rodando em http://localhost:${config.PORT}`);
      console.log(`📝 Ambiente: ${config.NODE_ENV}`);
    });
  } catch (error) {
    console.error('❌ Erro ao iniciar servidor:', error);
    process.exit(1);
  }
};

startServer();
