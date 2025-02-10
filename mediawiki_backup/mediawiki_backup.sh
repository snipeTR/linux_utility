#!/bin/bash
# MediaWiki Yedekleme ve Geri Yükleme Aracı - Geliştirilmiş Versiyon
#
# Bu betik:
# - LocalSettings.php'den veritabanı ayarlarını otomatik olarak çeker.
# - Veritabanı için SQL dump oluşturur.
# - MediaWiki dosyalarını geçici bir dizinde toplar,
#   ardından tüm içeriği "saatdakikasaniye_YYYY-MM-DD_yedek.tar.gz" formatında BACKUP_DIR'ye paketler.
# - Geri yükleme işleminde, kullanıcı mevcut yedek arşivlerinden seçim yapar;
#   seçilen arşiv geçici bir dizine çıkarılarak SQL dump kullanılarak veritabanı geri yüklenir,
#   dosyalar rsync ile kopyalanır.

#########################################
# Ayarlar - Lütfen sisteminize göre kontrol ediniz
#########################################
MEDIAWIKI_DIR="/var/www/html/mediawiki"  # MediaWiki kurulum yolu
BACKUP_DIR="backup"                        # Yedeklerin saklanacağı klasör

# Betik, yalnızca MEDIAWIKI_DIR dizininde çalıştırılmalıdır.
if [ "$(pwd)" != "$MEDIAWIKI_DIR" ]; then
    echo "Betiği lütfen $MEDIAWIKI_DIR dizininde çalıştırın!"
    exit 1
fi

#########################################
# DB Ayarlarını LocalSettings.php'den Çekelim
#########################################
LOCALSETTINGS="$MEDIAWIKI_DIR/LocalSettings.php"
if [ ! -f "$LOCALSETTINGS" ]; then
    echo "LocalSettings.php bulunamadı! Lütfen MediaWiki dizininde olduğunuzdan emin olun."
    exit 1
fi

# Aşağıdaki komutlar, LocalSettings.php dosyasındaki ayar satırlarının biçimine bağlıdır.
DB_SERVER=$(grep "^\$wgDBserver" "$LOCALSETTINGS" | head -n1 | cut -d'"' -f2)
DB_NAME=$(grep "^\$wgDBname" "$LOCALSETTINGS" | head -n1 | cut -d'"' -f2)
DB_USER=$(grep "^\$wgDBuser" "$LOCALSETTINGS" | head -n1 | cut -d'"' -f2)
DB_PASS=$(grep "^\$wgDBpassword" "$LOCALSETTINGS" | head -n1 | cut -d'"' -f2)

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo "Veritabanı ayarları çekilemedi. Lütfen LocalSettings.php dosyasını kontrol edin."
    exit 1
fi

# Eğer DB_SERVER tanımlı ise, mysqldump ve mysql komutlarında kullanılacak opsiyonları ayarlayalım:
if [ -n "$DB_SERVER" ]; then
    MYSQL_OPTS="--host=$DB_SERVER --user=$DB_USER --password=$DB_PASS --skip-lock-tables"
else
    MYSQL_OPTS="-u $DB_USER -p$DB_PASS"
fi

#########################################
# Gerekli Komutların Varlığı Kontrol Ediliyor (mysqldump, mysql, tar, rsync)
#########################################
check_dependencies() {
    MISSING_PKGS=()
    for cmd in mysqldump mysql tar rsync; do
        if ! command -v $cmd >/dev/null 2>&1; then
            MISSING_PKGS+=("$cmd")
        fi
    done
    if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
        echo "Gerekli paket(ler) bulunamadı: ${MISSING_PKGS[@]}"
        echo "Lütfen yukarıdaki komutları sağlayan paketleri yükleyin."
        exit 1
    fi
}
check_dependencies

#########################################
# Yedekleme Fonksiyonu
#########################################
backup_wiki() {
    # Zaman damgası: HHMMSS_YYYY-MM-DD_yedek.tar.gz formatında isimlendirme
    TIMESTAMP=$(date +"%H%M%S_%Y-%m-%d")
    ARCHIVE_NAME="${TIMESTAMP}_yedek.tar.gz"

    # Geçici yedekleme dizini oluşturuluyor
    TEMP_DIR="temp_backup"
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR/files"

    echo "Veritabanı yedekleniyor..."
    mysqldump $MYSQL_OPTS "$DB_NAME" > "$TEMP_DIR/db_backup.sql" || {
        echo "Veritabanı yedekleme hatası!"; exit 1;
    }

    echo "Dosyalar yedekleniyor..."
    # MediaWiki dosyalarını, BACKUP_DIR ve TEMP_DIR hariç, temp_backup/files altına kopyalıyoruz.
    rsync -av --exclude="$BACKUP_DIR" --exclude="$TEMP_DIR" . "$TEMP_DIR/files" || {
        echo "Dosya yedekleme hatası!"; exit 1;
    }

    # BACKUP_DIR yoksa oluşturuluyor
    [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"

    echo "Yedek arşivi oluşturuluyor: $ARCHIVE_NAME"
    tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$TEMP_DIR" . || {
        echo "Arşiv oluşturulurken hata oluştu!"; exit 1;
    }

    rm -rf "$TEMP_DIR"
    echo "Yedekleme tamamlandı: ${BACKUP_DIR}/${ARCHIVE_NAME}"
}

#########################################
# Geri Yükleme Fonksiyonu
#########################################
restore_wiki() {
    echo "Mevcut yedek arşivleri:"
    local backups=()
    local index=1
    for backup in "${BACKUP_DIR}"/*_yedek.tar.gz; do
        if [ -f "$backup" ]; then
            backups+=("$backup")
            echo "${index}) $(basename "$backup")"
            ((index++))
        fi
    done

    if [ ${#backups[@]} -eq 0 ]; then
        echo "Yedek bulunamadı!"
        exit 1
    fi

    read -p "Yüklenecek yedeğin numarasını girin: " choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backups[@]}" ]; then
        echo "Geçersiz seçim!"; exit 1;
    fi

    selected="${backups[$((choice-1))]}"
    read -p "$(basename "$selected") yedeği yüklenecek. Emin misiniz? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        echo "İptal edildi."; exit 0;
    fi

    # Geçici geri yükleme dizini oluşturuluyor
    RESTORE_DIR="temp_restore"
    [ -d "$RESTORE_DIR" ] && rm -rf "$RESTORE_DIR"
    mkdir -p "$RESTORE_DIR"

    echo "Yedek arşivi geçici dizine çıkarılıyor..."
    tar -xzvf "$selected" -C "$RESTORE_DIR" || {
        echo "Arşiv çıkarma hatası!"; exit 1;
    }

    if [ -f "$RESTORE_DIR/db_backup.sql" ]; then
        echo "Veritabanı geri yükleniyor..."
        mysql $MYSQL_OPTS "$DB_NAME" < "$RESTORE_DIR/db_backup.sql" || {
            echo "Veritabanı geri yükleme hatası!"; exit 1;
        }
    else
        echo "Hata: SQL yedeği bulunamadı!"
        exit 1
    fi

    echo "Dosyalar geri yükleniyor..."
    rsync -av "$RESTORE_DIR/files/" "$MEDIAWIKI_DIR" || {
        echo "Dosya geri yükleme hatası!"; exit 1;
    }

    rm -rf "$RESTORE_DIR"
    echo "Geri yükleme başarılı!"
}

#########################################
# Ana Menü
#########################################
echo "
=== MediaWiki Yedek Yöneticisi ===
1) Yedek Oluştur
2) Geri Yükle
3) Çıkış
"
read -p "Seçiminiz [1-3]: " option

case $option in
    1) backup_wiki ;;
    2) restore_wiki ;;
    3) echo "Çıkış yapılıyor..."; exit 0 ;;
    *) echo "Geçersiz seçim!"; exit 1 ;;
esac
