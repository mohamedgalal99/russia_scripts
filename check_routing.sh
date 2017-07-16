#!/bin/bash

ctrl1="10.200.2.2"
ctrl2="10.200.2.3"
cpu-01="10.200.2.11"

# Routing on first controller

if [[ ! $(ip r | grep -E "^172.18.0.0/24 via ${ctrl2}") ]]; then
  ip r a 172.18.0.0/24 via ${ctrl2} || { echo "[-] Can't add 172.18.0.0/24 routing"; exit 1; }
  echo "[+] routing added to 172.18.0.0/24"
else
  echo "[*] route to docker network 172.18.0.0/24 via ${ctrl2} found"
fi

if [[ ! $(ip r | grep -E "^172.19.0.0/24 via ${cpu-01}") ]]; then
  ip r a 172.19.0.0/24 via ${cpu-01} || { echo "[-] Can't add 172.19.0.0/24 routing"; exit 1; }
  echo "[+] routing added to 172.19.0.0/24"
else
  echo "[*] route to docker network 172.19.0.0/24 via ${ctrl2} found"
fi

#Routing on cpu node
if [[ $(ssh root@${cpu-01} "ip r | grep -E '^172.17.0.128/25 via 10.200.2.2' ") ]]; then
  echo "[+] Adding routing from cpu-01 to docker on ctrl-01"
  ssh root@${cpu-01} "ip r a 172.17.0.128/25 via """${ctrl-01}""" " || { echo "[-] Faild to add route entry for ${cpu-01}"}
  ssh root@${cpu-01} "ip r a 172.17.0.0/25 via """${ctrl-01}""" "
fi
