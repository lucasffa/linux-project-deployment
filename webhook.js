const http = require('http');
const exec = require('child_process').exec;
const dotenv = require('dotenv');
const path = require('path');

// Carrega as variáveis de ambiente do arquivo config.env
dotenv.config({ path: path.resolve('/var/www/linux-project-deployment/config.env') });

const PORT = process.env.WEBHOOK_PORT || 6000;

const server = http.createServer((req, res) => {
    if (req.method === 'POST' && req.url === '/webhook') {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            console.log('Webhook recebido, iniciando script de deploy...');
            exec('/var/www/linux-project-deployment/deploy.sh', (error, stdout, stderr) => {
                if (error) {
                    console.error(`Erro ao executar script: ${error}`);
                    res.statusCode = 500;
                    res.end('Erro ao executar script de deploy');
                    return;
                }
                console.log(`stdout: ${stdout}`);
                console.error(`stderr: ${stderr}`);
                res.end('Webhook processado com sucesso');
            });
        });
    } else {
        res.statusCode = 404;
        res.end('Not Found');
    }
});

server.listen(PORT, () => {
    console.log(`Servidor de Webhook escutando na porta ${PORT}`);
});

