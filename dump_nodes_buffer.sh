#!/bin/bash

function log_message
{
  status=$1
  message=$2
  echo "$(date +%b\ %d\ %H:%M:%S) $(hostname) [dump_buffer_nodes] [${status}]: ${message}" >> /var/log/nodes_dump_cache
}

function send_ssh_command ()
{
  [[ ${#@} != 2 ]] && { echo "[-] send_ssh_command function take only two args"; exit 1; }
  ip=$1
  comma=$2
  echo $ip
  echo $comma
  ssh -A -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" root@${ip} "${comma}"
}

[[ -f "/opt/g8-pxeboot/pxeboot/conf/hosts" ]] || { log_message "ERROR" "can't find /opt/g8-pxeboot/pxeboot/conf/hosts"; exit 1; }

for stor in $(grep -E "\ stor-..\ " /opt/g8-pxeboot/pxeboot/conf/hosts | awk '{print $3}')
do
  log_message "Info" "start in ${stor}"
  if $(nc -zv ${stor} 22 &> /dev/null); then
    log_message "Info" "port 22 on ${stor} opened"
    mem=($(ssh root@"${stor}" "free -m | grep Mem"))
    log_message "Info" "${stor} memory: -Used:${mem[2]}  -free:${mem[3]}  -Cached:${mem[5]}  -Available:${mem[6]}"
    if [[ ${mem[3]} -lt 20000 ]]; then
      log_message "Action" "Dump cache/buffer on ${stor}"
      send_ssh_command "${stor}" "echo 3 > /proc/sys/vm/drop_caches"
      mem=($(ssh root@"${stor}" "free -m | grep Mem"))
      log_message "Info" "${stor} memory: -Used:${mem[2]}  -free:${mem[3]}  -Cached:${mem[5]}  -Available:${mem[6]}"
      sleep 600
    fi
  else
    log_message "ERROR" "Can't connect to port 22 on ${stor}"
    continue
  fi
done
