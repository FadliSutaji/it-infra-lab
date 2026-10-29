# Lab 12 — MikroTik Interface Bonding & Link Aggregation (LACP 802.3ad & Failover)

## 1. Tujuan
Meningkatkan kapasitas throughput (*bandwidth aggregation*) dan membangun toleransi kegagalan link fisik (*link-level redundancy*) dengan menggabungkan beberapa antarmuka fisik (Ethernet) menjadi satu antarmuka logis (**Bonding Interface**) pada MikroTik RouterBOARD fisik (RB962UiGS-5HacT2HnT):
1. Mengonfigurasi mode bonding **Balance-RR (Round-Robin)** untuk pembebanan paket simetris ganda.
2. Mengonfigurasi mode bonding **Active-Backup** untuk proteksi link fisik tanpa switch support.
3. Mengonfigurasi mode bonding enterprise **802.3ad (LACP - Link Aggregation Control Protocol)**.
4. Menganalisis *link monitoring* (MII vs ARP) dan mekanisme *failover* instan saat salah satu kabel LAN dicabut (*cable cut test*).

---

## 2. Topologi Jaringan (Link Aggregation)

Dua perangkat MikroTik RouterBOARD fisik dihubungkan menggunakan **2 kabel LAN RJ-45 sekaligus** secara paralel pada port `ether3` dan `ether4`:

```text
       +-------------------------------+
       |     MikroTik RouterBOARD 1    |
       |     IP: 192.168.200.1/24      |
       +---------------+---------------+
               |               |
       (ether3)|               |(ether4)
               |   Bonding Link|
               | (Aggregated)  |
       (ether3)|               |(ether4)
               |               |
       +---------------+---------------+
       |     MikroTik RouterBOARD 2    |
       |     IP: 192.168.200.2/24      |
       +-------------------------------+
```

---

## 3. Konfigurasi MikroTik RouterOS (CLI)

### Bagian A: Pembuatan Interface Bonding (Mode Balance-RR)
Mengirimkan paket secara bergantian melalui `ether3` dan `ether4` untuk melipatgandakan throughput:
```routeros
# Buat Interface Bonding di Router 1
/interface bonding add name=bonding1 slaves=ether3,ether4 mode=balance-rr link-monitoring=mii mii-interval=100ms

# Berikan IP Address pada Interface Bonding (Bukan di ether3/ether4 fisik!)
/ip address add address=192.168.200.1/24 interface=bonding1 network=192.168.200.0
```

*(Konfigurasi pada Router 2: IP `192.168.200.2/24` pada interface `bonding1` dengan mode yang sama)*

### Bagian B: Pembuatan Interface Bonding (Mode Active-Backup)
Menyediakan redundansi murni: satu link aktif sebagai jalur utama, link kedua standby:
```routeros
/interface bonding set [ find name=bonding1 ] mode=active-backup primary=ether3
```

### Bagian C: Pembuatan Interface Bonding Enterprise (Mode 802.3ad LACP)
Standar industri IEEE 802.3ad yang bernegosiasi secara dinamis antar-perangkat:
```routeros
/interface bonding set [ find name=bonding1 ] mode=802.3ad lacp-rate=1sec transmit-hash-policy=layer-2-and-3
```

---

## 4. Pengujian & Verifikasi

### 1. Verifikasi Status Agregasi
```routeros
/interface bonding print
/interface bonding monitor bonding1
```
*Hasil:*
- Parameter `running: yes` dan kedua slave interface (`ether3`, `ether4`) terdeteksi aktif.

### 2. Uji Bandwidth Aggregation (Bandwidth Test)
Jalankan BTest antar kedua routerboard:
- Saat menggunakan single interface (tanpa bonding): Throughput maksimal ~100 Mbps / ~1 Gbps (sesuai limit port).
- Saat interface bonding aktif (`balance-rr`): Throughput meningkat mendekati **2x lipat** kapasitas single port karena beban terdistribusi seimbang di kedua kabel.

### 3. Uji Redundansi Fisik (*Cable Cut Simulation*)
- Jalankan `ping -t 192.168.200.2` berkelanjutan.
- Cabut kabel fisik `ether3`.
- Router mendeteksi link carrier down via MII monitor (100ms), lalu seketika mengalirkan 100% trafik ke `ether4` tanpa ada *Request Timed Out* (0% packet loss).
- Pasang kembali kabel; link kembali bergabung ke cluster bonding secara otomatis.
