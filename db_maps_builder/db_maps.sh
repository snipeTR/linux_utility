#!/bin/bash

# Kullanıcıdan veritabanı adı, kullanıcı adı ve parola iste
read -p "Veritabanı adı: " DB_NAME
read -p "Kullanıcı adı: " DB_USER
read -s -p "Parola (boş bırakmak için ENTER): " DB_PASS
echo ""  # Yeni satır için boş satır

# Parola boşsa şifresiz bağlan, doluysa parola ile bağlan
if [ -z "$DB_PASS" ]; then
    MYSQL_CMD="mysql -u $DB_USER"
else
    MYSQL_CMD="mysql -u $DB_USER -p$DB_PASS"
fi

# Çıktı dosyasının adı
OUTPUT_FILE="${DB_NAME}_structure.txt"

# Başlık oluştur
echo "Database: $DB_NAME" > "$OUTPUT_FILE"
echo "==========================" >> "$OUTPUT_FILE"

# Tüm tabloları al ve döngüye gir
tables=$($MYSQL_CMD -e "SHOW TABLES FROM $DB_NAME;" -s -N)

# Eğer tablo yoksa hata ver
if [ -z "$tables" ]; then
    echo "⚠️ Hata: '$DB_NAME' veritabanında tablo bulunamadı!" >&2
    exit 1
fi

# Her tablo için bilgileri al
for table in $tables; do
    echo "" >> "$OUTPUT_FILE"
    echo "📂 Table: $table" >> "$OUTPUT_FILE"
    echo "--------------------------" >> "$OUTPUT_FILE"

    # Sütun yapısını al
    echo "🗂️ Columns:" >> "$OUTPUT_FILE"
    $MYSQL_CMD -e "DESCRIBE $DB_NAME.$table;" -s -N | while IFS=$'\t' read -r field type null key default extra; do
        echo "   └── $field ($type)" >> "$OUTPUT_FILE"
    done

    echo "" >> "$OUTPUT_FILE"

    # İlk 2 satırı al
    echo "📄 First 2 Rows:" >> "$OUTPUT_FILE"
    rows=$($MYSQL_CMD -e "SELECT * FROM $DB_NAME.$table LIMIT 2;" -s -N)
    if [ -z "$rows" ]; then
        echo "   └── (Tablo boş)" >> "$OUTPUT_FILE"
    else
        echo "$rows" | while IFS=$'\t' read -r row; do
            echo "   └── $row" >> "$OUTPUT_FILE"
        done
    fi
done

# İşlem tamamlandı mesajı
echo "✅ Tüm tablolar başarıyla $OUTPUT_FILE dosyasına kaydedildi!"
