# Jarkom-Modul-3-2025-K-14

| Nama                         | Nrp        |
| ---------------------------- | ---------- |
| Oscaryavat Viryavan          | 5027241053 |
| Mohamad Arkan Zahir Asyafiq  | 5027241120 |

# SOAL 1

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

# SOAL 2

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

# SOAL 3

Tujuan dari soal ini adalah mengonfigurasi Aldarion sebagai DHCP Server yang memberikan alamat IP otomatis kepada seluruh node client di jaringan.
Dengan konfigurasi ini, setiap node (seperti Gilgalad, Amandil, Khamul, dan node lainnya) dapat memperoleh: <br>

1. Alamat IP sesuai subnetnya, <br>

2. Gateway yang benar (mengarah ke Durin sebagai router), <br>

3. DNS server otomatis (biasanya mengarah ke Mordor atau DNS eksternal seperti 8.8.8.8). <br>

Aldarion bekerja bersama Durin (DHCP Relay) agar dapat melayani beberapa subnet jaringan. <br>

## Langkah-langkah Konfigurasi
1. Jalankan perintah berikut di node Aldarion:

```
apt update
apt install isc-dhcp-server -y
```

2. Buka file konfigurasi interface DHCP: <br>

```
nano /etc/default/isc-dhcp-server
```

Ubah baris berikut: <br>

```
INTERFACESv4="eth0"
INTERFACESv6=""
```
Sesuaikan eth0 dengan interface yang terhubung ke jaringan internal (Durin). <br>

3. Konfigurasi File Utama DHCP <br>

Edit file:
```
nano /etc/dhcp/dhcpd.conf
```

Kemudian isi konfigurasi subnet untuk masing-masing jaringan.

```
# Subnet untuk jaringan Gilgalad
subnet 10.15.43.64 netmask 255.255.255.192 {
    range 10.15.43.66 10.15.43.126;
    option routers 10.15.43.65;
    option broadcast-address 10.15.43.127;
    option domain-name-servers 10.15.43.35;
    default-lease-time 360;
    max-lease-time 7200;
}

# Subnet untuk jaringan Amandil
subnet 10.15.43.128 netmask 255.255.255.128 {
    range 10.15.43.130 10.15.43.190;
    option routers 10.15.43.129;
    option broadcast-address 10.15.43.191;
    option domain-name-servers 10.15.43.35;
    default-lease-time 360;
    max-lease-time 7200;
}

# Subnet tanpa DHCP (link ke Durin)
subnet 10.15.43.32 netmask 255.255.255.248 {
}
```

Penjelasan:

> range → alamat IP yang akan diberikan secara dinamis ke client.

> routers → alamat gateway (Durin) untuk subnet tersebut.

> domain-name-servers → IP DNS server (bisa Mordor / 8.8.8.8).

> lease-time → lama waktu peminjaman IP sebelum diperpanjang.

4. Restart DHCP Server <br>

Setelah file selesai dikonfigurasi, restart service-nya:

```
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
```

5. Verifikasi Status DHCP Server <br>

Pastikan server aktif dan tidak ada error konfigurasi:<br>

```
systemctl status isc-dhcp-server
```

Untuk memeriksa log aktivitas DHCP: <br>

```
journalctl -u isc-dhcp-server | tail -n 10
```

## Uji Coba

Uji 1 

Masuk ke salah satu node client (misalnya Gilgalad atau Amandil), lalu jalankan:

```
dhclient -v
```

Hasil yang diharapkan:

```
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 3
DHCPOFFER from 10.15.43.34
DHCPREQUEST for 10.15.43.68
DHCPACK from 10.15.43.34
bound to 10.15.43.68 -- renewal in 300 seconds.
```

Artinya client berhasil memperoleh IP dari Aldarion melalui Durin (relay). <br>

Uji 2  <br>
```
ip addr show eth0
```

Hasilnya akan memperlihatkan IP yang diberikan sesuai range subnet masing-masing:

Uji 3 — Uji koneksi antar node dan internet  <>br.

Coba dari client:

```
ping 10.15.43.34    # ke Aldarion
ping 10.15.43.33    # ke Durin
ping google.com     # ke internet
```

Semua harus berhasil jika router Durin (soal 2) dan DNS server (soal 4) sudah benar.

# SOAL 4

Tujuan dari soal ini adalah untuk mengatur lease time alamat IP pada server DHCP agar sesuai dengan kebijakan Raja Aldarion. <br>
Adapun ketentuannya sebagai berikut:

> Lease time Amandil 30 menit.

> Lease time Gilgalad 10 menit.

> Lease maksimum untuk semua client → 1 jam.

Dengan konfigurasi ini, IP address akan lebih cepat direalokasikan ke perangkat lain jika node lama sudah tidak aktif dan meningkatkan efisiensi penggunaan IP. <br>

### Langkah-langkah Konfigurasi
1. Buka Konfigurasi DHCP Server <br>

Edit file konfigurasi utama DHCP:
```
nano /etc/dhcp/dhcpd.conf
```

2. Tambahkan atau Sesuaikan Subnet Setiap Keluarga <br>

Ubah pengaturan subnet yang sudah dibuat pada soal nomor 3, lalu tambahkan parameter lease time sesuai ketentuan. <br>

Contoh konfigurasi lengkap:

```
# Subnet untuk Keluarga Manusia (Amandil)
subnet 10.15.43.64 netmask 255.255.255.192 {
    range 10.15.43.66 10.15.43.94;
    option routers 10.15.43.65;
    option broadcast-address 10.15.43.95;
    option domain-name-servers 10.15.43.35;
    default-lease-time 1800;  # 30 menit
    max-lease-time 3600;      # 1 jam
}

# Subnet untuk Keluarga Peri (Gilgalad)
subnet 10.15.43.96 netmask 255.255.255.192 {
    range 10.15.43.98 10.15.43.126;
    option routers 10.15.43.97;
    option broadcast-address 10.15.43.127;
    option domain-name-servers 10.15.43.35;
    default-lease-time 600;   # 10 menit
    max-lease-time 3600;      # 1 jam
}

# Subnet tanpa DHCP (jaringan router Durin)
subnet 10.15.43.32 netmask 255.255.255.248 {
}
```

Semua subnet diarahkan ke DNS server Erendis (10.15.43.35).

3. Simpan dan Restart DHCP Server <br>

```
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
```

Periksa apakah konfigurasi benar:

```
systemctl status isc-dhcp-server
```

Jika berhasil, akan muncul status: `Active: active (running)`

### Uji Coba (Testing)

Uji 1<br>
Masuk ke node Amandil lalu jalankan:
```
dhclient -v
```

Output yang diharapkan:

```
DHCPDISCOVER on eth0 to 255.255.255.255 port 67
DHCPOFFER from 10.15.43.34
DHCPREQUEST for 10.15.43.70
DHCPACK from 10.15.43.34
bound to 10.15.43.70 -- renewal in 1800 seconds.
```

Artinya lease time = 1800 detik (30 menit).

Uji 2 <br>

Masuk ke node Gilgalad lalu jalankan:
```
dhclient -v
```

Output yang diharapkan:
```
bound to 10.15.43.100 -- renewal in 600 seconds.
```

Artinya lease time = 600 detik (10 menit).

Uji 3 <br>

Masuk ke node Aldarion dan lihat daftar lease:

```
cat /var/lib/dhcp/dhcpd.leases
```

Contoh hasil:

```
lease 10.15.43.70 {
  starts 4 2025/11/06 05:00:00;
  ends 4 2025/11/06 05:30:00;
  cltt 4 2025/11/06 05:00:00;
  binding state active;
  next binding state free;
  hardware ethernet 02:42:ac:11:00:1a;
  uid "\001\002B\254\241\305\034";
  client-hostname "Amandil";
}
```

Uji 4 <br>

Setelah waktu lease hampir habis, jalankan perintah:

```
dhclient -r && dhclient -v
```

Pastikan IP tetap sama (DHCP renew success).

# SOAL 5

Tujuan soal ini adlaah mengonfigurasi **DNS Server utama** untuk domain `k14.com` yang melayani seluruh host dalam jaringan menggunakan layanan **Bind9**.

DNS server ini memungkinkan setiap node di jaringan dapat diakses menggunakan **nama domain (FQDN)** seperti `elros.k14.com`, `pharazon.k14.com`, `galadriel.k14.com`, dan sebagainya.

## Langkah-langkah Pengerjaan 

### 1. Instalasi Bind9

```
apt-get update
apt-get install bind9 -y
```

2. Konfigurasi Zona di /etc/bind/named.conf.local <br>
Tambahkan:

```
zone "k14.com" {
    type master;
    file "/etc/bind/zone/db.k14.com";
};
```

3. Buat Zone File /etc/bind/zone/db.k14.com <br>
Contoh isinya:

```
$TTL    604800
@       IN      SOA     ns1.k14.com. root.k14.com. (
                        2         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL
;
@       IN      NS      ns1.k14.com.
@       IN      NS      ns2.k14.com.

ns1     IN      A       192.218.3.3
ns2     IN      A       192.218.3.4

elros   IN      A       192.218.1.35
pharazon IN     A       192.218.2.36
elendil IN      A       192.218.1.37
isildur IN      A       192.218.1.17
anarion IN      A       192.218.1.19
galadriel IN    A       192.218.2.3
celeborn IN     A       192.218.2.4
oropher IN      A       192.218.2.5
palantir IN     A       192.218.3.5
```

4. Restart Service
   
```
service bind9 restart
```

5. Uji dengan dig <br>

```

dig @192.218.3.4 k14.com NS
dig @192.218.3.4 elros.k14.com +short
dig @192.218.3.4 galadriel.k14.com +short
dig @192.218.3.4 palantir.k14.com +short
```

Contoh output:<br>

```
k14.com. 604800 IN NS ns2.k14.com.
k14.com. 604800 IN NS ns1.k14.com.
```

Dan hasil resolve: <br>

```
elros.k14.com -> 192.218.1.35
pharazon.k14.com -> 192.218.2.36
palantir.k14.com -> 192.218.3.5
```

<img width="1349" height="975" alt="image" src="https://github.com/user-attachments/assets/57287333-7a52-47c7-8a49-823389a0fe49" />


# SOAL 6

Soal ini bertujuan ntuk memastikan bahwa DNS lokal (192.218.5.2) tidak hanya bisa menjawab domain internal (k14.com), tapi juga bisa meneruskan (forward) ke internet global (seperti google.com). <br>

Langkah Uji: <br>

Restart Service <br>

```
service bind9 restart
```

Dari node mana pun (misalnya Elendil), lakukan:

```
dig @192.218.5.2 google.com
```

Jika muncul hasil seperti:

```
;; ANSWER SECTION:
google.com. IN A 74.125.68.100
google.com. 241 IN A 74.125.68.101
...
;; SERVER: 192.218.5.2#53(192.218.5.2)
...
```

maka DNS berhasil resolve domain eksternal. <br>

<img width="976" height="586" alt="image" src="https://github.com/user-attachments/assets/15997fc0-d200-4428-8e4f-fdcd1a2a2ee0" />

# SOAL 7

Tujuan soal ini yaitu membangun dua server Laravel yaitu: <br>
> - **Elendil (192.218.1.37:8001)**
> - **Anarion (192.218.1.19:8003)**  

Setiap server menjalankan aplikasi Laravel default page dengan Nginx dan PHP-FPM, serta dapat diakses melalui domain: <br>
- `http://elendil.k14.com:8001`
- `http://anarion.k14.com:8003`


## Langkah Pengerjaan

### 1. Instalasi Dependensi

```
apt-get update
apt-get install nginx php php-fpm php-mbstring php-xml php-bcmath php-json php-tokenizer composer unzip git -y
```

### 2. Kloning Laravel

```
cd /var/www/
git clone https://github.com/laravel/laravel.git .
composer install
cp .env.example .env
php artisan key:generate
```

### 3. Konfigurasi Nginx (/etc/nginx/sites-available/laravel)

```
server {
    listen 8001;                     # Elendil -> 8001 | Anarion -> 8003
    server_name elendil.k14.com;     # ubah sesuai node
    root /var/www/public;

    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```
Aktifkan konfigurasi:

```
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
service nginx restart
```

Pengujian <br>
1. Cek via curl <br>

```
curl http://elendil.k14.com:8001/
curl http://anarion.k14.com:8003/
```

Output menampilkan HTML halaman Laravel (<!DOCTYPE html>, <title>Laravel</title>).

2. Cek via lynx

```
lynx http://192.218.1.37:8001
```
Menampilkan halaman teks Laravel berisi: 

```
Documentation
Laracasts
Laravel News
Vibrant Ecosystem
```

<img width="672" height="41" alt="image" src="https://github.com/user-attachments/assets/703115da-5485-4b45-ae25-f3a60c9e5695" />

<img width="1069" height="106" alt="image" src="https://github.com/user-attachments/assets/ece9cf45-d573-45e2-a4b7-bd4c54fde2fe" />

<img width="1600" height="640" alt="image" src="https://github.com/user-attachments/assets/56363148-51fa-4977-b8c3-24fba3636bd4" />

<img width="1600" height="328" alt="image" src="https://github.com/user-attachments/assets/43ab2f38-433e-444f-9bdf-f2b7064e5c4d" />


# SOAL 8

Tujuan soal inii yaitu mengonfigurasi **Pharazon** agar melakukan **Weighted Load Balancing** (pembagian beban berdasarkan bobot) terhadap tiga server PHP worker:
- **Galadriel** (`192.218.2.3:8004`)
- **Celeborn** (`192.218.2.4:8005`)
- **Oropher** (`192.218.2.5:8006`)

Metode ini memastikan **Galadriel** mendapat porsi request lebih banyak dibanding dua worker lainnya. <br>

## Topologi Node yang Terlibat

| Node | Fungsi | IP | Port |
|------|---------|----|------|
| **Pharazon** | Load Balancer | 192.218.1.36 | 80 |
| **Galadriel** | PHP Worker 1 | 192.218.2.3 | 8004 |
| **Celeborn** | PHP Worker 2 | 192.218.2.4 | 8005 |
| **Oropher** | PHP Worker 3 | 192.218.2.5 | 8006 |
| **Miriel** | Client penguji | 192.218.1.11 | — |


## Konsep Weighted Load Balancing
Weighted load balancing memungkinkan distribusi request **tidak merata**, tetapi **proporsional terhadap bobot (weight)** yang diberikan pada tiap server. <br>

Misal:
```
upstream php_cluster {
    server galadriel weight=3;
    server celeborn weight=2;
    server oropher weight=1;
}
```
Maka dari total 6 request, server: <br>

> Galadriel menangani 3,

> Celeborn 2,

> Oropher 1.

Langkah Pengerjaan <br>

1. Buka Konfigurasi Nginx di Pharazon
Edit konfigurasi yang sebelumnya dibuat pada soal 7:

```
nano /etc/nginx/sites-available/loadbalancer
```

Ganti bagian upstream menjadi konfigurasi berbobot:

```
upstream php_cluster {
    server 192.218.2.3:8004 weight=3;  # Galadriel
    server 192.218.2.4:8005 weight=2;  # Celeborn
    server 192.218.2.5:8006 weight=1;  # Oropher
}
```
Pastikan bagian server tetap sama:

```
server {
    listen 80;
    server_name pharazon.k14.com;

    location / {
        proxy_pass http://php_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

1. Validasi & Restart Nginx

```
nginx -t
service nginx restart
```

3. Uji Coba dari Client (Miriel)
Gunakan perintah for loop untuk mengirim banyak request:

```
for i in {1..30}; do
  curl -u noldor:silvan http://pharazon.k14.com/ 2>/dev/null | grep "Hostname"
done | sort | uniq -c
```
Hasil Pengujian (Contoh Output) <br>

```
 15  Hostname: Galadriel
 10  Hostname: Celeborn
  5  Hostname: Oropher
```

Uji Akses Langsung ke Worker <br>
Gunakan perintah berikut untuk memastikan semua worker tetap aktif: <br>.

```
curl -u noldor:silvan http://galadriel.k14.com:8004/
curl -u noldor:silvan http://celeborn.k14.com:8005/
curl -u noldor:silvan http://oropher.k14.com:8006/
```
Output tiap worker akan menampilkan:

```
=== Taman Peri - PHP Worker ===
Hostname: (Nama Worker)
Server IP: 192.218.2.X
PHP Version: 8.4.11
```

# SOAL 9

Tujuan soal yaitu Menambahkan **Basic Authentication** pada server **Pharazon** agar hanya pengguna dengan kredensial tertentu yang dapat mengakses layanan load balancer `pharazon.k14.com`.  
Dengan konfigurasi ini, hanya user `noldor` dengan password `silvan` yang bisa mengakses halaman dari worker PHP (Galadriel, Celeborn, Oropher).

Topologi Node

| Node | Fungsi | IP | Port |
|------|---------|----|------|
| **Pharazon** | Load Balancer | 192.218.1.36 | 80 |
| **Galadriel** | Worker 1 | 192.218.2.3 | 8004 |
| **Celeborn** | Worker 2 | 192.218.2.4 | 8005 |
| **Oropher** | Worker 3 | 192.218.2.5 | 8006 |
| **Miriel** | Client Penguji | 192.218.1.11 | — |

---

## Konsep <br>
Basic Authentication adalah metode otentikasi HTTP bawaan Nginx yang meminta username dan password sebelum user bisa mengakses halaman web.  
Ketika user mengakses `pharazon.k14.com`, Nginx akan:
1. Mengecek apakah ada kredensial di header `Authorization`.
2. Jika tidak ada → kirim respons `401 Authorization Required`.
3. Jika ada dan cocok dengan file `.htpasswd` → izinkan akses ke worker.


## Langkah-Langkah Konfigurasi <br>

1. Instal paket autentikasi di Pharazon <br>
```
apt-get install apache2-utils -y
```
2️. Buat file kredensial pengguna
```
htpasswd -c /etc/nginx/htpasswd noldor
```
Kemudian masukkan password:

```
silvan
```

File /etc/nginx/htpasswd akan berisi hasil enkripsi dari password tersebut.

3. Tambahkan konfigurasi Basic Auth di Nginx <br>
Edit konfigurasi load balancer:

```
nano /etc/nginx/sites-available/loadbalancer
```
Tambahkan baris berikut di dalam blok location /:

```
auth_basic "Restricted Access";
auth_basic_user_file /etc/nginx/htpasswd;
```

Sehingga hasil akhirnya seperti ini:

```
upstream php_cluster {
    server 192.218.2.3:8004 weight=3;
    server 192.218.2.4:8005 weight=2;
    server 192.218.2.5:8006 weight=1;
}

server {
    listen 80;
    server_name pharazon.k14.com;

    location / {
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/htpasswd;

        proxy_pass http://php_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
4. Cek sintaks dan restart Nginx
   
```
nginx -t
service nginx restart
```

5 Uji Akses dari Client (Miriel) <br>
Akses tanpa login
```
curl http://pharazon.k14.com/
```
Output:

```
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx</center>
</body>
</html>
```
Akses dengan login <br>

```
curl -u noldor:silvan http://pharazon.k14.com/
```

Output: 

```
=== Taman Peri - PHP Worker ===
Hostname: Galadriel
Server IP: 192.218.2.3
PHP Version: 8.4.11
```

# SOAL 10

1. Instal Nginx di Node Elros
```
apt-get install nginx -y
```

2. Buat file konfigurasi load balancer
Buka file:

```
nano /etc/nginx/sites-available/elros
```
Isi dengan konfigurasi berikut:
```
upstream php_cluster {
    server 192.218.1.37:8001;   # Elendil
    server 192.218.1.38:8002;   # Isildur
    server 192.218.1.39:8003;   # Anarion
}

server {
    listen 80;
    server_name elros.k14.com;

    location / {
        proxy_pass http://php_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
3. Aktifkan konfigurasi br<>


```
ln -s /etc/nginx/sites-available/elros /etc/nginx/sites-enabled/
nginx -t
service nginx restart
```
4. Pastikan DNS Resolver sudah dikonfigurasi <br>
Tambahkan domain di server DNS (pada Elendil / NS server):

```
elros    IN  A   192.218.1.35
```
Uji Coba Load Balancer <br>
Tes akses load balancer dari client (Miriel)

```
curl http://elros.k14.com/
curl http://elros.k14.com/api/airing
```

Output:

```
{"data":[],"message":"succeed"}
```
Artinya request diteruskan ke salah satu worker dan berhasil diproses. <br>

Tes load balancing berulang untuk memastikan request dibagi ke beberapa worker, jalankan:

```
for i in {1..6}; do
    echo "Request $i:"
    curl -s http://elros.k14.com/api/airing
    echo ""
done
```
Output:

```
Request 1:
{"data":[],"message":"succeed"}
Request 2:
{"data":[],"message":"succeed"}
Request 3:
{"data":[],"message":"succeed"}
Request 4:
{"data":[],"message":"succeed"}
Request 5:
{"data":[],"message":"succeed"}
Request 6:
{"data":[],"message":"succeed"}
✅ Semua request berhasil — menandakan load balancer berfungsi dan worker aktif.
```
Tes langsung ke masing-masing worker <br>
Gunakan port sesuai masing-masing worker:

```
curl http://elendil.k14.com:8001/
curl http://isildur.k14.com:8002/
curl http://anarion.k14.com:8003/
```
Hasilnya menampilkan halaman Laravel atau PHP Worker, menandakan semua worker siap menerima request.

<img width="737" height="646" alt="image" src="https://github.com/user-attachments/assets/04ad1d05-ead3-4290-88f2-f72903fab40f" />

<img width="1056" height="392" alt="image" src="https://github.com/user-attachments/assets/9330facb-d4a1-44f4-a036-6a9b983c1657" />


# SOAL 11

## 📊 Perbandingan Hasil Pengujian Apache Benchmark

| **Metrik** | **Uji 1** | **Uji 2** | **Perbedaan** | **Analisis** |
|-------------|------------|------------|----------------|---------------|
| **Requests per second** | 463.09 | 452.26 | ↓ 2.3% | Fluktuasi wajar |
| **Time per request** | 21.59 ms | 22.11 ms | +0.52 ms | Stabil |
| **Transfer rate** | 138.84 KB/s | 135.59 KB/s | ↓ 3.25 KB/s | Tidak signifikan |
| **Failed requests** | 0 | 0 | — | Tidak ada error |


📈 **Kesimpulan Singkat:**  
Kedua pengujian menunjukkan performa yang hampir identik dengan perbedaan di bawah 3%.  
Tidak ada error atau penurunan signifikan, sehingga sistem load balancing bekerja **stabil dan efisien**.

<img width="1600" height="816" alt="image" src="https://github.com/user-attachments/assets/61f6bc44-2644-4e21-8c42-9cb074434e85" />

<img width="1450" height="865" alt="image" src="https://github.com/user-attachments/assets/4fcd027b-41de-4b6b-a586-bfd3a2212b29" />


# SOAL 12

<img width="777" height="365" alt="image" src="https://github.com/user-attachments/assets/f4c86311-a8b0-4392-9ebd-a341bb7bd5a4" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/5881675d-f451-4517-ab91-4fd7bcb5124e" />

<img width="940" height="341" alt="image" src="https://github.com/user-attachments/assets/035c27b8-af42-4dbf-a61f-fa1808e8a9e2" />

<img width="795" height="328" alt="image" src="https://github.com/user-attachments/assets/62eb0ac9-228b-44e4-a041-f74c64fa211b" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/2e1f982c-a8b5-4970-ab91-c8dd29662c60" />


# SOAL 13


# 14

<img width="1026" height="347" alt="image" src="https://github.com/user-attachments/assets/22fe05a5-c82c-4444-b0f7-501f3d905f16" />


# SOAL 15

<img width="1019" height="527" alt="image" src="https://github.com/user-attachments/assets/d96ff59c-24ad-4f33-9793-0fa9049cf305" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/8cb4cb0c-24ec-4268-b6fe-9cf19b3fb5b1" />


# SOAL 16

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/0ed67527-4cdf-4da4-9985-a0a97c7e2a0e" />


# 17



# 18
# 19
# 20
