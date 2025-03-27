
# 📚 Database Export Script (`db_maps.sh`)

This script securely exports the structure and the first 2 rows of each table in a MySQL/MariaDB database to a `.txt` file. 

⚠️ **WARNING:** Be cautious while using this script as it exports sensitive data from your database. Ensure the file is deleted securely after reviewing its content.



## 🚀 Features
- Exports table structure and first 2 rows of all tables.
- Generates output in an easy-to-read tree structure.
- Checks if `nano` is installed and optionally installs it.
- Asks if you want to open the resulting file in `nano`.
- Provides instructions to securely delete the output file.

---

## 🛡️ Security Warning
- The exported file contains sensitive database information.
- Securely delete the file after use with:
```bash
shred -u -z <filename>
```
- You are **fully responsible** for securing the exported file.

---

## 📥 Quick Installation & Run
To download and run the script in one command:
```bash
wget -O db_maps.sh https://github.com/snipeTR/linux_utility/raw/main/db_maps_builder/db_maps.sh && chmod +x db_maps.sh && ./db_maps.sh
```

---

## 📄 Usage Instructions
1. Run the script:
```bash
./db_maps.sh
```
2. Enter:
    - Database Name (case-sensitive!)
    - MySQL Username
    - Password (or press `ENTER` if there’s no password)
3. The script will:
    - Export the data to `<DB_NAME>_structure.txt`.
    - Check if `nano` is installed.
    - Ask to open the file with `nano` after completion.
4. To securely delete the output:
```bash
shred -u -z <DB_NAME>_structure.txt
```

---

## 📄 Sample Output:
```
Database: snipeTR
==========================

📂 Table: users
--------------------------
🗂️ Columns:
   └── id (int)
   └── name (varchar)
   └── email (varchar)

📄 First 2 Rows:
   └── 1   John Doe   john@example.com
   └── 2   Jane Doe   jane@example.com
```

---

## 🛑 Error Handling
- Invalid credentials: The script exits with an error.
- Empty database: Shows a message if no tables are found.

---

---

<p align="center">
  <img src="https://github.com/user-attachments/assets/4e9d5012-2b7f-4d08-91c6-536cf2e26ba4" width="100" alt="image description">
</p>

# 📚 Veritabanı Dışa Aktarma Betiği (`db_maps.sh`)

Bu betik, MySQL/MariaDB veritabanındaki tüm tabloların yapısını ve ilk 2 satırını `.txt` dosyasına güvenli bir şekilde aktarır.

⚠️ **UYARI:** Bu betik veritabanından hassas verileri dışa aktarır. İçeriği inceledikten sonra dosyayı güvenli bir şekilde silmelisiniz.

---

## 🚀 Özellikler
- Tüm tabloların yapısı ve ilk 2 satırını dışa aktarır.
- Ağaç yapısı şeklinde çıktıyı oluşturur.
- `nano` yüklü mü diye kontrol eder ve yükleme izni ister.
- Dosyayı `nano` ile açmak isteyip istemediğinizi sorar.
- Dosyayı güvenli bir şekilde silme talimatları verir.

---

## 🛡️ Güvenlik Uyarısı
- Dışa aktarılan dosya hassas veriler içerir.
- Kullanım sonrası dosyayı güvenli bir şekilde silmek için:
```bash
shred -u -z <dosya_adi>
```
- Bu dosyanın güvenliğinden tamamen **siz sorumlusunuz.**

---

## 📥 Hızlı Kurulum ve Çalıştırma
Tek satırda indirmek ve çalıştırmak için:
```bash
wget -O db_maps.sh https://github.com/snipeTR/linux_utility/raw/main/db_maps_builder/db_maps.sh && chmod +x db_maps.sh && ./db_maps.sh
```

---

## 📄 Kullanım Talimatları
1. Betiği çalıştırın:
```bash
./db_maps.sh
```
2. Girilecek bilgiler:
    - Veritabanı Adı (Büyük/küçük harfe duyarlı!)
    - MySQL Kullanıcı Adı
    - Parola (yoksa `ENTER` tuşuna basın)
3. Betik şu işlemleri yapar:
    - Verileri `<DB_NAME>_structure.txt` dosyasına kaydeder.
    - `nano` yüklü mü kontrol eder.
    - Dosyayı `nano` ile açmak isteyip istemediğinizi sorar.
4. Çıktıyı güvenli silmek için:
```bash
shred -u -z <DB_NAME>_structure.txt
```

---

## 📄 Örnek Çıktı:
```
Database: snipeTR
==========================

📂 Table: users
--------------------------
🗂️ Columns:
   └── id (int)
   └── name (varchar)
   └── email (varchar)

📄 First 2 Rows:
   └── 1   John Doe   john@example.com
   └── 2   Jane Doe   jane@example.com
```

---

## 🛑 Hata Durumları
- Hatalı kullanıcı adı/parola: Bağlantı hatası verilir.
- Boş veritabanı: Eğer tablo yoksa uyarı gösterir.

---

🎯 **Enjoy using the script and ensure your data is handled securely!**
```
