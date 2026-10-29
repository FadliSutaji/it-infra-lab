# Lab 09 — Bandwidth Management & Quality of Service (QoS Simple Queue & PCQ)

## 1. Tujuan
Mengelola dan membatasi pemakaian bandwidth (*Traffic Shaping*) pada jaringan LAN menggunakan fitur **Simple Queue** dan **PCQ (Per Connection Queue)** di MikroTik RouterOS:
1. Membatasi kecepatan unduh (*download*) dan unggah (*upload*) untuk alamat IP klien tertentu atau subnet.
2. Mengonfigurasi parameter **Target**, **Max-Limit**, dan **Limit-At** (*Guaranteed Bandwidth*).
3. Mengimplementasikan fitur **Burst** (kecepatan lonjakan sementara saat pertama kali membuka halaman web).
4. Menerapkan pembagian bandwidth adil dan merata secara otomatis (*fair sharing*) menggunakan algoritma **PCQ**.

---

## 2. Topologi Jaringan

```text
       +-------------------------------+
       |   Internet WAN (ether1)       |
       |   Total Bandwidth: 20 Mbps    |
       +---------------+---------------+
                       |
                       v
       +---------------+---------------+
       |    MikroTik RouterBOARD       | <--- Simple Queue / PCQ Bandwidth Limiter
       +---------------+---------------+
                       |
                       | ether2 (LAN 192.168.10.0/24)
                       v
       +---------------+---------------+
       |   Klien LAN / Departemen      |
       |   - PC VIP: 192.168.10.5      | (Max 5 Mbps)
       |   - PC Staff: 192.168.10.10   | (Max 2 Mbps)
       |   - Subnet Tamu / Sisanya     | (Fair Share via PCQ)
       +-------------------------------+
```

---

## 3. Konfigurasi MikroTik RouterOS (CLI)

### Bagian A: Simple Queue per Klien IP
```routeros
# Pembatasan Bandwidth untuk IP Tertentu (Staff)
/queue simple add name="Queue-Staff-1" target=192.168.10.10/32 max-limit=1M/2M comment="Upload 1Mbps, Download 2Mbps"

# Pembatasan Bandwidth dengan Jaminan Minimum (Limit-At)
/queue simple add name="Queue-Manager-VIP" target=192.168.10.5/32 limit-at=2M/4M max-limit=5M/10M priority=1/1 comment="VIP Prioritas Tertinggi"
```

### Bagian B: Konfigurasi Burst (Lonjakan Kecepatan Awal)
Memberikan kecepatan tinggi sementara selama waktu tertentu agar loading website terasa instan tanpa menghabiskan bandwidth jangka panjang:
```routeros
/queue simple add name="Queue-Fast-Web" target=192.168.10.20/32 \
    max-limit=1M/2M \
    burst-limit=2M/5M \
    burst-threshold=768k/1500k \
    burst-time=8s/8s \
    comment="Burst Download hingga 5Mbps selama 8 detik"
```

### Bagian C: Pembagian Bandwidth Otomatis Merata (PCQ - Per Connection Queue)
Mencegah satu user memonopoli koneksi dengan membagi rata total bandwidth yang tersedia ke seluruh user aktif:
```routeros
# Buat Queue Type PCQ untuk Download dan Upload
/queue type add name="PCQ-Download-Fair" kind=pcq pcq-rate=0 pcq-classifier=dst-address
/queue type add name="PCQ-Upload-Fair" kind=pcq pcq-rate=0 pcq-classifier=src-address

# Terapkan PCQ pada Seluruh Subnet LAN
/queue simple add name="Queue-Subnet-All" target=192.168.10.0/24 \
    queue=PCQ-Upload-Fair/PCQ-Download-Fair \
    max-limit=10M/20M \
    comment="Total 20Mbps dibagi adil otomatis untuk semua klien aktif"
```

---

## 4. Pengujian & Verifikasi
1. **Speedtest / Bandwidth Test:** Jalankan `speedtest.net` atau BTest dari PC klien; pastikan throughput berhenti tepat pada batas `max-limit`.
2. **Monitoring Trafik Real-time:** Pantau melalui Winbox di menu **Queues**; warna bar antrean akan berubah:
   - **Hijau:** Penggunaan bandwidth < 50%
   - **Kuning:** Penggunaan bandwidth 50% - 75%
   - **Merah:** Penggunaan bandwidth mencapai 100% (*limit reached*)
3. **Uji PCQ Fair Share:** Jalankan download besar di dua PC secara bersamaan; kedua PC otomatis mendapatkan pembagian rata 50:50 dari kapasitas yang tersedia.
