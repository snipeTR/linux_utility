# iptables Kurallarını Sıfırlama ve Tüm Trafiğe İzin Verme Scripti

Bu bash scripti, mevcut `iptables` kurallarını sıfırlayan, varsayılan politikaları tüm trafiğe izin verecek şekilde ayarlayan ve bu değişiklikleri kalıcı hale getiren bir scripttir. 

## Kullanım

Scripti çalıştırmak için aşağıdaki adımları izleyin:

1. Scripti bir dosyaya kaydedin, örneğin `reset_iptables.sh`.
2. Dosyayı çalıştırılabilir hale getirin:
    ```bash
    chmod +x reset_iptables.sh
    ```
3. Scripti çalıştırın:
    ```bash
    sudo ./reset_iptables.sh
    ```

## Adımlar

1. **Mevcut Kuralları Sıfırla**: 
    - `iptables -F`: Tüm mevcut iptables kurallarını sıfırlar.
    - `iptables -X`: Tüm kullanıcı tanımlı zincirleri siler.
    - `iptables -t nat -F`: NAT tablosundaki tüm kuralları sıfırlar.
    - `iptables -t mangle -F`: Mangle tablosundaki tüm kuralları sıfırlar.

2. **Varsayılan Politikaları ACCEPT Olarak Ayarla**:
    - `iptables -P INPUT ACCEPT`: Gelen trafiği kabul eder.
    - `iptables -P FORWARD ACCEPT`: Yönlendirilen trafiği kabul eder.
    - `iptables -P OUTPUT ACCEPT`: Giden trafiği kabul eder.

3. **Değişiklikleri Kaydet**:
    - `apt-get update -y`: Paket listelerini günceller.
    - `apt-get install -y iptables-persistent`: `iptables-persistent` paketini kurar.

4. **Kuralları Kalıcı Hale Getir**:
    - `netfilter-persistent save`: Mevcut `iptables` kurallarını kaydeder.
    - `netfilter-persistent reload`: Kaydedilen kuralları yeniden yükler.

Bu script, `iptables` kurallarını sıfırlayarak tüm trafiğe izin verir ve bu değişiklikleri kalıcı hale getirir.
