#!/bin/bash

# Carregar as variáveis de configuração
source /var/www/linux-project-deployment/config.env

# Extrair o nome do repositório da URL
REPO_NAME=$(basename -s .git $REPO_URL)
REPO_DIR="/var/www/deploys/$REPO_NAME"

# Tornar o script executável
chmod +x /var/www/linux-project-deployment/deploy.sh

# Remover conteúdo antigo
rm -rf $REPO_DIR

# Clonar o repositório
git clone $REPO_URL $REPO_DIR

# Remover qualquer versão antiga do .env
rm -f $REPO_DIR/.env

# Criar o arquivo .env com as variáveis de ambiente
cp /var/www/linux-project-deployment/.env $REPO_DIR/.env

# Navegar para o diretório do repositório
cd $REPO_DIR

# Instalar dependências
npm install

# Build da aplicação, dependendo do tipo de projeto
pm2 delete $API_PM2_NAME

if [ "$PROJECT_TYPE" == "nest" ]; then
    npm run build
    pm2 start $REPO_DIR/dist/main.js --name $API_PM2_NAME
elif [ "$PROJECT_TYPE" == "node" ]; then
    pm2 start $REPO_DIR/src/index.js --name $API_PM2_NAME
else
    pm2 start $REPO_DIR/app.js --name $API_PM2_NAME
fi

# Iniciar o webhook com PM2
pm2 stop $WEBHOOK_PM2_NAME
pm2 start /var/www/linux-project-deployment/webhook.sh --name $WEBHOOK_PM2_NAME

# Salvar o estado do PM2
pm2 save

# Reiniciar NGINX
systemctl restart nginx

