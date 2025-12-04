#!/bin/bash

# ==============================================================================
# VOID LINUX POST-INSTALL SCRIPT (XFCE + i3 + Stow Edition)
# ==============================================================================

# Parar o script se algum comando der erro
set -e

echo ">>> Iniciando a instalação e configuração..."

# 1. ATUALIZAÇÃO DO SISTEMA
# ==============================================================================
echo ">>> Atualizando repositórios e sistema..."
sudo xbps-install -Syu
sudo xbps-install -u xbps
sudo xbps-install -S void-repo-nonfree void-repo-multilib

# 2. INSTALAÇÃO DE PACOTES (BINÁRIOS)
# ==============================================================================

PACKAGES="
xorg-minimal xorg-fonts
xfce4 xfce4-goodies xfce4-timer-plugin gnome-calculator
i3 i3status rofi nitrogen arandr lxappearance picom
pulseaudio-utils pavucontrol pipewire wireplumber
bluez blueman
zsh git curl wget make cmake gcc ncdu rsync
neovim tmux stow xclip tree mise clang llvm lld clang-tools-extra
gimp obs audacity kdenlive vlc qbittorrent zathura zathura-pdf-mupdf vscode gearlever
bat eza 
ntfs-3g smartmontools 7zip rsync parted xz
noto-fonts-ttf noto-fonts-emoji font-hack-ttf nerd-fonts
"

echo ">>> Instalando pacotes principais..."
sudo xbps-install -S $PACKAGES -y

# Baixando AppImage utilizados e organizando-os
APPIMAGE_DIR="$HOME/AppImage"
if [ ! -d "$APPIMAGE_DIR" ]; then
    mkdir -p "$APPIMAGE_DIR"
fi

cd "$APPIMAGE_DIR" || exit
URLS="
https://github.com/jgraph/drawio-desktop/releases/download/v29.3.6/drawio-x86_64-29.3.6.AppImage
"
for URL in $URLS; do
    FILE_NAME=$(basename "$URL")
    wget -N "$URL"
    gearlever --integrate "$FILE_NAME" -y
done

QTSCRCPY_DIR="$HOME/Applications/QtScrcpy"
if [ ! -d "$QTSCRCPY_DIR" ]; then
    mkdir -p "$QTSCRCPY_DIR"
fi

QTSCRCPY_URL="https://github.com/barry-ran/QtScrcpy/releases/download/v3.3.3/QtScrcpy-ubuntu-20.04-gcc_64.AppImage"
cd ~/Applications
chmod +x QtScrcpy-ubuntu-20.04-gcc_64.AppImage
./QtScrcpy-ubuntu-20.04-gcc_64.AppImage --appimage-extract
rm QtScrcpy-ubuntu-20.04-gcc_64.AppImage
mv squashfs-root "$QTRSCPY_DIR"


# 3. CONFIGURAÇÃO DO SHELL (ZSH)
# ==============================================================================
echo ">>> Configurando ZSH..."

# Mudar shell padrão para Zsh (se já não for)
if [ "$SHELL" != "/bin/zsh" ]; then
    echo "Mudando shell padrão para zsh..."
    chsh -s $(which zsh)
fi

# Instalar plugins do Zsh (Apenas baixar, a config está no .zshrc do Stow)
ZSH_PLUGINS="$HOME/.local/share/zsh/plugins"
mkdir -p "$ZSH_PLUGINS"

# Powerlevel10k
if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

# Auto-suggestions
if [ ! -d "$ZSH_PLUGINS/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS/zsh-autosuggestions"
fi

# Syntax-highlighting
if [ ! -d "$ZSH_PLUGINS/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS/zsh-syntax-highlighting"
fi

# 4. APLICAR DOTFILES (STOW)
# ==============================================================================
echo ">>> Aplicando Dotfiles com Stow..."

REPO_URL="https://github.com/DiogoDomi/dotfiles.git"
DOTFILES_DIR="$HOME/zMy/.dotfiles"

if [! -d $"DOTFILES_DIR" ]; then
    echo "Dotfiles não encontrados. Clonando de $REPO_URL..."
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone "REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles já existem. Atualizando..."
    cd "$DOTFILES_DIR" && git pull
fi

cd "$DOTFILES_DIR"

echo " Preparando estrutura do VS Code..."
mkdir -p "$HOME/.config/Code - OSS/User/profiles"

if [ ! -L "$HOME/.config/Code" ] && [ ! -d "$HOME/.config/Code" ]; then
    ln -s "$HOME/.config/Code - OSS" "$HOME/.config/Code"
fi

echo "Limpando configs padrão antigas..."
rm -rf ~/.zshrc ~/.p10k.zsh ~/.gitconfig
rm -rf ~/.config/i3 ~/.config/nvim ~/.config/xfce4 ~/.config/picom.conf

rm -f "$HOME/.config/Code - OSS/User/settings.json"
rm -f "$HOME/.config/Code - OSS/User/keybindings.json"

echo "Aplicando Stow..."
stow -v -t ~ zsh git i3 nvim xfce4 vscode assets backgrounds

# 5. PACOTES RESTRITOS (XBPS-SRC)
# ==============================================================================
echo ">>> Verificando pacotes restritos (xbps-src)..."

if [ ! -d "$HOME/void-packages" ]; then
    cd ~
    git clone --depth=1 https://github.com/void-linux/void-packages.git
    cd void-packages
    ./xbps-src binary-bootstrap
    echo "XBPS_ALLOW_RESTRICTED=yes" >> etc/conf
fi

# Função para instalar via xbps-src
install_src_pkg() {
    if ! xbps-query -l | grep -q "$1"; then
        echo "Compilando e instalando $1..."
        cd ~/void-packages
        ./xbps-src pkg "$1"
        sudo xbps-install --repository hostdir/binpkgs "$1" -y
    else
        echo "$1 já está instalado."
    fi
}

install_src_pkg discord
install_src_pkg spotify

# 6. SERVIÇOS E ÁUDIO
# ==============================================================================
echo ">>> Habilitando serviços essenciais..."

# Função para linkar serviços
enable_service() {
    if [ ! -L "/var/service/$1" ]; then
        sudo ln -s "/etc/sv/$1" /var/service/
        echo "Serviço $1 habilitado."
    else
        echo "Serviço $1 já estava ativo."
    fi
}

enable_service dbus
enable_service bluetoothd
enable_service NetworkManager 

# 7. FINALIZAÇÃO
# ==============================================================================
echo "----------------------------------------------------------------"
echo "INSTALAÇÃO CONCLUÍDA!"
echo "----------------------------------------------------------------"
