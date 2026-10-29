# Lab 05 — MikroTik Dynamic Routing: BGP (Border Gateway Protocol)

## 1. Tujuan
Memahami dan mengimplementasikan protokol routing dinamis skala global/ISP **BGP (Border Gateway Protocol)** pada 4 perangkat fisik MikroTik RouterBOARD:
1. Konfigurasi Autonomous System Number (ASN) dan BGP Instance.
2. Membangun sesi BGP Peering (eBGP antar AS berbeda) melalui TCP port 179.
3. Mengiklankan (*advertise*) subnet lokal melalui BGP Network.
4. Menganalisis pemilihan jalur (*Path Vector*) dan pertukaran tabel routing BGP.

---

## 2. Topologi Jaringan BGP (Multi-AS Peering)

```text
 [ AS 65001 ]                     [ AS 65002 ]
+-------------------+           +-------------------+
|     Router 1      |           |     Router 2      |
|  ASN: 65001       |===========|  ASN: 65002       |
|  IP: 10.10.10.1/30|  eBGP     |  IP: 10.10.10.2/30|
+---------+---------+           +---------+---------+
          |                               |
          | eBGP                          | eBGP
          |                               |
+---------+---------+           +---------+---------+
|     Router 4      |===========|     Router 3      |
|  ASN: 65004       |  eBGP     |  ASN: 65003       |
|  IP: 30.30.30.2/30|           |  IP: 20.20.20.2/30|
+-------------------+           +-------------------+
 [ AS 65004 ]                     [ AS 65003 ]
```

---

## 3. Parameter Konfigurasi

| Perangkat | Autonomous System (ASN) | Router-ID | IP Interconnect (WAN) | Subnet LAN Klien |
|---|---|---|---|---|
| **Router 1** | `65001` | `1.1.1.1` | `10.10.10.1/30` (ke R2) | `192.168.3.0/24` |
| **Router 2** | `65002` | `2.2.2.2` | `10.10.10.2/30` (ke R1), `20.20.20.1/30` (ke R3) | `192.168.4.0/24` |
| **Router 3** | `65003` | `3.3.3.3` | `20.20.20.2/30` (ke R2), `30.30.30.1/30` (ke R4) | `192.168.5.0/24` |
| **Router 4** | `65004` | `4.4.4.4` | `30.30.30.2/30` (ke R3) | `192.168.6.0/24` |

---

## 4. Konfigurasi MikroTik RouterOS (Contoh: Router 1)

### Langkah 1: Pengalamatan IP Address
```routeros
# IP Interconnect point-to-point ke Router 2
/ip address add address=10.10.10.1/30 interface=ether3 comment="Link to R2"

# IP LAN Klien
/ip address add address=192.168.3.1/24 interface=ether2 comment="LAN Client 1"
```

### Langkah 2: Konfigurasi BGP Instance
Tentukan identitas router dan nomor Autonomous System (ASN):
```routeros
/routing bgp instance set default as=65001 router-id=1.1.1.1 redistribute-connected=no
```

### Langkah 3: Konfigurasi BGP Peer (Tetangga)
Menentukan router tetangga yang akan diajak bertukar informasi tabel routing via TCP 179:
```routeros
/routing bgp peer add name=peer-to-R2 instance=default remote-address=10.10.10.2 remote-as=65002
```

### Langkah 4: Mengumumkan Network Lokal (Advertise Subnet)
Mendaftarkan prefix network yang dimiliki agar dapat dijangkau oleh AS lain:
```routeros
/routing bgp network add network=192.168.3.0/24 synchronize=no
/routing bgp network add network=10.10.10.0/30 synchronize=no
```

*(Konfigurasi serupa diterapkan pada R2, R3, dan R4 dengan ASN dan IP masing-masing)*

---

## 5. Pengujian & Verifikasi

### 1. Verifikasi Sesi BGP Peer
```routeros
/routing bgp peer print
```
*Hasil:*
- Kolom status harus menunjukkan status **`established`** (menandakan *three-way handshake* TCP port 179 berhasil dan pertukaran pesan BGP OPEN/KEEPALIVE berjalan normal).

### 2. Pemeriksaan Routing Table BGP
```routeros
/ip route print where bgp
```
*Hasil:*
- Prefix jaringan dari AS lain (misal `192.168.4.0/24`, `192.168.5.0/24`, `192.168.6.0/24`) muncul otomatis dengan flag **`ADb`** (*Active, Dynamic, BGP*).

### 3. End-to-End Connectivity Test
- Dari PC 1 (`192.168.3.2`), jalankan `ping 192.168.6.2` (PC 4) melintasi 4 Autonomous System yang berbeda.
- Jalankan `tracert 192.168.6.2` untuk memverifikasi setiap hop routing antar-AS yang dilewati.
