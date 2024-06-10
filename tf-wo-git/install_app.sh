#!/bin/bash
mkdir /app
cd /app

cat << EOF > /app/docker-compose.yaml
version: '3.8'

services:
  app:
    build: ./python

  nginx:
    build: ./nginx
    ports:
      - "80:80"
    depends_on:
      - app
EOF

mkdir /app/nginx

cat << EOF > /app/nginx/Dockerfile
FROM nginx:latest
COPY nginx.conf /etc/nginx/nginx.conf
EOF

cat << \EOF >> /app/nginx/nginx.conf
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;

        location / {
            proxy_pass http://app:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

mkdir /app/python

cat << EOF > /app/python/requirements.txt
Flask
requests
EOF

cat << EOF > /app/python/Dockerfile
FROM python:3.9-slim

WORKDIR /usr/src/app
COPY app.py ./app.py
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080

CMD ["python", "app.py"]
EOF

cat << EOF > /app/python/app.py
from flask import Flask, request
import requests

app = Flask(__name__)

@app.route('/<user>/<repo>', methods=['GET'])
def get_latest_release(user, repo):
    url = f'https://api.github.com/repos/{user}/{repo}/releases/latest'
    response = requests.get(url)

    if response.status_code == 200:
        release_info = response.json()
        return release_info.get('tag_name', 'No release found')
    else:
        return ('error: Repository not found'), response.status_code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

cat << EOF > /app/run.sh
#!/bin/bash
# Install docker and docker-compose by https://docs.docker.com/engine/install/ubuntu/
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Start the application
sudo docker compose up -d
EOF

sudo chmod +x /app/run.sh
sudo /app/run.sh

