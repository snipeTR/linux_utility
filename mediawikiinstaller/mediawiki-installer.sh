#!/bin/bash
# set -e : herhangi bir komut hata verdiğinde scripti sonlandırır.
# set -u : tanımlanmamış değişken kullanımını hata olarak kabul eder.
set -euo pipefail

##############################
# Konfigürasyon ve Loglama   #
##############################

LOG_FILE="/var/log/mediawiki_install.log"
if ! sudo touch "$LOG_FILE" || ! sudo chmod 666 "$LOG_FILE"; then
    echo "Log dosyası oluşturulamıyor: $LOG_FILE. Lütfen yazma izinlerini kontrol edin." >&2
    exit 1
fi
exec > >(tee -a "$LOG_FILE") 2>&1

# ANSI renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

##############################
# Yardım / Kullanım Bilgisi   #
##############################
usage() {
    echo -e "${GREEN}MediaWiki Otomatik Kurulum Scripti${NC}"
    echo "Kullanım: $0 [-y] [-h]"
    echo "   -y  : Non-interactive mod (varsayılan değerler kullanılır)."
    echo "   -h  : Yardım mesajını gösterir."
    exit 0
}

##############################
# Hata Yönetimi ve Temizlik  #
##############################
handle_error() {
    echo -e "${RED}Hata oluştu: $1${NC}"
    echo -e "${YELLOW}Detaylar için logları kontrol edin: $LOG_FILE${NC}"
    exit 1
}

cleanup() {
    echo -e "${YELLOW}Temizlik yapılıyor...${NC}"
    [ -f /tmp/mediawiki.tar.gz ] && sudo rm -f /tmp/mediawiki.tar.gz
}
trap cleanup EXIT
trap 'handle_error "Kullanıcı tarafından kesildi."' SIGINT SIGTERM

##############################
# Mimari Tespiti             #
##############################
detect_architecture() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)    ARCH_LABEL="x86_64" ;;
        aarch64)   ARCH_LABEL="ARM64" ;;
        arm*)      ARCH_LABEL="ARM" ;;
        *)         ARCH_LABEL="Bilinmeyen ($ARCH)" ;;
    esac
    echo -e "${YELLOW}Mimari tespit edildi: $ARCH_LABEL${NC}"
}

##############################
# Bağımlılık Kurulumu         #
##############################
install_dependencies() {
    echo -e "${YELLOW}Sistem güncelleniyor...${NC}"
    sudo apt update -qq || handle_error "apt update başarısız."
    sudo apt upgrade -y -qq || handle_error "apt upgrade başarısız."

    echo -e "${YELLOW}Gerekli paketler kuruluyor...${NC}"
    # PHP versiyonu daha sonra global değişkende tanımlanacak (PHP_VER)
    sudo apt install -y -qq \
        apache2 \
        mysql-server \
        mysql-client \
        php${PHP_VER} \
        libapache2-mod-php${PHP_VER} \
        php${PHP_VER}-mysql \
        php${PHP_VER}-xml \
        php${PHP_VER}-mbstring \
        php${PHP_VER}-curl \
        php${PHP_VER}-zip \
        php${PHP_VER}-gd \
        php${PHP_VER}-intl \
        php${PHP_VER}-apcu \
        wget \
        tar \
        lsb-release \
        sudo || handle_error "Gerekli paketlerin kurulumu başarısız."

    # Opsiyonel: Certbot kurulumu (SSL için)
    sudo apt install -y -qq certbot || echo -e "${YELLOW}Certbot kurulamadı, devam ediliyor...${NC}"

    # MySQL servisini başlatmaya çalışıyoruz
    sudo systemctl start mysql || echo -e "${YELLOW}MySQL servisi başlatılamadı, lütfen kontrol edin...${NC}"
}

##############################
# Kullanıcı Girdileri         #
##############################
collect_user_input() {
    if [ "$NONINTERACTIVE" -eq 1 ]; then
        DB_NAME="mediawiki"
        DB_USER="wiki_user"
        DB_PASS="wiki_pass"  # Güvenlik için non-interactive modda değiştirebilirsiniz.
        DB_HOST="localhost"
        SERVER_NAME="wiki.example.com"
    else
        read -p "Veritabanı adı (default: mediawiki): " DB_NAME
        DB_NAME=${DB_NAME:-mediawiki}

        read -p "Veritabanı kullanıcı adı (default: wiki_user): " DB_USER
        DB_USER=${DB_USER:-wiki_user}

        while true; do
            read -sp "Veritabanı şifresi: " DB_PASS
            echo
            if [ -n "$DB_PASS" ]; then
                break
            else
                echo -e "${RED}Şifre boş olamaz. Lütfen geçerli bir şifre giriniz.${NC}"
            fi
        done

        read -p "Veritabanı sunucusu (default: localhost): " DB_HOST
        DB_HOST=${DB_HOST:-localhost}

        while true; do
            read -p "Sunucu alan adı/IP (örn: wiki.example.com): " SERVER_NAME
            if [ -n "$SERVER_NAME" ]; then
                break
            else
                echo -e "${RED}Sunucu adı/IP boş olamaz.${NC}"
            fi
        done
    fi
}

##############################
# Girdi Doğrulama            #
##############################
validate_input() {
    # Giriş değerlerini baştaki/sondaki boşluklardan ve varsa CR karakterlerinden temizliyoruz.
    DB_NAME="$(echo "$DB_NAME" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    DB_USER="$(echo "$DB_USER" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    DB_PASS="$(echo "$DB_PASS" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    DB_HOST="$(echo "$DB_HOST" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    SERVER_NAME="$(echo "$SERVER_NAME" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

    # Yalnızca alfanümerik ve alt çizgi karakterlerine izin veriyoruz.
    if ! [[ "$DB_NAME" =~ ^[[:alnum:]_]+$ ]]; then
        handle_error "Geçersiz veritabanı adı: $DB_NAME"
    fi
    if ! [[ "$DB_USER" =~ ^[[:alnum:]_]+$ ]]; then
        handle_error "Geçersiz veritabanı kullanıcı adı: $DB_USER"
    fi

    if [ "${#DB_PASS}" -lt 6 ]; then
        handle_error "Veritabanı şifresi en az 6 karakter olmalıdır."
    fi

    # MySQL servisine bağlanıp bağlanamadığımızı kontrol ediyoruz.
    if ! mysqladmin ping -h "$DB_HOST" --silent; then
        handle_error "Veritabanı sunucusuna ($DB_HOST) bağlanılamıyor."
    fi
}

##############################
# Kurulum Özeti              #
##############################
show_summary() {
    echo -e "${GREEN}"
    echo "================ KURULUM ÖZETİ ================"
    echo " İşletim Sistemi:      $OS $OS_VER"
    echo " Mimari:               $ARCH_LABEL"
    echo " PHP Versiyonu:        $PHP_VER"
    echo " MediaWiki Versiyonu:  $MW_VER"
    echo " Veritabanı:"
    echo "   - Adı:              $DB_NAME"
    echo "   - Kullanıcı:        $DB_USER"
    echo "   - Sunucu:           $DB_HOST"
    echo " Sunucu Adı/IP:         $SERVER_NAME"
    echo "================================================"
    echo -e "${NC}"

    if [ "$NONINTERACTIVE" -eq 0 ]; then
        read -p "Kuruluma devam etmek istiyor musunuz? (E/H) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ee]$ ]]; then
            echo "Kurulum iptal edildi."
            exit 0
        fi
    else
        echo "Non-interactive modda varsayılan değerler kullanılarak kuruluma devam ediliyor..."
    fi
}

##############################
# Veritabanı Kurulumu         #
##############################
setup_database() {
    echo -e "${YELLOW}Veritabanı yapılandırılıyor...${NC}"
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" || handle_error "Veritabanı oluşturulamadı."
    sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';" || handle_error "Kullanıcı oluşturulamadı."
    sudo mysql -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'$DB_HOST';" || handle_error "Yetkilendirme hatası."
    sudo mysql -e "GRANT PROCESS ON *.* TO '$DB_USER'@'localhost';" || handle_error "GRANT PROCESS komutu başarısız."
    sudo mysql -e "FLUSH PRIVILEGES;" || handle_error "Privilege flush hatası."
}

##############################
# MediaWiki Kurulumu         #
##############################
install_mediawiki() {
    echo -e "${YELLOW}MediaWiki indiriliyor...${NC}"
    wget -q "$MW_URL" -O /tmp/mediawiki.tar.gz || handle_error "MediaWiki indirme hatası."
    echo -e "${YELLOW}Dosyalar çıkarılıyor...${NC}"
    if [ -d /var/www/html/mediawiki ]; then
        echo -e "${YELLOW}/var/www/html/mediawiki dizini mevcut. Yedeklemek için taşınıyor...${NC}"
        sudo mv /var/www/html/mediawiki "/var/www/html/mediawiki_$(date +%s)" || handle_error "Mevcut dizin yedeklenemedi."
    fi
    sudo tar -xzf /tmp/mediawiki.tar.gz -C /var/www/html/ || handle_error "Dosya çıkarma hatası."
    if [ -d /var/www/html/mediawiki-"$MW_VER" ]; then
        sudo mv /var/www/html/mediawiki-"$MW_VER" /var/www/html/mediawiki || handle_error "Dizin taşıma hatası."
    else
        handle_error "Beklenen dizin /var/www/html/mediawiki-$MW_VER bulunamadı."
    fi
    echo -e "${YELLOW}İzinler ayarlanıyor...${NC}"
    sudo chown -R www-data:www-data /var/www/html/mediawiki || handle_error "İzin ayarlama hatası."
    sudo chmod -R 755 /var/www/html/mediawiki || handle_error "İzin ayarlama hatası."
}

##############################
# Komut Satırı Parametreleri  #
##############################
NONINTERACTIVE=0
while getopts ":yh" opt; do
    case ${opt} in
        y ) NONINTERACTIVE=1 ;;
        h ) usage ;;
        \? )
            echo "Bilinmeyen seçenek: -$OPTARG" >&2
            usage ;;
    esac
done
shift $((OPTIND -1))

##############################
# Sistem Bilgileri ve Versiyonlar #
##############################
detect_architecture
if command -v lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -is)
    OS_VER=$(lsb_release -rs)
else
    OS=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
    OS_VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
fi
PHP_VER="8.1"
MW_VER="1.43.0"
MW_URL="https://releases.wikimedia.org/mediawiki/${MW_VER%.*}/mediawiki-${MW_VER}.tar.gz"

##############################
# Ana Kurulum İşlemleri       #
##############################
install_dependencies
collect_user_input
validate_input
show_summary
setup_database
install_mediawiki
echo -e "${GREEN}MediaWiki kurulumu başarıyla tamamlandı!${NC}"
