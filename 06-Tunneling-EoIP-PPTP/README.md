# Lab 06 — Site-to-Site Tunneling: EoIP & PPTP VPN

## 1. Tujuan
Memahami konsep enkapsulasi paket dan mengimplementasikan mekanisme *tunneling* antar kantor/lokasi (*site-to-site*) melalui jaringan publik:
1. **EoIP (Ethernet over IP):** Tunnel proprietary MikroTik yang bekerja pada **Layer 2 (Data Link)**, memungkinkan bridging LAN transparan antar-lokasi yang terpisah rute Layer 3.
2. **PPTP (Point-to-Point Tunneling Protocol):** Tunnel berbasis PPP dan enkapsulasi GRE untuk koneksi privat aman antar-router.

---

## 2. Bagian A: Ethernet over IP (EoIP) Tunnel

### Topologi EoIP
```text
[ Branch A LAN ]                              [ Branch B LAN ]
192.168.100.0/24                              192.168.100.0/24 (Same L2 Broadcast Domain!)
       |                                             |
[ Router A ] <======== EoIP Tunnel (ID: 10) =======> [ Router B ]
Public: 10.33.108.3                           Public: 10.33.108.4
```

### Konfigurasi Router A (Branch A):
```routeros
# Buat Interface EoIP Tunnel
/interface eoip add name=eoip-to-branchB remote-address=10.33.108.4 tunnel-id=10 disabled=no

# Bridge interface LAN lokal dengan interface EoIP
/interface bridge add name=bridge-lan
/interface bridge port add bridge=bridge-lan interface=ether2 comment="Local LAN"
/interface bridge port add bridge=bridge-lan interface=eoip-to-branchB comment="EoIP Link"

# Berikan IP pada Bridge (Satu Subnet yang sama dengan Branch B)
/ip address add address=192.168.100.1/24 interface=bridge-lan
```

### Konfigurasi Router B (Branch B):
```routeros
# Buat Interface EoIP Tunnel (Tunnel ID harus sama!)
/interface eoip add name=eoip-to-branchA remote-address=10.33.108.3 tunnel-id=10 disabled=no

# Bridge interface LAN lokal dengan interface EoIP
/interface bridge add name=bridge-lan
/interface bridge port add bridge=bridge-lan interface=ether2
/interface bridge port add bridge=bridge-lan interface=eoip-to-branchA

# Berikan IP pada Bridge
/ip address add address=192.168.100.2/24 interface=bridge-lan
```

> **Keunggulan EoIP:** Perangkat di Branch A dan Branch B berada dalam **satu broadcast domain yang sama**, sehingga protokol Layer 2 (seperti DHCP, mDNS, ARP, file sharing lokal) dapat langsung menembus jaringan WAN tanpa memerlukan routing tambahan.

---

## 3. Bagian B: Point-to-Point Tunneling Protocol (PPTP)

### Konfigurasi PPTP Server (Kantor Pusat):
```routeros
# Aktifkan PPTP Server
/interface pptp-server server set enabled=yes authentication=mschap2

# Buat PPP Secret (Kredensial User)
/ppp secret add name=branch-vpn password=SuperSecretPassword service=pptp local-address=10.200.200.1 remote-address=10.200.200.2

# Tambahkan Rute ke Subnet Kantor Cabang
/ip route add dst-address=192.168.4.0/24 gateway=10.200.200.2 comment="Route to Branch LAN via VPN"
```

### Konfigurasi PPTP Client (Kantor Cabang):
```routeros
# Hubungkan ke Server
/interface pptp-client add name=pptp-to-hq connect-to=10.33.108.3 user=branch-vpn password=SuperSecretPassword disabled=no

# Tambahkan Rute ke Subnet Kantor Pusat
/ip route add dst-address=192.168.3.0/24 gateway=10.200.200.1 comment="Route to HQ LAN via VPN"
```

---

## 4. Pengujian & Verifikasi
- Lakukan `ping` antar komputer klien di kantor pusat dan kantor cabang.
- Uji isolasi paket menggunakan sniffer/Torch: seluruh payload paket internal dibungkus (*encapsulated*) di dalam header IP WAN.
