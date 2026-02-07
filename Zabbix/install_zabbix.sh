#!/bin/bash

#check if the script is running as root if not run ask to run as root
if [ $(id -u) -ne 0 ] ; then
    echo "please run the script as root"
    exit 1
fi 
#check which operating system its running 
OS_NAME=$( grep "^ID=" /etc/os-release | cut -d"=" -f2 | tr -d '"')
#check if there is already a zabbix installed and active in the server
if systemctl is-active --quiet zabbix-agent; then
    agent_status='zabbix-agent'
elif systemctl is-active --quiet zabbix-agent2; then
    agent_status='zabbix-agent2'

else 
    agent_status='none'
fi

#if it is unistall it 
if [ "$agent_status" != 'none' ]; then
    systemctl stop "$agent_status"
    systemctl disable "$agent_status"

    echo "uninstalling $agent_status .."
    if [ "$OS_NAME" = 'ubuntu' ]; then
        apt purge -y $agent_status
        apt autoremove $agent_status
    elif [ "$OS_NAME" = 'suse' ]; then
        zypper purge -y $agent_status
        zypper autoremove $agent_status
    fi
else 
    echo "no zabbix is installed so nothhing to remove "




#if not then we install the zabbix agent
#we change the configuraiton 
#restart the agent running with proper configuraition 
#we are done with the scripts