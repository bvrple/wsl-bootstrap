#!/usr/bin/env bash
set -e

echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installing essentials ==="
sudo apt install -y build-essential curl wget git unzip zip htop software-properties-common \
apt-transport-https ca-certificates gnupg lsb-release sudo file lsb-release

# -------------------------------------------------------
# Step 1: Install Homebrew (Linuxbrew)
# -------------------------------------------------------
echo "=== Installing Homebrew ==="
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# -------------------------------------------------------
# Step 2: Install Nushell
# -------------------------------------------------------
echo "=== Installing Nushell ==="
brew install nushell

# Set Nushell as default shell
echo "=== Setting Nushell as default shell ==="
echo "$(which nu)" | sudo tee -a /etc/shells
chsh -s "$(which nu)"

# -------------------------------------------------------
# Step 3: Install Starship (Bash-safe)
# -------------------------------------------------------
echo "=== Installing Starship prompt ==="
brew install starship

# Create cache folder for starship init
mkdir -p ~/.cache/starship

# Save Starship Nushell init (to run later inside Nushell)
echo "echo 'Run the following command inside Nushell once:'"
echo "starship init nu | save -f ~/.cache/starship/init.nu"

# Add line to config.nu to use Starship (after you run the above inside Nushell)
mkdir -p ~/.config/nushell
echo 'use ~/.cache/starship/init.nu *' >> ~/.config/nushell/config.nu

# -------------------------------------------------------
# Step 4: Install SDKMAN + JDK21, Kotlin, Gradle
# -------------------------------------------------------
echo "=== Installing SDKMAN ==="
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

sdk install java 21.0.4-tem
sdk default java 21.0.4-tem
sdk install kotlin
sdk install gradle

# -------------------------------------------------------
# Step 5: Install Dagger, Docker, k3d, kubectl, Helm, ArgoCD, Terraform, GitHub CLI, Ngrok, Hetzner CLI
# -------------------------------------------------------
echo "=== Installing developer tools ==="
curl -L https://dl.dagger.io/dagger/install.sh | sh
sudo mv bin/dagger /usr/local/bin/

brew install k3d kubectl helm argocd terraform gh hcloud
brew install --cask ngrok
# -------------------------------------------------------
# Step 6: Install databases
# -------------------------------------------------------
echo "=== Installing PostgreSQL, Redis ==="
brew install postgresql redis
brew services start postgresql
brew services start redis

# -------------------------------------------------------
# Step 7: Nushell version checker
# -------------------------------------------------------
echo "=== Adding Nushell version checker ==="
cat << 'EOF' > ~/.config/nushell/versions.nu
def main [] {
  {
    java: (java -version | lines | first)
    kotlin: (kotlinc -version | str replace "@" "")
    gradle: (gradle --version | lines | first)
    docker: (docker --version)
    "docker compose": (docker-compose --version)
    k3d: (k3d version | lines | first)
    kubectl: (kubectl version --client=true -o yaml | lines | first)
    helm: (helm version --short)
    argocd: (argocd version --client --short)
    terraform: (terraform version | lines | first)
    gh: (gh --version | lines | first)
    ngrok: (ngrok version)
    hcloud: (hcloud version)
    postgres: (psql --version)
    redis-cli: (redis-cli --version)
    redis-server: (redis-server --version)
  }
}
EOF

# -------------------------------------------------------
# Step 8: Nushell aliases (including bsv for versions)
# -------------------------------------------------------
echo "=== Adding Nushell aliases ==="
cat << 'EOF' >> ~/.config/nushell/config.nu

# Aliases for faster CLI usage (alphabetical)
alias acd = argocd
alias bsv = nu ~/.config/nushell/versions.nu
alias d = docker
alias dc = docker-compose
alias gw = ./gradlew
alias hc = hcloud
alias k = kubectl
alias rc = redis-cli
alias rs = redis-server
alias t = terraform
EOF

echo "=== Bootstrap complete! ==="
echo "1. Restart your terminal (Nushell is now default shell)"
echo "2. Inside Nushell, run:"
echo "   starship init nu | save -f ~/.cache/starship/init.nu"
echo "   (then reopen Nushell to have Starship active)"
echo "3. Run 'bsv' to see versions table once everything is ready"
