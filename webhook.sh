#!/bin/bash

source /var/www/linux-project-deployment/config.env

PORT=$WEBHOOK_PORT

node <<EOF
const http = require('http');
const exec = require('child_process').exec;

const PORT = process.env.PORT || $PORT;

http.createServer((req, res) => {
    if (req.method === 'POST' && req.url === '/webhook') {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            console.log('Webhook recebido, iniciando script de deploy...');
            exec('/var/www/linux-project-deployment/deploy.sh', (error, stdout, stderr) => {
                if (error) {
                    console.error(\`Erro ao executar script: \${error}\`);
                    return;
                }
                console.log(\`stdout: \${stdout}\`);
                console.error(\`stderr: \${stderr}\`);
            });
            res.end('Webhook recebido');
        });
    } else {
        res.statusCode = 404;
        res.end();
    }
}).listen(PORT, () => {
    console.log(\`Servidor de Webhook escutando na porta \${PORT}\`);
});
EOF

