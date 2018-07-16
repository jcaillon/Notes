#!/bin/sh
#-------------------------------------------------------------------------
#    File        :  bs00batchace.sh
#    Description : Lancement BATCH
#    Author(s)   :
#    Created     :
#  -----------------------------------------------------------------------
#  MODIFICATION
#   __________________________________________________________________________________________________
#  |  N°  |  DATE      | AUTEUR     | DESCRIPTION                                                     |
#  |______|____________|____________|_________________________________________________________________|
#  |   1  | 26/11/2008 | TMA-SOPRA  | Evolution BATCH ACE Dossier BATCH ACE                           |
#  |______|____________|____________|_________________________________________________________________|
#  |   2  | 01/06/2010 | OLBIE      | MAJ script pour BAO 62.000                                      |
#  |______|____________|____________|_________________________________________________________________|
#  |   3  | 20/07/2012 | JBE        | Aiguillage vers les fichiers de configuration spécifiques à la  |
#  |      |            |            | version cible                                                   |
#  |______|____________|____________|_________________________________________________________________|
#  |      |            |            | 025-9 signalements                                              |
#  |   4  | 11/10/2012 | JPL        | 06-BOI-33E-A008                                                 |
#  |______|____________|____________|_________________________________________________________________|
#  |      |            |            | v64.000 - 025-6 - 13-BOI-69N-A035                               |
#  |   5  | 01/07/2013 | HGR        | suppression de l'utilisation du suffixage (repris dev de CCH)   |
#  |______|____________|____________|_________________________________________________________________|
#  |      |            | CS-SOPRA   | v65.100 - 65M-3 - INC0114553 - valorisation du code organisme   |
#  |   6  | 26/10/2015 | QBI        | lorsqu'il n'est pas passé en paramètre d'entrée                 |
#  |______|____________|____________|_________________________________________________________________|
#  |      |            |            |                                                                 |
#  |  7   | MEX 16.10  | CS-SOPRA   | 280-1 - Migration Datacenter                                    |
#  |      | 11/07/2016 | JCA        | Modification interface MEX/ACE                                  |
#  |______|____________|____________|_________________________________________________________________|
#  |      |            |            |                                                                 |
#  |  8   | MEX 17.00  | CS-SOPRA   | 17m2 - INC0347173                                    			  |
#  |      | 05/06/2017 | JCA        | Ajout de $WRK/$DOM/$ENV/$CEL au PROPATH progress                |
#  |______|____________|____________|_________________________________________________________________|

# parametre 1  : Code domaine (ex : "PC")
# parametre 2  : Code environnement (ex: "P")
# parametre 3  : Code cellule (ex: "PROD")
# parametre 4  : Code application (ex: "SAC")
# parametre 5  : Code organisme (ex: "69n")
# parametre 6  : Code agent ACE (ex: "UNIX")
# parametre 7  : Mode execution (ex: "MULTI" ou "MONO")
# parametre 8  : ID batch ACE (ex: "INTERI")
# parametre 9  : Client planification ACE (ex: "CBOI")
# parametre 10 : Identifiant ACE (ex: "15554" calculé par ACE)
# parametre 11 : Identifiant pave ACE (ex: "0" ou "156545" calculé par ACE)
# parametre 12 : Nom programme ou code traitement (ex: "bs00interace.p")
# parametre 13 : Parametre(s) du programme batch (ex: PARAM1 "'valeur1' PARAM2 'valeur2'")


# ================================================================================
# Récupération + vérification des paramètres
# ================================================================================
T_CODDOM=${1}
T_CODENV=${2}
T_CODCEL=${3}
T_CODAPP=${4}
T_CODORG=${5}
T_USERACE=${6}
T_MODEXEC=${7}
T_CHAINE=${8}
T_CLIENT=${9}
T_IDACE=${10}
T_IDPAVEACE=${11}
T_PROG=${12}
T_PARAMS=${13}

if [ -z "${T_CLIENT}" ] ; then
    T_USERACE=UNIX
    T_CLIENT=UNIX
    T_IDACE=0
    T_IDPAVEACE=0
    T_UNIQUEID=$RANDOM
else
    T_UNIQUEID=~T_IDACE~T_IDPAVEACE
fi

if [ -z "${T_CODORG}" ] && [ "${T_CODAPP}" != "BOI" ] ; then
    echo -e "Erreur : le code organisme ne doit pas etre vide pour les applications autres que BOI.".
    exit 9
fi


# ================================================================================
# Localisation de LOCSERVEXEC
# ================================================================================
if [ -z "${LOCSERVEXEC}" ] ; then
	LOCSERVEXEC=/exploit/wrk/progress
	export LOCSERVEXEC
fi
if [ -z "$LOCSERVEXEC" ] ; then
    echo -e "Erreur : la variable d'environnement LOCSERVEXEC n'a pas pu être déterminée.".
    exit 9
fi


# ================================================================================
# Calcul des chemins vers mex/ de LOCAPP (en relatif par rapport à l'emplacement de ce .sh) et mex/ de LOCEXEC
# ================================================================================
BASEDIR=$(dirname "$0")
BASEDIR=$(realpath ${BASEDIR})
MEXDIR=$(realpath ${BASEDIR}/..)
MEXDIR=$(echo ${MEXDIR} | tr '[:upper:]' '[:lower:]')

MEXWRK=$(realpath ${LOCSERVEXEC})

# ================================================================================
# T_EXE est complete du numero code application code environnement code organisme nom_du_programme (ou identifiant du programme)
# ================================================================================
T_EXE=${MEXWRK}/tmp/${T_CODAPP,,}/${T_CODORG,,}/${T_PROG,,}-${T_UNIQUEID,,}-$(date +%Y-%m-%d_%H.%M.%S)
T_EXE=$(echo ${T_EXE} | tr '[:upper:]' '[:lower:]')
mkdir -p ${T_EXE}
chmod 777 ${T_EXE} 2>/dev/null

if [ ! -d "${T_EXE}" ]; then
    echo -e "**Erreur : le dossier <${T_EXE}> ne peut pas être crée."
    exit 98
fi

# on export cette variable qui sera utilisée par la session progress pour btGetLocExecACE
export T_EXE

T_EXETMP=${T_EXE}
export T_EXETMP


# ================================================================================
# Creation du fichier ${T_EXE}/exitproc.sh pour gerer les codes retours
# ================================================================================
test -f ${T_EXE}/exitproc.sh && rm -f ${T_EXE}/exitproc.sh
touch ${T_EXE}/exitproc.sh
chmod 777 ${T_EXE}/exitproc.sh 2>/dev/null

if [ ! -f "${T_EXE}/exitproc.sh" ]; then
    echo -e "**Erreur : le fichier <${T_EXE}/exitproc.sh> servant à la gestion des codes retour PROGRESS ne peut pas être crée."
    exit 98
fi


# ===============================================================================
# Creation fichier de collecte des messages console pour redirection dans log BOI
# ===============================================================================
test -f ${T_EXE}/console.log && rm -f ${T_EXE}/console.log
touch ${T_EXE}/console.log
chmod 777 ${T_EXE}/console.log 2>/dev/null


# ===============================================================================
# Calcul du propath pour la BOI
# ===============================================================================
echo -e "===============================" | tee -a ${T_EXE}/console.log

# on lit depuis boi.mex le propath par défaut
if [ ! -f "${MEXDIR}/boi.mex" ]; then
	echo -e "**Erreur : Impossible de trouver le fichier boi.mex pour calculer le PROPATH de session progress." | tee -a ${T_EXE}/console.log
	exit 98
fi
MYPROPATH=$(grep "^\s*\"FICPATHBAT\":\s*\"[^\"]*\"" ${MEXDIR}/boi.mex | head -1)
MYPROPATH=$(echo "${MYPROPATH}" | sed -rn 's/[^:]*:\s*\"([^\"]*).*/\1 /p' | xargs)
echo -e "Propath trouvé dans boi.mex = <${MYPROPATH}>" | tee -a ${T_EXE}/console.log
MYPROPATH=$(eval echo "${MYPROPATH}")
MYPROPATH=$(echo ${MYPROPATH} | tr '[:upper:]' '[:lower:]')
echo -e "Propath après remplacement des variables = <${MYPROPATH}>" | tee -a ${T_EXE}/console.log

# si il existe, on ajoute le propath défini dans propath_batch.txt
if [ -f "${MEXDIR}/propath_batch.txt" ]; then
	PRODPROPATH=$(cat "${MEXDIR}/propath_batch.txt" | sed -e 's|$|,|' | tr -d '\n' | tr -d '\r' | rev | cut -c 2- | rev)
	if [ "${MYPROPATH}" = "" ] ; then
		MYPROPATH=${MYPROPATH}
	else
		MYPROPATH=${PRODPROPATH},${MYPROPATH}
	fi
	MYPROPATH=$(echo "${MYPROPATH}" | sed -e 's/,,/,/g')
	echo -e "Propath trouvé dans propath_batch.txt = <${PRODPROPATH}>" | tee -a ${T_EXE}/console.log
fi

if [ "${PROPATH}" = "" ] ; then
	PROPATH=${MYPROPATH}
else
	PROPATH=${MYPROPATH},${PROPATH}
fi
export PROPATH


# ===============================================================================
# Trace des paramètres
# ===============================================================================
echo -e "Propath utilisé = <${PROPATH}>"  				   | tee -a ${T_EXE}/console.log
echo -e "Répertoire MEX (répertoire d'exécution) = <${MEXDIR}>"    				   | tee -a ${T_EXE}/console.log
echo -e "Répertoire MEXWRK = <${MEXWRK}>" 				   | tee -a ${T_EXE}/console.log
echo -e "Répertoire T_EXE = <${T_EXE}>"   				   | tee -a ${T_EXE}/console.log
echo -e "Chemin vers exitproc.sh = <${T_EXE}/exitproc.sh>" | tee -a ${T_EXE}/console.log

echo -e "===============================" 		  | tee -a ${T_EXE}/console.log
echo -e "Paramètres reçus par bs00batchace.sh : " | tee -a ${T_EXE}/console.log
echo -e "1 : T_CODDOM = <${T_CODDOM}>"       | tee -a ${T_EXE}/console.log
echo -e "2 : T_CODENV = <${T_CODENV}>"       | tee -a ${T_EXE}/console.log
echo -e "3 : T_CODCEL = <${T_CODCEL}>"       | tee -a ${T_EXE}/console.log
echo -e "4 : T_CODAPP = <${T_CODAPP}>"       | tee -a ${T_EXE}/console.log
echo -e "5 : T_CODORG = <${T_CODORG}>"       | tee -a ${T_EXE}/console.log
echo -e "6 : T_USERACE = <${T_USERACE}>"     | tee -a ${T_EXE}/console.log
echo -e "7 : T_MODEXEC = <${T_MODEXEC}>"     | tee -a ${T_EXE}/console.log
echo -e "8 : T_CHAINE = <${T_CHAINE}>"       | tee -a ${T_EXE}/console.log
echo -e "9 : T_CLIENT = <${T_CLIENT}>"       | tee -a ${T_EXE}/console.log
echo -e "10: T_IDACE = <${T_IDACE}>"         | tee -a ${T_EXE}/console.log
echo -e "11: T_IDPAVEACE = <${T_IDPAVEACE}>" | tee -a ${T_EXE}/console.log
echo -e "12: T_PROG = <${T_PROG}>"           | tee -a ${T_EXE}/console.log
echo -e "13: T_PARAMS = <${T_PARAMS}>"       | tee -a ${T_EXE}/console.log


# ===============================================================================
# Lancement session Progress
# ===============================================================================

# on initialise le exitproc.sh
echo "exit 9" > ${T_EXE}/exitproc.sh

cd ${MEXDIR}

echo -e "===============================" | tee -a ${T_EXE}/console.log
echo -e "Lancement session progress..."   | tee -a ${T_EXE}/console.log

# commande progress
_progres -b -T ${MEXWRK}/tmp -pf ${BASEDIR}/startbatchace.pf -param "$T_CODDOM $T_CODENV $T_CODCEL $T_CODAPP $T_CODORG $T_USERACE $T_MODEXEC $T_CHAINE $T_CLIENT $T_IDACE $T_IDPAVEACE $T_PROG \"$T_PARAMS\"" | tee -a ${T_EXE}/console.log

echo -e "===============================" | tee -a ${T_EXE}/console.log
echo -e "Fin session progress"   | tee -a ${T_EXE}/console.log

${T_EXE}/exitproc.sh
ret=${?}

if [ "$ret" != "0" ]; then
	echo -e "***********" | tee -a ${T_EXE}/console.log
    echo -e "**Erreur : l'exécution du programme <${T_PROG}> de la chaîne ACE <${T_CHAINE}> s'est terminée avec un code <${ret}>" | tee -a ${T_EXE}/console.log
	echo -e "***********" | tee -a ${T_EXE}/console.log
else
	echo -e "L'exécution du programme <${T_PROG}> de la chaîne ACE <${T_CHAINE}> s'est déroulée correctement" | tee -a ${T_EXE}/console.log
fi

echo -e "Consultez le suivi des traitements batch dans la Boîte à Outils" | tee -a ${T_EXE}/console.log

exit ${ret}
