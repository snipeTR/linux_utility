# 🖱️ Tmux Mouse ve Kopyalama Desteği Etkinleştirme

Bu script, Tmux'ta mouse desteğini etkinleştirir ve terminalin doğal kopyalama/yapıştırma işlevini korur.

---

## 🚀 Kurulum ve Çalıştırma

Tek satırda script'i indirip çalıştırmak için:

```bash
curl -o tmux_mouse_enable.sh https://raw.githubusercontent.com/username/repo/main/tmux_mouse_enable.sh && chmod +x tmux_mouse_enable.sh && ./tmux_mouse_enable.sh
```

---

## 📝 Manuel Kurulum

1. **Script'i indir:**

```bash
wget https://raw.githubusercontent.com/username/repo/main/tmux_mouse_enable.sh
```

2. **Çalıştırma izni ver:**

```bash
chmod +x tmux_mouse_enable.sh
```

3. **Script'i çalıştır:**

```bash
./tmux_mouse_enable.sh
```

---

## 🎯 Ne Yapıyor?

✅ Tmux ve `xclip` veya `xsel` bağımlılıklarını kurar.  
✅ `~/.tmux.conf` dosyasını günceller ve mouse desteğini etkinleştirir.  
✅ Mevcut Tmux oturumlarına yapılandırmayı otomatik uygular.  

---

## 💡 Sorun Giderme

- Eğer yapılandırma aktif olmazsa Tmux oturumunu kapatıp tekrar açın:

```bash
tmux kill-server
tmux
```

- Tmux yapılandırmasını manuel olarak yeniden yüklemek isterseniz:

```bash
tmux source-file ~/.tmux.conf
```

---

## 🛑 Not
Script, yapılandırmanızı yedekler (`~/.tmux.conf.bak`). Eski yapılandırmayı geri yüklemek için:

```bash
cp ~/.tmux.conf.bak ~/.tmux.conf
```

Herhangi bir sorun yaşarsanız buradan iletişime geçebilirsiniz! 😊
