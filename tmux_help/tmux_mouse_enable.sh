#!/bin/bash

# ================================
# Tmux Mouse Enable Script
# ================================

# ================================
# Linux Dağıtım ve Paket Yöneticisi Kontrolü
# ================================

# Paket yöneticisini belirle
detect_package_manager() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo "Linux dağıtımı belirlenemedi. Manuel olarak yükleme yapın."
        exit 1
    fi

    case $OS in
        ubuntu|debian)
            PACKAGE_MANAGER="apt-get"
            UPDATE_CMD="sudo apt-get update"
            INSTALL_CMD="sudo apt-get install -y"
            ;;
        fedora|centos|rhel)
            PACKAGE_MANAGER="dnf"
            UPDATE_CMD="sudo dnf check-update"
            INSTALL_CMD="sudo dnf install -y"
            ;;
        arch|manjaro)
            PACKAGE_MANAGER="pacman"
            UPDATE_CMD="sudo pacman -Syu --noconfirm"
            INSTALL_CMD="sudo pacman -S --noconfirm"
            ;;
        opensuse|sles)
            PACKAGE_MANAGER="zypper"
            UPDATE_CMD="sudo zypper refresh"
            INSTALL_CMD="sudo zypper install -y"
            ;;
        *)
            echo "Bu dağıtım desteklenmiyor: $OS"
            exit 1
            ;;
    esac
    echo "Dağıtım: $OS, Sürüm: $VERSION"
    echo "Paket yöneticisi: $PACKAGE_MANAGER"
}

# Paket yükleme işlemi
install_dependencies() {
    echo "Bağımlılıklar yükleniyor..."
    $UPDATE_CMD
    $INSTALL_CMD tmux xclip || $INSTALL_CMD xsel
}

# ================================
# Tmux Kurulu Mu Kontrol Et
# ================================

if ! command -v tmux &> /dev/null; then
    echo "Tmux kurulu değil. Kurulum başlatılıyor..."
    detect_package_manager
    install_dependencies
else
    echo "Tmux zaten kurulu."
fi

# xclip veya xsel kurulu mu kontrol et
if ! command -v xclip &> /dev/null && ! command -v xsel &> /dev/null; then
    echo "xclip veya xsel kurulu değil. Yükleniyor..."
    detect_package_manager
    install_dependencies
else
    echo "xclip veya xsel zaten kurulu."
fi

# ================================
# Tmux Yapılandırma Dosyasını Ayarla
# ================================

TMUX_CONF="$HOME/.tmux.conf"

# Yedek oluştur (varsa)
if [ -f "$TMUX_CONF" ]; then
    echo "Mevcut .tmux.conf dosyası yedekleniyor..."
    cp "$TMUX_CONF" "$HOME/.tmux.conf.bak"
fi

# Yeni yapılandırmayı ekle
cat <<EOL > "$TMUX_CONF"
# Mouse Desteği Açık
set -g mouse on

# Terminal'in doğal kopyalama/yapıştırma işlevini koru
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "xclip -in -selection clipboard"
EOL

echo ".tmux.conf dosyası güncellendi."

# ================================
# Tmux Yapılandırmasını Yeniden Yükle
# ================================

# Eğer tmux oturumu açıksa yapılandırmayı yenile
if tmux list-sessions &> /dev/null; then
    echo "Tmux yapılandırması yeniden yükleniyor..."
    tmux source-file "$TMUX_CONF"
else
    echo "Tmux oturumu bulunamadı. Yeni oturum açınca yapılandırma aktif olacak."
fi

# İşlem tamamlandı
echo "Tmux mouse desteği ve doğal kopyalama/yapıştırma başarıyla etkinleştirildi! 🎉"
