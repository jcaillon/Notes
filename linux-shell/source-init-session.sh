#!/bin/sh
# This script is called from onlogin.sh
# Before calling, the parent script enters the current directory so that current script can use $(pwd) to find its current location.
# $(dirname ${0}) can't be used because this script is sourced in another one so $(dirname) would reference the wrong script.

. ./lib/lib-colors.sh

export ADMIN=$(pwd)

. ./source-user-commands.sh


# Welcome
echo -e ""
echo -e "${COLOR_YELLOW}Welcome, user \"$(whoami)\"${COLOR_DEFAULT}"
if [ "$(whoami)" == "root" ] ; then
	echo -e "${COLOR_YELLOW}You are logging as root. Please make sure you know what you are doing.${COLOR_DEFAULT}"
fi
echo "This VM is reachable on @IP:"
IP_LIST=$(/sbin/ifconfig | grep "inet " | grep -v "127.0.0.1" | sed "s,addr:,,g" | awk '{ print $2; }')
for IP in ${IP_LIST} ; do
	echo -e "- ${COLOR_CYAN}${IP}${COLOR_DEFAULT}"
done
echo -e ""


# Show versions
echo -e "${COLOR_LIGHT_BLUE}$(cat /etc/centos-release)${COLOR_DEFAULT}"
if [ -f "${DLC}/version" ]; then
	echo -e "${COLOR_LIGHT_BLUE}$(cat "${DLC}/version")${COLOR_DEFAULT}"
fi


# Show last update date
if [ -f "${ADMIN}/_pasoe_version.txt" ] ; then
	echo -e "System current version: ${COLOR_LIGHT_BLUE}$(cat "${ADMIN}/_pasoe_version.txt" | grep -v "^$")${COLOR_DEFAULT}, last updated on: ${COLOR_LIGHT_BLUE}$(stat "${ADMIN}/_pasoe_version.txt" | grep "^Change: " | sed "s,Change: ,," | sed "s,\..*,,")${COLOR_DEFAULT}."
else
	echo -e "System current version is ${COLOR_LIGHT_BLUE}unknown${COLOR_DEFAULT} as it has ${COLOR_LIGHT_BLUE}never been updated${COLOR_DEFAULT}."
fi
echo -e ""


# Show useful commands
echo -e "Type ${COLOR_CYAN}switchto${COLOR_DEFAULT} to switch to an existing pasoe and get extra commands from there."
echo -e "You can also use a shortcut to directly specify the pasoe number to switch to : ${COLOR_CYAN}switchtonb 1${COLOR_DEFAULT}."
echo -e ""


return 0
