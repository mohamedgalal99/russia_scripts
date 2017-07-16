#!/bin/bash
old_ip=$1
new_ip=$2

function send_ssh_command ()
{
  [[ ${#@} != 2 ]] && { echo "[-] send_ssh_command function take only two args"; exit 1; }
  ip=$1
  comma=$2
  echo $ip
  echo $comma
  ssh -A -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${ip} "${comma}"
}
function qu ()
{
while true
do
  echo -n "[*] Do u want to continue [y/n]:"
  read answer
  if [[ "${answer}" == "y" ]]
  then
    break
  elif [[ "${answer}" == "n" ]]
  then
    exit
  fi
done
}
[[ $# -ne 2 ]] && { echo "[-] This script take 2 arguments (old ip and new ip) to replace them on all nodes"; exit 1; }
[[ -f "/opt/g8-pxeboot/pxeboot/conf/hosts" ]] || { echo "[-] Can't find host file "; exit 1; }

for node in $(grep -E "cpu|stor" /opt/g8-pxeboot/pxeboot/conf/hosts | grep -v 'ipmi' | awk '{print $1}')
do
  send_ssh_command "${node}" "cd /tmp && wget https://raw.githubusercontent.com/mohamedgalal99/russia_scripts/master/change_ip_hrd.sh"
  send_ssh_command "${node}" "cd /tmp && bash change_ip_hrd.sh ${old_ip} ${new_ip}"
  qu
done
