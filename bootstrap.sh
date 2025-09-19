#!/usr/bin/env bash

# =========================================
# WSL Dev Bootstrap Script (No Docker)
# =========================================

set -e

# --- 1. Update system ---
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget gnupg lsb-release software-properties-common apt-transport-https unzip zip htop git build-essential

# --- 2. Install Nushell ---
curl -LO https://github.com/nushell/nushell/releases/download/1.1.0/nu_1.1.0_amd64.deb
sudo dpkg -i nu_1.1.0_amd64.deb || sudo apt install -f -y
rm nu_1.1.0_amd64.deb

# --- 3. Install Starship ---
curl -sS https://starship.rs/install.sh | sh -s -- -y
mkdir -p ~/.config/nushell
echo 'starship init nu | save -f ~/.cache/starship/init.nu' >> ~/.config/nushell/config.nu

# --- 4. Install JDK 21 + Gradle ---
sudo apt install -y openjdk-21-jdk
wget https://services.gradle.org/distributions/gradle-8.4.1-bin.zip -P /tmp
sudo unzip -d /opt/gradle /tmp/gradle-8.4.1-bin.zip
rm /tmp/gradle-8.4.1-bin.zip
echo 'export PATH=$PATH:/opt/gradle/gradle-8.4.1/bin' >> ~/.profile
source ~/.profile

# --- 5. Install Kubernetes tools ---
## kubectl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

## k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

## Helm
curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg
sudo apt-get install apt-transport-https --yes
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm

## ArgoCD CLI
VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd
rm argocd

# --- 6. Install Terraform ---
sudo apt install -y gnupg software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform

# --- 7. Install databases ---
## PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable --now postgresql

## MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl enable --now mongod

## Redis
sudo apt install -y redis-server
sudo systemctl enable --now redis-server

# --- 8. Install Ngrok ---
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin/
rm ngrok-stable-linux-amd64.zip

# --- 9. Install Hetzner CLI ---
curl -sSfL https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz | tar -xz
sudo mv hcloud /usr/local/bin/

# --- 10. Setup Nushell aliases ---
cat << 'EOF' >> ~/.config/nushell/config.nu
alias acd = argocd
alias bsv = ~/.config/nushell/versions.nu
alias dc = docker-compose
alias d = docker
alias gw = ./gradlew
alias hc = hcloud
alias k = kubectl
alias m = mongo
alias md = mongod
alias rc = redis-cli
alias rs = redis-server
alias t = terraform
EOF

# --- 11. Create version check script (versions.nu) ---
cat << 'EOF' > ~/.config/nushell/versions.nu
open [
"Tool" "Version"
"docker" $(docker --version || echo "Using Docker Desktop")
"docker-compose" $(docker-compose --version || echo "Using Docker Desktop")
"kubectl" $(kubectl version --client --short)
"k3d" $(k3d version)
"helm" $(helm version --short)
"argocd" $(argocd version --client --short)
"terraform" $(terraform version | head -n1)
"postgresql" $(psql --version)
"mongodb" $(mongo --version | head -n1)
"redis" $(redis-server --version)
"java" $(java -version 2>&1 | head -n1)
"gradle" $(gradle --version | grep "Gradle")
]
EOF

echo "Bootstrap complete! Open Nushell and run 'bsv' to verify versions."
echo "Docker Desktop is expected to provide Docker and docker-compose functionality."
