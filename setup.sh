#!/bin/bash

# build docker
docker build -t babyrecruiter .

# setup firewall
docker run --cap-add=NET_ADMIN  -p 80:80 -it babyrecruiter /bin/bash -c 'chmod +x iptables.sh && ./iptables.sh && rm iptables.sh'