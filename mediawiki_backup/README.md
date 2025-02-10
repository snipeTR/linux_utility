# MediaWiki Yedekleme ve Geri Yükleme Betiği

Bu Bash betiği, Linux sunucunuzdaki (Ubuntu) MediaWiki kurulumunuzun yedeklenmesi ve geri yüklenmesi işlemlerini otomatikleştirir. MediaWiki dosyalarınızı ve veritabanınızı zaman damgalı bir arşiv halinde toplar ve yedekleme ile geri yükleme işlemleri için interaktif bir menü sunar.

Betiğin, `LocalSettings.php` dosyanızdan veritabanı kimlik bilgilerini otomatik olarak alması ve isteğe bağlı olarak XML dump oluşturabilme özelliği de bulunmaktadır.

> **GitHub Adresi:** [MediaWiki Yedekleme Betiği](https://github.com/snipeTR/linux_utility/blob/main/mediawiki_backup/mediawiki_backup.sh)

## Özellikler

- **Otomatik Veritabanı Ayarları Çekme:**  
  `LocalSettings.php` dosyanızdan (`wgDBserver`, `wgDBname`, `wgDBuser` ve `wgDBpassword`) veritabanı ayarlarını otomatik olarak alır.

- **Interaktif Menü:**  
  Yedek oluşturma veya mevcut bir yedeği geri yükleme seçenekleri sunar.

- **Zaman Damgalı Arşivler:**  
  Yedek arşivleri, `HHMMSS_YYYY-MM-DD_yedek.tar.gz` formatında isimlendirilir; bu sayede kolayca tanımlanabilirler.

- **XML Dump Oluşturma:**  
  Mevcutsa, MediaWiki’nin `maintenance/dumpBackup.php` aracını kullanarak XML dump oluşturur. (XML dump geri yüklemesi manuel olarak yapılmalıdır.)

- **Güvenli Dosya Senkronizasyonu:**  
  `rsync` kullanarak MediaWiki dosyalarını kopyalar; yedek ve geçici dizinler hariç tutulur.

- **Geçici Dizin Kullanımı:**  
  Yedekleme için `temp_backup`, geri yükleme için `temp_restore` geçici dizinleri kullanılarak süreç temiz bir şekilde yönetilir.

## Gereksinimler

- **İşletim Sistemi:** Ubuntu (veya uyumlu diğer Linux dağıtımları)
- **Yazılım Gereksinimleri:**
  - Bash
  - `mysqldump`
  - `mysql`
  - `tar`
  - `rsync`
  - PHP (XML dump oluşturma için)

## Kurulum

1. **Depoyu Klonlayın:**

   ```bash
   git clone https://github.com/snipeTR/linux_utility.git
   ```

2. **MediaWiki Yedekleme Dizinine Geçin:**

   ```bash
   cd linux_utility/mediawiki_backup
   ```

3. **Betiği Çalıştırılabilir Hale Getirin:**

   ```bash
   chmod +x mediawiki_backup.sh
   ```

## Yapılandırma

- **MediaWiki Dizini:**  
  Betik, MediaWiki kurulum dizininde (örneğin, `/var/www/html/mediawiki`) çalıştırılmak üzere tasarlanmıştır. Betiği bu dizinden çalıştırdığınızdan veya betikteki `MEDIAWIKI_DIR` değişkenini ihtiyaçlarınıza göre güncellediğinizden emin olun.

- **Veritabanı Kimlik Bilgileri:**  
  Betik, `LocalSettings.php` dosyasından veritabanı kimlik bilgilerini otomatik olarak alır. `LocalSettings.php` dosyanızın mevcut ve doğru yapılandırılmış olması gerekir.

- **Yedek Klasörü:**  
  Yedekler, betikte belirtilen `BACKUP_DIR` değişkeninde saklanır (varsayılan olarak MediaWiki dizinindeki `backup` klasörü).

## Kullanım

MediaWiki kurulum dizininde betiği çalıştırın:

```bash
./mediawiki_backup.sh
```

Interaktif menü karşınıza çıkacaktır:

1. **Yedek Oluştur (Backup):**  
   - Geçici bir dizin (`temp_backup`) oluşturulur.
   - Betik, MediaWiki veritabanınızın SQL dump’ını oluşturur.
   - Eğer mevcutsa XML dump da oluşturulur.
   - MediaWiki dosyaları, geçici dizine (yedek ve geçici dizinler hariç) kopyalanır.
   - Geçici dizinin içeriği, zaman damgalı arşiv (örneğin, `235959_2025-02-10_yedek.tar.gz`) haline getirilir ve yedek klasörüne kaydedilir.
   - İşlem tamamlandığında geçici dizin silinir.

2. **Geri Yükle (Restore):**  
   - Betik, yedek klasöründeki mevcut arşivleri listeler.
   - Yedeklemek istediğiniz arşivi seçersiniz.
   - Seçilen arşiv, geçici bir dizine (`temp_restore`) çıkarılır.
   - SQL dump kullanılarak veritabanı geri yüklenir.
   - `rsync` kullanılarak MediaWiki dosyaları orijinal dizine kopyalanır.
   - Geri yükleme işlemi tamamlandıktan sonra geçici dizin silinir.

3. **Çıkış:**  
   - Betikten çıkış yapılır.

> **Not:**  
> XML dump, ek bir yedek olarak oluşturulur; XML dump geri yüklemesi, gerektiğinde manuel olarak yapılmalıdır.

## Lisans

Bu proje, [MIT Lisansı](LICENSE) kapsamında lisanslanmıştır.

---

Katkıda bulunmak, sorun bildirmek veya geliştirme önerilerinde bulunmak için lütfen [GitHub deposunu](https://github.com/snipeTR/linux_utility/blob/main/mediawiki_backup/mediawiki_backup.sh) ziyaret edin.
