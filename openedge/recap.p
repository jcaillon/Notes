/* ------------------------------- */
/* BASIQUES */
/* ------------------------------- */

/* définir une variable */
DEFINE VARIABLE li_int AS INTEGER NO-UNDO.
/* on met no-undo pour dire que la variable ne sera pas "rollback" lors du UNDO d'une transaction, il faut le faire pour ne pas gaspiller inutilement de la mémoire (si on ne met pas NO-UNDO, progress garde une image avant + image courante à chaque fois qu'on ouvre une transaction au lieu de simplement garder la valeur courante) */
/* Portée d'une définition :
- si le DEFINE est au niveau 0 du .p ou .w c'est un DEFINE global et il est définit pour tout le fichier
- sinon, si le DEFINE est dans une procédure ou fonction, alors c'est défini juste localement et sa valeur est perdue à la fin de la procédure/fonction */
/* dans les applications de la CNAF, on met toujours les DEFINE en haut des procédures/fonctions */

/* assignation */
ASSIGN li_int = 10.
/* si on enchaine plusieurs assignation, il faut impérativement les grouper dans le même ASSIGN statement pour des raisons de performances, ex: */
ASSIGN
    li_int = 1
    li_int = 2
    .

DEFINE NEW SHARED VARIABLE gc_anepasfaire AS INTEGER NO-UNDO. /* shared by a procedure called directly or indirectly by the current procedure */
DEFINE NEW GLOBAL SHARED VARIABLE gc_anepasfaire AS INTEGER NO-UNDO. /* shared pour toute la session */

/* extent */
DEFINE VARIABLE tableau1 AS INTEGER EXTENT 10 NO-UNDO.
myloop:
DO li_int = 1 TO EXTENT(tableau1):
    IF tableau1[li_int] = 3 THEN
        LEAVE myloop.
END.


/* ------------------------------- */
/* CONTROLES */
/* ------------------------------- */

/* If */
IF TRUE THEN
    /* 1 simple statement */
    MESSAGE "ok".

IF TRUE THEN DO:
    /* DO créé un nouveau BLOCK dans lequel on met plusieurs statements */
    MESSAGE "ok".
    MESSAGE "dos".
END.

/* try/catch */
unblock:
DO ON ERROR UNDO unblock, LEAVE unblock:
    /* do something */

    ERROR-STATUS:ERROR = FALSE.
END.
IF ERROR-STATUS:ERROR THEN
    MESSAGE ERROR-STATUS:GET-MESSAGE(1).

/* for */
DEFINE VARIABLE li_i AS INTEGER NO-UNDO.
DO li_i = 1 TO 10 BY 1:

END.

/* tant que */
DO WHILE TRUE:

END.

/* tant que */
REPEAT WHILE FALSE:

END.

/* switch */
DEFINE VARIABLE lc_val AS CHARACTER NO-UNDO.
CASE lc_val:
    WHEN "zdze" THEN
        MESSAGE "ok".
    WHEN "zegerg" OR
    WHEN "zefzefze" THEN DO:
        MESSAGE "uno".
        MESSAGE "dos".
    END.
    /* default */
    OTHERWISE DO:

    END.
END CASE.


/* ------------------------------- */
/* PROCEDURES ET FONCTIONS */
/* ------------------------------- */

/* procedure */
PROCEDURE nomproc :
    DEFINE INPUT PARAMETER ipc_name AS CHARACTER NO-UNDO.
    /* NOTE :  une procédure finit toujours par un RETURN "" i elle s'est bien passé (la chaine peut être non vide si on veut passer une valeur de retour)
    Si le traitement c'est mal passé, il faut utiliser RETURN ERROR "descrption". à la place */
    CREATE BUFFER lh_ FOR TABLE "machin".
    RETURN "".
END PROCEDURE.

/* prototype de fonction */
FUNCTION fi_function RETURNS CHARACTER
  ( INPUT ipc_name AS CHARACTER ) FORWARD.

/* function */
FUNCTION fi_function RETURNS CHARACTER
  ( INPUT ipc_name AS CHARACTER ) :
  
    RETURN "".
END FUNCTION.

/* Appel d'une fonction */
MESSAGE fi_function(INPUT "mon input").
MESSAGE DYNAMIC-FUNCTION('fi_function', INPUT "mon input").
MESSAGE DYNAMIC-FUNCTION('fi_function' IN lh_proc, INPUT "mon input").

/* RUN procedure interne */
RUN nomproc.

/* RUn avec paramètres */
RUN nomproc (INPUT "mon parametre", OUTPUT "zzedze", INPUT-OUTPUT 3).

/* RUN procedure externe */
RUN mon_fichier.p (INPUT "mon parametre").

/* RUN persistent, permet d'appeler une sous procédure dans un .p */
DEFINE VARIABLE lh_proc AS HANDLE NO-UNDO.
RUN recap.p PERSISTENT SET lh_proc NO-ERROR.
RUN nomproc IN lh_proc (INPUT "param").
DELETE PROCEDURE lh_proc.

/* RUN super proc, permet d'appeler une sous procédure d'un .p sans avoir à nommer le .p (garder le handle vers cce .p) */
RUN recap.p PERSISTENT SET lh_proc NO-ERROR.
SESSION:ADD-SUPER-PROCEDURE(lh_proc).
RUN nomproc (INPUT "param").
SESSION:REMOVE-SUPER-PROCEDURE(lh_proc).
DELETE PROCEDURE lh_proc.

/* récupérer des valeurs de sorties d'une procédure : */
/* pour un type string, on peut directement utiliser le RETURN-VALUE d'une procédure, ex : */
RUN proc1.
MESSAGE "Retour de la procédure = " + QUOTER(RETURN-VALUE).
PROCEDURE proc1:
    RETURN "ceci est ma string de retour pour dire comment c'est passé ma procédure".
END.
/* sinon on utilise les paramtres de type OUTPUT */
RUN proc2 (OUTPUT lc_val).
PROCEDURE proc2:
    DEFINE OUTPUT PARAMETER opc_char AS CHARACTER NO-UNDO.
    ASSIGN opc_char = "cool".
    RETURN "".
END.

/* exécuter un .p sur le serveur */
RUN maproc.p ON lh_proc. // où lh_proc est mon handle de SERVER
RUN prog.p ON DYNAMIC-FUNCTION('btGetServerHandle') NO-ERROR.


/* ------------------------------- */
/* PRE COMPILATION */
/* ------------------------------- */

/* definir une variable de precompil */
&SCOPED-DEFINE myvar VALUE
&GLOBAL-DEFINE secondvar VALUE
/* SCOPED = defini uniquement pour le fichier dans lequel on a cette définition */
/* GLOBAL = défini pour tous les fichiers : si on défini ça dans un .i, qu'on inclu ce .i dans un .p, alors on peut utiliser cette variable dans le .p (on ne peut pas avec SCOPED) */

&IF TRUE &THEN
    /* permet un IF précompilé, ça fait toujours 1 expression de moins à vérifier au RUNTIME */
&ELSE

&ENDIF

&IF FALSE &THEN
    {nominclude.i param1 param2}
    {nominclude.i "param1 with spaces" param2}
    {nominclude.i &1=param1 &2=param2}
    {nominclude.i &1="param1 with spaces" &2=param2}
    /* dans l'include, on utiliser {1} et {2}, {0} représente le nom de l'include dans lequel on est */
&ENDIF


/* ------------------------------- */
/* GESTION DES ERREURS */
/* ------------------------------- */

/* La plupart des statements et des fonctions ont une option NO-ERROR qui permet de ne pas arrêter l'exécution du code lors d'une erreur. Chaque fois que l'on utilise NO-ERROR, il faut juste après vérifier si il y a eu une erreur ou pas et la gérer. */
/* ex : */
ASSIGN lc_val = "test" NO-ERROR.
/* ERROR-STATUS:ERROR sera à TRUE si il y a eu une erreur lors de la dernière instruction avec NO-ERROR */
IF ERROR-STATUS:ERROR THEN DO:
    /* on peut afficher les messages d'erreurs techniques : */
    DO li_i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE "Erreur technique n° " + STRING(ERROR-STATUS:GET-NUMBER(li_i)) + ", description : " + ERROR-STATUS:GET-MESSAGE(li_i).
    END.
END.

/* si dans une procédure on fait un RETURN ERROR, alors il faudra faire NO-ERROR et géré l'erreur à l'appel de cette procédure, exemple : */
RUN my_error_proc NO-ERROR.
IF ERROR-STATUS:ERROR THEN
    MESSAGE "Il y a eu une erreur, description : " + (IF RETURN-VALUE > "" THEN RETURN-VALUE ELSE "inconnue").
    
PROCEDURE my_error_proc PRIVATE:
    IF TRUE THEN
        /* il y a eu une erreur fonctionnelle, il faut quitter cette procédure en erreur */
        RETURN ERROR "oups, il y a un problème avec le montant total".
    RETURN "".
END PROCEDURE.

/* pour les fonctions, si il y a une erreur non gérée pendant l'exécution, la fonction va retourner ? */


/* ------------------------------- */
/* FONCTIONS DES CHARACTER */
/* ------------------------------- */

DEFINE VARIABLE lc_string AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll_logical AS LOGICAL NO-UNDO.

MESSAGE STRING(1).
MESSAGE QUOTER("to quote").

ASSIGN lc_string = "hello".
ASSIGN ll_logical = lc_string BEGINS "H".
ASSIGN ll_logical = lc_string MATCHES "..ll*". // . et *
MESSAGE STRING(ll_logical).

MESSAGE CHR(65).

MESSAGE CAPS("minuscula").
MESSAGE LC("CAPS").

MESSAGE FILL("a", 5).

MESSAGE QUOTER(TRIM("    zss efzefz   ")).
MESSAGE QUOTER(LEFT-TRIM("    zss efzefz   ")).
MESSAGE QUOTER(RIGHT-TRIM("    zss efzefz   ")).
MESSAGE QUOTER(TRIM("!!!!!!!!!!!!!!!!!!!!zss ! efzefz!!!!!!!!!!!!!!", "!")).

MESSAGE STRING(LENGTH("12345")).

MESSAGE STRING(NUM-ENTRIES("one,two,three", ",")).
MESSAGE STRING(NUM-ENTRIES("one/two/three", "/")).

MESSAGE ENTRY(2, "one/two/three", "/").

MESSAGE LOOKUP("two", "one/two/three", "/").

MESSAGE STRING(INDEX("une phrase !", "p", 1)).
MESSAGE STRING(INDEX("une phrase !", "e", 4)). /* search from left to right in " phrase !" -> 10*/
MESSAGE STRING(R-INDEX("une phrase !", "e", 4)). /* search from right to left in "une " -> 3 */

MESSAGE SUBSTRING("12345", 3, 2).

DEFINE VARIABLE lc_ AS CHARACTER NO-UNDO.

ASSIGN lc_ = "12345".
SUBSTRING(lc_, 3, 2) = "aaaaa".
MESSAGE lc_.

MESSAGE SUBSTITUTE("there are &1 substitute in this &2", 2, "sentence").

MESSAGE REPLACE("hello one ola", "one", "two").

MESSAGE ENCODE("password").

MESSAGE STRING(CAN-DO("0,2,10", STRING(9))).


/* ------------------------------- */
/* FONCTIONS DATE */
/* ------------------------------- */

MESSAGE STRING(TODAY, "99/99/9999").

MESSAGE STRING(TIME, "HH:MM:SS").

MESSAGE STRING(YEAR(TODAY)).
MESSAGE STRING(MONTH(TODAY)).
MESSAGE STRING(DAY(TODAY)).
MESSAGE STRING(WEEKDAY(TODAY)).

ETIME(TRUE).
PAUSE 1.
MESSAGE ETIME(FALSE).


/* ------------------------------- */
/* FONCTIONS MATH */
/* ------------------------------- */

MESSAGE STRING(EXP(2, 3)).
MESSAGE STRING(LOG(2, 3)).
MESSAGE STRING(5 MODULO 2).
MESSAGE STRING(RANDOM(1, 9)).
MESSAGE STRING(ROUND(110.52323, 0)).
MESSAGE STRING(TRUNCATE(110.51, 0)).
MESSAGE STRING(SQRT(4)).


/* ------------------------------- */
/* LA VALEUR ? */
/* ------------------------------- */

/* une expression qui contient ? devient entièremet ? ; par exemple : */
DEFINE VARIABLE li_test AS INTEGER NO-UNDO INITIAL 9.
DEFINE VARIABLE li_test2 AS INTEGER NO-UNDO INITIAL ?.
ASSIGN li_test = li_test + li_test2.
MESSAGE STRING(li_test).
/* c'est vrai pour tous, même les chaines de caractères par exemple! */

/* particularité du ? dans une expression de type IF, ça vaut FALSE : */
IF ? THEN
    MESSAGE "? <> true".
ELSE
    MESSAGE "? = false".

/* tester si une variable n'est ni nulle ni vide */
DEFINE VARIABLE lc_null AS CHARACTER NO-UNDO INITIAL ?.
DEFINE VARIABLE lc_empty AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE lc_full AS CHARACTER NO-UNDO INITIAL "nice".

/* le if ci-dessous est équivalent à
    IF lc_null <> ? AND lc_null <> "" THEN */
IF lc_null > "" THEN
    MESSAGE "nop".
ELSE
    MESSAGE "it's null or empty".

IF lc_empty > "" THEN
    MESSAGE "nop".
ELSE
    MESSAGE "it's null or empty".

IF lc_full > "" THEN
    MESSAGE "It's not null nor empty!".
ELSE
    MESSAGE "nop".

/* Attention! c'est impossible d'utiliser le contraire!!! */
IF NOT lc_null > "" THEN
    MESSAGE "nop".
ELSE
    MESSAGE "ça ne marche pas, on passe ici! car toute l'expression devient ? donc = FALSE".


/* ------------------------------- */
/* GESTION DES TRANSACTIONS */
/* ------------------------------- */

/* Démarrer explicitement une transaction */
monbloc:
DO ON ERROR UNDO monbloc:
    DO TRANSACTION:

    END.
END.

/* 
Sinon, une transaction est démarrée implicitiement dès lors qu'un statement update la base (création, assign, delete).
La portée de la transaction est alors le block dans lequel on a le statement d'update.
Les blocs qui déclenchent une transaction sont (si on update la base dans le block) :
    - FOR EACH
    - REPEAT
    - PROCEDURE BLOCK
    - DO ON ERROR... BLOCKS
*/


/*
?	Validation
?	Mot clé TRANSACTION (logical)
?	Transaction dans une transaction
?	Portée d’une transaction
?	Verrous
?	Réduire la portée d’une transaction
*/


/* ------------------------------- */
/* MANIPULATIONS DE TABLES ET BUFFERS */
/* ------------------------------- */

/* definir une temp table */
DEFINE TEMP-TABLE tt_table NO-UNDO
    FIELD field1 AS CHARACTER
    FIELD field2 AS INTEGER
    INDEX idx IS UNIQUE PRIMARY field2 .

/* Créer une tt comme une autre table (possible de définir comme une table en base) */
/* voir les notes de define temp-table pour plus de précisions mais si on ne précise pas 
les INDEX pour cette tt LIKE table, alors on hérite des index de la table */
DEFINE TEMP-TABLE tt_like NO-UNDO
    LIKE EMPLOYE.

/* Se positionner sur un enregistrement */
FIND tt_table NO-LOCK WHERE tt_table.field2 = 1.
FIND FIRST tt_table NO-LOCK.
FIND LAST tt_table NO-LOCK.
/* pour les temp table, pas besoin de préciser le LOCK */
/* pour les tables en bases, il faut TOUJOURS préciser quel LOCK utiliser : */
/* En écriture : */
FIND FIRST tt_table EXCLUSIVE-LOCK NO-WAIT.
/* L'instruction NO-WAIT permet de ne pas attendre qu'un enregistrement soit libéré et directement sortir en erreur si il est déjà pris en EXCLUSIVE-LOCK */
/* En lecture : */
FIND FIRST tt_table NO-LOCK.

/* chaque temp table / table en base à un buffer par defaut qui est appelé comme la table :
par exemple, quand on fait FIND FIRST tt_table NO-LOCK. on utilise le buffer par defaut de la table tt_table */
/* il est possible de définir d'autres buffers pour pouvoir sélectionner plusieurs enregistrements d'une même table en même temps, ex: */
DEFINE BUFFER lb_table FOR tt_table.

/* gérer les errors de find */
FIND tt_table WHERE tt_table.field2 = 1 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
IF AVAILABLE(tt_table) THEN
    /* the buffer is available (disponible) */
    MESSAGE tt_table.field1.
ELSE IF LOCKED(tt_table) THEN
    /* impossible de récupérer le buffer en écriture (ne sert que pour EXCLUSIVE-LOCK) */
    MESSAGE "Impossible de récuperer l'enregistrement en écriture".
ELSE IF AMBIGUOUS(tt_table) THEN
    MESSAGE "Plus d'un enregistrement trouvé pour l'instruction FIND, utilisez la clause WHERE pour trouver un seul enregistrement ou bien FIND FIRST?".

/* Test d'existance d'un enregistrement */
IF CAN-FIND(tt_table WHERE field1 MATCHES "*cool") THEN
    MESSAGE "l'enregistrement existe".
IF CAN-FIND(FIRST tt_table) THEN
    MESSAGE "Au moins un enregistrement existe".

/* Recherche de plusieurs enregistrements */
FOR EACH tt_table NO-LOCK:
    MESSAGE tt_table.field1.
END.

/* avec exclusive-lock? pas besoin de NO-WAIT NO-ERROR, on ne passera pas dans le for each si l'enreg n'existe pas ou n'est pas disponible */
FOR EACH tt_table EXCLUSIVE-LOCK:
    MESSAGE tt_table.field1.
END.

/* recherche avec une clause WHERE */
FOR EACH tt_table NO-LOCK WHERE tt_table.field2 > 2 :
    MESSAGE tt_table.field1.
END.

/* sort / tri ASCENDING ou DESCENDING */
FOR EACH tt_table NO-LOCK BY tt_table.field1 DESCENDING:
END.
/* si pas de clause BY, les records sont parcourus dans l'ordre de l'index PRIMARY (ou premier index par défaut) */

/* utilisation de OF, on récupère chaque EMPLOYE et pour chacun, on récupère son SALAIRE */
FOR EACH EMPLOYE NO-LOCK,
    FIRST SALAIRE OF EMPLOYE NO-LOCK:
    MESSAGE STRING(EMPLOYE.ID_EMPLOYE) + " > " + STRING(SALAIRE.ID_SALAIRE).
END.

FOR EACH EMPLOYE NO-LOCK,
    FIRST SALAIRE WHERE SALAIRE.ID_SALAIRE = EMPLOYE.ID_SALAIRE NO-LOCK:
    MESSAGE STRING(EMPLOYE.ID_EMPLOYE) + " > " + STRING(SALAIRE.ID_SALAIRE).
END.

/* le for each précédent est égal à ... */
FOR EACH EMPLOYE NO-LOCK:
    FIND FIRST SALAIRE OF EMPLOYE NO-ERROR.
    /* Le keyword "OF" revient à faire une clause WHERE mais de façon implicite (pas bien!) */
    /*FIND FIRST SALAIRE WHERE EMPLOYE.ID_SALAIRE = SALAIRE.ID_SALAIRE NO-ERROR. */
    /* il faut des noms de champ identiques et au moins un index unique pour ça */
    IF AVAILABLE(SALAIRE) THEN DO:
        MESSAGE STRING(EMPLOYE.ID_EMPLOYE) + " > " + STRING(SALAIRE.ID_SALAIRE).
    END.
END.
/* ...Sauf que la seconde syntaxe fait beaucoup plus d'aller-retours avec la base de données ->
donc moins performante */

/* compter le nombre d'enregistrements, on ne récupère pas tous les champs car leurs contenus ne nous intéressent pas */
DEFINE VARIABLE li_count AS INTEGER NO-UNDO.
FOR EACH EMPLOYE FIELDS(EMPLOYE.ID_EMPLOYE):
    ASSIGN li_count = li_count + 1.
END.
MESSAGE STRING(li_count).


/* creation d'un enregistrement */
/* il faut gérer les erreurs! */
CREATE tt_table.
ASSIGN tt_table.field1 = "".
VALIDATE tt_table.
RELEASE tt_table.

/* Utilité du VALIDATE : */
/* 
- CAS 1 : valider les champs de base en mandatory (les champs des tt ne peuvent pas être définis mandatory)
    une table "table1" avec un champ "field1" CHAR en MANDATORY et initial value ?
    si on essaie pas de ASSIGN ce field1 avec une valeur, on aura une erreur non catchée qui va apparaitre
    au moment où le commit en base se fait (fin transac).
    Cette erreur aurait pu être catch avec un VALIDATE table1 NO-ERROR. 
*/
/* 
- CAS 2 : 
    Cas extrêmement bizarre, le VALIDATE va servir à vérifier la condition d'unicité imposée via
    un index UNIQUE sur un champ de INTEGER pour la valeur 0...
    une table ou temptable "table1" avec un champ "field1" de type INTEGER et un INDEX IS UNIQUE sur field1
    Si on créé un enreg avec field1 = 10 puis un second enreg avec même valeur, on sort en erreur lors du 
    second ASSIGN.
    MAIS... Si on créé un enreg avec field1 = 0 puis un second enreg de la même valeur, le ASSIGN n'est plus en erreur, ni le release. Et on sort en erreur non catché à la fin de la transaction. On aurait pu
    éviter ce pb avec un VALIDATE.
*/
/* à noter également, le VALIDATE déclenche les triggers WRITE et/ou CREATE de la table */
DEFINE TEMP-TABLE tt_omg NO-UNDO
    FIELD id_poste  AS INTEGER
    INDEX constraint IS UNIQUE id_poste.
    
DEFINE VARIABLE li_wtf AS INTEGER NO-UNDO.

DO li_wtf = 0 TO 1:
    CREATE tt_omg.
    ASSIGN tt_omg.id_poste = li_wtf.
    RELEASE tt_omg.

    CREATE tt_omg.
    ASSIGN tt_omg.id_poste = li_wtf NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        /* will fail on the assign when breaking the unique condition with any value different than 0 */
        MESSAGE "Failed ON ASSIGN for li_wtf = " + STRING(li_wtf) + " !" SKIP ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX ERROR.
        DELETE tt_omg.
    END.
    ELSE DO:
        VALIDATE tt_omg NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
            /* will catch the case where we break a unique index with the default value of 0!!! (if the index is primary, we would break on assign!!) */
            MESSAGE "Failed ON VALIDATE for li_wtf = " + STRING(li_wtf) + " !" SKIP ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX ERROR.
            DELETE tt_omg.
        END.
        RELEASE tt_omg.
    END.
END.


/* vider la temp table */
EMPTY TEMP-TABLE tt_table.

/* pour vider une table en base : */
FOR EACH lb_table EXCLUSIVE-LOCK:
    DELETE lb_table.
END.


/* 
Un enregistrement n'est dispo en base qu'au moment où la transaction se termine. 
Cependant, il est visible juste après avoir des assign des champs faisant parti d'un index!!! (wtf!) Attention, il est visible (lisible) mais évidemment toujours pris en exclusive-lock 
jusqu'à ce que la transaction soit validée (ou bien undo et dans ce cas le record est dégagé)
 */
CREATE tt_table.
ASSIGN tt_table.field1 = "1".
FOR EACH lb_table:
    MESSAGE "test 1 : " + lb_table.field1. /* ne va pas s'afficher car on a pas encore RELEASE le nouvel enregistrement dans la table tt_table */
END.

/* pourtant on peut bien récupérer l'information avec le buffer (buffer par défaut de tt_table) */
MESSAGE "test 2 : " + tt_table.field1.
RELEASE tt_table.

EMPTY TEMP-TABLE tt_table.

CREATE tt_table.
ASSIGN tt_table.field2 = 1.
FOR EACH lb_table:
    MESSAGE "test 3 : " + STRING(lb_table.field2). /* va s'afficher car field2 fait parti d'un index! wtf la logique? */
END.

EMPTY TEMP-TABLE tt_table.

/* moralité : bien maitriser ses transactions pour être sûr que son enreg soit commit quand on veut qu'il le soit... */
DO TRANSACTION :
    CREATE tt_table.
    ASSIGN tt_table.field1 = "1".
END. // enreg commit ici! 
FOR EACH lb_table:
    MESSAGE "test 4 : " + lb_table.field1. /* s'affiche car on a bien fini la trans et on l'a commit */
END.



/* passer une table en paramètre (= on passe tous les enregistrements en paramètres!) */
CREATE tt_table.
ASSIGN tt_table.field2 = 1.
RELEASE tt_table.

FIND FIRST tt_table.
RUN pi_table.p (OUTPUT TABLE tt_table).

FOR EACH tt_table:
    MESSAGE STRING(tt_table.field2). 
END.

PROCEDURE pi_table.p :

    /* definir une temp table */
    DEFINE TEMP-TABLE tt_table NO-UNDO
        FIELD field1 AS CHARACTER
        FIELD field2 AS INTEGER
        INDEX idx IS UNIQUE PRIMARY field2 .

    DEFINE OUTPUT PARAMETER TABLE FOR tt_table.

    CREATE tt_table.
    ASSIGN tt_table.field2 = 2.
    RELEASE tt_table.

    RETURN "".

END PROCEDURE.


/* modifier un enregistrement en base */
/* on se positionne dessus */
DEFINE BUFFER lb_employe FOR EMPLOYE.
FIND lb_employe WHERE lb_employe.ID_EMPLOYE = 1 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
IF AVAILABLE(lb_employe) THEN DO:
    /* on modifie */
    ASSIGN lb_employe.PRENOM = "paco" NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
        RETURN ERROR "assign " + ERROR-STATUS:GET-MESSAGE(1).
    VALIDATE lb_employe NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
        RETURN ERROR "val " + ERROR-STATUS:GET-MESSAGE(1).
    RELEASE lb_employe NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
        RETURN ERROR "release " + ERROR-STATUS:GET-MESSAGE(1).
END.


DEFINE TEMP-TABLE tt_nopk NO-UNDO
    FIELD field1 AS CHARACTER
    FIELD field2 AS INTEGER
    .
DEFINE BUFFER lb_nopk FOR tt_nopk.

/* copie d'enregistrements */
EMPTY TEMP-TABLE tt_nopk.
CREATE tt_nopk.
ASSIGN
    tt_nopk.field1 = "1"
    tt_nopk.field2 = 1
    .
RELEASE tt_nopk.

/* copie de l'enregistrement avec les valeurs 1 (on aura deux enregistrements avec ces valeurs) */
FIND FIRST tt_nopk.
CREATE lb_nopk.
BUFFER-COPY tt_nopk TO lb_nopk.
RELEASE lb_nopk.

/* si la cible de la copie n'est pas positionnée, le CREATE se fait automatiquement */
BUFFER-COPY tt_nopk TO lb_nopk.
/* on a maintenant 3 enregistrements identiques */

/* on peut copier tout les champs SAUF field2 et assigner à la place la valeur 5 pour field2 */
BUFFER-COPY tt_nopk EXCEPT tt_nopk.field2 TO lb_nopk
    ASSIGN lb_nopk.field2 = 5.
    
/* copie de tous les enregistrements d'une table vers une autre */
TEMP-TABLE tt_target:COPY-TEMP-TABLE(TEMP-TABLE tt_source:HANDLE).

/* comparaison de buffer */
DEFINE VARIABLE ll_equals AS LOGICAL NO-UNDO.
BUFFER-COMPARE tt_nopk TO lb_nopk SAVE ll_equals.
MESSAGE STRING(ll_equals).

DEFINE VARIABLE ll_diff2 AS CHARACTER NO-UNDO.
BUFFER-COMPARE tt_nopk TO lb_nopk SAVE ll_diff2.
MESSAGE ll_diff2.


/* supprimer un enregistrement? -> se positionner et DELETE*/
FIND FIRST lb_base WHERE lb_base.ID_EMPLOYE = 1 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
IF AVAILABLE(lb_table) THEN DO:
    DELETE lb_table NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
        RETURN ERROR "delete impossible " + ERROR-STATUS:GET-MESSAGE(1).
END.


/* désactiver les TRIGGERS pour des tables en base */
DISABLE TRIGGERS FOR LOAD OF EMPLOYE.
DISABLE TRIGGERS FOR DUMP OF EMPLOYE.


/* ------------------------------- */
/* DATASET */
/* ------------------------------- */

DEFINE DATASET ds_myds
    SERIALIZE-HIDDEN
    FOR tt_table, tt_like.

/* vider un dataset */
DATASET ds_myds:EMPTY-DATASET().

RUN monprog.p (INPUT DATASET ds_myds).
DEFINE INPUT PARAMETER DATASET FOR ds_myds.


/* ------------------------------- */
/* SEQUENCES */
/* ------------------------------- */

ASSIGN
    CURRENT-VALUE(seq_exercice5_employe) = 1 /* forcer une sequence à une valeur */
    li_int = CURRENT-VALUE(seq_exercice5_employe) /* = 1 récupérer la valeur actuelle */
    li_int = NEXT-VALUE(seq_exercice5_employe) /* = 2 récupérer la prochaine valeur de la séquence (incrémente puis renvoi la nouvelle valeur) */
    .



/* ------------------------------- */
/* FICHIERS TRIGGERS */
/* ------------------------------- */
&IF FALSE &THEN
TRIGGER PROCEDURE FOR CREATE OF EMPLOYE.
TRIGGER PROCEDURE FOR FIND OF EMPLOYE.
TRIGGER PROCEDURE FOR DELETE OF EMPLOYE.

TRIGGER PROCEDURE FOR WRITE OF EMPLOYE
    NEW BUFFER lb_new
    OLD BUFFER lb_old.
TRIGGER PROCEDURE FOR ASSIGN
    OF EMPLOYE.PRENOM
        NEW VALUE newval LIKE EMPLOYE.PRENOM
        OLD VALUE oldval LIKE EMPLOYE.PRENOM
        .

&ENDIF


/* ------------------------------- */
/* GRAPHIQUE */
/* ------------------------------- */

&IF FALSE &THEN

/* rafraichir un browse */
{&OPEN-QUERY-BROWSE-X} /* réinsert la commande OPEN QUERY BROWSE-X... */
BROWSE-X:REFRESH(). /* permet de rafraichir uniquement l'enregistrement courant (ligne sélectionnée) */

/* récuperer la valeur d'un fill-in? */
ASSIGN lc_val = fl_nom:SCREEN-VALUE.

/* si on est dans un trigger pour le fill-in en question, on peut aussi faire ça : */
ASSIGN lc_val = fl_nom:SCREEN-VALUE.
ASSIGN lc_val = {&SELF-NAME}:SCREEN-VALUE.
ASSIGN lc_val = SELF:SCREEN-VALUE.

/* accéder aux objets d'une FRAME quand on est pas dans un trigger : */
DO WITH FRAME DEFAULT-FRAME:
    /* avec DEFAULT-FRAME le nom de la FRAME sur laquelle se positionner */
END.

/* ou bien */
ASSIGN fl_nom:SCREEN-VALUE IN FRAME DEFAULT-FRAME = "value".

/* remplissage de combo box (exemple pour ITEM-LIST-PAIRS) */
/* LIST-ITEMS */
ASSIGN  COMBO-BOX-1:LIST-ITEM-PAIRS  = "item1,value1,item2,value2".
COMBO-BOX-1:ADD-LAST("item3", "value3").
COMBO-BOX-1:INSERT("itemx", "valuex", 3).

&ENDIF


/* forcer un évnement de widget */
APPLY "choose" TO bt_button.

