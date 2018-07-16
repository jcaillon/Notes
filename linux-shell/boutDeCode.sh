#!/bin/ksh
#-------------------------------------------------------------------------
#    File         : boi_deployerinterv.sh
#    Description  : R�alise l'ex�cution de la proc�dure progress de d�ploiement                  
#    Author(s)    : CS-SOPRA - NLA
#    Created      : 18/01/2016
#  -----------------------------------------------------------------------
#  MODIFICATION
#   __________________________________________________________________________________________________
#  |  N�  |  DATE      | AUTEUR     | DESCRIPTION                                                     |
#  |______|____________|____________|_________________________________________________________________|
#  |      |            |            |                                                                 |
#  |  1   | 15/02/2016 | CS-SOPRA   | 337-1 : changement du code organisme                            |
#  |      | BOI 65.010 |   JCA      |                                                                 |
#  |______|____________|____________|_________________________________________________________________|
#

# Forcer ces variables en minuscules
typeset -l T_CODENV
typeset -l T_CODORGOLD
typeset -l T_CODORGNEW

# Lecture des param�tres :
echo ""
echo "----- Param�trage du batch de mise � jour des donn�es organismes -----"

echo "Code environnement (1c.) ......................... : \c"
if [ -z "$1" ] ; then
     read T_CODENV
else
    T_CODENV=$1
    echo ${T_CODENV}
fi

if [ -z "${T_CODENV}" ] || [ -z "`echo ${T_CODENV} | grep '^[0-9a-z]$'`" ] ; then
    echo "Code environnement invalide. Attendu : unique caract�re alphanum�rique."
    exit 1
fi

echo "Ancien code organisme (3c.) ...................... : \c"
if [ -z "$2" ] ; then
    read T_CODORGOLD
else
    T_CODORGOLD=$2
    echo ${T_CODORGOLD}
fi
if [ -z "${T_CODORGOLD}" ] || [ -z "`echo ${T_CODORGOLD} | grep '^[0-9a-z]{3}$'`" ] ; then
    echo "Code organisme invalide. Attendu : 3 caract�res alphanum�riques."
    exit 1
fi

echo "Nouveau code organisme (3c.) ..................... : \c"
if [ -z "$3" ] ; then
    read T_CODORGNEW
else
    T_CODORGNEW=$3
    echo ${T_CODORGNEW}
fi
if [ -z "${T_CODORGNEW}" ] || [ -z "`echo ${T_CODORGNEW} | grep '^[0-9a-z]{3}$'`" ] ; then
    echo "Code organisme invalide. Attendu : 3 caract�res alphanum�riques."
    exit 1
fi

# R�cup�ration du code organisme (principal)
nomappliboi="boi${T_CODENV}"
pg $HOME/confinst.txt | grep "^$nomappliboi; ;" >/tmp/confinst3.tmp 2>/dev/null
T_CODORG=`awk -v lig=2 -v numchamp=6 -f $OAPDIR/oap_champ.awk /tmp/confinst3.tmp`

# lancement du traitement
${APPLI}/boi${T_CODENV}/bs00batchace.sh "${T_CODENV}" "boi" "${T_CODORG}" "" "" "0" "0" "bs00deployerinterv.r" "P_CODORGOLD '${T_CODORGOLD}' P_CODORGNEW '${T_CODORGNEW}'"
RET=$?

if [ $RET != 0 ]; then
    echo "**Le traitement s'est termin� en erreur, consulter les logs batch"
else
    echo "Le traitement s'est effectu� sans erreurs"
fi

exit $RET


# parametres
T_CODENV=$1
T_CODORGANC=$2
T_CODORGNVO=$3

{

    echo "  Script $0"
    echo "  Changement code organisme"
    echo "  Param�tres en entr�e"
    echo "  " $T_CODENV $T_CODORGANC $T_CODORGNVO
    if [ -d "$APPLI/boi$T_CODENV/client$T_CODORGANC" ]; then
    
        #modification du nom du r�pertoire
        mv -f "$APPLI/boi$T_CODENV/client$T_CODORGANC" "$APPLI/boi$T_CODENV/client$T_CODORGNVO"
        v_exit=$?
        if [ $v_exit -eq 0 ]; then
            echo "  Nom du r�pertoire $APPLI/boi$T_CODENV/client$T_CODORGANC modifi� en $APPLI/boi$T_CODENV/client$T_CODORGNVO"
        else
            echo "  ERREUR lors de la tentative de renommage du r�pertoire $APPLI/boi$T_CODENV/client$T_CODORGANC en $APPLI/boi$T_CODENV/client$T_CODORGNVO, code erreur=$v_exit"
        fi
    fi

    T_LISTE_CONTENU=`echo $APPLI/boi$T_CODENV/client$T_CODORGNVO/*.ini \
        $APPLI/boi$T_CODENV/*.ini \
        $APPLI/boi$T_CODENV/configtrace/_batch.cfg \
        $APPLI/boi$T_CODENV/paramurl/paramurl*.cfg \
        $APPLI/boi$T_CODENV/startas.pf \
        `

    T_LISTE_NOM=`echo $APPLI/boi$T_CODENV/configtrace/trace*${T_CODORGANC}*.cfg \
        `

    # Modification du contenu du fichier
    for i in `echo $T_LISTE_CONTENU`; do
        if [ -f $i ]; then
        
            # Sauvegarde fichier avant modification + suppression des \r
            tr -d '\r' < "$i" > "$i.bak"

            # on remplace l'ancien code org par le nouveau
            sed `echo "s/${T_CODORGANC}/${T_CODORGNVO}/g"` "$i.bak" > "$i"
            v_exit=$?
            
            if [ $v_exit -eq 0 ]; then
                echo "  Contenu du fichier $i trait� avec succ�s"
                rm -f "$i.bak"
            else
                echo "  ERREUR lors du traitement du fichier $i, code erreur=$v_exit"
                mv -f "$i.bak" "$i"
            fi
        fi
    done

    # Modification du nom du fichier
    for i in `echo $T_LISTE_NOM`; do
        if [ -f $i ]; then
        
            # on cr�e par copie le nouveau fichier (dans le nom le code org est remplac�)
            # l'ancien fichier boit169n_s.pf est n�cessaire pour bb00mig_init_appsrvtt.sh 
            cp -f "$i" "`echo $i | sed -e "s/${T_CODORGANC}/${T_CODORGNVO}/g"`"
            v_exit=$?
            
            if [ $v_exit -eq 0 ]; then
                echo "  Nom du fichier $i trait� avec succ�s"
            else
                echo "  ERREUR lors du traitement du fichier $i, code erreur=$v_exit"
            fi
        fi
    done

} > test.txt
pg test.txt
rm test.txt