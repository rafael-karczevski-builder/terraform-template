#!/bin/bash
export GITHUB_TOKEN=${github_token}
export AIRFLOW_USER=${airflow_user}
export AIRFLOW_PASS=${airflow_pass}
export AIRFLOW_MAIL=${airflow_mail}
export DAGS_REPO=${dags_repo}

echo 'Starting Docker instalation...'
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg git
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo 'Docker instaled! Now configuring the airflow...'

mkdir /home/airflow && cd /home/airflow
chmod 777 -R /home/airflow

mkdir config

echo "POSTGRES_USER=airflow" >> config/variables.env
echo "POSTGRES_PASSWORD=airflow" >> config/variables.env
echo "POSTGRES_DB=airflow_db" >> config/variables.env
echo "AIRFLOW_ENV=qa" >> config/variables.env
echo "AIRFLOW_ADMIN_USER=$AIRFLOW_USER" >> config/variables.env
echo "AIRFLOW_ADMIN_PASSWORD=$AIRFLOW_PASS" >> config/variables.env
echo "AIRFLOW_ADMIN_EMAIL=$AIRFLOW_MAIL" >> config/variables.env
echo "AIRFLOW_ADMIN_FIRST_NAME=Admin" >> config/variables.env
echo "AIRFLOW_ADMIN_LAST_NAME=Builders" >> config/variables.env
echo "AIRFLOW__CORE__FERNET_KEY=b3MYJTB7ddyuyT9v87TOeYgCQX7s8Dp0IemhQ4_Syv8=" >> config/variables.env
echo "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow_db" >> config/variables.env
echo "AIRFLOW__WEBSERVER__BASE_URL=http://localhost:8080" >> config/variables.env
echo "AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080" >> config/variables.env
echo "AIRFLOW__WEBSERVER__SECRET_KEY=JK3PU6syfBItlK8mgHrYnA==" >> config/variables.env

git clone https://github-integration-builders:$GITHUB_TOKEN@github.com/$DAGS_REPO/
cd /home/airflow/braveo-lakehouse

sudo docker compose -f docker/docker-compose.yml up --build -d

echo 'Finish!!!'