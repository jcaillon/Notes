#!/bin/sh
# ccleaud, 2016


# Overall variables
SCRIPT_NAME=$(basename "${0}")
SCRIPT_DIR=$(dirname "${0}")
SCRIPT_DIR=$(realpath ${SCRIPT_DIR})


# Include libs
. ${SCRIPT_DIR}/lib/lib-consts.sh
. ${SCRIPT_DIR}/lib/lib-colors.sh


function Main
{
	local remoteHostname="slnxlyoncnafpasoe01.lyon.fr.sopra"
	local listScriptsExecuted="/tmp/ssg-list-scripts-executed.txt"
	local logFile="/tmp/ssg-update.txt"
	local localHostname=$(hostname)
	
	# This command needs to be run by root
	if [ "$(whoami)" != "root" ] ; then
		echo -e "${COLOR_RED}** This script MUST be run by user root.${COLOR_DEFAULT}"
		return ${ERR}
	fi
	
	if [ ${localHostname} != ${remoteHostname} ]; then
		
		# ssh-keyscan slnxlyoncnafpasoe01.lyon.fr.sopra >>~/.ssh/known_hosts
		sshpass -p progress scp -r progress@slnxlyoncnafpasoe01.lyon.fr.sopra:/exploit/scripts /exploit/scripts
		sshpass -p progress scp -r progress@slnxlyoncnafpasoe01.lyon.fr.sopra:/appli3/moteurs_progress_v11/v11.7_Linux64/PROGRESS_OE_11.7.3_LNX_64.tar.gz .
		#sshpass -p "sopra*" scp -r root@slnxlyoncnafpasoe01.lyon.fr.sopra:/usr/admin-sopra/ /tmp/admin-sopra/
		#rsync --remove-source-files -a /tmp/admin-sopra/ /usr/admin-sopra/
		#chmod -R 755 /usr/admin-sopra/
		#rm -rf /tmp/admin-sopra

		if [ -d "${SCRIPT_DIR}/update_scripts/" ]; then
		
			echo "Executing scripts in : \"${SCRIPT_DIR}/update_scripts/\"" >> ${logFile}
			echo "----- $(date)---- " >> ${logFile}
		
			if ! [ -f "${listScriptsExecuted}" ]; then
				echo "" > ${listScriptsExecuted}
			fi
		
			for f in "${SCRIPT_DIR}/update_scripts/*.sh"; do  # or wget-*.sh instead of *.sh
				if [ -f "$f" ]; then
			
					if ! grep -q "<$f>" "${listScriptsExecuted}"; then
						bash "$f" -H >> ${logFile} 2>&1
						
						returnCode=$?
																				
						if [ ${returnCode} -eq 0 ] ; then
							echo "script ok..." >> ${logFile}										
						else
							echo "script failed with error code $?..." >> ${logFile}
						fi
						
						echo "<$f>" >> ${listScriptsExecuted}
					fi  
				fi
			done
		else
			echo "Update scripts folder not found : \"${SCRIPT_DIR}/update_scripts/\"" >> ${logFile}
		fi
	fi
	
	return ${OK}
}


# --------------------------------------------------------------------------------------------------


# Finally, let's start
Main $@
exit $?
