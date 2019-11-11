#!/bin/bash
IPT="/sbin/iptables"

# Server IP
SERVER_IP="$(ip addr show eth0 | grep 'inet ' | cut -f2 | awk '{ print $2}')"

echo "flush iptable rules"
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X

echo "Set default policy to 'DROP'"
$IPT -P INPUT   DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT  DROP

## This should be one of the first rules.
## so dns lookups are already allowed for your other rules
$IPT -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -p udp --sport 53 -m state --state ESTABLISHED     -j ACCEPT
$IPT -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -p tcp --sport 53 -m state --state ESTABLISHED     -j ACCEPT


echo "allow all and everything on localhost"
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

#################################	######################################################################
## Global iptable rules. Not IP specific

echo "Allowing new and established incoming connections to port 80"
$IPT -A INPUT  -p tcp -m multiport --dports 80 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -p tcp -m multiport --sports 80 -m state --state ESTABLISHED     -j ACCEPT

# Log before dropping
$IPT -A INPUT  -j LOG  -m limit --limit 12/min --log-level 4 --log-prefix 'IP INPUT drop: '
$IPT -A INPUT  -j DROP

$IPT -A OUTPUT -j LOG  -m limit --limit 12/min --log-level 4 --log-prefix 'IP OUTPUT drop: '
$IPT -A OUTPUT -j DROP

exit 0