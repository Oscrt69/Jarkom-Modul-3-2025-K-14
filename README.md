# Jarkom-Modul-3-2025-K-14

| Nama                         | Nrp        |
| ---------------------------- | ---------- |
| Oscaryavat Viryavan          | 5027241053 |
| Mohamad Arkan Zahir Asyafiq  | 5027241120 |

# 1

Di awal buatlah topologi sesuai dengan soal.

<img width="600" height="495" alt="Modul 3" src="https://github.com/user-attachments/assets/7573f66c-52de-47e1-a5f7-4e625c574546" />

Tujuan dari soal ini adalah menyiapkan seluruh node di topologi GNS3 agar dapat terhubung satu sama lain (antar subnet melalui router utama “Durin”), dan memiliki akses internet sementara, khususnya agar semua node bisa melakukan update package (apt update, apt install, dsb) sebelum jaringan DHCP dan DNS permanen dibangun.

## Langkah-Langkah Pengerjaan: <br>

1️. Pastikan semua node sudah aktif 
<br>

2. Cek konektivitas antar node, Pastikan dari node mana pun bisa ping ke router Durin: <br>
```
ping 10.15.43.33
```
(ganti 10.15.43.33 sesuai IP Durin)
<br>

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

Tujuan dari soal ini adalah menjadikan node Durin sebagai router utama dan DHCP Relay Agent dalam topologi jaringan. Durin bertugas: <br>

1. Meneruskan paket antar subnet, sehingga seluruh node (client maupun server) dapat saling berkomunikasi. <br>

2. Menghubungkan jaringan internal ke internet menggunakan NAT (Network Address Translation).<br>

3. Meneruskan permintaan DHCP dari client ke server DHCP (Aldarion), karena DHCP server hanya berada di satu jaringan. <br>

Tanpa konfigurasi ini, node lain seperti Amandil, Gilgalad, atau Khamul tidak akan bisa memperoleh alamat IP secara otomatis.

## Langkah-langkah Konfigurasi <br>

1️. Aktifkan IP Forwarding <br>

IP forwarding mengizinkan Durin untuk meneruskan paket antar jaringan (fungsi dasar router). <br>

2. Jalankan perintah berikut: <br>
```
echo 1 > /proc/sys/net/ipv4/ip_forward
```
<br>
Agar permanen setelah reboot, tambahkan pada file /etc/sysctl.conf:

```
net.ipv4.ip_forward=1
```

Lalu aktifkan konfigurasi:
```
sysctl -p
```

2. Konfigurasi NAT (Network Address Translation) <br>

Durin perlu menerjemahkan alamat IP lokal (private) ke alamat publik agar node lain bisa mengakses internet. <br>

Tambahkan rule berikut:
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Penjelasan: <br>

> -t nat → menggunakan tabel NAT. <br>

> POSTROUTING → aturan diterapkan pada paket keluar. <br>

> -o eth0 → interface keluar ke internet (hubungan ke NAT Cloud). <br>

> MASQUERADE → mengganti alamat sumber dengan IP router (Durin). <br>

3. Instal dan Konfigurasikan DHCP Relay <br>

Durin tidak membagikan IP secara langsung, tapi meneruskan permintaan DHCP dari client ke server Aldarion. <br>

```
apt update
apt install isc-dhcp-relay -y
```

Saat instalasi, akan muncul prompt konfigurasi:

Servers → isi dengan IP DHCP Server: 10.15.43.34

Interfaces → isi dengan interface yang terhubung ke client (misalnya eth1, eth2, dll).

Options → kosongkan.

Atau edit manual di file:

/etc/default/isc-dhcp-relay


Isi file:
```
SERVERS="10.15.43.34"
INTERFACES="eth1 eth2 eth3"
OPTIONS=""
```

Restart service:
```
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
```

4. Verifikasi Status Layanan <br>

Cek apakah DHCP relay aktif:

```
systemctl status isc-dhcp-relay
```

## Uji Coba

Uji 1 <br>

Coba dari salah satu node client (misal: Amandil atau Gilgalad):
```
ping 8.8.8.8
ping google.com
```

Uji 2 <br>

Pastikan server DHCP (Aldarion) sudah dikonfigurasi lebih dulu.
Lalu dari node client (Gilgalad / Amandil):

```
dhclient -v
```

Uji 3 <br>

Untuk memastikan relay benar-benar meneruskan permintaan:
```
journalctl -u isc-dhcp-relay | tail -n 10
```

Akan muncul log seperti:
```
Forwarded BOOTREQUEST for 10.15.43.68 to 10.15.43.34
```

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
