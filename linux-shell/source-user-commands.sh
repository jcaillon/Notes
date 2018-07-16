#!/bin/bash
# https://superuser.com/questions/176783/what-is-the-difference-between-executing-a-bash-script-vs-sourcing-it/176788#176788
# source switchto.sh

# Include libs
. ./lib/lib-consts.sh
. ./lib/lib-colors.sh

function changevmname() {
	local newHostName="${1}"

	# Only root can do this
	if [ "$(whoami)" != "root" ] ; then
		echo -e "${COLOR_RED}** This script must be run by user root.${COLOR_DEFAULT}"
		exit ${ERR}
	fi

	# Ask the user what he wannna do if target hostname is not provided
	echo "Current hostname: $(hostname)"
	if [ -z "${newHostName}" ] ;  then
		echo -ne "New hostname: "
		read newHostName
	fi
	echo -e "Target hostname: ${newHostName}"

	# Empty answer is forbidden
	if [ -z "${newHostName}" ] ; then
		echo -e "${COLOR_RED}** New hostname can't be empty.${COLOR_DEFAULT}"
		exit ${ERR}
	fi

	# Need to remove the hostname from host then add the new name
	echo -e "- updating /etc/hosts"
	mv -f "/etc/hosts" "/etc/hosts.old"
	cat "/etc/hosts.old" | grep -v "[ \t]$(hostname)[ \t$]" > "/etc/hosts"
	echo "127.0.0.1    ${newHostName}" >> "/etc/hosts"
	echo "::1          ${newHostName}" >> "/etc/hosts"

	# Need to change the hostname
	echo -e "- updating /etc/hostname"
	echo "${newHostName}" > /etc/hostname
	echo -e "- updating volative hostname"
	hostname ${newHostName}
	echo -e "${COLOR_YELLOW}In order for changes to take effect, you have to log-on again.${COLOR_DEFAULT}"

	# Finished!
	echo -e "Done."
	return ${OK}
}

function admin() {
	echo -e "${COLOR_CYAN}---[ Administration Commands ]---${COLOR_DEFAULT}"
	\ls -1 ${ADMIN} | grep "\.sh$" | grep -v "^on" | grep -v "^source-" | sed 's,^,- ,'
	return ${OK}
}

function restorerights() {

	echo ""
	echo -e "${COLOR_GREEN}>> Restoring rights...${COLOR_DEFAULT}"
	echo ""
	
	# change the default permission on files created in this rep
	sudo setfacl -Rb /exploit
	sudo setfacl -Rm default:mask:rwx /exploit
	getfacl /exploit
	
	sudo chown -R progress:progress /exploit
	sudo chmod -R 777 /exploit
	
	sudo chown -R samba:progress /exploit/appli
	sudo chmod -R 755 /exploit/appli
	
	chcon -R -t samba_share_t /exploit
	chcon -R -t public_content_rw_t /exploit/webclient
	
	ls -ldZ /exploit
	ls -ldZ /exploit/appli
	ls -ldZ /exploit/webclient
	
	return ${OK}
}

function getready() {

	if [ ! -d "${PASOE}/${CDOM}-${CENV}-${CCEL}" ]; then
		echo -e "${COLOR_RED}Use the ${COLOR_CYAN}switchto${COLOR_RED} command first${COLOR_DEFAULT}"
		return ${ERR}
	fi
	
	echo ""
	echo -e "${COLOR_GREEN}>> Starting databases for ${CDOM}-${CENV}-${CCEL}${COLOR_DEFAULT}"
	echo ""
	
	eval ${SC_DBSTART}
	
	echo ""
	echo -e "${COLOR_GREEN}>> Starting pasoe for ${CDOM}-${CENV}-${CCEL}${COLOR_DEFAULT}"
	echo ""
	
	eval ${SC_TCSTART}
	
	return ${OK}
}

function switchtonb() {
	local opt=$(find /exploit/pasoe/ -maxdepth 1 -type d -name "*" | sed -n '2p')
	local pasoeName=$(printf "%s" "${opt##*/}")
	local DOM=$(echo "${pasoeName}"| awk -F"-" '{print $1}' )
	local ENV=$(echo "${pasoeName}"| awk -F"-" '{print $2}' )
	local CEL=$(echo "${pasoeName}"| awk -F"-" '{print $3}' )
	
	switchto ${DOM} ${ENV} ${CEL}
	
	return ${OK}
}

function switchto() {

	if [ -z "${DLC}" ]; then
		setuserenv
	fi

	if [ -z "${1}" ] && [ -z "${2}" ] && [ -z "${3}" ]; then
		user_select_pasoe
		if [ $? -eq ${ERR} ] ; then
			return ${ERR}
		fi
	elif [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then
		echo -e "${COLOR_RED}syntax is : switchto.sh domaine environnement cellule${COLOR_DEFAULT}"
		return ${ERR}
	else
		export CDOM=${1}
		export CENV=${2}
		export CCEL=${3}
	fi

	if [ -z "${CDOM}" ] || [ -z "${CENV}" ] || [ -z "${CCEL}" ]; then
		return ${ERR}
	fi
		
	if [ ! -d "${PASOE}/${CDOM}-${CENV}-${CCEL}" ]; then
		echo -e "${COLOR_RED}Could not find pasoe named ${CDOM}-${CENV}-${CCEL}!${COLOR_DEFAULT}"
		return ${ERR}
	fi
	
	setuseraliases
	
	return ${OK}
}

function setuserenv() {
	echo -e "${COLOR_GREEN}Setting user environment variables${COLOR_DEFAULT}"
	echo ""
	
	# Define immutable variables
	export DLC=/usr/progress/v1160/dlc
	export PROGRESS_DIR=/var/log/progress
	export PRO_LOG_DIR=${PROGRESS_DIR}/v1160
	export OEM_LOG_DIR=${PROGRESS_DIR}/wrk_oemgmt
	export CATALINA_HOME=${DLC}/servers/pasoe
	export CNAF_ROOT=/exploit
	export BASE=${CNAF_ROOT}/db
	export APPLI=${CNAF_ROOT}/appli
	export PASOE=${CNAF_ROOT}/pasoe
	export LOCSERVEXEC=/exploit/wrk
	export LOCSERVEXECTEMP=/exploit/wrk/progress


	# update PATH
	export PATH=${ADMIN}:${CATALINA_HOME}/bin:${DLC}/bin:${PATH}:/exploit/lib


	# HTTP PROXY
	export http_proxy='http://lyon.proxy.corp.sopra:8080'
	export https_proxy='http://lyon.proxy.corp.sopra:8080'

	ulimit -c unlimited
	
	echo -e "You can use those environment variables (and others, type ${COLOR_CYAN}export${COLOR_DEFAULT})"
	echo -e "  ${COLOR_CYAN}DLC${COLOR_DEFAULT}       --> ${DLC}"
	echo -e "  ${COLOR_CYAN}PASOE${COLOR_DEFAULT}     --> ${PASOE}"
	echo ""
	
	return ${OK}
}

function setuseraliases() {
	echo -e "${COLOR_GREEN}Setting aliases for ${CDOM}-${CENV}-${CCEL}${COLOR_DEFAULT}"
	echo ""
	
	export CATALINA_BASE=${PASOE}/${CDOM}-${CENV}-${CCEL}
	export TCMANSH=${CATALINA_BASE}/bin/tcman.sh

	# Define aliases
	alias nano='vim'
	alias vi='vim'
	alias ll='ls -al --color'
	
	# db
	export "SC_DBSTART=find ${BASE}/${CCEL}/${CENV}/${CDOM} -type f \( -name '*.lg' -or -name '*.lk' -or -name 'pid*.cnx' \) -delete && pushd ${ADMIN}/openedge 1>/dev/null && ${DLC}/bin/_progres -b -T /tmp -p dbgo.p -param start,"
	alias dbstart=${SC_DBSTART}
	alias dbrepair="pushd ${ADMIN}/openedge 1>/dev/null && ${DLC}/bin/_progres -b -T /tmp -p dbgo.p -param repair,"
	alias dbstop="pushd ${ADMIN}/openedge 1>/dev/null && ${DLC}/bin/_progres -b -T /tmp -p dbgo.p -param stop,"
	alias dbkill="ps ax | grep /usr/progress/v1160/dlc/bin/_mprosrv | grep -v grep | awk '{print $1}' | xargs kill -9 2>/dev/null"

	export "SC_TCSTART=${TCMANSH} clean && ${TCMANSH} start"
	alias tcman="${TCMANSH}"
	alias tcstart=${SC_TCSTART}
	alias tcstop="${TCMANSH} stop"
	alias tcrestart="${TCMANSH} stop && sleep 2 && tcstart"
	alias tcstatus="${TCMANSH} status -u tomcat:tomcat"
	
	alias getready='getready'

	alias cdmex="cd ${APPLI}/${CDOM}/${CENV}/${CCEL}/mex/"

	alias oemstart="proadsv -start && fathom -start && echo 'Dispo sur http://vm:9090/ avec admin/sopra*'"
	alias oemstop="fathom -stop && proadsv -stop"

	alias killme="shutdown -h now"
	alias restartnetwork="service network restart && service smb restart"
	
	alias switchto="switchto"
	alias admin="admin"
	alias change-vm-name="changevmname"
	
	echo -e "You can use the following commands (and others, type ${COLOR_CYAN}alias${COLOR_DEFAULT})"
	echo -e "  ${COLOR_CYAN}getready${COLOR_DEFAULT}       --> start the databases (dbstart) and the PASOE (tcstart)"
	echo -e "  ${COLOR_CYAN}tcrestart${COLOR_DEFAULT}      --> restart the pasoe"
	echo ""
	echo -e "${COLOR_YELLOW}>> The commands are set to work for ${CDOM}-${CENV}-${CCEL}${COLOR_DEFAULT}"
	echo ""
	
	return ${OK}
}

function user_select_pasoe() {
	unset options i
	while IFS= read -r -d $'\0' f; do
	  options[i++]="$f"
	done < <(find /exploit/pasoe/ -maxdepth 1 -type d -name "*-*-*" -print0  | sed 's/.*\///')
	select opt in "${options[@]}" "Do nothing"; do
		case $opt in
			*-*-*)
				echo ""
				export CDOM=$(echo "${opt}"| awk -F"-" '{print $1}' )
				export CENV=$(echo "${opt}"| awk -F"-" '{print $2}' )
				export CCEL=$(echo "${opt}"| awk -F"-" '{print $3}' )
				break
				;;
			"Do nothing")
				echo "K bye"
				return ${ERR}
				break
				;;
			*)
				echo "This is not a number"
				;;
		esac
	done
	
	return ${OK}
}

function Main
{

	export -f setuserenv
	export -f switchto
	export -f switchtonb
	export -f getready
	export -f restorerights

	return ${OK}
}

# Finally, let's start
Main $@
return 0