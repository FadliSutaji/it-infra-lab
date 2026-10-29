# 🌐 IT Infrastructure & Enterprise Networking Lab

> Dokumentasi laboratorium, topologi, dan implementasi jaringan komputer tingkat enterprise (*Routing, Switching, Redundancy, Tunneling, & Security Hardening*) berbasis **MikroTik RouterOS** dan **Cisco IOS**.

**Disusun oleh:**  
**Fadli Sutaji Muidita**  
Mahasiswa D-IV Teknologi Rekayasa Internet — Departemen Teknik Elektro dan Informatika, Sekolah Vokasi, Universitas Gadjah Mada (UGM)  
[![GitHub](https://img.shields.io/badge/GitHub-FadliSutaji-blue?logo=github)](https://github.com/FadliSutaji)

---

## 📌 Ringkasan Kemampuan Teknis (Technical Skill Map)

Berdasarkan praktikum intensif dan pengujian laboratorium nyata (*physical hardware* RouterBOARD RB962 / RB951, Cisco Catalyst & simulasi CHR / Cisco Packet Tracer):

| Kategori | Protokol & Teknologi | Implementasi Nyata |
|---|---|---|
| **Routing Dinamis (Enterprise & ISP)** | OSPF (v2/v3), BGP, RIPv2 | Single & Multi-area OSPF, OSPF Mesh (hingga studi kasus 24 Router), eBGP/iBGP peering, Route Redistribution |
| **High Availability & Redundansi** | Dual-ISP Failover, Bonding | Check-Gateway Ping/ARP, Distance metric priority, LACP / 802.3ad link aggregation |
| **Switching & VLAN** | IEEE 802.1Q, Trunking, RoS | Access Port, Trunk Port, Router-on-a-Stick (Inter-VLAN Routing) di Cisco & MikroTik |
| **Device Hardening & Security** | SSH v2, Port Security, Firewall | RSA Key generation, SVI management, Port Security (sticky MAC violation), Filter Rules, Masquerade |
| **Tunneling & VPN** | EoIP, PPTP, GRE, L2TP | Layer-2 over Layer-3 EoIP transparent bridge, Site-to-Site tunneling, routing over VPN |
| **Network Core Services** | DHCP, DNS, NTP, IPAM | DHCP Server/Client, Recursive DNS Resolver, VLSM / Subnetting |

---

## 📂 Katalog Laboratorium (Lab Catalog)

### Bagian 1: Fundamental Jaringan & Gateway Dasar
* [Lab 01 — Subnetting & VLSM Cheat Sheet](./01-Subnetting/)
* [Lab 02 — RouterOS Basic Internet Gateway & NAT Masquerade](./02-RouterOS-NAT/)

### Bagian 2: High Availability & Redundansi ISP
* [Lab 03 — MikroTik Dual-ISP Automatic Failover](./03-Failover-Dual-ISP/)
  > *Failover otomatis 2 ISP (Ethernet + Wireless/Secondary WAN) menggunakan Distance Metric & Check-Gateway.*

### Bagian 3: Protokol Routing Dinamis (Enterprise Routing)
* [Lab 04 — MikroTik OSPF Dynamic Routing (Backbone, Mesh & Multi-Router)](./04-OSPF-Routing/)
  > *Konfigurasi OSPF Area 0, multi-router mesh, router-id, cost metric, hingga pengujian topologi skala besar.*
* [Lab 05 — MikroTik BGP (Border Gateway Protocol)](./05-BGP-Routing/)
  > *Implementasi Autonomous System (ASN), BGP Instance, BGP Peering antar routerboard, dan network advertisement.*

### Bagian 4: Tunneling & Virtual Private Network (VPN)
* [Lab 06 — Site-to-Site Tunneling (EoIP & PPTP)](./06-Tunneling-EoIP-PPTP/)
  > *Layer-2 Ethernet over IP (EoIP) dan PPTP Point-to-Point tunneling untuk komunikasi antar kantor cabang.*

### Bagian 5: Switching & Segmentasi Trafik
* [Lab 07 — VLAN & Inter-VLAN Routing (802.1Q)](./07-VLAN-InterVLAN/)
  > *Segmentasi broadcast domain dengan 802.1Q trunking dan Router-on-a-Stick di Cisco IOS & MikroTik.*

### Bagian 6: Cisco Enterprise Switching & Device Hardening
* [Lab 08 — Cisco Device Hardening & Secure Remote Management (SSH v2)](./08-Cisco-Device-Hardening-SSH/)
  > *Hardening switch Cisco Catalyst: Banner MOTD, SVI management VLAN 1, enkripsi RSA 2048-bit SSH v2, dan Layer-2 Port Security sticky MAC.*

---

## 🛠️ Perangkat & Alat Laboratorium

- **Hardware:** MikroTik RouterBOARD (RB962UiGS-5HacT2HnT, RB951-2nD), Cisco Catalyst Switches, Laptop Testbeds, Kabel UTP Cat5e/6.
- **Software / Virtualisasi:** MikroTik RouterOS v6 & v7 (CHR), Cisco Packet Tracer, Winbox, Oracle VM VirtualBox, Ubuntu Server 22.04/24.04 LTS.

---

## 📜 Lisensi & Dokumentasi

Seluruh konfigurasi dan dokumentasi disusun untuk portofolio teknis dan repositori pembelajaran infrastruktur jaringan komputer.
