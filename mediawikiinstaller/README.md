# MediaWiki Kurulum Scripti

Bu proje, Linux sistemlerinde (özellikle Debian/Ubuntu tabanlı dağıtımlarda) MediaWiki kurulumunu otomatikleştiren bir Bash scripti sunar. Script, LAMP (Linux, Apache, MySQL, PHP) yığını üzerinde MediaWiki'nin kurulumunu, yapılandırmasını ve (isteğe bağlı olarak) Let's Encrypt SSL sertifikası kurulumunu otomatikleştirir.

---

## Özellikler

- **Sistem Güncellemesi:**
  - `apt update` ve `apt upgrade` kullanarak sistem paketlerini günceller.

- **LAMP Yığını Kurulumu:**
  - Apache, MySQL ve PHP (sürüm 8.1) ile gerekli modülleri (mbstring, curl, xml, zip, gd, intl, apcu) kurar.

- **Veritabanı Kurulumu:**
  - Sağlanan bilgilerle bir veritabanı oluşturur.
  - Uygun izinlerle bir veritabanı kullanıcısı oluşturur.

- **MediaWiki Kurulumu:**
  - Belirtilen sürümü (örneğin, 1.43.0) resmi Wikimedia sunucularından indirir.
  - Dosyaları `/var/www/html/mediawiki` konumuna çıkarır.
  - Mevcut bir MediaWiki kurulumu varsa yedekler.

- **Apache Yapılandırması:**
  - Apache için yeni bir VirtualHost yapılandırma dosyası oluşturur.
  - Apache yapılandırmasını test eder ve yeniden yükler.
  - Apache `rewrite` modülünü etkinleştirir.

- **SSL Sertifikası Kurulumu (İsteğe Bağlı):**
  - Kullanıcı tercih ederse Let's Encrypt SSL sertifikasını Certbot aracılığıyla kurar.

- **Etkileşimsiz Mod:**
  - `-y` bayrağını kullanarak scripti varsayılan değerlerle etkileşimsiz olarak çalıştırın.

- **Kayıt ve Hata Yönetimi:**
  - Tüm işlemleri `/var/log/mediawiki_install.log` dosyasına kaydeder.
  - Ayrıntılı hata mesajları sağlar ve hatalar durumunda güvenli bir şekilde sonlandırır.

---

## Ön Koşullar ve Uyarılar

- **Sistem:**
  - Debian/Ubuntu tabanlı Linux dağıtımları için tasarlanmıştır.

- **İzinler:**
  - Paket kurulumları ve yapılandırma değişiklikleri dahil olmak üzere bazı işlemler için `sudo` ayrıcalıkları gerektirir.
  - Kayıt dosyasını oluşturma ve yazma izinlerinin doğru olduğundan emin olun.

- **Güvenlik:**
  - Komut satırından veritabanı parolaları gibi hassas bilgileri işler.
  - Etkileşimsiz modda varsayılan parolaların kullanılması üretim ortamları için önerilmez.

- **Test:**
  - Scripti üretim ortamına dağıtmadan önce bir test ortamında test etmeniz şiddetle önerilir.

---

## Kurulum ve Kullanım

Tüm gerekli bağımlılıkların (örneğin, `lsb_release`, `mysqladmin`, `wget`, `tar`, `sudo`, `apache2ctl` ve isteğe bağlı olarak `certbot`) sisteminizde kurulu olduğundan emin olun.

### Tek Satırda Kurulum ve Çalıştırma

Scripti indirmek ve tek bir komutla çalıştırmak için terminalde aşağıdaki komutları çalıştırın:

```bash
curl -sL https://raw.githubusercontent.com/snipeTR/linux_utility/main/mediawikiinstaller/mediawiki-installer.sh | bash
