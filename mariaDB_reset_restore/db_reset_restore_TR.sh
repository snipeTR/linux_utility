#!/bin/bash

echo "📌 Lütfen işlem için aşağıdaki bilgileri girin:"

read -p "Veritabanı adı (DB_NAME): " DB_NAME
read -p "Yedek klasörü (DB_BACKUP_PATH): " DB_BACKUP_PATH
read -p "MySQL kullanıcı adı (MYSQL_USER): " MYSQL_USER

DB_NAME=${DB_NAME:-mydatabase}
DB_BACKUP_PATH=${DB_BACKUP_PATH:-/root/mydatabase_backup}
MYSQL_USER=${MYSQL_USER:-mydbuser}
DB_PATH="/var/lib/mysql/$DB_NAME"

echo
echo "📋 Girdiğiniz bilgiler:"
echo "🔹 Veritabanı adı     : $DB_NAME"
echo "🔹 Yedek klasörü       : $DB_BACKUP_PATH"
echo "🔹 MySQL kullanıcı adı : $MYSQL_USER"
echo "🔹 Veritabanı dizini   : $DB_PATH"
echo

# UYARI
echo
echo "============================================="
echo "⚠️  DIKKAT! BU SCRIPT NE YAPAR?"
echo " - '$DB_NAME' veritabanındaki TÜM TABLOLARI siler."
echo " - '$DB_NAME' Veritabanını tamamen siler ve yeniden oluşturur."
echo " - '$DB_PATH' klasörünü temizler."
echo " - '$DB_BACKUP_PATH' altındaki yedek dosyaları geri yükler."
echo " - MariaDB servisini birkaç kez durdurup başlatır."
echo " - BU İŞLEM SONUCU TÜM BİLGİLERİNİZİ KAYBEDEBİLİRSİNİZ."
echo "❌ BU İŞLEM GERİ DÖNDÜRÜLEMEZ! EMİN MİSİNİZ?"
echo "============================================="

# Disk hızı ve tahmini süre
echo "🔍 Disk okuma hızı test ediliyor (256MB)..."
DISK_TEST_OUTPUT=$(dd if=/dev/zero bs=1M count=256 of=/dev/null 2>&1)
READ_SPEED=$(echo "$DISK_TEST_OUTPUT" | grep copied | awk -F, '{print $3}' | xargs)

if [[ "$READ_SPEED" =~ ([0-9]+(\.[0-9]+)?)\ MB/s ]]; then
    AVG_SPEED_MB=${BASH_REMATCH[1]}
else
    echo " - HIZ BİLGİSİ ALINAMADI, VARSAYILAN OLARAK 200MB/s DEĞERİ HESAPLANACAK."
    AVG_SPEED_MB=200
fi

echo "💽 Ortalama disk okuma hızı: $AVG_SPEED_MB MB/s"

BACKUP_SIZE_MB=$(du -sm "$DB_BACKUP_PATH" | cut -f1)
ESTIMATED_TIME_SEC=$(echo "$BACKUP_SIZE_MB / $AVG_SPEED_MB" | bc)

echo "📦 Yedek boyutu: $BACKUP_SIZE_MB MB"
echo "⏳ Tahmini kopyalama süresi: $ESTIMATED_TIME_SEC saniye"

# Kullanıcıya bilgi okuması için süre tanı
echo
echo "⌛ Devam etmeden önce lütfen yukarıdaki bilgileri kontrol edin..."
sleep 3

read -p "Devam etmek istiyor musunuz? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ İşlem iptal edildi."
    exit 1
fi

echo "1. Tablolar siliniyor..."
echo "============================================="
mysql -u "$MYSQL_USER" -e "USE \`$DB_NAME\`; SET FOREIGN_KEY_CHECKS=0; \
    SET @tables = (SELECT GROUP_CONCAT(table_name) FROM information_schema.tables WHERE table_schema = '$DB_NAME'); \
    SET @query = CONCAT('DROP TABLE IF EXISTS ', @tables); \
    PREPARE stmt FROM @query; EXECUTE stmt; DEALLOCATE PREPARE stmt; \
    SET FOREIGN_KEY_CHECKS=1;"

echo "2. Veritabanı '$DB_NAME' siliniyor..."
echo "============================================="
mysql -u "$MYSQL_USER" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`;"

echo "3. MariaDB servisi durduruluyor..."
echo "============================================="
systemctl stop mariadb

echo "4. Eski veritabanı klasörü temizleniyor..."
echo "============================================="
rm -rf "$DB_PATH"

echo "5. MariaDB servisi tekrar başlatılıyor..."
echo "============================================="
systemctl start mariadb

echo "6. Veritabanı '$DB_NAME' yeniden oluşturuluyor..."
echo "============================================="
mysql -u "$MYSQL_USER" -e "CREATE DATABASE \`$DB_NAME\`;"

echo "7. MariaDB servisi tekrar durduruluyor (dosya kopyalama için)..."
echo "============================================="
systemctl stop mariadb

echo "8. Yedek dosyalar kopyalanıyor (~${ESTIMATED_TIME_SEC} saniye sürebilir)..."
echo "============================================="

USE_CP=false

# rsync kontrolü ve kurulum
if ! command -v rsync &> /dev/null; then
    echo "🔍 'rsync' yüklü değil. Kurulmaya çalışılıyor..."
    apt-get update && apt-get install -y rsync
    if ! command -v rsync &> /dev/null; then
        echo "⚠️  'rsync' yüklenemedi. 'cp' komutu ile kopyalanacak."
        USE_CP=true
    fi
fi

# Kopyalama işlemi
if [ "$USE_CP" = false ]; then
    echo "🚀 rsync ile kopyalanıyor (ilerleme gösterilir):"
    rsync -ah --info=progress2 "$DB_BACKUP_PATH/" "$DB_PATH/"
else
    echo "📁 cp ile kopyalanıyor (ilerleme gösterilmez):"
    cp -r "$DB_BACKUP_PATH/"* "$DB_PATH/"
fi

# Sahiplik ayarlanıyor
chown -R mysql:mysql "$DB_PATH"

echo "9. Kopyalama işlemi bitti"
echo "============================================="

echo "10. MariaDB servisi tekrar başlatılıyor..."
systemctl start mariadb

echo "✅ İşlem tamamlandı. Veritabanı '$DB_NAME' başarıyla yeniden kuruldu."
