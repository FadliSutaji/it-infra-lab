# Lab 10 — MikroTik Hotspot Gateway & Wireless (Captive Portal & User Management)

## 1. Tujuan
Membangun sistem autentikasi akses internet publik/kantor menggunakan **MikroTik Hotspot Gateway (Captive Portal)** dan konfigurasi antarmuka nirkabel (**Wireless 802.11b/g/n**):
1. Mengonfigurasi antarmuka nirkabel routerboard sebagai **Access Point (AP Bridge)**.
2. Membangun server Hotspot dengan *wizard setup*, autentikasi berbasis web login (Captive Portal).
3. Mengatur **User Profiles** (pembatasan durasi sesi, uptime, dan limit kecepatan per user).
4. Menerapkan fitur **IP Binding** (*Bypass MAC tanpa login*) dan **Walled Garden** (domain yang dapat diakses sebelum login).

---

## 2. Topologi Jaringan

```text
       +-------------------------------+
       |   Internet WAN (ether1)       |
       +---------------+---------------+
                       |
                       v
       +---------------+---------------+
       |    MikroTik RouterBOARD       | <--- Hotspot Server & Captive Portal
       |    (AP Bridge Mode)           |
       +-------+---------------+-------+
               |               |
     (wlan1 - Wireless)    (ether2 - Wired LAN)
               |               |
               v               v
       +-------+-------+  +----+----------+
       | Laptop / HP   |  | PC Klien LAN  |
       | Klien WiFi    |  | (Hotspot Auth)|
       +---------------+  +---------------+
```

---

## 3. Konfigurasi MikroTik RouterOS (CLI)

### Bagian A: Konfigurasi Interface Wireless (AP Bridge)
```routeros
# Buat Security Profile WPA2 (jika menggunakan proteksi sebelum hotspot) atau Open System
/interface wireless security-profiles add name=profile-open mode=none

# Aktifkan interface wlan1 sebagai Access Point
/interface wireless set [ find default-name=wlan1 ] \
    mode=ap-bridge \
    ssid="Hotspot-Lab-Fadli" \
    band=2ghz-b/g/n \
    channel-width=20mhz \
    frequency=2412 \
    security-profile=profile-open \
    disabled=no
```

### Bagian B: Konfigurasi IP Pool & Server Hotspot
```routeros
# IP Address untuk Interface Hotspot (wlan1)
/ip address add address=192.168.20.1/24 interface=wlan1 network=192.168.20.0

# IP Pool untuk Klien Hotspot
/ip pool add name=hs-pool ranges=192.168.20.10-192.168.20.100

# Hotspot Server Profile
/ip hotspot profile add name=hsprof1 hotspot-address=192.168.20.1 dns-name="hotspot.lab" login-by=http-chap,cookie

# Aktifkan Hotspot Server
/ip hotspot add name=hotspot1 interface=wlan1 address-pool=hs-pool profile=hsprof1 disabled=no
```

### Bagian C: Manajemen User & Profil Kecepatan
```routeros
# Profil Kecepatan (Contoh: Mahasiswa maks 1Mbps/2Mbps)
/ip hotspot user profile add name="Profil-Mahasiswa" rate-limit=1M/2M session-timeout=2h shared-users=1

# Profil Kecepatan Dosen (Maks 5Mbps/10Mbps)
/ip hotspot user profile add name="Profil-Dosen" rate-limit=5M/10M shared-users=2

# Buat Akun Pengguna
/ip hotspot user add name=fadli password=fadlipass profile=Profil-Mahasiswa comment="User Mahasiswa"
/ip hotspot user add name=dosen1 password=dosenpass profile=Profil-Dosen comment="User Dosen"
```

### Bagian D: IP Binding (Bypass Login) & Walled Garden
```routeros
# Bypass autentikasi untuk perangkat printer / server lokal berdasarkan MAC address
/ip hotspot ip-binding add mac-address=00:11:22:33:44:55 type=bypassed comment="Printer WiFi"

# Walled Garden: Mengizinkan akses ke website kampus tanpa perlu login terlebih dahulu
/ip hotspot walled-garden add dst-host="*.ugm.ac.id" action=allow comment="Bypass Domain Kampus"
```

---

## 4. Pengujian & Verifikasi
1. **Redirect Captive Portal:** Hubungkan laptop/HP ke SSID `Hotspot-Lab-Fadli`; saat membuka browser dan mengakses sembarang website HTTP, URL otomatis dialihkan (*redirect*) ke halaman `http://hotspot.lab/login`.
2. **Uji Walled Garden:** Sebelum login, buka website `ugm.ac.id`. Halaman kampus langsung terbuka normal.
3. **Autentikasi User:** Masukkan username `fadli` dan password; status berubah menjadi *connected* dan internet terbuka penuh.
4. **Verifikasi Kecepatan & Limit:** Lakukan speedtest; throughput klien dibatasi sesuai profil `1M/2M`.
