#!/bin/bash

# Exit immediately on error, unset variable, and pipeline failure
set -euo pipefail

# Update system and install base utilities
echo "Updating system and installing base packages..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    gnupg \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    terminator \
    vlc \
    gdebi \
    libfuse2

# Extra system, productivity, and dev tools
echo "Installing extra system, productivity, and dev tools..."
sudo apt install -y \
    htop \
    neofetch \
    tmux \
    nmap \
    gparted \
    flameshot \
    obs-studio \
    zsh \
    tree \
    unzip \
    ffmpeg \
    jq

# Install Oh My Zsh for better shell experience
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
fi

# Add repositories and keys
echo "Setting up repositories and keys..."

# Brave Browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] \
    https://brave-browser-apt-release.s3.brave.com/ stable main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | \
    sudo tee /usr/share/keyrings/vscode.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list

# Spotify
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | \
    sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | \
    sudo tee /etc/apt/sources.list.d/spotify.list

# Node.js (LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Update package lists after adding repositories
echo "Updating package lists..."
sudo apt update -y

# Install main applications
echo "Installing main applications..."
sudo apt install -y \
    brave-browser \
    code \
    spotify-client \
    nodejs \
    build-essential

# Development tools
echo "Installing development tools..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    docker.io \
    docker-compose

# Configure Python alternatives
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Python global packages
pip install --upgrade pip
pip install \
    requests \
    pandas \
    numpy \
    virtualenv

# Configure Docker
echo "Configuring Docker..."
sudo systemctl enable docker
sudo usermod -aG docker "$USER"

# Install Snap packages
echo "Installing Snap packages..."
sudo snap install pycharm-community --classic
sudo snap install postman
sudo snap install telegram-desktop
sudo snap install discord
sudo snap install slack --classic

# Install Skype
echo "Installing Skype..."
wget -O skype.deb https://go.skype.com/skypeforlinux-64.deb
sudo gdebi -n skype.deb
rm skype.deb

# System cleanup
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# Post-install messages
echo "Installation complete!"
echo "Please restart your session for Docker group changes to take effect."
echo "Installed applications:"
echo "- Brave Browser, VS Code, Spotify, Node.js $(node -v), Python $(python --version)"
echo "- Docker $(docker --version), PyCharm, Postman, Telegram, Discord"
