#!/bin/bash

# ================================
# Tmux Mouse Enable Script
# ================================

# Gereken bağımlılıkları yükleme fonksiyonu
install_dependencies() {
    echo "Bağımlılıklar yükleniyor..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update
        sudo apt-get install -y tmux xclip
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y tmux xclip
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -Syu --noconfirm tmux xclip
    else
        echo "Desteklenmeyen paket yöneticisi. Manuel olarak tmux ve xclip yükleyin."
        exit 1
    fi
}

# Tmux kurulu mu kontrol et
if ! command -v tmux &> /dev/null; then
    echo "Tmux kurulu değil. Kurulum başlatılıyor..."
    install_dependencies
else
    echo "Tmux zaten kurulu."
fi

# xclip veya xsel kurulu mu kontrol et
if ! command -v xclip &> /dev/null && ! command -v xsel &> /dev/null; then
    echo "xclip veya xsel kurulu değil. Yükleniyor..."
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
