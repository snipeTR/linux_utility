# MediaWiki Yedekleme ve Geri Yükleme Betiği

Bu betik, MediaWiki kurulumunuzun dosyalarını ve veritabanını otomatik olarak yedeklemenize ve gerektiğinde geri yüklemenize olanak tanır. Betik, `LocalSettings.php` dosyasından veritabanı bilgilerini otomatik olarak çeker, SQL dump oluşturur. Dosyalar, geçici dizinlerde toplanıp zaman damgalı bir arşiv haline getirilir. Geri yükleme işlemi interaktif menü üzerinden gerçekleştirilir.

> **GitHub Adresi:** [mediawiki_backup.sh](https://github.com/snipeTR/linux_utility/blob/main/mediawiki_backup/mediawiki_backup.sh)

---

## Özellikler

- **Otomatik Veritabanı Ayarları:**  
  `LocalSettings.php` dosyasından `wgDBserver`, `wgDBname`, `wgDBuser` ve `wgDBpassword` bilgilerini otomatik olarak alır.

- **SQL Dump:**  
  Veritabanının SQL dump’ını alır.

- **Geçici Dizin Kullanımı:**  
  Yedekleme için `temp_backup` ve geri yükleme için `temp_restore` geçici dizinleri kullanılır.

- **Zaman Damgalı Arşivler:**  
  Yedek arşivleri `HHMMSS_YYYY-MM-DD_yedek.tar.gz` formatında oluşturulur.

- **Güvenli Dosya Senkronizasyonu:**  
  `rsync` kullanılarak MediaWiki dosyaları yedeklenir ve geri yüklenir.

- **Interaktif Menü:**  
  Yedek oluşturma, geri yükleme veya çıkış seçeneklerini içeren kullanıcı dostu bir menü sunar.

---

## Gereksinimler

- **İşletim Sistemi:** Ubuntu (veya uyumlu Linux dağıtımları)
- **Gerekli Yazılımlar:**  
  - Bash  
  - `mysqldump`  
  - `mysql`  
  - `tar`  
  - `rsync`  

---

## Kurulum

### 1. Betiği Doğrudan MediaWiki Klasörüne İndirin

Betiğin MediaWiki kurulum dizininizde (örneğin, `/var/www/html/mediawiki`) bulunması gerekmektedir. Aşağıdaki tek satırlık komut ile betiği indirebilir, çalıştırılabilir hale getirebilir ve hemen çalıştırabilirsiniz:

```bash
cd /var/www/html/mediawiki && curl -o mediawiki_backup.sh https://raw.githubusercontent.com/snipeTR/linux_utility/main/mediawiki_backup/mediawiki_backup.sh && chmod +x mediawiki_backup.sh && ./mediawiki_backup.sh
```

### 2. Alternatif Olarak Manuel İndirme

1. MediaWiki kurulum dizinine gidin:
   ```bash
   cd /var/www/html/mediawiki
   ```
2. Betiği indirin:
   ```bash
   curl -o mediawiki_backup.sh https://raw.githubusercontent.com/snipeTR/linux_utility/main/mediawiki_backup/mediawiki_backup.sh
   ```
3. Betiği çalıştırılabilir hale getirin:
   ```bash
   chmod +x mediawiki_backup.sh
   ```
4. Betiği çalıştırın:
   ```bash
   ./mediawiki_backup.sh
   ```

---

## Yapılandırma

- **MediaWiki Dizini:**  
  Betik, MediaWiki kurulum dizininde çalıştırılmak üzere tasarlanmıştır (örn. `/var/www/html/mediawiki`). Betiği bu dizinde çalıştırdığınızdan emin olun veya `MEDIAWIKI_DIR` değişkenini düzenleyin.

- **Veritabanı Bilgileri:**  
  Betik, `LocalSettings.php` dosyasından veritabanı bilgilerini otomatik olarak çeker. Dosyanızın doğru yapılandırılmış olduğundan emin olun.

- **Yedek Klasörü:**  
  Yedek arşivleri, betikte belirtilen `BACKUP_DIR` (varsayılan: `backup` klasörü) altında saklanır.

---

## Kullanım

Betiği çalıştırdığınızda, interaktif bir menü ile karşılaşacaksınız:

1. **Yedek Oluştur (Backup):**  
   - Geçici bir dizin (`temp_backup`) oluşturulur.
   - SQL dump alınır.
   - MediaWiki dosyaları, yedek ve geçici dizinler hariç geçici dizine kopyalanır.
   - Tüm içerik, zaman damgalı bir arşiv dosyası haline getirilip `BACKUP_DIR` altında saklanır.
   - Geçici dizin silinir.

2. **Geri Yükle (Restore):**  
   - Yedek klasöründeki mevcut arşivler listelenir.
   - Seçilen arşiv, geçici bir dizine (`temp_restore`) çıkarılır.
   - SQL dump kullanılarak veritabanı geri yüklenir.
   - Dosyalar `rsync` ile MediaWiki dizinine kopyalanır.
   - Geçici dizin silinir.

3. **Çıkış:**  
   - Betikten çıkılır.

---

## Lisans

Bu proje [MIT Lisansı](LICENSE) kapsamında lisanslanmıştır.

---

Katkıda bulunmak, sorun bildirmek veya geliştirme önerilerinde bulunmak için lütfen [GitHub deposunu](https://github.com/snipeTR/linux_utility/blob/main/mediawiki_backup/mediawiki_backup.sh) ziyaret edin.
