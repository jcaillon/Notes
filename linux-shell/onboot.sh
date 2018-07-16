#!/bin/sh
### ## add script to run on boot
### https://www.thegeekdiary.com/centos-rhel-7-how-to-make-custom-script-to-run-automatically-during-boot/
### #echo -ne "echo $(whoami) >> /tmp/script.out" > /usr/admin-sopra/onboot.sh
### chmod 744 /usr/admin-sopra/onboot.sh
### echo -ne "[Unit]\nDescription=Custom on boot script\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=/usr/admin-sopra/onboot.sh\nTimeoutStartSec=0\n\n[Install]\nWantedBy=default.target" > /etc/systemd/system/ssgonboot.service
### #
### #After= : If the script needs any other system facilities (networking, etc), modify the [Unit] section to include appropriate After=, Wants=, or Requires= directives.
### #Type= : Switch Type=simple for Type=idle in the [Service] section to delay execution of the script until all other jobs are dispatched
### #WantedBy= : target to run the sample script in
### #
### chmod 664 /etc/systemd/system/ssgonboot.service
### systemctl daemon-reload
### systemctl enable ssgonboot.service
### # test : 
### systemctl start ssgonboot.service


# Overall variables
SCRIPT_NAME=$(basename "${0}")
SCRIPT_DIR=$(dirname "${0}")
SCRIPT_DIR=$(realpath ${SCRIPT_DIR})


# Include libs
. ${SCRIPT_DIR}/lib/lib-consts.sh
. ${SCRIPT_DIR}/lib/lib-colors.sh


function Main
{
	echo $(whoami) >> /tmp/script.out	
	return ${OK}
}


# --------------------------------------------------------------------------------------------------


# Finally, let's start
Main $@
exit $?
