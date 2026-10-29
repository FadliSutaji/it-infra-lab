# 🌐 IT Infrastructure & Enterprise Networking Lab

> Dokumentasi laboratorium, topologi, dan implementasi jaringan komputer tingkat enterprise (*Routing, Switching, High Availability, Link Aggregation, Tunneling, Bandwidth Management, Security Hardening & Stateful Firewall*) berbasis **MikroTik RouterOS** dan **Cisco IOS**.

**Disusun oleh:**  
**Fadli Sutaji Muidita**  
Mahasiswa D-IV Teknologi Rekayasa Internet — Departemen Teknik Elektro dan Informatika, Sekolah Vokasi, Universitas Gadjah Mada (UGM)  
[![GitHub](https://img.shields.io/badge/GitHub-FadliSutaji-blue?logo=github)](https://github.com/FadliSutaji)

---

## 📌 Ringkasan Kemampuan Teknis (Technical Skill Map)

Berdasarkan praktikum intensif 2 tahun (Jaringan Komputer 1 & 2) dan pengujian laboratorium nyata (*physical hardware* RouterBOARD RB962 / RB951, Cisco Catalyst & simulasi CHR / Cisco Packet Tracer):

| Kategori | Protokol & Teknologi | Implementasi Nyata |
|---|---|---|
| **Routing Dinamis (Enterprise & ISP)** | OSPF (v2/v3), BGP, RIPv2 | Single & Multi-area OSPF, OSPF Mesh (hingga studi kasus 24 Router), eBGP/iBGP peering, Route Redistribution (OSPF + RIPv2) |
| **High Availability & Redundansi** | Dual-ISP Failover, Bonding | Check-Gateway Ping/ARP, Distance metric priority, LACP / 802.3ad link aggregation, Balance-RR cable redundancy |
| **Switching & VLAN** | IEEE 802.1Q, Trunking, RoS | Access Port, Trunk Port, Router-on-a-Stick (Inter-VLAN Routing) di Cisco & MikroTik |
| **Stateful Firewall & Web Proxy** | Connection Tracking, Dst-NAT | "Drop Many Accept Few", Address Lists, Logging, Transparent Web Proxy (port 80 to 8080 redirect), URL filtering |
| **Device Hardening & Security** | SSH v2, Port Security, SVI | RSA Key generation (2048-bit), SVI management, Port Security (sticky MAC violation), Console protection |
| **Traffic Shaping & QoS** | Simple Queue, PCQ, Burst | Bandwidth limiting per IP/subnet, Guaranteed bandwidth (Limit-At), Burst threshold, Automatic fair sharing (PCQ) |
| **Wireless & Captive Portal** | 802.11b/g/n, Hotspot Server | AP-Bridge, Station mode, Captive Portal Web Auth, User profiles, IP Binding (MAC bypass), Walled Garden |
| **Tunneling & VPN** | EoIP, PPTP, GRE, L2TP | Layer-2 over Layer-3 EoIP transparent bridge, Site-to-Site tunneling, routing over VPN |
| **Network Core Services** | DHCP, DNS, NTP, IPAM | DHCP Server/Client/Relay, Recursive DNS Resolver, VLSM / Subnetting |

---

## 📂 Katalog Laboratorium (12 Modul Lengkap)

### Bagian 1: Fundamental Jaringan & Gateway Dasar
* [Lab 01 — Subnetting & VLSM Cheat Sheet](./01-Subnetting/)
* [Lab 02 — RouterOS Basic Internet Gateway & NAT Masquerade](./02-RouterOS-NAT/)

### Bagian 2: High Availability & Redundansi ISP
* [Lab 03 — MikroTik Dual-ISP Automatic Failover](./03-Failover-Dual-ISP/)
  > *Failover otomatis 2 ISP (Ethernet + Wireless/Secondary WAN) menggunakan Distance Metric & Check-Gateway.*

### Bagian 3: Protokol Routing Dinamis (Enterprise Routing)
* [Lab 04 — MikroTik OSPF Dynamic Routing (Backbone, Mesh, 24 Router & Redistribution)](./04-OSPF-Routing/)
  > *Konfigurasi OSPF Area 0, multi-router mesh, studi kasus 24 router satu angkatan, dan Route Redistribution OSPF + RIPv2.*
* [Lab 05 — MikroTik BGP (Border Gateway Protocol)](./05-BGP-Routing/)
  > *Implementasi Autonomous System (ASN), BGP Instance, BGP Peering antar routerboard fisik, dan network advertisement.*

### Bagian 4: Tunneling & Virtual Private Network (VPN)
* [Lab 06 — Site-to-Site Tunneling (EoIP & PPTP)](./06-Tunneling-EoIP-PPTP/)
  > *Layer-2 Ethernet over IP (EoIP) transparent bridge dan PPTP Point-to-Point tunneling untuk interkoneksi cabang.*

### Bagian 5: Switching & Segmentasi Trafik
* [Lab 07 — VLAN & Inter-VLAN Routing (802.1Q)](./07-VLAN-InterVLAN/)
  > *Segmentasi broadcast domain dengan 802.1Q trunking dan Router-on-a-Stick di Cisco IOS & MikroTik.*

### Bagian 6: Cisco Enterprise Switching & Device Hardening
* [Lab 08 — Cisco Device Hardening & Secure Remote Management (SSH v2)](./08-Cisco-Device-Hardening-SSH/)
  > *Hardening switch Cisco Catalyst: Banner MOTD, SVI management VLAN 1, enkripsi RSA 2048-bit SSH v2, dan Layer-2 Port Security sticky MAC.*

### Bagian 7: Manajemen Trafik, QoS & Akses Publik
* [Lab 09 — Bandwidth Management & Quality of Service (QoS Simple Queue & PCQ)](./09-Bandwidth-Management-QoS/)
  > *Traffic shaping, limit-at, max-limit, burst rate, dan pembagian bandwidth merata otomatis menggunakan algoritma PCQ.*
* [Lab 10 — MikroTik Hotspot Gateway & Wireless (Captive Portal & User Management)](./10-MikroTik-Hotspot-Wireless/)
  > *Hotspot captive portal, user profiles, rate limiting per user, IP binding bypass, dan Walled Garden domain UGM.*

### Bagian 8: Keamanan Jaringan & Web Proxy
* [Lab 11 — MikroTik Stateful Firewall Filtering, Address Lists & Transparent Web Proxy](./11-MikroTik-Firewall-Filter-Proxy/)
  > *Penerapan filosofi Drop Many Accept Few, Connection Tracking (established/related/invalid), Address Lists blocking, dan Transparent Web Proxy.*

### Bagian 9: Agregasi Link & Redundansi Kabel Fisik
* [Lab 12 — MikroTik Interface Bonding & Link Aggregation (LACP 802.3ad & Failover)](./12-MikroTik-Interface-Bonding-LACP/)
  > *Agregasi 2 kabel fisik RJ-45 secara paralel, mode Balance-RR, Active-Backup, LACP 802.3ad, dan pengujian cable cut.*

---

## 🛠️ Perangkat & Alat Laboratorium

- **Hardware:** MikroTik RouterBOARD (RB962UiGS-5HacT2HnT, RB951-2nD), Cisco Catalyst Switches, Laptop Testbeds, Kabel UTP Cat5e/6.
- **Software / Virtualisasi:** MikroTik RouterOS v6 & v7 (CHR), Cisco Packet Tracer, Winbox, Oracle VM VirtualBox, Ubuntu Server 22.04/24.04 LTS.

---

## 📜 Lisensi & Dokumentasi

Seluruh konfigurasi dan dokumentasi disusun untuk portofolio teknis dan repositori pembelajaran infrastruktur jaringan komputer.
