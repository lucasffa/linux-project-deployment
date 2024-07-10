#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Load configuration variables
source /var/www/linux-project-deployment/config.env

# Extract repository name from URL
REPO_NAME=$(basename -s .git $REPO_URL)
REPO_DIR="/var/www/deploys/$REPO_NAME"

# Change to a valid directory
cd /var/www

# Remove old content if it exists
if [ -d "$REPO_DIR" ]; then
    rm -rf $REPO_DIR
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
pm2 delete $API_PM2_NAME || true

if [ "$PROJECT_TYPE" == "nest" ]; then
    npm run build
    pm2 start $REPO_DIR/dist/main.js --name $API_PM2_NAME
elif [ "$PROJECT_TYPE" == "node" ]; then
    pm2 start $REPO_DIR/src/index.js --name $API_PM2_NAME
else
    pm2 start $REPO_DIR/app.js --name $API_PM2_NAME
fi

# Restart the webhook with PM2
pm2 stop $WEBHOOK_PM2_NAME || true
pm2 start /var/www/linux-project-deployment/webhook.sh --name $WEBHOOK_PM2_NAME

# Save the PM2 state
pm2 save

# Restart NGINX
systemctl restart nginx
