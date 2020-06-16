#!/bin/bash

#change all iptables to drop + flush
echo "FLUSH IPTABLES"
iptables -F 
iptables -t nat -F 
iptables -t mangle -F

echo
echo "Setting All IPtables to DROP SETTING"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo
echo "What is the name of your LAN-SEG interface?"
read iface

echo
echo "Opening up firewall for loopback interface + LAN SEG"
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i $iface -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -o $iface -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo
echo "Since this script is for your DNS or Web Server what are your port needs to be open?"
read port

echo
echo "Opening Port $port!!!"
iptables -A INPUT -p tcp -m tcp --dport $port -j ACCEPT

echo
echo "Allowing ICMP Packets to go through"
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

