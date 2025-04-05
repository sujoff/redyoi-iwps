```markdown
# IWPMS Deployment

## Overview
- Web-based app for work permit management on Ubuntu 24.04.1 LTS.

## Infrastructure
- Web Server: 'appserver2' (192.168.8.72)
- Database Server: 'database2' (192.168.8.79)
- Username: 'aramco'

## Pre-Requisites
- Ubuntu: 24.04.1 LTS
- MongoDB: 7.0.7
- Docker: 27.4.0
- Docker Buildx: 0.19.2
- Docker Compose: 2.31.0
- Mongo Shell: 2.2.0

## Setup

### Web Server ('appserver2')
1. Install Ubuntu 24.04.1 LTS.
2. Install Docker:
   ```bash
   sudo apt update && sudo apt install -y docker.io docker-buildx-plugin docker-compose-plugin
   sudo systemctl start docker && sudo systemctl enable docker
   sudo usermod -aG docker $USER
   ```
3. Create directory:
   ```bash
   mkdir /home/aramco/iwpms && cd /home/aramco/iwpms
   ```
4. Download artifacts: `iwpms_client.tar`, `iwpms_server.tar`, `files/`, `load_images.sh`, `start.sh`, `deploy.sh`, `app.prod.yml`.
5. Generate HTTPS certificates:
   ```bash
   cd /home/aramco/iwpms/files/cert
   openssl genrsa -out ca.key 2048
   openssl req -x509 -new -nodes -key ca.key -sha256 -days 1095 -out ca.crt -subj "/C=SA/ST=Riyadh/O=Aramco/CN=AramcoLocalCA"
   ```
6. Deploy:
   ```bash
   ./deploy.sh
   ```

### Database Server ('database2')
1. Install Ubuntu 24.04.1 LTS.
2. Install MongoDB:
   ```bash
   sudo apt update && sudo apt install -y mongodb-org=7.0.7
   sudo systemctl start mongod && sudo systemctl enable mongod
   ```
3. Install Mongo Shell:
   ```bash
   sudo apt install -y mongodb-mongosh
   ```
4. Open firewall:
   ```bash
   sudo ufw allow from 192.168.8.72 to any port 27017 proto tcp
   ```
5. Seed database:
   ```bash
   mongosh
   use iwpms
   db.getCollection('users').insertOne({...})
   ```

## Post-Deployment
1. Access: `https://192.168.8.72` (Email: `admin@dualroots.com`, Password: `Test123!`).
2. Delete temp admin:
   ```bash
   mongosh
   use iwpms
   db.getCollection('users').deleteOne({ 'NormalizedEmail': 'ADMIN@DUALROOTS.COM' })
   ```

## Cleanup
- ```bash
  docker compose -f app.prod.yml down
  ```

## Files
- `appsettings.json`, `nginx.conf`, `.gitignore`, `app.prod.yml`, `deploy.sh`, `load_images.sh`, `start.sh`, `iwpms_client.tar`, `iwpms_server.tar`
```