#!/bin/bash

# 1. Mevcut kuralları sıfırla
echo "Mevcut iptables kuralları sıfırlanıyor..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# 2. Varsayılan politikaları ACCEPT olarak ayarla
echo "Varsayılan politikalar ACCEPT olarak ayarlanıyor..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# 3. Değişiklikleri kaydet
echo "iptables-persistent kuruluyor ve kurallar kaydediliyor..."
apt-get update -y
apt-get install -y iptables-persistent

# 4. Kuralları kalıcı hale getir
netfilter-persistent save
netfilter-persistent reload

echo "Tüm iptables kuralları sıfırlandı, tüm trafiğe izin verildi ve değişiklikler kalıcı hale getirildi."
