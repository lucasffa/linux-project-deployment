#!/bin/bash

# Função para verificar a instalação de um pacote
is_installed() {
    dpkg -l | grep -q "$1"
}

# Atualizar pacotes
sudo apt update

# Instalar curl, git, nginx, postgresql se não estiverem instalados
for package in curl git nginx postgresql; do
    if is_installed $package; then
        echo "$package já está instalado"
    else
        echo "Instalando $package"
        sudo apt install -y $package
    fi
done

# Instalar Node.js e npm se não estiverem instalados
if command -v node >/dev/null 2>&1; then
    echo "Node.js já está instalado"
else
    echo "Instalando Node.js"
    sudo apt-get install -y nodejs
fi

if command -v npm >/dev/null 2>&1; then
    echo "npm já está instalado"
else
    echo "Instalando npm"
    sudo apt-get install -y npm
fi

# Instalar PM2 globalmente
if command -v pm2 >/dev/null 2>&1; then
    echo "PM2 já está instalado"
else
    echo "Instalando PM2"
    sudo npm install -g pm2
fi

# Tornar os scripts executáveis
chmod +x /var/www/linux-project-deployment/deploy.sh
chmod +x /var/www/linux-project-deployment/webhook.sh

# Configurar serviço systemd para deploy
sudo tee /etc/systemd/system/deploy.service > /dev/null <<EOF
[Unit]
Description=Deploy Script
After=network.target

[Service]
Type=oneshot
ExecStart=/var/www/linux-project-deployment/deploy.sh

[Install]
WantedBy=multi-user.target
EOF

# Habilitar serviço de deploy
sudo systemctl enable deploy.service

# Configurar PM2 para iniciar na inicialização
sudo pm2 startup
sudo pm2 save

# Carregar as variáveis de configuração
source /var/www/linux-project-deployment/config.env

# Verificar se todas as variáveis estão carregadas
if [ -z "$APP_IP" ] || [ -z "$API_ROUTE" ] || [ -z "$API_PM2_NAME" ] || [ -z "$WEBHOOK_PM2_NAME" ] || [ -z "$API_PORT" ] || [ -z "$WEBHOOK_PORT" ] || [ -z "$PROJECT_TYPE" ] || [ -z "$REPO_URL" ]; then
    echo "Erro: Uma ou mais variáveis de ambiente não estão definidas em config.env"
    exit 1
fi

# Configurar NGINX
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    server_name $APP_IP;

    location $API_ROUTE {
        rewrite ^$API_ROUTE(.*) /$1 break;
        proxy_pass http://localhost:$API_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /webhook {
        proxy_pass http://localhost:$WEBHOOK_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Verificar a configuração do NGINX e reiniciar o serviço
sudo nginx -t && sudo systemctl restart nginx

