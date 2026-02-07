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
    case $OS_NAME in 
        ubuntu|debian) 
            apt purge -y "$agent_status" 2>/dev/null || true
            apt autoremove -y 2>/dev/null || true
        ;;
        suse|opensuse*)
            zypper remove -y "$agent_status" 2>/dev/null || true
            zypper clean -a 2>/dev/null || true
        ;;
        centos|rhel|fedora|rocky|almalinux)
            yum remove -y "$agent_status" 2>/dev/null || true
            ;;
        *)
            echo "unsupported os $OS_NAME"
            exit 1
            ;;
    esac
    echo "uninstall is successfull"


else 
    echo "no zabbix is installed so nothhing to remove "
fi



#if not then we install the zabbix agent
case $OS_NAME in 
    ubuntu|debian) 
    wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
    dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
    apt update
    apt install -y zabbix-agent2 zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql
    
    ;;
    suse|opensuse*)
    rpm -Uvh --nosignature https://repo.zabbix.com/zabbix/7.0/sles/15/x86_64/zabbix-release-latest-7.0.sles15.noarch.rpm
    zypper --gpg-auto-import-keys refresh 'Zabbix Official Repository'
    zypper --non-interactive in zabbix-agent2
    ;;
    centos|rhel|fedora|rocky)
    OS_VER=$(rpm -E %{rhel})

    rpm -Uvh "https://repo.zabbix.com/zabbix/7.0/rhel/$OS_VER/x86_64/zabbix-release-latest-7.0.el$OS_VER.noarch.rpm" || \
        rpm -Uvh "https://repo.zabbix.com/zabbix/7.0/rhel/$OS_VER/x86_64/zabbix-release-7.0-1.el$OS_VER.noarch.rpm"
    dnf clean all
    dnf install -y zabbix-agent2 
    
        ;;
    *)
        echo "unsupported os $OS_NAME"
        exit 1
        ;;
esac
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2

echo "zabbix installed successfuly"

#we change the configuraiton 
ZABBIX_SERVER="example.com.1,example.com.2"
sed -i "s|^Server=.*|$ZABBIX_SERVER|" /etc/zabbix/zabbix_agent2.conf
sed -i "s|^ServerActive=.*|ServerActive=$ZABBIX_SERVER|" /etc/zabbix/zabbix_agent2.conf


#restart the agent running with proper configuraition 
systemctl restart zabbix-agent2

#check if everything is as expected 
grep "^Server=" /etc/zabbix/zabbix_agent2.conf

echo zabbix_agent2 -V | head -n 1
systemctl is-active zabbix-agent2
#we are done with the scripts