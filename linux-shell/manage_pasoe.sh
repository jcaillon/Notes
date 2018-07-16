#!/bin/sh
# ccleaud, 2016
# TODO: oeprop oepas1.ROOT.APSV.adapterEnabled=1


# Overall variables
SCRIPT_VERSION="1.19"
SCRIPT_NAME=$(basename "${0}")
SCRIPT_DIR=$(dirname "${0}")


# Include libs
. ${SCRIPT_DIR}/lib/lib-consts.sh
. ${SCRIPT_DIR}/lib/lib-colors.sh
. ${SCRIPT_DIR}/lib/lib-misc.sh


function Main
{
	# Check for mandatory variables
	if [ "$(whoami)" == "root" ] ; then
		echo -e "${COLOR_RED}** This script must NOT be run by user root.${COLOR_DEFAULT}"
		return ${ERR}
	fi
	if [ -z "${DLC}" ] ; then
		echo -e "${COLOR_RED}** DLC variable is missing.${COLOR_DEFAULT}"
		return ${ERR}
	fi
	if [ -z "${PASOE}" ] ; then
		echo -e "${COLOR_RED}** PASOE variable is missing.${COLOR_DEFAULT}"
		return ${ERR}
	fi

	# Show menu
	while true; do
		Menu || break
	done

	echo -e "--- END OF SCRIPT ---"
	echo -e ""
	return ${OK}
}


function Menu
{
	local currentServer
	local userAction
	local runCommand
	local portPasoeHttp
	local portPasoeHttps
	local portPasoeStop
	local portPasoeAjp13
	local execStatus=${OK}

	# Say hello
	echo ""
	echo ""
	echo -e "${COLOR_CYAN}---[ ${SCRIPT_NAME}, v${SCRIPT_VERSION} ]---${COLOR_DEFAULT}"
	echo -e "${COLOR_BLUE}$(cat "${DLC}/version")${COLOR_DEFAULT}"

	echo -e ""
	ListStatus
	echo -e "${COLOR_TITLE}--- Miscellaneous Commands ---${COLOR_DEFAULT}"
	echo -e "  refresh (or simply r)"
	echo -e "  create-pasoe"
	echo -e "  stop-all"
	echo -e "  exit (or empty answer)"
	echo -e "${COLOR_TITLE}----------${COLOR_DEFAULT}"
	echo -e ""

	echo -e "${COLOR_YELLOW}REMEMBER:${COLOR_DEFAULT} PASOE is available at address ${COLOR_CYAN}http://<hostname>:<portnumber>/apsv${COLOR_DEFAULT} (or ${COLOR_CYAN}/rest${COLOR_DEFAULT}) (or ${COLOR_CYAN}/soap${COLOR_DEFAULT}) (or ${COLOR_CYAN}/web${COLOR_DEFAULT})"

	read -p "Select server (admin, oem, pasoe-xxx): " currentServer
	echo -e ""
	echo -e ""

	if [ -z "${currentServer}" ] || [ "${currentServer}" == "exit" ] ; then
		echo -e "${COLOR_YELLOW}Aborted by user.${COLOR_DEFAULT}"
		return ${ERR}
	elif [ "${currentServer}" == "refresh" ] || [ "${currentServer}" == "r" ] ; then
		echo -e "Refreshing... Please wait."
	elif [ "${currentServer}" == "stop-all" ] ; then
		local line

		# PASOEs
		\ls -1 "${PASOE}" | while read line ; do
			if [ -x "${PASOE}/${line}/bin/tcman.sh" ] ; then
				ExecCommand "tcman.sh stop" "${PASOE}/${line}/bin"
			fi
		done

		# OEM
		ExecCommand "fathom -stop" "${DLC}/bin"

		# Admin server
		ExecCommand "proadsv -stop" "${DLC}/bin"

		# Kill other process
		ps -edf | grep "/dlc/java/" | tr -s " " | cut -f 2 -d " " | while read line ; do
			echo -e "  Killing process ${line}..."
			kill -kill "${line}" 2>/dev/null
		done
	elif [ "${currentServer}" == "admin" ] ; then
		local oemPort

		# Case admin-server
		echo -e "${COLOR_TITLE}--- Actions ---${COLOR_DEFAULT}"
		echo -e "  1. start"
		echo -e "  2. stop"
		echo -e "  3. restart"
		echo -e "${COLOR_TITLE}----------${COLOR_DEFAULT}"
		read -p "Your choice: " userAction
		echo -e ""

		case "${userAction}" in
			"1")
				ExecCommand "proadsv -start" "${DLC}/bin"
				GetOemPort oemPort
				echo "If configured for auto-start, OpenEdge Management will be available on port ${oemPort}."
			;;
			"2")
				ExecCommand "proadsv -stop" "${DLC}/bin"
			;;
			"3")
				ExecCommand "proadsv -stop" "${DLC}/bin"
				ExecCommand "proadsv -start" "${DLC}/bin"
			;;
			*)
				echo -e "${COLOR_YELLOW}Dumbass, you should read before typing stupid things.${COLOR_DEFAULT}"
			;;
		esac
	elif [ "${currentServer}" == "oem" ] ; then
		local oemPort

		# Case OpenEdge Management
		echo -e "${COLOR_TITLE}--- Actions ---${COLOR_DEFAULT}"
		echo -e "  1. start"
		echo -e "  2. stop"
		echo -e "  3. restart"
		echo -e "${COLOR_TITLE}----------${COLOR_DEFAULT}"
		read -p "Your choice: " userAction
		echo -e ""

		case "${userAction}" in
			"1")
				ExecCommand "fathom -start" "${DLC}/bin"
				GetOemPort oemPort
				echo "When started, OpenEdge Management is available on port ${oemPort}."
			;;
			"2")
				ExecCommand "fathom -stop" "${DLC}/bin"
			;;
			"3")
				ExecCommand "fathom -stop" "${DLC}/bin"
				ExecCommand "fathom -start" "${DLC}/bin"
				GetOemPort oemPort
				echo "When started, OpenEdge Management is available on port ${oemPort}."
			;;
			*)
				echo -e "${COLOR_YELLOW}Dumbass, you should read before typing stupid things.${COLOR_DEFAULT}"
			;;
		esac
	elif [ "${currentServer}" == "create-pasoe" ] ; then
		# Case PASOE creation
		read -p "New PAS-OE name (leave empty to abort): " currentServer

		if [ -z "${currentServer}" ] ; then
			echo -e "${COLOR_YELLOW}Aborted by user.${COLOR_DEFAULT}"
		elif [ -e "${PASOE}/${currentServer}" ] ; then
			echo -e "${COLOR_YELLOW}Sorry, dude, this PASOE appears already existing.${COLOR_DEFAULT}"
		else
			read -p "Port number for HTTP (in range 50000..50999): " portPasoeHttp

			if [ ${portPasoeHttp} -lt 50000 ] || [ ${portPasoeHttp} -gt 50999 ] ; then
				echo -e "${COLOR_YELLOW}Invalid port number.${COLOR_DEFAULT}"
			else
				portPasoeHttps=$(expr ${portPasoeHttp} + 1000)
				portPasoeStop=$(expr ${portPasoeHttp} + 2000)
				portPasoeAjp13=$(expr ${portPasoeHttp} + 3000)

				ExecCommand "tcman.sh create -p ${portPasoeHttp} -P ${portPasoeHttps} -s ${portPasoeStop} -j ${portPasoeAjp13} ${PASOE}/${currentServer}" "${CATALINA_HOME}/bin"
				if [ $? -eq ${OK} ] ; then
					# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					# !! DON'T DO THIS --> THIS CAUSES OEM AND ADMIN-SERVER TO STOP WORKING !!
					# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					#					# Make this instance visible to OEM (add only in file if not already present)
					#					cat "${CATALINA_HOME}/conf/instances.unix" | grep "^${currentServer}=" > /dev/null
					#					if [ $? -ne ${OK} ] ; then
					#						echo "${currentServer}=${PASOE}/${currentServer}" >> "${CATALINA_HOME}/conf/instances.unix"
					#					fi
					# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

					# Apply correct permissions
					find "${PASOE}/${currentServer}" -type d -exec chmod 755 {} \;

					# Adjust JVM memory
					#cd "${PASOE}/${currentServer}/conf"
					#cat "jvm.properties" | sed "s|^[ \t]*-Xms[0-9]*m$|-Xms128m|" | sed "s|^[ \t]*-Xmx[0-9]*m$|-Xms256m|" >  "jvm.properties.tmp"
					#mv -f "jvm.properties.tmp" "jvm.properties"

					#ExecCommand "tcman.sh deploy -a manager ${CATALINA_HOME}/extras/manager.war -u tomcat:tomcat" "${PASOE}/${currentServer}"
					#if [ $? -eq ${OK} ] ; then
					#	ExecCommand "tcman.sh deploy -a oemanager ${CATALINA_HOME}/extras/oemanager.war -u tomcat:tomcat" "${PASOE}/${currentServer}"
					#	echo -e "${COLOR_CYAN}-- PAS-OE ports: http: ${portPasoeHttp}, https: ${portPasoeHttps}, stop: ${portPasoeStop}, ajp13: ${portPasoeAjp13} --${COLOR_DEFAULT}"
					#	# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					#	# !! DON'T DO THIS --> THIS CAUSES PASOE TO FAIL STARTING !!
					#	# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					#	# if [ $? -eq ${OK} ] ; then
					#	# 	ExecCommand "tcman.sh deploy -a oeabl ${CATALINA_HOME}/extras/oeabl.war -u tomcat:tomcat" "${PASOE}/${currentServer}"
					#	# fi
					#	# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					#fi
					
					
				fi
			fi
		fi
	elif [ ! -z "$(echo ${currentServer} | grep '^pasoe-')" ] ; then
		# Other cases: PASOE
		currentServer=$(echo "${currentServer}" | sed 's|^pasoe-||')

		if [ ! -d "${PASOE}/${currentServer}" ] ; then
			echo -e "${COLOR_YELLOW}** Invalid PASOE name.${COLOR_DEFAULT}"
		else
			local pasoeLogFile

			# Re-create structure in case of corrupted PASOE
			if [ ! -d "${PASOE}/${currentServer}/bin" ] ; then
				mkdir -p "${PASOE}/${currentServer}/bin"
				echo "#!/bin/sh" > "${PASOE}/${currentServer}/bin/tcman.sh"
				echo "echo \"** Error: Corrupted PASOE - please delete this PASOE.\"" >> "${PASOE}/${currentServer}/bin/tcman.sh"
				echo "exit 1" >> "${PASOE}/${currentServer}/bin/tcman.sh"
				chmod 755 "${PASOE}/${currentServer}/bin/tcman.sh"
			fi

			# Get log file name according to properties file
			GetPasoeLogFileName ${currentServer} pasoeLogFile

			echo -e "${COLOR_TITLE}--- Actions ---${COLOR_DEFAULT}"
			echo -e "  1. start"
			echo -e "  2. stop"
			echo -e "  3. restart"
			echo -e "  4. delete"
			echo -e "  5. edit openedge.properties"
			echo -e "  6. edit logs (${pasoeLogFile})"
			echo -e "  7. tail -f logs (${pasoeLogFile})"
			echo -e "  8. go to log directory"
			echo -e "  9. show errors from OpenEdge log files ${COLOR_YELLOW}[!! new !!]${COLOR_DEFAULT}"
			echo -e " 10. show errors from ALL log files ${COLOR_YELLOW}[!! new !!]${COLOR_DEFAULT}"
			echo -e "${COLOR_TITLE}----------${COLOR_DEFAULT}"
			read -p "Your choice: " userAction
			echo -e ""

			case "${userAction}" in
				"1")
					ExecCommand "tcman.sh start" "${PASOE}/${currentServer}/bin"
				;;
				"2")
					ExecCommand "tcman.sh stop" "${PASOE}/${currentServer}/bin"
				;;
				"3")
					ExecCommand "tcman.sh stop" "${PASOE}/${currentServer}/bin"
					ExecCommand "tcman.sh start" "${PASOE}/${currentServer}/bin"
				;;
				"4")
					echo -ne "${COLOR_YELLOW}!! DELETE ${currentServer} !!${COLOR_DEFAULT} Are you sure (y/N)? "
					read userAction
					if [ "${userAction}" == "y" ] || [ "${userAction}" == "Y" ] ; then
						local oemPort

						ExecCommand "tcman.sh stop" "${PASOE}/${currentServer}/bin"
						ExecCommand "tcman.sh delete -y ${currentServer}" "${CATALINA_HOME}/bin"

						# Remove the instance from OEM
						${SCRIPT_DIR}/lib/ini-remove-section.sh -i "${DLC}/properties/pasmgr.properties" -s "PAS.${currentServer}" -o "${DLC}/properties/pasmgr.properties"

						# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						# !! DON'T DO THIS --> THIS CAUSES OEM AND ADMIN-SERVER TO STOP working !!
						# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						#						cat "${CATALINA_HOME}/conf/instances.unix" | grep -v "^${currentServer}=" > "/tmp/pasoe-delete-$$.tmp"
						#						mv -f "/tmp/pasoe-delete-$$.tmp" "${CATALINA_HOME}/conf/instances.unix"
						# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

						GetOemPort oemPort
						echo -e "${COLOR_CYAN}Contacting OEM using REST API...${COLOR_DEFAULT}"
						curl --connect-timeout 3 -u "admin:sopra*" -i -X DELETE "http://localhost:${oemPort}/oem/containers/$(hostname)/pas/localhost:resource.openedge.pas.${currentServer}" | grep "^HTTP"

						if [ -d "${PASOE}/${currentServer}" ] ; then
							rm -rf "${PASOE}/${currentServer}"
						fi
					else
						echo -e "${COLOR_YELLOW}Aborted by user.${COLOR_DEFAULT}"
					fi
				;;
				"5")
					ExecCommand "vim ${PASOE}/${currentServer}/conf/openedge.properties" ""
				;;
				"6")
					ExecCommand "vim ${pasoeLogFile}" ""
				;;
				"7")
					ExecCommand "tail -f ${pasoeLogFile}" ""
				;;
				"8")
					cd "${PASOE}/${currentServer}/logs"
					ls -al --color
					echo -e ""
					echo -e ""
					echo -e "Forking to sub-shell..."
					echo -e ""
					echo -e "${COLOR_YELLOW}----------------------------------------${COLOR_DEFAULT}"
					echo -e "${COLOR_YELLOW}-- You will enter a Shell sub session --${COLOR_DEFAULT}"
					echo -e "${COLOR_YELLOW}-- Press CTRL+D to return to the menu --${COLOR_DEFAULT}"
					echo -e "${COLOR_YELLOW}----------------------------------------${COLOR_DEFAULT}"
					${SHELL}
					echo -e "${COLOR_YELLOW}-----------------------------------------------------${COLOR_DEFAULT}"
					echo -e "${COLOR_YELLOW}-- End of sub shell session, returning to the menu --${COLOR_DEFAULT}"
					echo -e "${COLOR_YELLOW}-----------------------------------------------------${COLOR_DEFAULT}"
					cd - 1>/dev/null
				;;
				"9")
					cd "${PASOE}/${currentServer}/logs"
					egrep -H -n "(\*\*|ERROR|SEVERE)" --color=always "${pasoeLogFile}"
					cd - 1>/dev/null
				;;
				"10")
					cd "${PASOE}/${currentServer}/logs"
					egrep -H -n "(\*\*|ERROR|SEVERE)" --color=always *
					cd - 1>/dev/null
				;;
				*)
					echo -e "${COLOR_YELLOW}Dumbass, you should read before typing stupid things.${COLOR_DEFAULT}"
				;;
			esac
		fi
	else
		echo -e "${COLOR_YELLOW}Dumbass, you should read before typing stupid things.${COLOR_DEFAULT}"
	fi
	return ${OK}
}


# --------------------------------------------------------------------------------------------------


function ListStatus
{
	local pasoeName

	echo -e "${COLOR_TITLE}--- Product Servers ---${COLOR_DEFAULT}"
	echo -e "  admin:              \c"; ShowAdminServerStatus
	echo -e "  oem:                \c"; ShowOemStatus

	echo -e "${COLOR_TITLE}--- List of known PASOE Instances ---${COLOR_DEFAULT}"
	\ls -1 "${PASOE}" | while read pasoeName ; do
		printf "  %-20s" "pasoe-${pasoeName}:"
		ShowPasoeStatus "${pasoeName}"
	done

	return ${OK}
}


# --------------------------------------------------------------------------------------------------


# @param 1 - output - admin server status text
# @param 2 - output - admin server return code (0 means OK, <> 0 means error)
# @param 3 - output - admin server started state (${OK}: started, ${ERR}: stopped)
function GetAdminServerStatus
{
	local statusRaw
	local outReturnCode
	local outStatusText
	local outStateStarted

	if [ -d "${DLC}/bin" ] ; then
		cd "${DLC}/bin"
		statusRaw=$(proadsv -query)
		outReturnCode=$?
		outStatusText=$(echo "${statusRaw}" | grep -v "OpenEdge Release " | sed "s|'| |g")
		cd - 1>/dev/null 2>/dev/null

		if [ ! -z "$(echo ${outStatusText} | grep '\(8545\)')" ] ; then
			outStateStarted=${OK}
		else
			outStateStarted=${ERR}
		fi

		eval "${1}='${outStatusText}'"
		eval "${2}='${outReturnCode}'"
		eval "${3}='${outStateStarted}'"
		return ${OK}
	fi
	return ${ERR}
}


function ShowAdminServerStatus
{
	local admStatusText
	local admReturnCode
	local admStarted

	GetAdminServerStatus admStatusText admReturnCode admStarted
	if [ ${admStarted} -eq ${OK} ] ; then
		echo -e "${COLOR_GREEN}AdminPort: 20931 - ${admStatusText}${COLOR_DEFAULT}"
	else
		echo -e "${COLOR_RED}AdminPort: 20931 - ${admStatusText}${COLOR_DEFAULT}"
	fi
	return ${OK}
}


# --------------------------------------------------------------------------------------------------


# @param 1 - output - OEM status text
# @param 2 - output - OEM return code (0 means OK, <> 0 means error)
# @param 3 - output - OEM started state (${OK}: started, ${ERR}: stopped)
function GetOemStatus
{
	local statusRaw
	local outStatusText
	local outReturnCode
	local outStateStarted

	if [ -d "${DLC}/bin" ] ; then
		cd "${DLC}/bin"
		statusRaw=$(fathom -query)
		outReturnCode=$?
		outStatusText=$(echo "${statusRaw}" | grep -v "OpenEdge Release ")
		cd - 1>/dev/null 2>/dev/null

		if [ ! -z "$(echo ${outStatusText} | grep -i '^Running$')" ] ; then
			outStateStarted=${OK}
		else
			outStateStarted=${ERR}
		fi

		eval "${1}='${outStatusText}'"
		eval "${2}='${outReturnCode}'"
		eval "${3}='${outStateStarted}'"
		return ${OK}
	fi
	return ${ERR}
}


# @param 1 - output - OEM http port
function GetOemPort
{
	local outPortHttp

	if [ -f "${DLC}/properties/fathom.properties" ] ; then
		outPortHttp=$(cat "${DLC}/properties/fathom.properties" | grep "^[ \t]*HttpPort[ \t]*=" | cut -d "=" -f 2 | sed "s|[ \t]||")
		eval "${1}='${outPortHttp}'"
		return ${OK}
	fi
	return ${ERR}
}


function ShowOemStatus
{
	local oemStatusText
	local oemReturnCode
	local oemStarted
	local oemPort

	GetOemPort oemPort
	if [ $? -ne ${OK} ] ; then
		oemPort="Unknown Port"
	fi

	GetOemStatus oemStatusText oemReturnCode oemStarted
	if [ ${oemStarted} -eq ${OK} ] ; then
		echo -e "${COLOR_GREEN}HTTP: ${oemPort} - ${oemStatusText}${COLOR_DEFAULT}"
	else
		echo -e "${COLOR_RED}HTTP: ${oemPort} - ${oemStatusText}${COLOR_DEFAULT}"
	fi
	return ${OK}
}


# --------------------------------------------------------------------------------------------------


# @param 1 - input - PASOE name
# @param 2 - output - PASOE status text
# @param 3 - output - PASOE return code
# @param 4 - output - PASOE started state (${OK}: started, ${ERR}: stopped, ${ALMOST_OK}: started but not accessible)
function GetPasoeStatus
{
	local statusRaw
	local outStatusText
	local outReturnCode
	local outStateStarted

	if [ -d "${PASOE}/${1}/bin" ] ; then
		cd "${PASOE}/${1}/bin"
		statusRaw=$(tcman.sh status -u tomcat:tomcat)
		outStatusText=${statusRaw}
		outReturnCode=$?
		cd - 1>/dev/null 2>/dev/null

		if [ ! -z "$(echo ${statusRaw} | grep '^<?xml')" ] ; then
			outStateStarted=${OK}
			outStatusText="OK"
		elif [ ! -z "$(echo ${statusRaw} | grep '^jget (status)')" ] ; then
			outStateStarted=${ALMOST_OK}
		else
			outStateStarted=${ERR}
		fi

		eval "${2}='${outStatusText}'"
		eval "${3}='${outReturnCode}'"
		eval "${4}='${outStateStarted}'"
		return ${OK}
	fi
	return ${ERR}
}


# @param 1 - input - PASOE name
# @param 2 - output - PASOE http port
# @param 3 - output - PASOE https port
# @param 4 - output - PASOE shutdown port
# @param 5 - output - PASOE ajp13 port
function GetPasoePorts
{
	local outPortHttp
	local outPortHttps
	local outPortShutdown
	local outPortAjp13
	local propFile="${PASOE}/${1}/conf/catalina.properties"

	if [ -f "${propFile}" ] ; then
		outPortHttp=$(cat "${propFile}" | grep "^[ \t]*psc\.as\.http\.port[ \t]*=" | cut -d "=" -f 2 | sed "s|[ \t]||")
		outPortHttps=$(cat "${propFile}" | grep "^[ \t]*psc\.as\.https\.port[ \t]*=" | cut -d "=" -f 2 | sed "s|[ \t]||")
		outPortShutdown=$(cat "${propFile}" | grep "^[ \t]*psc\.as\.shut\.port[ \t]*=" | cut -d "=" -f 2 | sed "s|[ \t]||")
		outPortAjp13=$(cat "${propFile}" | grep "^[ \t]*psc\.as\.ajp13\.port[ \t]*=" | cut -d "=" -f 2 | sed "s|[ \t]||")

		eval "${2}='${outPortHttp}'"
		eval "${3}='${outPortHttps}'"
		eval "${4}='${outPortShutdown}'"
		eval "${5}='${outPortAjp13}'"
		return ${OK}
	fi
	return ${ERR}
}


# @param 1 - input - PASOE name
function ShowPasoeStatus
{
	local pasoeStatusText
	local pasoeReturnCode
	local pasoeStarted
	local pasoePortHttp
	local pasoePortHttps
	local pasoePortShutdown
	local pasoePortAjp13
	local portsStatus

	GetPasoeStatus "${1}" pasoeStatusText pasoeReturnCode pasoeStarted
	GetPasoePorts "${1}" pasoePortHttp pasoePortHttps pasoePortShutdown pasoePortAjp13

	# Build port status string
	portsStatus=""
	if [ ! -z "${pasoePortHttp}" ] ; then
		portsStatus="${portsStatus}HTTP: ${pasoePortHttp} - "
	fi
	if [ ! -z "${pasoePortHttps}" ] ; then
		portsStatus="${portsStatus}HTTPS: ${pasoePortHttps} - "
	fi
	if [ ! -z "${pasoePortShutdown}" ] ; then
		portsStatus="${portsStatus}Shut: ${pasoePortShutdown} - "
	fi
	if [ ! -z "${pasoePortAjp13}" ] ; then
		portsStatus="${portsStatus}AJP13: ${pasoePortAjp13} - "
	fi

	# Show information
	if [ -z  "${pasoeStatusText}" ] ; then
		echo -e "${COLOR_YELLOW}???${COLOR_DEFAULT}"
	else
		if [ ${pasoeStarted} -eq ${OK} ] ; then
			echo -e "${COLOR_GREEN}${portsStatus}${pasoeStatusText}${COLOR_DEFAULT}"
		elif [ ${pasoeStarted} -eq ${ERR} ] ; then
			echo -e "${COLOR_RED}${portsStatus}${pasoeStatusText}${COLOR_DEFAULT}"
		else
			echo -e "${COLOR_YELLOW}${portsStatus}${pasoeStatusText}${COLOR_DEFAULT}"
		fi
	fi
	return ${OK}
}


# @param 1 - input - PASOE name
# @param 2 - output - full path to log file name
function GetPasoeLogFileName
{
	local outLogFileName
	local pasoeName=${1}

	if [ ! -z "${pasoeName}" ] ; then
		outLogFileName=$(cat "${PASOE}/${pasoeName}/conf/openedge.properties" | grep "agentLogFile=..*" | cut -f 2- -d "=" | sed "s|\${catalina.base}|${PASOE}/${pasoeName}|" | head -1)
		eval "${2}='${outLogFileName}'"
		return ${OK}
	fi

	return ${ERR}
}


# --------------------------------------------------------------------------------------------------


# Finally, let's start
Main $@
exit $?
