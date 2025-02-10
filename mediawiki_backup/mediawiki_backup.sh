#!/bin/bash
# MediaWiki Yedekleme ve Geri Yükleme Aracı
# Bu betik, önce geçici bir klasörde (temp_backup) veritabanı yedeğini ve MediaWiki dosyalarını toplar,
# ardından bu içerik saatdakikasaniye_tarih_yedek.tar.gz formatında paketlenip backup klasörüne aktarılır.
# Geri yükleme sırasında, seçilen arşiv geçici bir klasöre çıkarılarak dosyalar ve veritabanı geri yüklenir.

#########################################
# Ayarlar - Lütfen kendi ortamınıza göre düzenleyin
#########################################
DB_NAME="mediawiki_db"                      # Veritabanı adı
DB_USER="mediawiki_user"                    # Veritabanı kullanıcı adı
DB_PASS="sifre"                             # Veritabanı şifresi
BACKUP_DIR="backup"                         # Yedeklerin saklanacağı klasör
MEDIAWIKI_DIR="/var/www/html/mediawiki"     # MediaWiki kurulum yolu

#########################################
# Betik çalışma dizini kontrolü
#########################################
if [ "$(pwd)" != "$MEDIAWIKI_DIR" ]; then
  echo "Betiği $MEDIAWIKI_DIR dizininde çalıştırın!"
  exit 1
fi

#########################################
# Yedekleme Fonksiyonu
#########################################
backup_wiki() {
  # Zaman damgası: HHMMSS_YYYY-MM-DD_yedek.tar.gz şeklinde isimlendirme
  TIMESTAMP=$(date +"%H%M%S_%Y-%m-%d")
  ARCHIVE_NAME="${TIMESTAMP}_yedek.tar.gz"
  
  # Geçici yedekleme dizini oluşturuluyor
  TEMP_DIR="temp_backup"
  [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
  mkdir -p "$TEMP_DIR/files"
  
  echo "Veritabanı yedekleniyor..."
  mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$TEMP_DIR/db_backup.sql" || {
    echo "Veritabanı yedekleme hatası!"; exit 1;
  }
  
  echo "Dosyalar yedekleniyor..."
  # MediaWiki dosyalarını, backup ve geçici dizin hariç, temp_backup/files altına kopyalıyoruz
  rsync -av --exclude="$BACKUP_DIR" --exclude="$TEMP_DIR" . "$TEMP_DIR/files" || {
    echo "Dosya yedekleme hatası!"; exit 1;
  }
  
  # Backup klasörü yoksa oluşturuluyor
  [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
  
  echo "Yedek arşivi oluşturuluyor: $ARCHIVE_NAME"
  tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$TEMP_DIR" . || {
    echo "Arşiv oluşturulurken hata oluştu!"; exit 1;
  }
  
  # Geçici dizin temizleniyor
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
  
  # BACKUP_DIR altındaki *_yedek.tar.gz dosyalarını listeliyoruz
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
  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Geçersiz numara!"; exit 1;
  fi
  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backups[@]}" ]; then
    echo "Hatalı aralık!"; exit 1;
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
  
  # Veritabanı geri yüklemesi
  if [ -f "$RESTORE_DIR/db_backup.sql" ]; then
    echo "Veritabanı geri yükleniyor..."
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$RESTORE_DIR/db_backup.sql" || {
      echo "Veritabanı geri yükleme hatası!"; exit 1;
    }
  else
    echo "Uyarı: db_backup.sql dosyası bulunamadı!"
  fi
  
  echo "Dosyalar geri yükleniyor..."
  # Geri yüklenen dosyalar, temp_restore/files altındaki içeriktir.
  rsync -av "$RESTORE_DIR/files/" "$MEDIAWIKI_DIR" || {
    echo "Dosya geri yükleme hatası!"; exit 1;
  }
  
  # Geçici geri yükleme dizini temizleniyor
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
