#!/bin/sh

# Prompt the user for input
echo -n "Enter T (must be between 1-4): "
read T

echo -n "Enter Group number (must be between 1-6): "
read G

echo "T: $T"
echo "G: $G"

requisitos() {
  apk add --no-cache dhcrelay || { echo "Falha ao instalar pacotes"; exit 1; }
  rc-update add dhcrelay
}

# alinea a
configurar_network_interfaces() {
  # Backup do arquivo de configuração de rede
  cp /etc/network/interfaces /etc/network/interfaces.bkp
  :> /etc/network/interfaces
  echo "
auto lo
iface lo inet loopback

# Rede interligacao 172.20.0.0/30 
auto eth0 
iface eth0 inet static
  address 172.20.${T}${G}.2
  netmask 255.255.255.252
  gateway 172.20.${T}${G}.1

# Rede 1 192.168.1${T}${G}.128/25
auto eth1
iface eth1 inet static
  address 192.168.1${T}${G}.129
  netmask 255.255.255.128
  " >> /etc/network/interfaces

  service networking restart
}

# alinea b
ativar_encaminhamento_ip() {
  echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf 
  sysctl -p
}

# alinea c
configurar_agente_relay_dhcp() {
  sed -i "/^DHCRELAY_SERVERS=/c\DHCRELAY_SERVERS=\"172.20.${T}${G}.1\"" /etc/conf.d/dhcrelay
}

configurar_network_interfaces || { echo "Falha ao configurar interfaces de rede"; exit 1; }
ativar_encaminhamento_ip || { echo "Falha ao ativar encaminhamento IP"; exit 1; }
requisitos || { echo "Falha ao instalar requisitos"; exit 1; }
configurar_agente_relay_dhcp || { echo "Falha ao configurar agente relay DHCP"; exit 1; }
