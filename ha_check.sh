#!/bin/bash
#title           :ha_check.sh
#description     :This script used to monitoe ovcmaster and start services on ovcmaster2 if it's umreachable
#author		       :Mohamed Galal
#git url         :https://github.com/mohamedgalal99/russia_scripts/blob/master/ha_check.sh
ovcmaster1='172.17.0.8'
function log_message
{
  message="${1}"
  status="${2}"
  RED='\033[0;31m'
  ORG='\033[1;33m'
  GRE='\033[0;32m'
  NC='\033[0m'
  if [[ ${status} == "error" ]]; then
    echo -e "$(date)\t${RED}[ERROR]${NC} ${message}" >> /var/log/master-available.log
  elif [[ ${status} == "warning" ]]; then
    echo -e "$(date)\t${ORG}[WARNING]${NC} ${message}" >> /var/log/master-available.log
  elif [[ ${status} == "success" ]]; then
    echo -e "$(date)\t${GRE}[SUCCESS]${NC} ${message}" >> /var/log/master-available.log
  fi
}
function port_status
{
  ipadd=${1}
  port ${2}
  nc -zv ${ipadd} ${port}
  echo $?
}

function can_connect
{
  ipadd=${1}
  # check if i can connect to ovc master on firest controller
  ping -c2 ${ipadd} &> /dev/null
  res=$?
  while [[ ${res} != 0 ]]; do
    log_message "Can't connect to ${ipadd}" "error"
    sleep 2
    ping -c2 ${ipadd} &> /dev/null
    res=$?
  done
  # check if agentcontroller on first ovcmaster is listen on port 4444
  nc -zv ${ipadd} 4444 &> /dev/null
  res=$?
  while [[ ${res} != 0 ]]; do
    log_message "Can't connect to port 4444 ip:${ipadd}" "warning"
    sleep 2
    nc -zv ${ipadd} 4444 &> /dev/null
    res=$?
  done
  for service in $(ays status |grep -E '^jumpscale|^openvcloud' | grep -v 'mongodb' | awk '{print $2}')
  do
    ays stop -n ${service}
    #echo "ays stop -n ${service}"
  done

}


## main ##
if [[ ! $(dpkg -l | grep 'ii  netcat-openbsd') ]]; then
  apt-get install netcat -y
fi

ping -c2 ${ovcmaster1} &> /dev/null
if [[ $? == 0 ]]; then
  log_message "Can connect to ${ovcmaster1} now" "success"
else
  ays start
  echo "ays start || log_message \"${ovcmaster1} unreachable\" 'error'"
  #echo "nooooooo"
  can_connect ${ovcmaster1}
fi
