# Lab 02 - RouterOS NAT & Gateway Configuration

## 1. Tujuan
Konfigurasi dasar Mikrotik RouterOS di VirtualBox untuk menghubungkan jaringan LAN (Host-Only) ke internet menggunakan DHCP Client di WAN dan Source NAT (Masquerade).

## 2. Topologi Jaringan
[ Internet / Host ]
|
(ether1 - DHCP Client / WAN)
[ RouterOS VM ]
(ether2 - 192.168.56.2/24 / LAN Gateway)
|
[ Ubuntu Client ] (IP: 192.168.56.10/24)

## 3. Konfigurasi Utama
File konfigurasi lengkap hasil ekspor RouterOS dapat dilihat pada [config.rsc](./config.rsc).

- **WAN (ether1):** IP Dynamic via DHCP Client
- **LAN (ether2):** Static IP `192.168.56.2/24`
- **DNS Server:** `8.8.8.8` (Allow Remote Requests)
- **NAT Rule:** `chain=srcnat out-interface=ether1 action=masquerade`

## 4. Masalah yang Ditemui & Solusi (Troubleshooting)
> *Catatan: Bagian ini akan dilengkapi setelah pengujian komprehensif.*
- **Masalah:** Client Ubuntu tidak dapat melakukan ping ke domain luar (google.com) meskipun IP internet bisa di-ping.
- **Solusi:** Menambahkan DNS Resolver di RouterOS dan mengaktifkan `allow-remote-requests=yes` serta memastikan DNS di client mengarah ke IP Gateway / Public DNS.
