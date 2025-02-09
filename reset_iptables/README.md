# 🔐 Reset iptables Script

Bu betik, **Linux** sistemlerde kullanılan `iptables` güvenlik duvarı kurallarını sıfırlamak, tüm ağ trafiğine izin vermek ve yapılan değişiklikleri kalıcı hale getirmek için geliştirilmiştir. Özellikle ağ sorunlarını gidermek veya iptables yapılandırmasını temizlemek isteyen sistem yöneticileri için pratik bir çözümdür.

---

## 🚀 Nasıl Çalışır?

`reset_iptables.sh` betiği şu işlemleri otomatik olarak gerçekleştirir:

1. **Mevcut iptables Kurallarını Temizler**
2. **Varsayılan Politikaları Tüm Trafiğe İzin Verecek Şekilde Ayarlar**
3. **iptables-persistent Paketini Yükler (Kuralları Kalıcı Hale Getirmek İçin)**
4. **Yeni Kuralları Kaydeder ve Yükler**

Bu sayede ağ trafiği tamamen açılır ve kurallar sistem yeniden başlatıldığında da korunur.

---

## 📥 Kurulum ve Çalıştırma

### Tek Satırda İndirme ve Çalıştırma

```bash
curl -sSL https://github.com/snipeTR/linux_utility/raw/main/reset_iptables/reset_iptables.sh | sudo bash
```

Bu komut, betiği indirir ve doğrudan çalıştırır.

### Manuel Kurulum

1. Betiği GitHub'dan indir:

   ```bash
   git clone https://github.com/snipeTR/linux_utility.git
   cd linux_utility/reset_iptables
   ```

2. Çalıştırma izni ver:

   ```bash
   chmod +x reset_iptables.sh
   ```

3. Betiği çalıştır:

   ```bash
   sudo ./reset_iptables.sh
   ```

---

## 📝 Betik İçeriği ve Açıklamaları

```bash
#!/bin/bash

# 1. Mevcut kuralları sıfırla
echo "Mevcut iptables kuralları sıfırlanıyor..."
iptables -F               # Tüm iptables kurallarını temizler
iptables -X               # Kullanıcı tanımlı zincirleri siler
iptables -t nat -F        # NAT tablosundaki kuralları temizler
iptables -t mangle -F     # Mangle tablosundaki kuralları temizler

# 2. Varsayılan politikaları ACCEPT olarak ayarla
echo "Varsayılan politikalar ACCEPT olarak ayarlanıyor..."
iptables -P INPUT ACCEPT  # Gelen tüm trafiğe izin verir
iptables -P FORWARD ACCEPT # Yönlendirilen tüm trafiğe izin verir
iptables -P OUTPUT ACCEPT  # Giden tüm trafiğe izin verir

# 3. Değişiklikleri kaydet
echo "iptables-persistent kuruluyor ve kurallar kaydediliyor..."
apt-get update -y                       # Paket listesini günceller
apt-get install -y iptables-persistent  # iptables-persistent paketini yükler

# 4. Kuralları kalıcı hale getir
netfilter-persistent save               # Kuralları kaydeder
netfilter-persistent reload             # Kaydedilen kuralları uygular

echo "Tüm iptables kuralları sıfırlandı, tüm trafiğe izin verildi ve değişiklikler kalıcı hale getirildi."
```

### 📌 Komutların Açıklamaları

- **iptables -F**: Tüm mevcut iptables kurallarını temizler.
- **iptables -X**: Kullanıcı tanımlı zincirleri siler.
- **iptables -t nat -F**: NAT tablosundaki kuralları temizler.
- **iptables -t mangle -F**: Mangle tablosundaki kuralları temizler.
- **iptables -P INPUT/OUTPUT/FORWARD ACCEPT**: Tüm gelen, giden ve yönlendirilen trafiğe izin verir.
- **apt-get install iptables-persistent**: Kuralları kalıcı hale getirmek için gerekli paketi yükler.
- **netfilter-persistent save/reload**: Kuralları kaydeder ve yeniden yükler.

---

## ⚠️ Uyarılar

- **Güvenlik:** Bu betik tüm portları ve trafiği açar. Güvenlik risklerini önlemek için yalnızca ihtiyacınız olan portlara izin verecek kurallar ekleyebilirsiniz.
- **Root Yetkisi:** Betiğin çalışabilmesi için `sudo` yetkisine sahip olmanız gereklidir.

---

## 🤝 Katkıda Bulunma

Katkıda bulunmak isterseniz:

1. Fork'layın 🍴
2. Değişikliklerinizi yapın 🛠️
3. Pull request gönderin 🚀

---

## 📄 Lisans

Bu proje açık kaynaklıdır. Detaylar için `LICENSE` dosyasına göz atabilirsiniz.

