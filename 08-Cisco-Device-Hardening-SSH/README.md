# Lab 08 — Cisco Device Hardening & Secure Remote Management (SSH v2)

## 1. Tujuan
Mengonfigurasi dan mengamankan perangkat *Layer 2 (Switch)* dan *Layer 3 (Router)* Cisco berbasis Cisco IOS sesuai standar keamanan enterprise (Cisco Networking Academy):
1. **Konfigurasi Dasar & Hardening Fisik:** Hostname, Banner MOTD, enkripsi password lokal, dan timeout konsol.
2. **Switch Virtual Interface (SVI):** Pengalamatan IP manajemen pada VLAN 1 dan default gateway switch.
3. **Secure Remote Management:** Mengamankan akses remote VTY menggunakan protokol terenkripsi **SSH versi 2** (menggantikan Telnet yang tidak aman).
4. **Port Security (Layer 2 Access Control):** Membatasi akses port switch hanya untuk alamat MAC yang sah dan mencegah serangan MAC Flooding / unauthorized access.

---

## 2. Topologi Jaringan

```text
       +-------------------------------+
       |  Admin PC / Workstation       |
       |  IP: 192.168.1.10/24          |
       +---------------+---------------+
                       |
                       | FastEthernet0/1 (Port Security Active)
                       v
       +---------------+---------------+
       |  Cisco Catalyst 2960 Switch   |
       |  Management SVI: 192.168.1.2  |
       +---------------+---------------+
                       |
                       | GigabitEthernet0/1
                       v
       +---------------+---------------+
       |  Cisco ISR 4321 / 2911 Router |
       |  Gateway IP: 192.168.1.1/24   |
       +-------------------------------+
```

---

## 3. Konfigurasi Cisco IOS (CLI)

### Bagian A: Hardening Dasar Switch & Enkripsi Kredensial
```cisco
Switch> enable
Switch# configure terminal
Switch(config)# hostname SW-Access-01

# Enkripsi Password Privilege EXEC
SW-Access-01(config)# enable secret CiscoSecurePass!
SW-Access-01(config)# service password-encryption

# Banner Peringatan Hukum
SW-Access-01(config)# banner motd # PERINGATAN: Akses tidak sah dilarang keras dan akan diproses hukum! #

# Pengamanan Port Konsol Fisik
SW-Access-01(config)# line console 0
SW-Access-01(config-line)# password ConsolePass123
SW-Access-01(config-line)# login
SW-Access-01(config-line)# exec-timeout 5 0
SW-Access-01(config-line)# logging synchronous
SW-Access-01(config-line)# exit
```

### Bagian B: Konfigurasi Switch Virtual Interface (SVI) untuk Manajemen
```cisco
# IP Manajemen Switch pada Interface VLAN 1
SW-Access-01(config)# interface vlan 1
SW-Access-01(config-if)# ip address 192.168.1.2 255.255.255.0
SW-Access-01(config-if)# no shutdown
SW-Access-01(config-if)# exit

# Default Gateway agar switch dapat di-remote dari luar subnet lokal
SW-Access-01(config)# ip default-gateway 192.168.1.1
```

### Bagian C: Konfigurasi Secure Shell (SSH v2) pada Line VTY
```cisco
# Tentukan Domain Name (Syarat pembuatan RSA Key)
SW-Access-01(config)# ip domain-name lab.ugm.ac.id

# Buat Kunci Enkripsi Kriptografi RSA (Minimal 1024 bit, disarankan 2048 bit)
SW-Access-01(config)# crypto key generate rsa
How many bits in the modulus [512]: 2048

# Paksa Penggunaan SSH Versi 2
SW-Access-01(config)# ip ssh version 2

# Buat User Lokal Database dengan Privilege Tertinggi
SW-Access-01(config)# username admin privilege 15 secret AdminSuperP@ss!

# Konfigurasi Virtual Terminal (VTY) hanya menerima SSH
SW-Access-01(config)# line vty 0 15
SW-Access-01(config-line)# transport input ssh
SW-Access-01(config-line)# login local
SW-Access-01(config-line)# exec-timeout 10 0
SW-Access-01(config-line)# exit
```

### Bagian D: Implementasi Layer 2 Port Security
Mencegah perangkat liar dicolokkan ke switch dan mengunci port berdasarkan MAC address asli PC admin:
```cisco
SW-Access-01(config)# interface FastEthernet0/1
SW-Access-01(config-if)# switchport mode access
SW-Access-01(config-if)# switchport port-security
SW-Access-01(config-if)# switchport port-security maximum 1
SW-Access-01(config-if)# switchport port-security mac-address sticky
SW-Access-01(config-if)# switchport port-security violation shutdown
SW-Access-01(config-if)# exit
```

---

## 4. Pengujian & Verifikasi

### 1. Verifikasi Akses SSH dari Terminal Klien
```bash
# Uji koneksi SSH dari workstation admin
ssh -l admin 192.168.1.2

# Pastikan Telnet ditolak
telnet 192.168.1.2
# Output: Connection refused (karena hanya transport input ssh yang diizinkan)
```

### 2. Status SSH & Port Security di Cisco Switch
```cisco
SW-Access-01# show ip ssh
# Output: SSH Enabled - version 2.0; Authentication timeout: 120 secs; Retries: 3

SW-Access-01# show port-security interface FastEthernet0/1
# Port Security              : Enabled
# Port Status                : Secure-up
# Violation Mode             : Shutdown
# Maximum MAC Addresses      : 1
# Total MAC Addresses        : 1
# Configured MAC Addresses   : 0
# Sticky MAC Addresses       : 1
# Last Source Address:Vlan   : 0050.7966.6801:1
# Security Violation Count   : 0
```

### 3. Uji Penetrasi Unauthorized Device (Violation Test)
Ketika kabel dipindahkan ke laptop lain tanpa otorisasi:
- Port `FastEthernet0/1` langsung berubah status menjadi **`err-disabled`** (mati otomatis).
- Log console menghasilkan pesan pelanggaran keamanan (*Security Violation*).
- Untuk memulihkan setelah verifikasi: `shutdown` lalu `no shutdown`.
