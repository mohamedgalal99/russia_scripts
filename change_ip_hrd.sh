#!/bin/bash

[[ $# -ne 2 ]] && { echo "[-] This script take 2 arguments (old ip and new ip) to replace them on all nodes"; exit 1; }

node_name=$(hostname)
old_ip=$1
new_ip=$2

if [[ "${node_name::3}" == 'cpu' ]]
then
  for i in $(grep -Rn "${old_ip}" /opt/jumpscale7/ | grep -E '^/opt' | awk -F: '{print $1}')
  do
    sed -i "s/${old_ip}/${new_ip}/" ${i}
  done
elif [[ "${node_name::4}" == 'stor' ]]; then
  for i in $(grep -Rn "${old_ip}" /opt/jumpscale7/hrd/ | grep -E '^/opt' | awk -F: '{print $1}')
  do
    sed -i "s/${old_ip}/${new_ip}/" ${i}
  done
else
  echo "[-] This node ${node} has unknown type"
fi
ays restart
