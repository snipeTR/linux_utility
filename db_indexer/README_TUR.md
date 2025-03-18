# MySQL Veritabanı İndeksleme Aracı

Bu Python betiği, MySQL veritabanlarınızdaki tabloları ve sütunları otomatik olarak indekslemenize yardımcı olan interaktif bir terminal aracıdır. `curses` kütüphanesi ile etkileşimli bir menü arayüzü sunar, `mysql.connector` ile veritabanı bağlantısını sağlar ve `rich` kütüphanesi ile renkli raporlama sunar.

## 🔧 Özellikler
- Tüm MySQL veritabanlarını listeleme ve seçme
- Seçilen veritabanın tablolarını listeleme ve seçme
- Tabloların sütunlarını listeleme ve indeksleme için seçme
- **Seçilen ve seçilmeyen sütunları renkli raporlama:**
  - 💚 **Yeşil:** İndexlenecek sütunlar
  - 🔴 **Kırmızı:** İndexlenmeyecek sütunlar
- Terminal içinden yukarı-aşağı gezebilme ve **enter** ile onaylama
- MySQL indeksleme için otomatik sorgular

---
## ⚡ Gereksinimler

1. **Python 3.6+** (Python 3.6 veya daha yeni bir sürüm gereklidir)
2. **MySQL Server** (Kurulu ve erişim bilgilerinizin hazır olması gerekir)
3. **Gerekli Python Paketleri:**

   Aşağıdaki komutu terminalinizde çalıştırarak gerekli bağımlılıkları yükleyebilirsiniz:

   ```bash
   pip3 install mysql-connector-python rich
   ```

   `curses` kütüphanesi genellikle Python ile gelir. İşletim sisteminize göre farklı özelleştirme gerekebilir.

---
## 📚 Kurulum

### 1. Python 3'ü Kurma
Python'un en son sürümünü indirmek ve kurmak için [resmi Python sitesi](https://www.python.org/downloads/)ni ziyaret edin.

### 2. Betiği İndirme

Betiği terminalden şu komutla indirebilirsiniz:

```bash
wget -O cli_mysql_indexer.py https://raw.githubusercontent.com/snipeTR/linux_utility/main/db_indexer/cli_mysql_indexer.py
```

Ardından dosyayı çalıştırılabilir hale getirin:

```bash
chmod +x cli_mysql_indexer.py
```

Alternatif olarak, betiği elle indirip Python ile çalıştırabilirsiniz.

---
## ⚡ Kullanım

Betik çalıştırmak için aşağıdaki komutu kullanabilirsiniz:

```bash
python3 cli_mysql_indexer.py
```

### Terminalde Etkileşimli Seçenekler
- **Veritabanı Seçimi**: Kullanıcıya sunucu üzerindeki tüm veritabanları listelenir ve birini seçmesi istenir.
- **Tablo Seçimi**: Seçilen veritabanın içindeki tüm tablolar listelenir.
- **Sütun Seçimi**: Kullanıcı, indekslemek istediği sütunları belirler.
- **Renkli Raporlama**: İndexlenecek sütunlar yeşil, indexlenmeyecek olanlar kırmızı gösterilir.
- **Onay Mekanizması**: Kullanıcıdan son onay alındıktan sonra indeksleme başlatılır.

---
## 🚀 Örnek Kullanım Senaryosu

```bash
python3 cli_mysql_indexer.py
```

1. MySQL Bağlantı bilgilerini girin veya varsayılan bilgileri onaylayın.
2. Mevcut veritabanlarından birini seçin.
3. İçinde indeksleme yapmak istediğini tabloları belirleyin.
4. Seçilen tabloların sütunlarını gözden geçirin ve indeksleme yapmak istediklerinizi seçin.
5. Terminalde indekslenecek ve indekslenmeyecek sütunları renkli olarak görün.
6. Onay verdikten sonra indeksleme başlatılır ve tamamlandığında bildirilir.

---
## ⚠ Notlar
- İşlem sırasında tabloların yapısı değişebileceği için **yüdüksek boyutlu veritabanlarında önce test edilmesi önerilir**.
- `curses` bazı sistemlerde uyumsuzluk çıkarabilir. Terminalinizin desteklediği bir Python ortamı kullandığınızdan emin olun.
- **Veritabanınızı yedekleyin!** Herhangi bir işlem yapmadan önce mevcut veritabanının bir yedeğini almak iyi bir uygulamadır.

## Uzun Süren İşlemler İçin Öneri

İşlemler, veritabanının boyutuna bağlı olarak uzun sürebilir. Kesintisiz çalışmasını sağlamak için `tmux` veya `screen` gibi araçları kullanabilirsiniz. Bu araçlar, terminal oturumlarını arka planda çalıştırmanıza ve bağlantınız kesildiğinde bile işlemlerin devam etmesini sağlar.

### **tmux Kullanımı**

1. Yeni bir `tmux` oturumu başlatın:
    ```bash
    tmux new -s my_session
    ```
2. Betiği çalıştırın:
    ```bash
    python3 all_index.sh
    ```
3. `tmux` oturumundan çıkmak için:
    ```bash
    Ctrl + B, ardından D
    ```
4. Oturuma geri dönmek için:
    ```bash
    tmux attach -t my_session
    ```

### **screen Kullanımı**

1. Yeni bir `screen` oturumu başlatın:
    ```bash
    screen -S my_session
    ```
2. Betiği çalıştırın:
    ```bash
    python3 all_index.sh
    ```
3. `screen` oturumundan çıkmak için:
    ```bash
    Ctrl + A, ardından D
    ```
4. Oturuma geri dönmek için:
    ```bash
    screen -r my_session
    ```

Bu yöntemlerle indeksleme işlemi, bağlantınız kesilse bile devam eder. Özellikle büyük veritabanlarıyla çalışırken önerilir.


---
## 🌟 Katkı Sağlama

Bu projeye katkıda bulunmak ister misiniz? Pull request (PR) oluşturarak veya issue açarak geri bildirimde bulunabilirsiniz! 🚀

**Repo Bağlantısı:** [https://github.com/snipeTR/linux_utility](https://github.com/snipeTR/linux_utility)



