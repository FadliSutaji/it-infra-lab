# Lab 11 — MikroTik Stateful Firewall Filtering, Address Lists & Transparent Web Proxy

## 1. Tujuan
Mengimplementasikan sistem keamanan jaringan komprehensif pada MikroTik RouterOS menggunakan arsitektur **Stateful Firewall Filter**, pengelompokan IP dinamis (**Address Lists**), dan penyaringan konten web menggunakan **Transparent Web Proxy**:
1. Menerapkan filosofi keamanan **"Drop Many, Accept Few"** pada chain `input` dan `forward`.
2. Memanfaatkan fitur **Connection Tracking** (*state: established, related, untracked, invalid*).
3. Melakukan pemblokiran domain/situs terlarang menggunakan Layer-7 Content, DNS Static, dan Address Lists.
4. Mengonfigurasi **Transparent Web Proxy** (redirect port 80 ke 8080) dan membuat aturan akses (*Web Proxy Access Control*).

---

## 2. Topologi Jaringan

```text
       +-------------------------------+
       |   Internet WAN (ether1)       |
       +---------------+---------------+
                       |
                       v
       +---------------+---------------+
       |    MikroTik RouterBOARD       | <--- Stateful Filter, NAT & Web Proxy
       +---------------+---------------+
                       |
                       | ether2 (LAN 192.168.10.0/24)
                       v
       +---------------+---------------+
       |   Klien LAN / Departemen      |
       |   - IP Terdaftar / Sah        | (Allowed by Firewall)
       |   - IP Asing / Tidak Terdaftar| (Dropped by Firewall)
       +-------------------------------+
```

---

## 3. Konfigurasi MikroTik RouterOS (CLI)

### Bagian A: Stateful Firewall Filter (Drop Many, Accept Few)
Mengamankan router (*chain input*) dan lalu lintas klien (*chain forward*) berbasis status koneksi:
```routeros
# 1. Izinkan koneksi yang sudah valid dan berjalan (Established, Related, Untracked)
/ip firewall filter add chain=input connection-state=established,related,untracked action=accept comment="Accept Established/Related"
/ip firewall filter add chain=forward connection-state=established,related,untracked action=accept comment="Accept Established/Related Forward"

# 2. Tolak paket yang rusak/cacat (Invalid)
/ip firewall filter add chain=input connection-state=invalid action=drop comment="Drop Invalid Input"
/ip firewall filter add chain=forward connection-state=invalid action=drop comment="Drop Invalid Forward"

# 3. Izinkan ICMP Ping terbatas untuk diagnostik
/ip firewall filter add chain=input protocol=icmp action=accept comment="Allow ICMP Ping"

# 4. Izinkan akses manajemen Winbox/SSH hanya dari IP Admin
/ip firewall filter add chain=input src-address=192.168.10.5 protocol=tcp dst-port=8291,22 action=accept comment="Admin Winbox/SSH Access"

# 5. Drop seluruh koneksi lain yang tidak diizinkan secara eksplisit (Drop Many)
/ip firewall filter add chain=input action=drop comment="Default Drop Input"
```

### Bagian B: Pemblokiran Situs Menggunakan Address List & Logging
```routeros
# Buat Address List untuk target blokir
/ip firewall address-list add list=Blocked-SocialMedia address=instagram.com
/ip firewall address-list add list=Blocked-SocialMedia address=tiktok.com

# Aturan Drop Forward dengan Logging aktif
/ip firewall filter add chain=forward dst-address-list=Blocked-SocialMedia action=drop log=yes log-prefix="[FIREWALL-BLOCKED]: " comment="Drop and Log Blocked Sites"
```

### Bagian C: Transparent Web Proxy & HTTP Access Control
Mengalihkan seluruh lalu lintas web browsing port 80 menuju proxy lokal router untuk inspeksi dan filter URL:
```routeros
# 1. Aktifkan Web Proxy Internal
/ip proxy set enabled=yes port=8080 cache-administrator="admin@lab.ugm.ac.id" max-cache-size=none

# 2. Redirect port HTTP (80) ke Port Proxy (8080) menggunakan Destination NAT
/ip firewall nat add chain=dstnat protocol=tcp dst-port=80 action=redirect to-ports=8080 comment="Transparent Proxy Redirect"

# 3. Buat Aturan Akses Blokir Kata Kunci URL / Domain
/ip proxy access add dst-host="*judi*" action=deny comment="Block Gambling Keywords"
/ip proxy access add dst-host="*xxx*" action=deny comment="Block Adult Content"
/ip proxy access add path="*.iso" action=deny comment="Block Large ISO Downloads"
```

---

## 4. Pengujian & Verifikasi

1. **Uji Connection Tracking:** Jalankan `torch` atau pantau `/ip firewall connection print`. Router secara dinamis mengenali *state* paket TCP handshake.
2. **Uji Firewall Logging:** Saat klien mencoba mengakses alamat dalam `Blocked-SocialMedia`, paket langsung dibuang (*drop*), dan terminal router menghasilkan catatan log:
   ```text
   [FIREWALL-BLOCKED]: forward: in:ether2 out:ether1, src-ip 192.168.10.15, proto TCP (SYN), len 52
   ```
3. **Uji Transparent Web Proxy:** Buka browser di PC klien dan akses domain dengan kata kunci terlarang; browser langsung menampilkan halaman penolakan resmi MikroTik: **`ERROR: 403 Forbidden - Access Denied by Web Proxy`**.
