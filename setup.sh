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
cat <<EOF | sudo tee /etc/systemd/system/deploy.service
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

# Configurar NGINX
source /var/www/linux-project-deployment/config.env
sudo bash -c "cat > /etc/nginx/sites-available/default" <<EOF
server {
    listen 80;
    server_name $APP_IP;

    location $API_ROUTE {
        rewrite ^$API_ROUTE(.*) /$1 break;
        proxy_pass http://localhost:$API_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
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

# Reiniciar NGINX
sudo systemctl restart nginx

# Testes do NGINX
sudo nginx -t

# Reinicializar NGINX
sudo systemctl restart nginx

# Verificar status do NGINX
sudo systemctl status nginx.service

# Verificar journals do NGINX
journalctl -xeu nginx.service


