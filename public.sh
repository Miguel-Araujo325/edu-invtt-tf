#!/bin/bash

# Função para verificar a versão do Java
check_java() {
    if type -p java &> /dev/null; then
        echo "Java encontrado."
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        if [[ "$java_version" == "17.0.2" ]]; then
            echo "Java 17.0.2 já está instalado."
        else
            echo "Versão diferente de Java instalada ($java_version)."
            install_java
        fi
    else
        echo "Java não encontrado."
        install_java
    fi
}

# Função para instalar o Java 17.0.2
install_java() {
    echo "Instalando Java 17.0.2..."
    sudo apt update
    sudo apt --fix-broken install -y
    sudo apt install -y openjdk-17-jdk
}

# Função para verificar e instalar o Git
check_git() {
    if ! command -v git &> /dev/null; then
        echo "Git não está instalado. Instalando o Git..."
        sudo apt update
        sudo apt install -y git
    else
        echo "Git já está instalado."
    fi
}

# Função para verificar e instalar o Nginx
check_nginx() {
    if ! command -v nginx &> /dev/null; then
        echo "Nginx não está instalado. Instalando o Nginx..."
        sudo apt update
        sudo apt install -y nginx
    else
        echo "Nginx já está instalado."
    fi
}

# Verificações iniciais
check_java
check_git
check_nginx

# Clonando/atualizando o repositório
REPO_URL="https://github.com/Miguel-Araujo325/edu-invtt-tf"
REPO_DIR="edu-invtt-tf"  # Diretório local onde será clonado o repositório

if [ ! -d "$REPO_DIR" ]; then
    echo "Repositório não encontrado. Clonando o repositório..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Repositório já existe. Atualizando com git pull..."
    cd "$REPO_DIR"
    git pull
    cd ..
fi

# Função para configurar e executar o front-end
run_frontend() {
    # 1. Remover tudo do diretório /var/www/html
    echo "Removendo conteúdo de /var/www/html..."
    sudo rm -rf /var/www/html/*

    # 2. Copiar o front-end para /var/www/html
    echo "Copiando arquivos do front-end para /var/www/html..."
    sudo cp -r edu-invtt-tf/front-end/* /var/www/html/

    # 3. Configurar Nginx (copiar default para myserver e sobrescrever conteúdo)
    echo "Configurando o arquivo myserver em /etc/nginx/sites-available/..."
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/myserver

    # Ajuste conforme a sua necessidade (rotas /css/, /js/, /imgs/, /api/, etc.)
    cat << 'EOF' | sudo tee /etc/nginx/sites-available/myserver
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    # Diretório raiz onde ficam os arquivos estáticos do front-end
    root /var/www/html/front-end/solucao-e4e/html;
    index login2.html;

    # Blocos de localização de arquivos estáticos
    location /css/ {
        alias /var/www/html/front-end/solucao-e4e/css/;
    }
    location /js/ {
        alias /var/www/html/front-end/solucao-e4e/js/;
    }
    location /imgs/ {
        alias /var/www/html/front-end/solucao-e4e/imgs/;
    }

    # Proxy para a API em localhost:8080
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

    # Remove configurações default para evitar conflito
    sudo rm -f /etc/nginx/sites-available/default
    sudo rm -f /etc/nginx/sites-enabled/default

    # 4. Reiniciar e aplicar as alterações no serviço do Nginx
    echo "Reiniciando o Nginx..."
    sudo systemctl restart nginx
}

# Função para executar as duas APIs Spring simultaneamente
run_backend() {
    # Ajuste os caminhos se necessário:
    JAR_FILE="back-end/eduinovatte-0.0.1-SNAPSHOT.jar"
    JAR_FILE_DASH="back-end/eduinovatte-dashboard-0.0.1-SNAPSHOT.jar"

    if [ -f "$JAR_FILE" ]; then
        echo "Executando o backend (API principal)..."
        java -jar "$JAR_FILE" &
    else
        echo "Arquivo JAR não encontrado: $JAR_FILE"
    fi

    if [ -f "$JAR_FILE_DASH" ]; then
        echo "Executando o backend (Dashboard API)..."
        java -jar "$JAR_FILE_DASH" &
    else
        echo "Arquivo JAR não encontrado: $JAR_FILE_DASH"
    fi

    # Aguarda ambos os processos terminarem
    wait
}

run_frontend
run_backend
