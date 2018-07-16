REM plink -batch -pw progress -ssh progress@vmlocale "echo progress | sudo -S chmod -R 777 /usr/admin-sopra"
plink -batch -pw progress -ssh progress@vmlocale rm -R /exploit/scripts/*
pscp -r -pw progress D:\VMs\admin-sopra\ progress@vmlocale:/exploit/scripts/
plink -batch -pw progress -ssh progress@vmlocale chmod -R 777 /exploit/scripts/
REM pause