# Lab 04 — MikroTik Dynamic Routing: OSPF (Open Shortest Path First)

## 1. Tujuan
Mempelajari dan mengimplementasikan protokol routing dinamis *Link-State* **OSPF (Open Shortest Path First)** pada MikroTik RouterOS:
1. Konfigurasi OSPF Area Backbone (`area 0` / `0.0.0.0`).
2. Pembentukan tetangga (*Neighbor Adjacency*) pada topologi **Full Mesh 4 Router** dan studi kasus skala besar hingga **24 Router**.
3. Menganalisis algoritma Dijkstra (Shortest Path First) dalam penentuan jalur terbaik serta *dynamic convergence* saat terjadi gangguan link.

---

## 2. Topologi Jaringan (OSPF Full Mesh)

Pada topologi Full Mesh, setiap router memiliki link langsung (*point-to-point* `/30`) ke seluruh router lainnya untuk menjamin redundansi maksimal:

```text
               +-------------------+
               |     Router 1      |
               | Router-ID: 1.1.1.1|
               +---------+---------+
                        /|\
             10.10.10.0/30 | 30.30.30.0/30
                      /  |  \
                     /   |   \
   +----------------+    |    +----------------+
   |    Router 2    |----+----|    Router 3    |
   | Router-ID:     |20.20.20 | Router-ID:     |
   |    2.2.2.2     |   /30   |    3.3.3.3     |
   +----------------+         +----------------+
            \                 /
             \               /
              \             /
               +-----------+
               | Router 4  |
               | Router-ID:|
               |  4.4.4.4  |
               +-----------+
```

---

## 3. Konfigurasi MikroTik RouterOS (CLI)

### Langkah 1: Pengalamatan IP Antar-Router (Interconnect /30) & Loopback
Gunakan interface Loopback (Bridge dummy) sebagai IP Router-ID yang stabil:
```routeros
# Buat Interface Loopback
/interface bridge add name=lo0 comment="Loopback Interface for Router-ID"
/ip address add address=1.1.1.1/32 interface=lo0

# Alokasi IP Interconnect ke Router Neighbor
/ip address add address=10.10.10.1/30 interface=ether2 comment="Link to R2"
/ip address add address=20.20.20.1/30 interface=ether3 comment="Link to R4"
/ip address add address=30.30.30.1/30 interface=ether4 comment="Link to R3"

# IP LAN Klien
/ip address add address=192.168.10.1/24 interface=ether5 comment="LAN PC1"
```

### Langkah 2: Konfigurasi OSPF Instance & Router-ID
```routeros
# RouterOS v6
/routing ospf instance set [ find default=yes ] router-id=1.1.1.1 redistribute-connected=as-type-1

# RouterOS v7 (Alternatif)
/routing ospf instance add name=ospf-instance-1 router-id=1.1.1.1
/routing ospf area add name=backbone area-id=0.0.0.0 instance=ospf-instance-1
```

### Langkah 3: Mendaftarkan Network ke OSPF Area Backbone
Daftarkan seluruh subnet interconnect dan LAN ke dalam area 0 (Backbone):
```routeros
# RouterOS v6 (Network statement)
/routing ospf network add network=10.10.10.0/30 area=backbone
/routing ospf network add network=20.20.20.0/30 area=backbone
/routing ospf network add network=30.30.30.0/30 area=backbone
/routing ospf network add network=192.168.10.0/24 area=backbone

# RouterOS v7 (Interface template)
/routing ospf interface-template add area=backbone interfaces=ether2,ether3,ether4,ether5,lo0
```

---

## 4. Pengujian & Analisis

### 1. Verifikasi Status Tetangga (Neighbor Adjacency)
Jalankan di terminal RouterOS:
```routeros
/routing ospf neighbor print
```
*Output yang diharapkan:*
- Status neighbor berada pada state **`Full`** (artinya database Link-State Request dan Update sudah saling tersinkronisasi sempurna).
- Terlihat seluruh router tetangga (`2.2.2.2`, `3.3.3.3`, `4.4.4.4`).

### 2. Pemeriksaan Routing Table Dinamis
```routeros
/ip route print where ospf
```
Seluruh subnet LAN dari router lain otomatis muncul dengan flag **`ADo`** (*Active, Dynamic, OSPF*).

### 3. Uji Redundansi & Konvergensi (*Link Failure Test*)
- Lakukan `ping -t` dari PC1 ke PC yang berada di belakang R3.
- Nonaktifkan link langsung R1-R3 (`ether4`).
- Router OSPF langsung menghitung ulang Shortest Path via R2 (`R1 -> R2 -> R3`) dengan waktu konvergensi sub-detik tanpa terputusnya sesi komunikasi.

---

## 5. Implementasi Skala Lanjut & Route Redistribution

### A. Penggabungan Dua Protokol Routing Dinamis (OSPF & RIPv2 Redistribution)
Pada praktikum PJK 2 Pertemuan 7, diimplementasikan redistribusi rute antar Autonomous System / area yang menggunakan protokol berbeda (RIPv2 pada kantor cabang lama dan OSPF pada jaringan backbone):
```routeros
# Konfigurasi RIP Instance & Interface
/routing rip instance add name=rip-instance-1 redistribute-ospf=yes
/routing rip interface add interface=ether2 receive=v2 send=v2

# Pada Router Border (ASBR), lakukan redistribusi rute RIP ke dalam domain OSPF
/routing ospf instance set [ find default=yes ] redistribute-rip=as-type-1 redistribute-connected=as-type-1
```
*Hasil:* Router yang hanya menjalankan OSPF dapat mengenali subnet RIPv2 sebagai rute eksternal (**`ADo`** / **`E1`**), dan sebaliknya.

### B. Studi Kasus OSPF Skala Besar (24 Router Terdistribusi)
Telah diuji implementasi multi-node hingga **24 Router** terdistribusi satu angkatan:
- Pembuktian routing convergence dan packet delivery antar subnet seluruh peserta praktikum.
- Verifikasi hop-by-hop menggunakan `tracert` dan analisis metrik cost Dijkstra.
