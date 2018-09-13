/* ------------------------------- */
/* BASIQUES */
/* ------------------------------- */

/* d�finir une variable */
DEFINE VARIABLE li_int AS INTEGER NO-UNDO.
/* on met no-undo pour dire que la variable ne sera pas "rollback" lors du UNDO d'une transaction, il faut le faire pour ne pas gaspiller inutilement de la m�moire (si on ne met pas NO-UNDO, progress garde une image avant + image courante � chaque fois qu'on ouvre une transaction au lieu de simplement garder la valeur courante) */
/* Port�e d'une d�finition :
- si le DEFINE est au niveau 0 du .p ou .w c'est un DEFINE global et il est d�finit pour tout le fichier
- sinon, si le DEFINE est dans une proc�dure ou fonction, alors c'est d�fini juste localement et sa valeur est perdue � la fin de la proc�dure/fonction */
/* dans les applications de la CNAF, on met toujours les DEFINE en haut des proc�dures/fonctions */

/* assignation */
ASSIGN li_int = 10.
/* si on enchaine plusieurs assignation, il faut imp�rativement les grouper dans le m�me ASSIGN statement pour des raisons de performances, ex: */
ASSIGN
    li_int = 1.
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
    /* DO cr�� un nouveau BLOCK dans lequel on met plusieurs statements */
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
    /* NOTE :  une proc�dure finit toujours par un RETURN "" i elle s'est bien pass� (la chaine peut �tre non vide si on veut passer une valeur de retour)
    Si le traitement c'est mal pass�, il faut utiliser RETURN ERROR "descrption". � la place */
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

/* RUN procedure interne */
RUN nomproc.

/* RUn avec param�tres */
RUN nomproc (INPUT "mon parametre", OUTPUT "zzedze", INPUT-OUTPUT 3).

/* RUN procedure externe */
RUN mon_fichier.p (INPUT "mon parametre").

/* RUN persistent, permet d'appeler une sous proc�dure dans un .p */
DEFINE VARIABLE lh_proc AS HANDLE NO-UNDO.
RUN recap.p PERSISTENT SET lh_proc NO-ERROR.
RUN nomproc IN lh_proc (INPUT "param").
DELETE PROCEDURE lh_proc.

/* RUN super proc, permet d'appeler une sous proc�dure d'un .p sans avoir � nommer le .p (garder le handle vers cce .p) */
RUN recap.p PERSISTENT SET lh_proc NO-ERROR.
SESSION:ADD-SUPER-PROCEDURE(lh_proc).
RUN nomproc (INPUT "param").
SESSION:REMOVE-SUPER-PROCEDURE(lh_proc).
DELETE PROCEDURE lh_proc.

/* r�cup�rer des valeurs de sorties d'une proc�dure : */
/* pour un type string, on peut directement utiliser le RETURN-VALUE d'une proc�dure, ex : */
RUN proc1.
MESSAGE "Retour de la proc�dure = " + QUOTER(RETURN-VALUE).
PROCEDURE proc1:
    RETURN "ceci est ma string de retour pour dire comment c'est pass� ma proc�dure".
END.
/* sinon on utilise les paramtres de type OUTPUT */
RUN proc2 (OUTPUT lc_val).
PROCEDURE proc2:
    DEFINE OUTPUT PARAMETER opc_char AS CHARACTER NO-UNDO.
    ASSIGN opc_char = "cool".
    RETURN "".
END.

/* ex�cuter un .p sur le serveur */
RUN maproc.p ON lh_proc. // o� lh_proc est mon handle de SERVER
RUN prog.p ON DYNAMIC-FUNCTION('btGetServerHandle') NO-ERROR.


/* ------------------------------- */
/* PRE COMPILATION */
/* ------------------------------- */

/* definir une variable de precompil */
&SCOPED-DEFINE myvar VALUE
&GLOBAL-DEFINE secondvar VALUE
/* SCOPED = defini uniquement pour le fichier dans lequel on a cette d�finition */
/* GLOBAL = d�fini pour tous les fichiers : si on d�fini �a dans un .i, qu'on inclu ce .i dans un .p, alors on peut utiliser cette variable dans le .p (on ne peut pas avec SCOPED) */

&IF TRUE &THEN
    /* permet un IF pr�compil�, �a fait toujours 1 expression de moins � v�rifier au RUNTIME */
&ELSE

&ENDIF

&IF FALSE &THEN
    {nominclude.i param1 param2}
    {nominclude.i "param1 with spaces" param2}
    {nominclude.i &1=param1 &2=param2}
    {nominclude.i &1="param1 with spaces" &2=param2}
    /* dans l'include, on utiliser {1} et {2}, {0} repr�sente le nom de l'include dans lequel on est */
&ENDIF


/* ------------------------------- */
/* GESTION DES ERREURS */
/* ------------------------------- */

/* La plupart des statements et des fonctions ont une option NO-ERROR qui permet de ne pas arr�ter l'ex�cution du code lors d'une erreur. Chaque fois que l'on utilise NO-ERROR, il faut juste apr�s v�rifier si il y a eu une erreur ou pas et la g�rer. */
/* ex : */
ASSIGN lc_val = "test" NO-ERROR.
/* ERROR-STATUS:ERROR sera � TRUE si il y a eu une erreur lors de la derni�re instruction avec NO-ERROR */
IF ERROR-STATUS:ERROR THEN DO:
    /* on peut afficher les messages d'erreurs techniques : */
    DO li_i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE "Erreur technique n� " + STRING(ERROR-STATUS:GET-NUMBER(li_i)) + ", description : " + ERROR-STATUS:GET-MESSAGE(li_i).
    END.
END.

/* si dans une proc�dure on fait un RETURN ERROR, alors il faudra faire NO-ERROR et g�r� l'erreur � l'appel de cette proc�dure, exemple : */
RUN my_error_proc NO-ERROR.
IF ERROR-STATUS:ERROR THEN
    MESSAGE "Il y a eu une erreur, description : " + (IF RETURN-VALUE > "" THEN RETURN-VALUE ELSE "inconnue").
    
PROCEDURE my_error_proc PRIVATE:
    IF TRUE THEN
        /* il y a eu une erreur fonctionnelle, il faut quitter cette proc�dure en erreur */
        RETURN ERROR "oups, il y a un probl�me avec le montant total".
    RETURN "".
END PROCEDURE.

/* pour les fonctions, si il y a une erreur non g�r�e pendant l'ex�cution, la fonction va retourner ? */


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

/* une expression qui contient ? devient enti�remet ? ; par exemple : */
DEFINE VARIABLE li_test AS INTEGER NO-UNDO INITIAL 9.
DEFINE VARIABLE li_test2 AS INTEGER NO-UNDO INITIAL ?.
ASSIGN li_test = li_test + li_test2.
MESSAGE STRING(li_test).
/* c'est vrai pour tous, m�me les chaines de caract�res par exemple! */

/* particularit� du ? dans une expression de type IF, �a vaut FALSE : */
IF ? THEN
    MESSAGE "? <> true".
ELSE
    MESSAGE "? = false".

/* tester si une variable n'est ni nulle ni vide */
DEFINE VARIABLE lc_null AS CHARACTER NO-UNDO INITIAL ?.
DEFINE VARIABLE lc_empty AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE lc_full AS CHARACTER NO-UNDO INITIAL "nice".

/* le if ci-dessous est �quivalent �
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
    MESSAGE "�a ne marche pas, on passe ici! car toute l'expression devient ? donc = FALSE".


/* ------------------------------- */
/* MANIPULATIONS DE TABLES ET BUFFERS */
/* ------------------------------- */

/* definir une temp table */
DEFINE TEMP-TABLE tt_table NO-UNDO
    FIELD field1 AS CHARACTER
    FIELD field2 AS INTEGER
    INDEX idx IS UNIQUE PRIMARY field2 .

/* Cr�er une tt comme une autre table (possible de d�finir comme une table en base) */
/* voir les notes de define temp-table pour plus de pr�cisions mais si on ne pr�cise pas 
les INDEX pour cette tt LIKE table, alors on h�rite des index de la table */
DEFINE TEMP-TABLE tt_like NO-UNDO
    LIKE EMPLOYE.

/* Se positionner sur un enregistrement */
FIND tt_table NO-LOCK WHERE tt_table.field2 = 1.
FIND FIRST tt_table NO-LOCK.
FIND LAST tt_table NO-LOCK.
/* pour les temp table, pas besoin de pr�ciser le LOCK */
/* pour les tables en bases, il faut TOUJOURS pr�ciser quel LOCK utiliser : */
/* En �criture : */
FIND FIRST tt_table EXCLUSIVE-LOCK NO-WAIT.
/* L'instruction NO-WAIT permet de ne pas attendre qu'un enregistrement soit lib�r� et directement sortir en erreur si il est d�j� pris en EXCLUSIVE-LOCK */
/* En lecture : */
FIND FIRST tt_table NO-LOCK.

/* chaque temp table / table en base � un buffer par defaut qui est appel� comme la table :
par exemple, quand on fait FIND FIRST tt_table NO-LOCK. on utilise le buffer par defaut de la table tt_table */
/* il est possible de d�finir d'autres buffers pour pouvoir s�lectionner plusieurs enregistrements d'une m�me table en m�me temps, ex: */
DEFINE BUFFER lb_table FOR tt_table.

/* g�rer les errors de find */
FIND tt_table WHERE tt_table.field2 = 1 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
IF AVAILABLE(tt_table) THEN
    /* the buffer is available (disponible) */
    MESSAGE tt_table.field1.
ELSE IF LOCKED(tt_table) THEN
    /* impossible de r�cup�rer le buffer en �criture (ne sert que pour EXCLUSIVE-LOCK) */
    MESSAGE "Impossible de r�cuperer l'enregistrement en �criture".
ELSE IF AMBIGUOUS(tt_table) THEN
    MESSAGE "Plus d'un enregistrement trouv� pour l'instruction FIND, utilisez la clause WHERE pour trouver un seul enregistrement ou bien FIND FIRST?".

/* Test d'existance d'un enregistrement */
IF CAN-FIND(tt_table WHERE field1 MATCHES "*cool") THEN
    MESSAGE "l'enregistrement existe".
IF CAN-FIND(FIRST tt_table) THEN
    MESSAGE "Au moins un enregistrement existe".

/* Recherche de plusieurs enregistrements */
FOR EACH tt_table NO-LOCK:
    MESSAGE tt_table.field1.
END.

/* avec exclusive-lock? pas besoin de NO-WAIT NO-ERROR, on ne passera pas dans le for each si l'enreg
n'existe pas ou n'est pas disponible */
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
/* si pas de clause BY, les records sont parcourus dans l'ordre de l'index PRIMARY (ou premier index par d�faut) */

/* utilisation de OF, on r�cup�re chaque EMPLOYE et pour chacun, on r�cup�re son SALAIRE */
FOR EACH EMPLOYE NO-LOCK,
    FIRST SALAIRE OF EMPLOYE NO-LOCK:
    MESSAGE STRING(EMPLOYE.ID_EMPLOYE) + " > " + STRING(SALAIRE.ID_SALAIRE).
END.
/* le for each pr�c�dent est �gal � ... */
FOR EACH EMPLOYE NO-LOCK:
    FIND FIRST SALAIRE OF EMPLOYE NO-ERROR.
    /* Le keyword "OF" revient � faire une clause WHERE mais de fa�on implicite (pas bien!) */
    /*FIND FIRST SALAIRE WHERE EMPLOYE.IDSALAIRE = SALAIRE.IDSALAIRE NO-ERROR. */
    IF AVAILABLE(SALAIRE) THEN DO:
        MESSAGE STRING(EMPLOYE.ID_EMPLOYE) + " > " + STRING(SALAIRE.ID_SALAIRE).
    END.
END.
/* ...Sauf que la seconde syntaxe fait beaucoup plus d'aller-retours avec la base de donn�es ->
donc moins performante */

/* compter le nombre d'enregistrements, on ne r�cup�re pas tous les champs car leurs contenus ne nous int�ressent pas */
DEFINE VARIABLE li_count AS INTEGER NO-UNDO.
FOR EACH EMPLOYE FIELDS(EMPLOYE.ID_EMPLOYE):
    ASSIGN li_count = li_count + 1.
END.
MESSAGE STRING(li_count).


/* creation d'un enregistrement */
/* il faut g�rer les erreurs! */
CREATE tt_table.
ASSIGN tt_table.field1 = "".
VALIDATE tt_table.
RELEASE tt_table.

/*
le VALIDATE n'est pas utile quand on a uniquement un index PRIMARY UNIQUE et/ou des index "normaux",
si la condition d'unicit� n'est pas respect�e alors on sort en erreur au ASSIGN

par contre, si on a des index UNIQUE, l'erreur n'est pas lev�e au ASSIGN ni au RELEASE...
c'est l� qu'on a besoin du VALIDATE
*/

/* vider la temp table */
EMPTY TEMP-TABLE tt_table.

/* pour vider une table en base : */
FOR EACH lb_table EXCLUSIVE-LOCK:
    DELETE lb_table.
END.

/* Attention! Tant que le RELEASE n'a pas eu lieu, les infos ne sont pas disponibles dans la TABLE / TEMP-TABLE, par exemple : */
CREATE tt_table.
ASSIGN tt_table.field1 = "1".
FOR EACH lb_table:
    MESSAGE "test 1 : " + lb_table.field1. /* ne va pas s'afficher car on a pas encore RELEASE le nouvel enregistrement dans la table tt_table */
END.

/* pourtant on peut bien r�cup�rer l'information avec le buffer (buffer par d�faut de tt_table) */
MESSAGE "test 2 : " + tt_table.field1.
RELEASE tt_table.


/* passer une table en param�tre (= on passe tous les enregistrements en param�tres!) */
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
DEFINE BUFFER lb_base FOR EMPLOYE.
FIND lb_base WHERE lb_base.ID_EMPLOYE = 1 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
IF AVAILABLE(lb_base) THEN DO:
    /* on modifie */
    ASSIGN lb_base.PRENOM = "paco" NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
        RETURN ERROR "ass " + ERROR-STATUS:GET-MESSAGE(1).
    VALIDATE lb_base NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
        RETURN ERROR "val " + ERROR-STATUS:GET-MESSAGE(1).
    /* on pousse la modifcation en base */
    RELEASE lb_base NO-ERROR.
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

/* si la cible de la copie n'est pas positionn�e, le CREATE se fait automatiquement */
BUFFER-COPY tt_nopk TO lb_nopk.
/* on a maintenant 3 enregistrements identiques */

/* on peut copier tout les champs SAUF field2 et assigner � la place la valeur 5 pour field2 */
BUFFER-COPY tt_nopk EXCEPT tt_nopk.field2 TO lb_nopk
    ASSIGN lb_nopk.field2 = 5.

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


/* d�sactiver les TRIGGERS pour des tables en base */
DISABLE TRIGGERS FOR LOAD OF EMPLOYE.
DISABLE TRIGGERS FOR DUMP OF EMPLOYE.


/* ------------------------------- */
/* DATASET */
/* ------------------------------- */

DEFINE DATASET ds_myds
    FOR tt_table, tt_like.

/* vider un dataset */
DATASET ds_myds:EMPTY-DATASET().

RUN monprog.p (INPUT DATASET ds_myds).
DEFINE INPUT PARAMETER DATASET FOR ds_myds.


/* ------------------------------- */
/* SEQUENCES */
/* ------------------------------- */

ASSIGN
    CURRENT-VALUE(seq_exercice5_employe) = 1 /* forcer une sequence � une valeur */
    li_int = CURRENT-VALUE(seq_exercice5_employe) /* = 1 r�cup�rer la valeur actuelle */
    li_int = NEXT-VALUE(seq_exercice5_employe) /* = 2 r�cup�rer la prochaine valeur de la s�quence (incr�mente puis renvoi la nouvelle valeur) */
    .


/* ------------------------------- */
/* GESTION DES TRANSACTIONS */
/* ------------------------------- */

/* D�marrer explicitement une transaction */
monbloc:
DO ON ERROR UNDO monbloc:
    DO TRANSACTION:

    END.
END.

/* Les blocs qui d�clenchent une transaction (si on update la base dans le block) :
    - FOR EACH
    - REPEAT
    - PROCEDURE BLOCK
    - DO ON ERROR... BLOCKS
*/


/*
?	Validation
?	Mot cl� TRANSACTION (logical)
?	Transaction dans une transaction
?	Port�e d�une transaction
?	Verrous
?	R�duire la port�e d�une transaction
*/



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
{&OPEN-QUERY-BROWSE-X} /* r�insert la commande OPEN QUERY BROWSE-X... */
BROWSE-X:REFRESH(). /* permet de rafraichir uniquement l'enregistrement courant (ligne s�lectionn�e) */

/* r�cuperer la valeur d'un fill-in? */
ASSIGN lc_val = fl_nom:SCREEN-VALUE.

/* si on est dans un trigger pour le fill-in en question, on peut aussi faire �a : */
ASSIGN lc_val = fl_nom:SCREEN-VALUE.
ASSIGN lc_val = {&SELF-NAME}:SCREEN-VALUE.
ASSIGN lc_val = SELF:SCREEN-VALUE.

/* acc�der aux objets d'une FRAME quand on est pas dans un trigger : */
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


/* forcer un �vnement de widget */
APPLY "choose" TO bt_button.
