# Lab 03 — MikroTik Dual-ISP Automatic Failover & Redundancy

## 1. Tujuan
Membangun redundansi koneksi internet (*High Availability*) menggunakan 2 jalur ISP berbeda pada satu router MikroTik. Ketika link ISP utama (*Primary Link*) mati atau putus, seluruh trafik jaringan secara otomatis dialihkan (*automatic failover*) ke link cadangan (*Secondary Link*) tanpa gangguan berkepanjangan pada sisi klien.

---

## 2. Topologi Jaringan

```text
       +-------------------------+
       |   ISP 1 (Primary WAN)   |
       |  Gateway: 10.33.108.254 |
       +------------+------------+
                    | (ether1)
                    v
       +------------+------------+
       |   MikroTik RouterBOARD  | <--- Default Route (Distance 1, Check-Gateway)
       |   (RB962 / RB951)       | <--- Backup Route  (Distance 2)
       +------------+------------+
                    ^ (wlan1 / ether3)
                    |
       +------------+------------+
       |   ISP 2 (Secondary WAN) |
       |  Gateway: 10.33.64.1    |
       +-------------------------+
                    | (ether2)
                    v
       +------------+------------+
       |  Local Client Network   |
       |  IP: 192.168.5.0/24     |
       +-------------------------+
```

---

## 3. Parameter Pengalamatan & Interface

| Interface | Tipe Koneksi | IP Address / Network | Fungsi |
|---|---|---|---|
| `ether1` | Wired (Ethernet) | `10.33.108.6/24` (GW: `10.33.108.254`) | **Primary WAN** (ISP 1 - Prioritas Utama) |
| `wlan1` / `ether3` | Wireless Station / Wired | DHCP Client / `10.33.64.x/24` (GW: `10.33.64.1`) | **Secondary WAN** (ISP 2 - Cadangan) |
| `ether2` | Wired LAN | `192.168.5.1/24` | Gateway Client LAN |

---

## 4. Konfigurasi MikroTik RouterOS (CLI)

### Langkah 1: Konfigurasi IP Address
```routeros
# IP untuk Primary WAN & Local LAN
/ip address add address=10.33.108.6/24 interface=ether1 network=10.33.108.0
/ip address add address=192.168.5.1/24 interface=ether2 network=192.168.5.0

# Secondary WAN (Contoh via DHCP Client pada wlan1/ether3)
/ip dhcp-client add interface=wlan1 add-default-route=no disabled=no
```

### Langkah 2: Konfigurasi Source NAT (Masquerade) untuk Kedua WAN
Agar paket dari jaringan lokal dapat menuju internet melalui kedua jalur:
```routeros
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="NAT Masquerade ISP-1"
/ip firewall nat add chain=srcnat out-interface=wlan1 action=masquerade comment="NAT Masquerade ISP-2"
```

### Langkah 3: Konfigurasi Failover Routing (Distance & Check-Gateway)
Inti dari mekanisme failover otomatis terletak pada nilai **Administrative Distance** dan pengecekan liveness gateway:
```routeros
# Route Utama (Prioritas 1) dengan deteksi ICMP Ping berkala ke gateway
/ip route add dst-address=0.0.0.0/0 gateway=10.33.108.254 distance=1 check-gateway=ping comment="Primary Route via ISP 1"

# Route Cadangan (Prioritas 2)
/ip route add dst-address=0.0.0.0/0 gateway=10.33.64.1 distance=2 comment="Secondary Backup Route via ISP 2"
```

---

## 5. Pengujian & Verifikasi Failover

1. **Kondisi Normal (Kedua ISP Aktif):**
   - Periksa tabel routing dengan `/ip route print`.
   - Route `distance=1` berstatus **Active Dynamic/Static (`AS`)**. Seluruh trafik client melewati `ether1`.
   - Jalankan `traceroute 8.8.8.8` dari client; hop pertama mengarah ke `10.33.108.254`.

2. **Simulasi Kegagalan Link Utama (Failover Trigger):**
   - Cabut kabel `ether1` atau nonaktifkan interface `/interface ethernet disable ether1`.
   - Fitur `check-gateway=ping` mendeteksi paket ping tidak terbalas (timeout 2x10 detik).
   - Status route `distance=1` berubah menjadi **unreachable**.
   - Router secara otomatis mengaktifkan route `distance=2` (`10.33.64.1`) menjadi **Active (`AS`)**.

3. **Verifikasi Jalur Cadangan:**
   - Jalankan `ping google.com` berkelanjutan (`ping -t`). Terjadi *drop packet* sekitar 1-2 detik, setelah itu koneksi kembali reply normal.
   - Jalankan `traceroute 8.8.8.8`; hop pertama berganti melalui gateway `10.33.64.1`.

4. **Kondisi Recovery (Failback):**
   - Aktifkan kembali `ether1`. Gateway terdeteksi up, router mengalihkan kembali rute aktif ke `distance=1`.

---

## 6. Pembelajaran Teknis & Troubleshooting
- **Mengapa butuh `check-gateway=ping`?** Jika link antara router dan modem tetap up tapi internet ISP mati (*silent drop*), router tidak akan tahu tanpa mekanisme probing ping ke gateway.
- **Masalah Recursive Routing:** Jika gateway ISP berjarak beberapa hop dari router, metode recursive routing dengan routing mark dan IP publik (seperti `8.8.8.8` / `1.1.1.1` sebagai target scope) dapat digunakan untuk akurasi deteksi konektivitas internet end-to-end.
