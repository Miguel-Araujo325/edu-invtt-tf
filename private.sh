#!/bin/bash

check_mysql() {
    if ! command -v mysql &> /dev/null; then
        echo "MySQL não está instalado. Instalando o MySQL..."
        install_mysql
    else
        echo "MySQL já está instalado."
    fi
}

install_mysql() {
    echo "Instalando a última versão do MySQL..."
    sudo apt install -y mysql-server
    sudo systemctl start mysql
    sudo systemctl enable mysql
    echo "MySQL instalado e iniciado."
    create_db_user
}

create_db_user() {
    # Defina o nome do usuário e a senha desejados
    DB_USER="eduinovate"
    DB_PASS="jau0987!!"
    echo "Criando o usuário '$DB_USER' no MySQL..."
    mysql -u root -p -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
    mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'localhost' WITH GRANT OPTION;"
    mysql -u root -p -e "FLUSH PRIVILEGES;"
    echo "Usuário '$DB_USER' criado com sucesso."
    setup_database
}

setup_database() {
    DB_REPO_URL="https://github.com/Miguel-Araujo325/edu-invtt-tf"
    DB_REPO_DIR="database"

    if [ ! -d "$DB_REPO_DIR" ]; then
        echo "Clonando o repositório do banco de dados..."
        git clone "$DB_REPO_URL"
    else
        echo "Repositório do banco de dados já existe. Atualizando com git pull..."
        cd "$DB_REPO_DIR"
        git pull
        cd ..
    fi

    echo "Executando script SQL para configurar o banco de dados..."
    # Ajuste estes comandos conforme necessário para executar seus scripts SQL
    mysql -u root -p < "$DB_REPO_DIR/ddl-table.sql"
    mysql -u root -p < "$DB_REPO_DIR/inserts-acess-levels.sql"
    mysql -u root -p < "$DB_REPO_DIR/views.sql"
    mysql -u root -p < "$DB_REPO_DIR/inserts-users.sql"
}

check_git() {
    if ! command -v git &> /dev/null; then
        echo "Git não está instalado. Instalando o Git..."
        sudo apt update
        sudo apt install git -y
    else
        echo "Git já está instalado."
    fi
}

check_git
check_mysql

