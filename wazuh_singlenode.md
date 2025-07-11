# 🛡️ Deploy a Single-Node Wazuh Stack using Docker

This guide walks you through deploying Wazuh's official [single-node Docker container](https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html) on a Linux system.

---

## ✅ Requirements

- Docker Engine & Docker Compose installed
- Internet connection
- Basic Linux terminal knowledge

---

## 🧱 Step 1: Clone the Official Wazuh Docker Repository
Create a workspace directory and clone the repo:

```bash
mkdir -p ~/docker
cd ~/docker
git clone https://github.com/wazuh/wazuh-docker.git -b v4.12.0
cd wazuh-docker/single-node
```

# You should now see the following structure:
```  .
├── config/
├── docker-compose.yml
├── generate-indexer-certs.yml
└── README.md
```
## 🔐 Step 2: Generate TLS Certificates
This step creates the necessary Elasticsearch indexer certificates:
``` 
docker compose -f generate-indexer-certs.yml run --rm generator
```
## 🚀 Step 3: Start Wazuh Stack
Now bring up the full stack in detached mode:
```
docker compose up -d
```
Docker will now pull and deploy:
• Wazuh Manager
• Filebeat
• Elasticsearch
• Kibana
• NGINX

## 🌍 Accessing the Wazuh Web Interface
Once all containers are up, access the dashboard in your browser: <br>
🧑‍💻 Default Credentials:
```
Username: admin
Password: SecretPassword (default, change it!)
```
## 📌 Notes
Firewall: Ensure ports 443, 1514, 1515, 55000 are open if remote agents will connect. <br>
Resources: Wazuh can be resource-hungry. <br>
Minimum 4GB RAM recommended. <br>
Persistence: Data volumes are already configured in the docker-compose.yml. <br>
