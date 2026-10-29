# Lab 07 — VLAN (802.1Q) & Inter-VLAN Routing (Router-on-a-Stick)

## 1. Tujuan
Memahami segmentasi jaringan lokal pada Layer 2 untuk memisahkan *broadcast domain*, meningkatkan keamanan, dan menghemat infrastruktur fisik:
1. Konfigurasi **VLAN (Virtual Local Area Network)** menggunakan standar **IEEE 802.1Q**.
2. Pengaturan **Access Port** (ke end-device) dan **Trunk Port** (link agregasi antar switch/router).
3. Implementasi **Inter-VLAN Routing** menggunakan metode **Router-on-a-Stick (RoS)** baik pada perangkat Cisco maupun MikroTik.

---

## 2. Topologi Jaringan

```text
                  +---------------------------+
                  |  Router (Gateway Default) |
                  |  Cisco ISR / MikroTik     |
                  +-------------+-------------+
                                | Trunk Link (802.1Q Tagged: VLAN 10, 20)
                                v
                  +-------------+-------------+
                  |    Cisco Catalyst Switch  |
                  +------+-------------+------+
                         |             |
           (Access VLAN 10)           (Access VLAN 20)
                         |             |
                         v             v
                  +------+----+   +----+------+
                  |   PC 1    |   |   PC 2    |
                  | Divisi IT |   | Divisi HR |
                  | 192.168.  |   | 192.168.  |
                  |  10.10/24 |   |  20.10/24 |
                  +-----------+   +-----------+
```

---

## 3. Implementasi pada Cisco IOS (Packet Tracer)

### A. Konfigurasi Switch (Cisco 2960)
```cisco
# 1. Pembuatan Database VLAN
Switch(config)# vlan 10
Switch(config-vlan)# name IT_Dept
Switch(config-vlan)# exit

Switch(config)# vlan 20
Switch(config-vlan)# name HR_Dept
Switch(config-vlan)# exit

# 2. Konfigurasi Access Port ke Klien
Switch(config)# interface FastEthernet0/1
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# exit

Switch(config)# interface FastEthernet0/2
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 20
Switch(config-if)# exit

# 3. Konfigurasi Trunk Port ke Router
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk allowed vlan 10,20
Switch(config-if)# exit
```

### B. Konfigurasi Router-on-a-Stick (Cisco Router)
```cisco
# Aktifkan interface fisik utama tanpa IP
Router(config)# interface GigabitEthernet0/0
Router(config-if)# no shutdown
Router(config-if)# exit

# Sub-Interface untuk VLAN 10
Router(config)# interface GigabitEthernet0/0.10
Router(config-subif)# encapsulation dot1Q 10
Router(config-subif)# ip address 192.168.10.1 255.255.255.0
Router(config-subif)# exit

# Sub-Interface untuk VLAN 20
Router(config)# interface GigabitEthernet0/0.20
Router(config-subif)# encapsulation dot1Q 20
Router(config-subif)# ip address 192.168.20.1 255.255.255.0
Router(config-subif)# exit
```

---

## 4. Implementasi pada MikroTik RouterOS

```routeros
# Buat Sub-Interface VLAN di atas interface fisik (misal ether2)
/interface vlan add name=vlan10-IT vlan-id=10 interface=ether2
/interface vlan add name=vlan20-HR vlan-id=20 interface=ether2

# Berikan IP Gateway untuk masing-masing VLAN
/ip address add address=192.168.10.1/24 interface=vlan10-IT
/ip address add address=192.168.20.1/24 interface=vlan20-HR
```

---

## 5. Pengujian & Verifikasi
1. **Isolasi Broadcast:** PC 1 (`192.168.10.10`) dan PC 2 (`192.168.20.10`) berada pada broadcast domain terpisah sehingga paket ARP/broadcast tidak bocor antar divisi.
2. **Inter-VLAN Communication:** PC 1 dapat melakukan ping ke PC 2 melewati gateway router.
3. **Security Filtering (Optional):** Akses antar VLAN dapat dibatasi menggunakan Access Control List (ACL) pada Cisco atau IP Firewall Filter pada MikroTik jika hanya port tertentu yang diizinkan (misal hanya HTTP/HTTPS).
