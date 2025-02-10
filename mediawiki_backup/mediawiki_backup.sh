#!/bin/bash
# MediaWiki Yedekleme ve Geri Yükleme Betiği
# Çalışma dizini: /var/www/html/mediawiki
# Yedekler, "backup" isimli klasörde saklanır.
# Yedek dosya adı formatı: tarih_saat-dakika-saniye_backup.tar.gz

#############################
# Lütfen aşağıdaki değişkenleri kendi sisteminize göre düzenleyin!
#############################
DB_NAME="mediawiki_db"         # MediaWiki veritabanı adı
DB_USER="mediawiki_user"       # Veritabanı kullanıcı adı
DB_PASS="your_password"        # Veritabanı şifresi
#############################

BACKUP_DIR="backup"

# ------------------------------
# Gerekli komutların kurulu olup olmadığını kontrol eden fonksiyon
# Eğer kurulu değilse, sudo ile apt-get update yaparak gerekli paketleri kurar.
# mysqldump ve mysql için "mysql-client", tar için "tar" paketini yükler.
# ------------------------------
check_dependencies() {
    MISSING_PKGS=()

    # mysqldump kontrolü
    if ! command -v mysqldump >/dev/null 2>&1; then
        MISSING_PKGS+=("mysql-client")
    fi

    # mysql kontrolü
    if ! command -v mysql >/dev/null 2>&1; then
        MISSING_PKGS+=("mysql-client")
    fi

    # tar kontrolü
    if ! command -v tar >/dev/null 2>&1; then
        MISSING_PKGS+=("tar")
    fi

    # Aynı paket adlarının tekrarını engellemek için uniq liste oluşturuyoruz.
    UNIQUE_PKGS=($(echo "${MISSING_PKGS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    if [ ${#UNIQUE_PKGS[@]} -gt 0 ]; then
        echo "Gerekli paket(ler) bulunamadı: ${UNIQUE_PKGS[@]}"
        echo "Kurulum yapılıyor..."
        sudo apt-get update
        sudo apt-get install -y "${UNIQUE_PKGS[@]}"
    fi
}

# Gerekli bağımlılıkların kontrolü
check_dependencies

# Betiğin çalıştığı dizinin "mediawiki" olup olmadığını kontrol ediyoruz.
if [ "$(basename "$PWD")" != "mediawiki" ]; then
    echo "Bu betik /var/www/html/mediawiki dizininde çalıştırılmalıdır."
    exit 1
fi

# Backup klasörü yoksa oluşturuyoruz.
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

echo "=========================================="
echo " MediaWiki Yedekleme / Geri Yükleme Aracı"
echo "=========================================="
echo ""
echo "Lütfen yapmak istediğiniz işlemi seçiniz:"
echo "1) Yedekleme (Backup)"
echo "2) Geri Yükleme (Restore)"
read -p "Seçiminiz (1 veya 2): " choice

case $choice in
    1)
        echo ""
        echo "Yedekleme işlemi başlatılıyor..."
        # Tarih ve saat bilgisiyle dosya adı oluşturuyoruz.
        timestamp=$(date +"%Y_%m_%d_%H-%M-%S")
        backup_filename="${timestamp}_backup.tar.gz"
        
        # Önce veritabanını yedekleyelim.
        echo "Veritabanı yedeği alınıyor..."
        mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > db_backup.sql
        if [ $? -ne 0 ]; then
            echo "Hata: Veritabanı yedeği alınamadı!"
            rm -f db_backup.sql
            exit 1
        fi
        
        # Ardından tüm dosyaları (backup klasörü hariç) arşivleyelim.
        echo "Dosyalar arşivleniyor..."
        tar --exclude="$BACKUP_DIR" -czf "$BACKUP_DIR/$backup_filename" .
        if [ $? -ne 0 ]; then
            echo "Hata: Dosyalar arşivlenirken bir problem oluştu!"
            rm -f db_backup.sql
            exit 1
        fi
        
        # Geçici veritabanı yedek dosyasını siliyoruz.
        rm -f db_backup.sql
        
        echo "------------------------------------------"
        echo "Yedekleme tamamlandı: $BACKUP_DIR/$backup_filename"
        echo "------------------------------------------"
        ;;
    2)
        echo ""
        echo "Geri yükleme işlemi başlatılıyor..."
        # Backup klasöründeki yedek dosyalarını listeleyelim.
        backup_files=("$BACKUP_DIR"/*_backup.tar.gz)
        if [ ${#backup_files[@]} -eq 0 ]; then
            echo "Hata: Hiç yedek dosyası bulunamadı!"
            exit 1
        fi
        
        echo "Mevcut yedek dosyaları:"
        i=1
        for file in "${backup_files[@]}"; do
            echo "  $i) $(basename "$file")"
            ((i++))
        done
        
        read -p "Yüklemek istediğiniz yedeğin numarasını giriniz: " file_choice
        
        # Kullanıcı girişini kontrol ediyoruz.
        if ! [[ "$file_choice" =~ ^[0-9]+$ ]] || [ "$file_choice" -lt 1 ] || [ "$file_choice" -gt "${#backup_files[@]}" ]; then
            echo "Geçersiz seçim! Program sonlandırılıyor."
            exit 1
        fi
        
        selected_backup="${backup_files[$((file_choice-1))]}"
        echo "Seçilen yedek: $(basename "$selected_backup")"
        
        read -p "UYARI: Bu işlem mevcut dosyaların üzerine yazacaktır. Devam etmek istiyor musunuz? (E/H): " confirm
        if [[ ! "$confirm" =~ ^[Ee] ]]; then
            echo "İşlem iptal edildi."
            exit 0
        fi
        
        # Yedek arşiv dosyasını çıkarıyoruz.
        echo ""
        echo "Arşivden çıkarma işlemi başlatılıyor..."
        tar -xzvf "$selected_backup"
        if [ $? -ne 0 ]; then
            echo "Hata: Arşivden çıkarma sırasında bir problem oluştu!"
            exit 1
        fi
        
        # Eğer arşivde veritabanı yedeği (db_backup.sql) varsa, veritabanını geri yüklüyoruz.
        if [ -f "db_backup.sql" ]; then
            echo ""
            echo "Veritabanı geri yüklemesi yapılıyor..."
            mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < db_backup.sql
            if [ $? -ne 0 ]; then
                echo "Hata: Veritabanı geri yüklemesi sırasında bir problem oluştu!"
                exit 1
            fi
            # Geri yükleme bittikten sonra, geçici SQL dosyasını siliyoruz.
            rm -f db_backup.sql
        else
            echo "Uyarı: db_backup.sql dosyası bulunamadı. Sadece dosya geri yüklemesi yapıldı."
        fi
        
        echo "------------------------------------------"
        echo "Geri yükleme işlemi tamamlandı."
        echo "------------------------------------------"
        ;;
    *)
        echo "Geçersiz seçim. Program sonlandırılıyor."
        exit 1
        ;;
esac
