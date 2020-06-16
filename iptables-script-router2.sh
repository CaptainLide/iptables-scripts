#!/bin/bash

echo "What is the IP Address of your default gateway?"
read gateway

echo
echo "What is the IP Schema of LAN-2 Subnet + Netmask (e.g 192.168.29.0/26)?"
read lan2

echo
echo "What is the IP Address of the LAN Segment that connects to other subnets?"
read lan

echo
echo "Adding Routes"
sudo ip route add default via $gateway
sudo ip route add $lan2 via $lan

echo "FLUSHING IPTABLES"
iptables -F
iptables -t nat -F
iptables -t mangle -F

echo "Setting all IPTABLES to drop"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo "Opening up firewall for loopback interface..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

echo

#ask for ext interface
echo "What is your external interface?"
read ext

#allow for ext access
echo
echo "Allowing $ext access"
iptables -A INPUT -i $ext -j ACCEPT
iptables -A OUTPUT -o $ext -j ACCEPT

#ask for int interface
echo "What is your internal network interface?"
read int

#ask for HOST-ONLY INTERFACE
echo
echo "What is your HOST-ONLY INTERFACE?"
read host

#allow for host-only access
iptables -A INPUT -i $host -j ACCEPT
iptables -A OUTPUT -o $host -j ACCEPT
iptables -A FORWARD -i $int -o $host -j ACCEPT
iptables -A FORWARD -i $host -o $int -j ACCEPT
iptables -A FORWARD -i $host -o $ext -j ACCEPT
iptables -A FORWARD -i $ext -o $host -j ACCEPT

#allow for INTERNET ACCESS and for other nodes to see Host-PC
iptables -t nat -A POSTROUTING -o $ext -j MASQUERADE
iptables -t nat -A POSTROUTING -o $host -j MASQUERADE
iptables -A FORWARD -i $ext -o $int -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables  -A FORWARD -i $int -o $ext -j ACCEPT 

#allow for int access
echo
echo "Allowing $int access"
iptables -A INPUT -i $int -j ACCEPT
iptables -A OUTPUT -o $int -j ACCEPT


#allow for TCP traffic to occur
echo "Allow for TCP TRAFFIC"
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#allow for outside devices to ping network
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

#allow for inside interfaces to ping externally
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

#save rules
echo
echo "Saving Rules"
service iptables save
service iptables restart

#make new lines
echo
echo

#test for internet
echo "Testing for Internet"
ping -c4 8.8.8.8

echo
echo

echo "Testing for DNS Resolve/Internet"
ping -c4 google.com


