#!/bin/bash

echo "Atualizando pacotes..."
sudo apt update && sudo apt install -y nginx git aws-cli openjdk-17-jdk

REPO_URL="https://github.com/Miguel-Araujo325/edu-invtt-tf"
TMP_DIR="/tmp/edu-invtt-tf"

echo "Removendo qualquer versão antiga do repositório..."
sudo rm -rf "$TMP_DIR"

echo "Clonando o repositório no diretório temporário..."
git clone "$REPO_URL" "$TMP_DIR"

# ======================== Configurando Frontend ========================
echo "Configurando o frontend..."
sudo rm -rf /var/www/html/*
sudo cp -r "$TMP_DIR/front-end/*" /var/www/html/

# ======================== Obtendo o IP do MySql ========================
BACKEND_IP=$(aws ssm get-parameter --name "/config/backend_private_ip" --query "Parameter.Value" --output text)
echo "IP do MySql obtido: $BACKEND_IP"

# ======================== Configurando Nginx ========================
cat <<EOT > /etc/nginx/sites-available/myserver
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html/front-end/solucao-e4e/html;
    index login2.html;

    location /css/ {
        alias /var/www/html/front-end/solucao-e4e/css/;
    }
    location /js/ {
        alias /var/www/html/front-end/solucao-e4e/js/;
    }
    location /imgs/ {
        alias /var/www/html/front-end/solucao-e4e/imgs/;
    }

    # Proxy para API principal
    location /api/ {
        proxy_pass http://$BACKEND_IP:8080/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # Proxy para API Dashboard
    location /api-dashboard/ {
        proxy_pass http://$BACKEND_IP:7000/api-dashboard/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOT

# Ativando a configuração do Nginx
ln -sf /etc/nginx/sites-available/myserver /etc/nginx/sites-enabled/myserver
rm -f /etc/nginx/sites-enabled/default
systemctl reload nginx
systemctl restart nginx
echo "Nginx configurado com sucesso."

# ======================== Configurando Backend ========================
BACKEND_DIR="/opt/edu-invtt"
sudo mkdir -p "$BACKEND_DIR"

echo "Movendo arquivos .jar para $BACKEND_DIR..."
sudo cp "$TMP_DIR/back-end/eduinovatte-0.0.1-SNAPSHOT.jar" "$BACKEND_DIR/api.jar"
sudo cp "$TMP_DIR/back-end/eduinovatte-dashboard-0.0.1-SNAPSHOT.jar" "$BACKEND_DIR/dashboard.jar"

echo "Iniciando backend..."
nohup java -DIPV4_PRIVATE=$BACKEND_IP -jar "$BACKEND_DIR/api.jar" > /var/log/api.log 2>&1 &
nohup java -DIPV4_PRIVATE=$BACKEND_IP -jar "$BACKEND_DIR/dashboard.jar" > /var/log/dashboard.log 2>&1 &
echo "Backend iniciado com sucesso."

# ======================== Removendo Diretório Temporário ========================
echo "Removendo arquivos temporários..."
sudo rm -rf "$TMP_DIR"

echo "Instalação concluída!"
