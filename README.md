
   # Linux Project Deployment

   Este projeto automatiza o processo de deploy de uma aplicação Node.js ou Nest.js em um servidor Linux. Ele configura e gerencia a aplicação usando PM2 e NGINX, além de fornecer um webhook para deploy automático.

   ## Requisitos

   - Servidor Linux (testado no Ubuntu)
   - Node.js e npm
   - Git
   - NGINX
   - PostgreSQL
   - PM2 (para gerenciamento de processos Node.js)
   - Apenas projetos Node.js com ou sem TypeScript

   ## Passos para Configuração

   ### 1. Clonar o Repositório

   ```bash
   git clone https://seu-repositorio.git /var/www/linux-project-deployment
   cd /var/www/linux-project-deployment
   ```

   ### 2. Configurar o `config.env`

   Crie um arquivo `config.env` com as seguintes variáveis de configuração:

   ```plaintext
   APP_IP=127.0.0.1 # Troque pelo IP da máquina que hospedará a aplicação
   API_ROUTE=/api/ # Lembre-se de utilizar a última /
   API_PM2_NAME=ApiServer # Costumizável
   WEBHOOK_PM2_NAME=WebhookServer # Costumizável
   API_PORT=3000
   WEBHOOK_PORT=6000
   PROJECT_TYPE=nest  # 'nest' para projetos Nest.js, 'node' para projetos Node.js, 'plain' para projetos sem build (sem typescript)
   ```

   - `APP_IP`: O endereço IP do servidor onde a aplicação será executada.
   - `API_ROUTE`: A rota para acessar a API.
   - `API_PM2_NAME`: O nome do processo PM2 para a API.
   - `WEBHOOK_PM2_NAME`: O nome do processo PM2 para o webhook.
   - `API_PORT`: A porta em que a API será executada.
   - `WEBHOOK_PORT`: A porta em que o webhook será executado.
   - `PROJECT_TYPE`: O tipo de projeto ('nest' para projetos Nest.js, 'node' para projetos Node.js, 'plain' para projetos sem build).

   ### 3. Configurar o `.env`

   Crie um arquivo `.env` com as variáveis de ambiente da aplicação:

   ```plaintext
   NODE_ENV=development

   ## jwt
   JWT_SECRET=my_jwt_secret
   JWT_EXPIRES_IN=60m

   ## rate limit
   RATE_LIMIT_WINDOW_TIME=60000
   RATE_LIMIT_SUPER_USER=3

   ## db
   DATABASE_HOST=localhost
   DATABASE_PORT=5432
   DATABASE_USERNAME=best_user
   DATABASE_PASSWORD=best_password
   DATABASE_NAME=db_sistriagem

   ## redis
   REDIS_HOST=localhost
   REDIS_PORT=6379

   ## feature toggles
   USE_REDIS=false
   ENABLE_TOKEN_BLACKLISTING=true
   ```

   - `NODE_ENV`: Ambiente de execução (e.g., development, production).
   - `JWT_SECRET`: Segredo para geração de tokens JWT.
   - `JWT_EXPIRES_IN`: Tempo de expiração dos tokens JWT.
   - `RATE_LIMIT_WINDOW_TIME`: Tempo de janela para limite de taxa (em milissegundos).
   - `RATE_LIMIT_SUPER_USER`: Limite de solicitações para super usuários.
   - `DATABASE_HOST`: Host do banco de dados.
   - `DATABASE_PORT`: Porta do banco de dados.
   - `DATABASE_USERNAME`: Nome de usuário do banco de dados.
   - `DATABASE_PASSWORD`: Senha do banco de dados.
   - `DATABASE_NAME`: Nome do banco de dados.
   - `REDIS_HOST`: Host do Redis.
   - `REDIS_PORT`: Porta do Redis.
   - `USE_REDIS`: Flag para usar Redis (true ou false).
   - `ENABLE_TOKEN_BLACKLISTING`: Flag para habilitar blacklist de tokens (true ou false).

   ### 4. Executar o Script de Configuração

   Execute o script de configuração para instalar dependências e configurar o ambiente:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   ### 5. Deploy da Aplicação

   Para realizar o deploy da aplicação, utilize o webhook ou execute o script de deploy manualmente:

   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   ## Limitações

   - Este script foi testado no Ubuntu, outras distribuições Linux podem exigir ajustes.
   - O script de deploy assume que o repositório da aplicação está disponível publicamente ou com acesso configurado.
   - As configurações de segurança, como firewalls e permissões, devem ser gerenciadas separadamente.

   ## Considerações Finais

   Este projeto visa simplificar o processo de deploy de aplicações Node.js e Nest.js, fornecendo um fluxo de trabalho automatizado e configurável. Sinta-se à vontade para ajustar os scripts conforme suas necessidades específicas.
