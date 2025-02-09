#!/bin/bash

# ANSI renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Renk sıfırlama

# Hata yönetimi fonksiyonu
handle_error() {
    echo -e "${RED}Hata oluştu: $1${NC}"
    echo -e "${YELLOW}Detaylar için logları kontrol edin: /var/log/mediawiki_install.log${NC}"
    exit 1
}

# Sistem bilgilerini topla
OS=$(lsb_release -is)
OS_VER=$(lsb_release -rs)
PHP_VER="8.1"
MW_VER="1.43.0"
MW_URL="https://releases.wikimedia.org/mediawiki/${MW_VER%.*}/mediawiki-${MW_VER}.tar.gz"

# Kullanıcı girdilerini al
read -p "Veritabanı adı (default: mediawiki): " DB_NAME
DB_NAME=${DB_NAME:-mediawiki}

read -p "Veritabanı kullanıcı adı (default: wiki_user): " DB_USER
DB_USER=${DB_USER:-wiki_user}

read -sp "Veritabanı şifresi: " DB_PASS
echo

read -p "Veritabanı sunucusu (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Sunucu alan adı/IP (örn: wiki.example.com): " SERVER_NAME

# Girdi doğrulama
validate_input() {
    if ! [[ "$DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
        handle_error "Geçersiz veritabanı adı"
    fi
    
    if ! mysqladmin ping -h "$DB_HOST" --silent; then
        handle_error "Veritabanı sunucusuna bağlanılamıyor"
    fi
}

# Kurulum özeti göster
show_summary() {
    echo -e "${GREEN}"
    echo "================ KURULUM ÖZETİ ================"
    echo " İşletim Sistemi:      $OS $OS_VER"
    echo " PHP Versiyonu:        $PHP_VER"
    echo " MediaWiki Versiyonu:  $MW_VER"
    echo " Veritabanı:"
    echo "   - Adı:              $DB_NAME"
    echo "   - Kullanıcı:        $DB_USER"
    echo "   - Sunucu:           $DB_HOST"
    echo " Sunucu Adı:           $SERVER_NAME"
    echo "================================================"
    echo -e "${NC}"
    
    read -p "Kuruluma devam etmek istiyor musunuz? (E/H) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ee]$ ]]; then
        echo "Kurulum iptal edildi."
        exit 0
    fi
}

# Bağımlılık kurulumu
install_dependencies() {
    echo -e "${YELLOW}Sistem güncelleniyor...${NC}"
    sudo apt update -qq && sudo apt upgrade -y -qq || handle_error "Sistem güncellemesi başarısız"
    
    echo -e "${YELLOW}LAMP Stack kuruluyor...${NC}"
    sudo apt install -y -qq \
        apache2 \
        mysql-server \
        php$PHP_VER \
        libapache2-mod-php$PHP_VER \
        php$PHP_VER-mysql \
        php$PHP_VER-xml \
        php$PHP_VER-mbstring \
        php$PHP_VER-curl \
        php$PHP_VER-zip \
        php$PHP_VER-gd \
        php$PHP_VER-intl \
        php$PHP_VER-apcu \
        || handle_error "Paket kurulumu başarısız"
}

# Veritabanı kurulumu
setup_database() {
    echo -e "${YELLOW}Veritabanı yapılandırılıyor...${NC}"
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;" || handle_error "Veritabanı oluşturulamadı"
    sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';" || handle_error "Kullanıcı oluşturulamadı"
    sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';" || handle_error "Yetkilendirme hatası"
    sudo mysql -e "FLUSH PRIVILEGES;" || handle_error "Privilege flush hatası"
}

# MediaWiki kurulumu
install_mediawiki() {
    echo -e "${YELLOW}MediaWiki indiriliyor...${NC}"
    wget -q $MW_URL -O /tmp/mediawiki.tar.gz || handle_error "İndirme hatası"
    
    echo -e "${YELLOW}Dosyalar çıkarılıyor...${NC}"
    sudo tar -xzf /tmp/mediawiki.tar.gz -C /var/www/html/ || handle_error "Dosya çıkarma hatası"
    sudo mv /var/www/html/mediawiki-$MW_VER /var/www/html/mediawiki || handle_error "Dizin taşıma hatası"
    
    echo -e "${YELLOW}İzinler ayarlanıyor...${NC}"
    sudo chown -R www-data:www-data /var/www/html/mediawiki || handle_error "İzin ayarlama hatası"
    sudo chmod -R 755 /var/www/html/mediawiki || handle_error "İzin ayarlama hatası"
}

# Apache yapılandırması
configure_apache() {
    echo -e "${YELLOW}Apache yapılandırılıyor...${NC}"
    sudo tee /etc/apache2/sites-available/mediawiki.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $SERVER_NAME
    DocumentRoot /var/www/html/mediawiki

    <Directory /var/www/html/mediawiki>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    sudo a2ensite mediawiki.conf > /dev/null
    sudo a2dissite 000-default.conf > /dev/null
    sudo a2enmod rewrite > /dev/null
    sudo systemctl restart apache2 || handle_error "Apache yeniden başlatma hatası"
}

# SSL Sertifikası
configure_ssl() {
    read -p "SSL sertifikası kurmak istiyor musunuz? (Let's Encrypt) (E/H) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ee]$ ]]; then
        echo -e "${YELLOW}SSL sertifikası kuruluyor...${NC}"
        sudo apt install -y -qq certbot python3-certbot-apache || handle_error "Certbot kurulum hatası"
        sudo certbot --apache -d $SERVER_NAME --non-interactive --agree-tos --redirect || handle_error "SSL sertifika hatası"
    fi
}

# Son kontrol
final_check() {
    echo -e "${GREEN}"
    echo "================ KURULUM TAMAMLANDI ================"
    echo " MediaWiki erişim adresi: http://$SERVER_NAME"
    echo " Veritabanı Bilgileri:"
    echo "   - Adı: $DB_NAME"
    echo "   - Kullanıcı: $DB_USER"
    echo "   - Şifre: ********"
    echo "====================================================="
    echo -e "${NC}"
}

# Ana iş akışı
main() {
    clear
    echo -e "${GREEN}MediaWiki Otomatik Kurulum Scripti${NC}"
    echo "========================================"
    
    validate_input
    show_summary
    install_dependencies
    setup_database
    install_mediawiki
    configure_apache
    configure_ssl
    final_check
}

# Scripti çalıştır
main "$@"
