#!/bin/bash

#ask user for ip addresses
echo "What is the IP Address of your host machine?"
read host

echo
echo "What is the IP Address of your raspberry pi?"
read pi

echo 
echo "What is the PORT that should only be accessed by the Raspberry Pi?"
read port1

echo
echo "What is the PORT that should only be accessed by the Host Machine?"
read port2

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
echo "Opening up firewall!!!"
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s $host -p tcp -m tcp --dport $port2 -j ACCEPT
iptables -A INPUT -s $pi -p tcp -m tcp --dport $port1 -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


echo
echo "Allowing ICMP Packets to go through"
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

service iptables save
service iptables restart
