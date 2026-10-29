# Lab 01 — Subnetting & VLSM (Variable Length Subnet Masking)

## 1. Tujuan
Memahami prinsip dasar pengalamatan IPv4, menghitung subnetting secara cepat (block size, network ID, broadcast ID, usable host), dan mendesain alokasi alamat efisien menggunakan metode VLSM untuk kebutuhan multidepartemen.

---

## 2. Subnetting Cheat Sheet (Class C / /24 - /30)

| Prefix | Subnet Mask | Block Size (2^(32-prefix)) | Usable Host Range | Penggunaan Umum |
|---|---|---|---|---|
| **/24** | `255.255.255.0` | 256 | 254 | LAN Skala Menengah |
| **/25** | `255.255.255.128` | 128 | 126 | Subnet Departemen Besar |
| **/26** | `255.255.255.192` | 64 | 62 | Subnet Departemen Sedang |
| **/27** | `255.255.255.224` | 32 | 30 | Divisi Khusus / Server Farm kecil |
| **/28** | `255.255.255.240` | 16 | 14 | Manajemen / Tamu |
| **/29** | `255.255.255.248` | 8 | 6 | Cluster Server / Failover IP |
| **/30** | `255.255.255.252` | 4 | 2 | Point-to-Point antar Router (Serial/Tunnel) |

---

## 3. Rumus & Metode Perhitungan Cepat

1. **Hitung Bit Host ($h$):**  
   $$h = 32 - \text{prefix}$$
2. **Hitung Block Size:**  
   $$\text{Block Size} = 2^h$$
3. **Hitung Network ID:**  
   Kelipatan *block size* terdekat yang nilainya $\le$ IP host.
4. **Hitung Broadcast ID:**  
   $$\text{Broadcast} = \text{Network ID} + \text{Block Size} - 1$$
5. **Rentang Host yang Dapat Dipakai (*Usable Host*):**  
   $$\text{Network ID} + 1 \quad \text{s/d} \quad \text{Broadcast ID} - 1$$

---

## 4. Contoh Kasus Desain VLSM

**Alokasi Blok Jaringan:** `192.168.10.0/24` (Kapasitas total: 254 host)  
**Kebutuhan:**
1. Divisi Sales: 50 host
2. Divisi IT: 20 host
3. Tamu / WiFi Publik: 10 host

### Tabel Alokasi VLSM (Diurutkan dari kebutuhan terbesar):

| Departemen | Kebutuhan Host | Alokasi Prefix | Network Address | Subnet Mask | Usable Host Range | Broadcast Address |
|---|---|---|---|---|---|---|
| **Sales** | 50 host | `/26` (maks 62 host) | `192.168.10.0` | `255.255.255.192` | `192.168.10.1` - `192.168.10.62` | `192.168.10.63` |
| **IT** | 20 host | `/27` (maks 30 host) | `192.168.10.64` | `255.255.255.224` | `192.168.10.65` - `192.168.10.94` | `192.168.10.95` |
| **Tamu** | 10 host | `/28` (maks 14 host) | `192.168.10.96` | `255.255.255.240` | `192.168.10.97` - `192.168.10.110` | `192.168.10.111` |

> *Sisa blok dari `192.168.10.112` hingga `192.168.10.255` masih tersedia untuk ekspansi masa depan tanpa overlap.*

---

## 5. Troubleshooting & Catatan Penting
- **Pencegahan Overlap:** Selalu urutkan alokasi VLSM mulai dari divisi dengan jumlah host terbanyak ke terkecil.
- **Kesalahan Umum:** Menggunakan network ID atau broadcast ID sebagai IP perangkat client/gateway akan menyebabkan konflik dan kegagalan komunikasi subnet.
