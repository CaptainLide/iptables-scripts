#!/bin/bash

echo "What is your x? for your VM Network? (e.g 192.168.x.0/26)"
read x

echo
echo "What is your netmask?"
read n

echo
echo "What is the last notation for the IP Address on your eth0 interface (192.168.z.0/24) give z "
read z

echo
echo "What is the last notation fo the IP Address on your VM Interface (ens33: 192.168.z.y)"
read y

# This section should be edited according to the netmask and its subnets
sudo ip route add 192.168.$x.0/$n via 192.168.$z.$y 
sudo ip route add 192.168.$x.64/$n via 192.168.$z.$y

echo
echo "Adding Routes"
ip route list

echo
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

iptables -A FORWARD -i $ext -o $int -j ACCEPT 

#allow for INTERNET ACCESS
iptables -t nat -A POSTROUTING -o $ext -j MASQUERADE
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

echo "Testing for DNS Resolve/Internet"
ping -c4 google.com


