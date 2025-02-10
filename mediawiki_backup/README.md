```markdown
# MediaWiki Backup ve Restore Script

Bu script, **MediaWiki** kurulumunuzun dosya yedeklemesini ve veritabanı yedeğini alıp, gerektiğinde bu yedekleri geri yüklemenizi sağlayan bir Bash betiğidir.

## Özellikler

- **Dosya Yedeklemesi:** MediaWiki kurulum dizinindeki (backup klasörü hariç) tüm dosyaları arşivler.
- **Veritabanı Yedeklemesi:** MySQL/MariaDB veritabanının yedeğini `mysqldump` komutu ile alır.
- **Geri Yükleme:** Yedeklenen dosyalar ve veritabanı yedeği, uygun şekilde geri yüklenir.
- **Bağımlılık Kontrolü:** Script, çalışmadan önce `mysqldump`, `mysql` ve `tar` komutlarının kurulu olup olmadığını kontrol eder; eksikse gerekli paketleri (Ubuntu'da genellikle `mysql-client` ve `tar`) otomatik olarak yükler.

## Gereksinimler

- **Sistem:** Ubuntu 24 veya uyumlu Ubuntu tabanlı bir sistem.
- **Yetkiler:** Paket kurulumu için `sudo` yetkisi gereklidir.
- **Bağımlılıklar:**  
  - `mysqldump`  
  - `mysql`  
  - `tar`

## Kurulum

1. **Script Dosyasını Edinin:**

   Bu script'i `/var/www/html/mediawiki` dizinine `mediawiki_backup.sh` adıyla kaydedin.

2. **Script İçindeki Ayarları Güncelleyin:**

   Bir metin düzenleyici ile `mediawiki_backup.sh` dosyasını açın ve aşağıdaki kısımları kendi sisteminize göre düzenleyin:

   ```bash
   DB_NAME="mediawiki_db"         # MediaWiki veritabanı adı
   DB_USER="mediawiki_user"       # Veritabanı kullanıcı adı
   DB_PASS="your_password"        # Veritabanı şifresi
   ```

   Gerekirse DB_HOST veya diğer parametreleri de ekleyebilirsiniz.

3. **Çalıştırılabilir Yapın:**

   Terminalde aşağıdaki komutu çalıştırarak dosyayı çalıştırılabilir hale getirin:

   ```bash
   chmod +x mediawiki_backup.sh
   ```

## Kullanım

Script, çalıştırıldığında iki seçenek sunar: **Yedekleme (Backup)** ve **Geri Yükleme (Restore)**.

### Yedekleme (Backup)

- **İşleyiş:**  
  1. Veritabanı yedeği `mysqldump` kullanılarak geçici bir `db_backup.sql` dosyasına alınır.
  2. MediaWiki dosyaları (backup klasörü hariç) `tar` komutu ile zaman damgalı bir arşiv dosyası olarak `backup` klasörüne kaydedilir.
  3. İşlem sonunda geçici SQL dosyası silinir.

- **Tek Satırda Çalıştırma:**

  ```bash
  cd /var/www/html/mediawiki && ./mediawiki_backup.sh
  ```

### Geri Yükleme (Restore)

- **İşleyiş:**  
  1. Script, `backup` klasöründeki yedek dosyalarını listeler.
  2. Kullanıcı, listeden geri yüklemek istediği yedek dosyasını seçer.
  3. Seçilen arşiv dosyası çıkarılır ve eğer içerikte `db_backup.sql` varsa veritabanı geri yüklenir.

- **Tek Satırda Çalıştırma:**

  ```bash
  cd /var/www/html/mediawiki && ./mediawiki_backup.sh
  ```

## Nasıl Çalışır?

1. **Bağımlılık Kontrolü:**  
   Script, `mysqldump`, `mysql` ve `tar` komutlarının sistemde kurulu olup olmadığını kontrol eder. Kurulu olmayan paketler bulunursa, `sudo apt-get update` ve `sudo apt-get install` komutları ile yüklenir.

2. **Çalışma Dizini Kontrolü:**  
   Script yalnızca `/var/www/html/mediawiki` dizininde çalışacak şekilde tasarlanmıştır. Farklı bir dizinde çalıştırıldığında uyarı verip işlemi sonlandırır.

3. **Yedekleme İşlemi:**  
   - **Veritabanı Yedeği:** `mysqldump` ile alınır.
   - **Dosya Arşivleme:** `tar` komutu ile arşivlenir.
   - **Geçici Dosya Temizleme:** Yedekleme işlemi tamamlandıktan sonra `db_backup.sql` dosyası silinir.

4. **Geri Yükleme İşlemi:**  
   - Kullanıcı, `backup` klasöründeki yedek dosyalarından birini seçer.
   - Seçilen arşiv dosyası çıkarılır.
   - Eğer arşivde veritabanı yedeği (`db_backup.sql`) bulunuyorsa, bu dosya kullanılarak veritabanı geri yüklenir.

## Uyarılar

- **Veri Üzerine Yazma:**  
  Geri yükleme işlemi mevcut dosyaların üzerine yazabilir. Geri yükleme yapmadan önce yedeklerinizin güncel olduğundan emin olun.

- **Yetki Gereksinimi:**  
  Bağımlılıkların kurulumu için `sudo` yetkisine ihtiyaç vardır.

- **Test Ortamı:**  
  Üretim ortamında kullanmadan önce, script'i test ortamında denemeniz önerilir.

## Sonuç

Bu script, MediaWiki kurulumunuzun dosya ve veritabanı yedeklerini almanızı ve gerektiğinde kolayca geri yüklemenizi sağlayan kullanışlı bir araçtır. Herhangi bir sorunla karşılaşırsanız veya geliştirme yapmak isterseniz, script içindeki yorum satırları ve kod parçacıkları üzerinden düzenlemeler yapabilirsiniz.
```
