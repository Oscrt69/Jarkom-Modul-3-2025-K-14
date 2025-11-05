# Jarkom-Modul-3-2025-K-14

| Nama                         | Nrp        |
| ---------------------------- | ---------- |
| Oscaryavat Viryavan          | 5027241053 |
| Mohamad Arkan Zahir Asyafiq  | 5027241120 |

# 1

Di awal buatlah topologi sesuai dengan soal.

<img width="600" height="495" alt="Modul 3" src="https://github.com/user-attachments/assets/7573f66c-52de-47e1-a5f7-4e625c574546" />

Tujuan dari soal ini adalah menyiapkan seluruh node di topologi GNS3 agar dapat terhubung satu sama lain (antar subnet melalui router utama “Durin”), dan memiliki akses internet sementara, khususnya agar semua node bisa melakukan update package (apt update, apt install, dsb) sebelum jaringan DHCP dan DNS permanen dibangun.

Langkah-Langkah Pengerjaan
1️. Pastikan semua node sudah aktif
2. Cek konektivitas antar node, Pastikan dari node mana pun bisa ping ke router Durin:
```
ping 10.15.43.33
```
(ganti 10.15.43.33 sesuai IP Durin)

3. Tambahkan resolver sementara

Edit file `/etc/resolv.conf` di setiap node:
```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

## Uji coba output

```
ping google.com
apt update
```

# 2



# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
# 11
# 12
# 13
# 14
# 15
# 16
# 17
# 18
# 19
# 20
