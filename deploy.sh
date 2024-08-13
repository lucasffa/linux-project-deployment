#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Load configuration variables
source /var/www/linux-project-deployment/config.env

# Extract repository name from URL
REPO_NAME=$(basename -s .git $REPO_URL)
REPO_DIR="/var/www/deploys/$REPO_NAME"
ECOSYSTEM_CONFIG="$REPO_DIR/ecosystem.config.js"

# Change to a valid directory
cd /var/www

# Remove old content if it exists
if [ -d "$REPO_DIR" ]; then
    sudo rm -rf $REPO_DIR
fi

# Clone the repository
git clone $REPO_URL $REPO_DIR

# Remove any old .env file
rm -f $REPO_DIR/.env

# Create the .env file with environment variables
cp /var/www/linux-project-deployment/.env $REPO_DIR/.env

# Navigate to the repository directory
cd $REPO_DIR

# Install dependencies
npm install

# Build the application, depending on the project type
if [ "$PROJECT_TYPE" == "nest" ]; then
    npm run build
elif [ "$PROJECT_TYPE" == "node" ]; then
    npm run build # se necessário, ou remova essa linha se não for aplicável
else
    echo "Unsupported project type: $PROJECT_TYPE"
    exit 1
fi

# Start or reload the application using PM2 ecosystem file
pm2 startOrReload $ECOSYSTEM_CONFIG

# Run webhook.js with PM2
pm2 stop $WEBHOOK_PM2_NAME || true
pm2 start /var/www/linux-project-deployment/webhook.js --name $WEBHOOK_PM2_NAME

# Save the PM2 state
pm2 save

# Restart NGINX
systemctl restart nginx

