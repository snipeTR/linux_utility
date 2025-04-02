# MariaDB Yedek Geri Yükleme Scripti

## 😉 Açıklama (Türkçe) [English description below. (MariaDB Backup Restore Script)]

Bu script, bir MariaDB veritabanını tamamen sıfırlayıp belirtilen yedek klasöründen tüm verileri geri yükler.

### 🚀 Ne Yapar?

- Seçilen veritabanındaki **tüm tabloları siler**
- Veritabanını **tamamen siler ve yeniden oluşturur**
- `/var/lib/mysql/` altındaki veritabanı klasörünü temizler
- Belirtilen yedek klasöründen veritabanı dosyalarını **kopyalar**
- Gerekli hizmetleri (MariaDB) **durdurup başlatır**
- `rsync` varsa **ilerleme çubuğu** ile kopyalama yapar, yoksa `cp` komutu ile kopyalar

### ⚠️ Güvenlik Uyarısı

> Bu script **geri döndürülemez işlemler** içerir. Tüm veritabanı ve verileri tamamen silinir.  
> Script'i çalıştırmadan önce yedeklerinizi aldığınızdan emin olun.  
> Yalnızca ne yaptığınızı biliyorsanız kullanın!

---

### 📦 Bağımlılıklar

- `bash`
- `mysql` (komut satırı istemcisi)
- `rsync` (opsiyonel – ilerleme göstergesi için)
- `systemctl` (MariaDB servisini yönetmek için)

#### Nasıl Kurulur?

```bash
sudo apt update
sudo apt install -y mariadb-server rsync
```

---

### 🛠️ Kullanım

#### 1. Tek Satırda İndirme ve Çalıştırma

```bash
curl -O https://raw.githubusercontent.com/snipeTR/linux_utility/main/mariaDB_reset_restore/db_reset_restore_TR.sh && chmod +x db_reset_restore_TR.sh && sudo ./db_reset_restore_TR.sh
```

#### 2. Manuel Kullanım

```bash
chmod +x db_reset_restore_TR.sh
sudo ./db_reset_restore_TR.sh
```

Script çalıştıktan sonra sizden aşağıdaki bilgileri ister:

- Veritabanı adı
- Yedek klasörü (örnek: `/root/backup_mydatabase`)
- MySQL kullanıcı adı

---

## 🌐 English Version

# MariaDB Backup Restore Script

## 📌 Description

This script completely resets a MariaDB database and restores it from a specified backup directory.

### 🚀 What It Does

- **Deletes all tables** in the selected database
- **Drops and recreates** the database
- Cleans the database directory under `/var/lib/mysql/`
- **Copies data** from the given backup folder
- Stops and starts the **MariaDB service**
- Uses `rsync` with a **progress bar** if available, otherwise falls back to `cp`

### ⚠️ Security Warning

> This script performs **irreversible actions**. It will delete the entire database and all its contents.  
> Be sure to take a backup **before running this script**.  
> Only use if you fully understand the consequences.

---

### 📦 Dependencies

- `bash`
- `mysql` CLI
- `rsync` (optional – for progress display)
- `systemctl` (to manage MariaDB service)

#### How to Install

```bash
sudo apt update
sudo apt install -y mariadb-server rsync
```

---

### 🛠️ Usage

#### 1. One-liner Download and Run

```bash
curl -O https://raw.githubusercontent.com/snipeTR/linux_utility/main/mariaDB_reset_restore/db_reset_restore.sh && chmod +x db_reset_restore.sh && sudo ./db_reset_restore.sh
```

#### 2. Manual Execution

```bash
chmod +x db_reset_restore.sh
sudo ./db_reset_restore.sh
```

The script will prompt for:

- Database name  
- Backup folder path (e.g., `/root/backup_mydatabase`)  
- MySQL username

