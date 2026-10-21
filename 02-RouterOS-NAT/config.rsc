# 2026-10-21 19:22:33 by RouterOS 7.23.8
# system id = m0xklJArOOG
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/ip address
add address=192.168.56.2/24 interface=ether2 network=192.168.56.0
/ip dhcp-client
add interface=ether1 name=client1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
