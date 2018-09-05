{bx00ds_mex.i &1="NEW GLOBAL SHARED "}
{bs00ds_confserveur.i &1="NEW GLOBAL SHARED "}
{bc00ds_confclient.i}


DEFINE TEMP-TABLE tt_prog2 NO-UNDO XML-NODE-NAME "INT_PROG" LIKE INT_PROG
    FIELD cdDocCompo AS CHARACTER.

DEFINE TEMP-TABLE tt_env2 NO-UNDO XML-NODE-NAME "INT_ENV" LIKE INT_ENV
    FIELD yolo AS CHARACTER.

DEFINE DATASET ds_HOLYFUCK
    SERIALIZE-HIDDEN
    FOR tt_prog2, tt_env2.

RUN bx00getdataset.p PERSISTENT SET lh_run.
SESSION:ADD-SUPER-PROCEDURE(lh_run).

DATASET ds_mex:EMPTY-DATASET().

ASSIGN lh_ = DATASET ds_HOLYFUCK:HANDLE.
ASSIGN lc_ = DYNAMIC-FUNCTION('BtGetDataset', INPUT "FOR EACH INT_ENV WHERE INT_ENV.ISEXPLOIT = TRUE, FIRST INT_PROG. FOR EACH INT_PROG MAX-ROWS 1", INPUT-OUTPUT DATASET-HANDLE lh_) NO-ERROR.

DATASET ds_HOLYFUCK:EMPTY-DATASET().
MESSAGE DYNAMIC-FUNCTION('BtGetDataset', INPUT "FOR EACH INT_ENV WHERE INT_ENV.ISEXPLOIT = TRUE, w INT_PROG OF INT_ENV.", INPUT-OUTPUT DATASET ds_HOLYFUCK).

DATASET ds_HOLYFUCK:EMPTY-DATASET().
MESSAGE DYNAMIC-FUNCTION('BtGetDataset', INPUT "FOR EACH INT_ENV, each INT_PROG.", INPUT-OUTPUT DATASET ds_HOLYFUCK).

EMPTY TEMP-TABLE tt_prog2.
MESSAGE DYNAMIC-FUNCTION('BtGetTable', INPUT "FOR EACH INT_PROG.", INPUT-OUTPUT TABLE tt_prog2).

EMPTY TEMP-TABLE tt_prog2.
MESSAGE DYNAMIC-FUNCTION('BtGetTable', INPUT "FOR EACH INT_PROG MAX-ROWS 1.", INPUT-OUTPUT TABLE tt_prog2).

DATASET ds_HOLYFUCK:EMPTY-DATASET().
MESSAGE DYNAMIC-FUNCTION('BtGetDataset', INPUT "FOR EACH INT_ENV, EACH INT_PROG MAX-ROWS 1.", INPUT-OUTPUT DATASET ds_HOLYFUCK).

DEFINE VARIABLE ll_writeStatus AS LOGICAL NO-UNDO.
ASSIGN ll_writeStatus = DATASET ds_HOLYFUCK:WRITE-JSON("FILE", "O:\appli\boib\_tests\fuck.json", TRUE).
IF NOT ll_writeStatus OR ERROR-STATUS:ERROR THEN
    MESSAGE "log : impossible d'écrire le fichier , erreur = " + ERROR-STATUS:GET-MESSAGE(1).

DEFINE VARIABLE gc_list AS CHARACTER NO-UNDO.
MESSAGE DYNAMIC-FUNCTION('btGetList', INPUT "FOR EACH INT_ENV WHERE INT_ENV.IDENVLP = " + QUOTER("2016030916363100") + ", FIRST INT_PROG OF INT_ENV.", INPUT "INT_ENV.IDENVLP\INT_PROG.MODEEXEC\INT_ENV.EMAIL", INPUT "\", OUTPUT gc_list).

DEFINE VARIABLE gc_list2 AS CHARACTER NO-UNDO.
DEFINE VARIABLE li_ AS INTEGER NO-UNDO.

DO li_ = 1 TO NUM-ENTRIES(gc_list, "\") - 1 BY 3:
    gc_list2 = gc_list2 + ENTRY(li_, gc_list, "\") + "," + ENTRY(li_ + 1, gc_list, "\") + "," + ENTRY(li_ + 2, gc_list, "\") + "~n~n".
END.

MESSAGE gc_list2.

FOR each tt_prog2.
    MESSAGE "tt_prog2 = " + tt_prog2.CODAPPL + " " + tt_prog2.NOMPROG.
end.

FOR each tt_env2.
    MESSAGE "tt_env2 = " + tt_env2.CODAPPL.
end.

DYNAMIC-FUNCTION('btGetLocScripts', INPUT "BOI") + 
DYNAMIC-FUNCTION('btGetListOrgaGest')

/* btAfficherMessageSep() */

/*
Retourne le message sous forme de boite de dialogue associé aux paramètres ci-dessous identifiée par :
	Le code application
	Le code module
	Le n° du message
	Les paramètres du contenu du message
Les paramètres sont séparés par un caractère qui se trouve sur le premier caractère du message transmis à la fonction.
*/




DYNAMIC-FUNCTION('btAfficherMessageSep', INPUT "|SAC|CAT|001|").

DYNAMIC-FUNCTION('btAfficherMessageSep', INPUT "|BOI|B1|002|Impossible de trouver l'enregistrement du programme de cette enveloppe").
DYNAMIC-FUNCTION('btAfficherMessageSep', INPUT "|BOI|L0|023|Pour info il y a un truc chelou").

DYNAMIC-FUNCTION('btAfficherMessageSep', INPUT DYNAMIC-FUNCTION('btFormaterErreurSep', INPUT "|")).

/* btGetMessageSep() */
/*Retourne le libellé du message associé aux paramètres ci-dessous identifiée par :
	Le code application
	Le code module
	Le n° du message
	Les paramètres du contenu du message
Le premier caractère de la liste des paramètres identifie le caractère utilisé pour séparé les paramètres.*/
DYNAMIC-FUNCTION("btGetMessageSep", INPUT "|BOI|IN|065|").

/* btformatermessage */
/* Remplace les <0>, <1>... dans un message donné */

/* btformatererreursep */
/* Permet de retourner un message de type : |BOI|xx|xxx| qui contient la derniere return-value rencontrée ou les GET-MESSAGE de l'error status 
  Purpose:
    Cette fonction renvoi un message formaté en : |APP|MOD|NUM|PARAM1|PARAM2...
    avec | un caractère de séparation qui varie selon le paramètre d'entrée
    on retourne un message avec :
        - soit la valeur de la dernière erreur progress (ERROR-STATUS:GET-MESSAGE)
        - soit la valeur de la RETURN-VALUE (dans ce cas, cela doit contenir un message BOI)
        - soit avec un message informant que la fonction a été invoquée sans message (pour rien)
  Notes:
    Le séparateur doit être un seul caractère, de préférence |
*/
DYNAMIC-FUNCTION("btformatererreursep", INPUT "|").

/* récupérer le dernier message d'erreur en clair */
DYNAMIC-FUNCTION('btGetMessageSep', INPUT DYNAMIC-FUNCTION('btformatererreursep', INPUT "|")).

DYNAMIC-FUNCTION('btTracesTracerMessage', INPUT ?, INPUT ?, INPUT 0, INPUT "SERVEUR", INPUT ENTRY(gi_i,RETURN-VALUE,"§")).
DYNAMIC-FUNCTION('btTracesTracerMessage', INPUT ?, INPUT ?, INPUT 3, INPUT "TRACE", INPUT "message").
/*BASES,BICIBAN,BOS,CLIENT,CTRLVERSION,DAD,DIASP,ECHANGE,EMPREINT,FLUXMG,FLXFILE,HABBOS,INTERV,LOCRES,MSG_,PARAMURL,PROPATH,SERVEUR,SLD,TRACE,TRAFIC,TRANSFERT,WEBSERVICES,WEBSVC,WS,Wservices,ZOOM,*/

RETURN ERROR DYNAMIC-FUNCTION('btReturnError').

/* btGetServerHandle
 retourne le "handle" du serveur, permet d'exécuter une procédure côté serveur depuis le client
*/
RUN prog.p ON DYNAMIC-FUNCTION('btGetServerHandle') (INPUT "hello") NO-ERROR.

/* griser/dégriser des widgets */
DYNAMIC-FUNCTION('btRtGriser', INPUT RT_liste:HANDLE).
DYNAMIC-FUNCTION('btRtActiver', INPUT RT_liste:HANDLE).

/* récupérer le code organisme de la session */
DYNAMIC-FUNCTION('btGetSessionOrga')


/* Handle error at program level */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* get last error */
IF (ERROR-STATUS:NUM-MESSAGES > 0) THEN ERROR-STATUS:GET-MESSAGE(1) ELSE (IF RETURN-VALUE <> ? THEN RETURN-VALUE ELSE "").
IF (ERROR-STATUS:NUM-MESSAGES > 0) THEN ERROR-STATUS:GET-MESSAGE(1) ELSE RETURN-VALUE.
(IF RETURN-VALUE > "" THEN RETURN-VALUE ELSE ERROR-STATUS:GET-MESSAGE(1))

/* on s'assure que le chemin du dossier finisse par / */
ASSIGN
    ipc_path = REPLACE(ipc_path, "~\", "~/")
    ipc_path = ipc_path + IF (R-INDEX(ipc_path, "~/") <> LENGTH(ipc_path)) THEN "~/" ELSE "".

/* run programme serveur */
RUN sp99agevertra.p ON DYNAMIC-FUNCTION("Getserverhandle") (OUTPUT o_idutil, OUTPUT o_nomutil, OUTPUT o_profutil) NO-ERROR.

/* renvoi erreur specifique */
RETURN ERROR "@SAC@PS@81@PSCE" + (IF AVAILABLE ZAVCASO THEN ZAVCASO.LIB2TYAVACASO ELSE TT_DOSCASO_ImgApres.TYAVACASO).

/* renvoi erreur generique (ou bien dans la couche au dessus) */
RETURN ERROR DYNAMIC-FUNCTION("sac_btformatererreursep", INPUT "@").

/* traitement de l'erreur dans la couche appelante */
IF ERROR-STATUS:ERROR THEN
    DYNAMIC-FUNCTION('btaffichermessagesep', INPUT DYNAMIC-FUNCTION('btformatererreursep', INPUT "@")).

/* delete un fichier */
OS-DELETE VALUE(DYNAMIC-FUNCTION("btgetfictrsappli", DYNAMIC-FUNCTION("btgetsessionappli")) +  substring(i_fichier_import,1,22)   + ".trt").

/* MANIPULATION DE FICHIERS */
OS-RENAME, OS-DELETE

/* FORMAT DATE */
ASSIGN fuck = STRING(YEAR(TODAY), "9999") + "-" + STRING(MONTH(TODAY), "99") + "-" + STRING(DAY(TODAY), "99") + "T" + STRING(TIME, "HH:MM:SS") + ".000".

MESSAGE "---  DEBUG.TRACE (JCA) @ " CAPS(PROGRAM-NAME(1)) "  ---" SKIP "before sacmagicinterface_s"  VIEW-AS ALERT-BOX WARNING BUTTONS OK.

/* list contains */
IF LOOKUP(tt_resultat.motiden, "ERSAI,ENREG") > 0 THEN

IF STRING(CAN-DO("manager,!acctg8,acctg@*", "acctg@5454")).

MESSAGE STRING(CAN-DO("0,2,10", STRING(9))).

DYNAMIC-FUNCTION("btTracesTracerMessage", INPUT "BOI", INPUT gcTraceOrgaPrincipal, INPUT 3, INPUT "ZOOM", INPUT cText).

/* assign with frame */
ASSIGN opc_nomPaquet = fl_detailNomPaq:SCREEN-VALUE IN FRAME {&FRAME-NAME}.

/* run persistent, delete procedure */
RUN VALUE("efef.p") PERSISTENT SET gh_btFunction (INPUT gc_proAppli, INPUT gc_jpaqDirectory) NO-ERROR.
IF ERROR-STATUS:ERROR OR NOT VALID-HANDLE(gh_btFunction) THEN DO:
    ASSIGN gh_btFunction = ?.
    fi_message(INPUT "Erreur lors du chargement du contexte BOI.~n~n" + RETURN-VALUE).
END.
SESSION:ADD-SUPER-PROCEDURE(gh_btFunction).
/* do stuff */
SESSION:REMOVE-SUPER-PROCEDURE(gh_btFunction).
/* décharge la proc des fonctions dynamiques après avoir déconnecté l'appserveur */
IF VALID-HANDLE(gh_btFunction) THEN DO:
    DELETE PROCEDURE gh_btFunction.
    ASSIGN gh_btFunction = ?.
END.

/* extract file name */
SUBSTRING("zefzef.r", 1, R-INDEX("zefzef.r", ".") - 1).

/* trigger l'evenement zoom */
PUBLISH "zoom" (INPUT FRAME {&FRAME-NAME}:HANDLE).

/* subscribe "paquet_interventions" */
SUBSCRIBE lc_monNomEvenement ANYWHERE RUN-PROCEDURE lc_monNomProcedure.

/* Copy to temp-table */
TEMP-TABLE tt_paquet_browse:COPY-TEMP-TABLE(TEMP-TABLE tt_rtb_paquet:HANDLE, ?, TRUE, TRUE).

TEMP-TABLE tt_respath:COPY-TEMP-TABLE(HANDLE(DYNAMIC-FUNCTION('btGetRessourceTableHandle'))) NO-ERROR.
IF ERROR-STATUS:ERROR THEN
    RETURN ERROR DYNAMIC-FUNCTION("btFormaterErreurSep", "|").

/* check folder existence */
FILE-INFO:FILE-NAME = ipc_rep.
IF FILE-INFO:FILE-TYPE <> ? AND FILE-INFO:FILE-TYPE MATCHES "*D*" THEN

/* check if file exists */
FILE-INFO:FILE-NAME = {&ToCompileListFile}.
IF FILE-INFO:FILE-TYPE = ? OR NOT FILE-INFO:FILE-TYPE MATCHES("*R*") OR NOT FILE-INFO:FILE-TYPE MATCHES("*F*")  THEN

/* Dump database definition in a .df file */
RUN prodict/dump_df.p (INPUT "ALL", INPUT cFileName, INPUT "ISO8859-15") NO-ERROR.

/* load database definition */
RUN prodict/load_df.p (INPUT cFileName) NO-ERROR.

DYNAMIC-FUNCTION("btrtgriser", INPUT rt_envlp:HANDLE).
DYNAMIC-FUNCTION("btrtactiver", INPUT rt_recherche:HANDLE).


OUTPUT STREAM str_logout TO VALUE(gc_outputFilePath) APPEND BINARY.
PUT STREAM str_logout UNFORMATTED SUBSTITUTE("&1~t&2~t&3~t&4~t&5~t&6~t&7",
    pSourcefile,
    fi_severity_label(pSeverity),
    pLineNumber,
    0,
    pSeverity,
    "rule " + pRuleID + ", " + pDescription,
    ""
    ) SKIP.
OUTPUT STREAM str_logout CLOSE.


RUN btOpenFluxEcriture (INPUT "BOI", INPUT "", INPUT "btGetLocAppli", INPUT l_nomfic, INPUT TRUE, INPUT FALSE, OUTPUT lh_flux   ) NO-ERROR.


/* Read xml */
/* contenu du fichier */
COPY-LOB FROM FILE FILE-INFO:FILE-NAME TO llg_xmlData NO-ERROR.
IF ERROR-STATUS:ERROR THEN
    RETURN ERROR "Erreur lors de la lecture du contenu du fichier <" + lc_file + "> : " + ERROR-STATUS:GET-MESSAGE(1).

/* Import des données dans le DATASET (après l'avoir vidé) */
ASSIGN ll_ok = DATASET ds_intervexp:READ-XML("LONGCHAR", iplg_xmlData, "EMPTY", ?, ?) NO-ERROR.
IF ERROR-STATUS:ERROR THEN
    RETURN ERROR "Erreur lors de l'import du contenu du xml".

    
/* test if progress 32 bits */
&IF PROVERSION >= '11.3' AND PROCESS-ARCHITECTURE = 32 &THEN
    RETURN TRUE.
&ELSE
    RETURN FALSE.
&ENDIF

/* convert char to decimal */
REPLACE(REPLACE(lc_, ".", SESSION:NUMERIC-DECIMAL-POINT), ",", SESSION:NUMERIC-DECIMAL-POINT)
session:numeric-decimal-point


/* WEB SERVICE */
sacpsoalpharecupnbdeclaencours_s.p
ou bs00impression.p -> AppelNDL

/* loop through list of comma separeted value */
DEF VAR i AS INT NO-UNDO.
&SCOPED-DEFINE LIST "one,two,three,four"
DO i=1 TO NUM-ENTRIES({&LIST}):
  MESSAGE SUBSTITUTE("LIST[&1] is &2", i, ENTRY(i, {&LIST})).
END.

/* loop tableau type extent */
myloop:
DO li_i = 1 TO EXTENT(tableau1):
    IF tableau1[li_i] = mavalatrouver THEN
        LEAVE myloop.
END.

/* count number of records + measure time */
DEFINE VARIABLE i AS INTEGER     NO-UNDO.
ETIME(TRUE).
FOR EACH orderline FIELDS(ordernum) NO-LOCK:
  i = i + 1.
END.
MESSAGE ETIME i
    VIEW-AS ALERT-BOX INFO BUTTONS OK.

/* case, switch */
CASE lh_field:DATA-TYPE:
    WHEN "character" THEN DO:
    END.
    OTHERWISE DO:
    END.
END CASE.

/* Pour chaque fichier .xml du dossier */
INPUT STREAM str_read FROM OS-DIR(ipc_directory).
REPEAT:
    IMPORT STREAM str_read lc_file.
    IF lc_file <> ? AND lc_file <> "." AND lc_file <> ".." AND lc_file <> "" AND lc_file MATCHES "*.xml" THEN DO :
        FILE-INFO:FILE-NAME = ipc_directory + "~/" + lc_File.
        IF FILE-INFO:FILE-TYPE MATCHES "*R*" THEN DO:

            /* contenu du fichier */
            COPY-LOB FROM FILE FILE-INFO:FILE-NAME TO llg_xmlData NO-ERROR.
            IF ERROR-STATUS:ERROR THEN
                RETURN ERROR "Erreur lors de la lecture du contenu du fichier <" + lc_file + "> : " + ERROR-STATUS:GET-MESSAGE(1).
        END.
    END.
END.
INPUT STREAM str_read CLOSE.

/* Download file from URL */
PROCEDURE URLDownloadToFileA EXTERNAL "Urlmon.dll" :
    DEFINE INPUT  PARAMETER pCaller      AS LONG.
    DEFINE INPUT  PARAMETER szURL       AS CHARACTER.
    DEFINE INPUT  PARAMETER szFileName        AS CHARACTER.
    DEFINE INPUT  PARAMETER dwReserved    AS LONG.
    DEFINE INPUT  PARAMETER lpfnCB     AS LONG.
    DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.

DEFINE VARIABLE liReturnValue         AS INTEGER      NO-UNDO.

/* download a file */
RUN URLDownloadToFileA(0, "http://noyac.fr/3pWebService/v1.4.1/", "D:\Profiles\jcaillon\Downloads\test.json", 0, 0, OUTPUT liReturnValue).
MESSAGE STRING(liReturnValue).


/* to base 64 */
DEFINE VARIABLE encdmptr AS MEMPTR   NO-UNDO.
DEFINE VARIABLE encdlngc AS LONGCHAR NO-UNDO.

ASSIGN encdlngc = "admin:sopra*".
COPY-LOB FROM encdlngc TO encdmptr.
encdlngc = BASE64-ENCODE(encdmptr).
CLIPBOARD:VALUE = STRING(encdlngc).


FUNCTION DirectoryExists RETURNS LOGICAL
  ( INPUT ipc_directoryPath AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Summary    : Returns TRUE if the given directoy path exists  
------------------------------------------------------------------------------*/

    ASSIGN FILE-INFO:FILE-NAME = ipc_directoryPath.
    IF FILE-INFO:FILE-TYPE <> ? AND FILE-INFO:FILE-TYPE MATCHES "*D*" THEN
        RETURN TRUE.
    ELSE
        RETURN FALSE.

END FUNCTION.


/* SORT TABLES TEMP TABLES */
/* en fait... la close BY ça sert uniquement à trier les enregistrements dans le cas ou tu fais une boucle dessus,
si tu te contentes de :
FOR EACH MATABLE BY MONFIELD:
    COPY dans MATEMPTABLE
END.
ne t'attends pas à ce que tu retrouves le bon ordre quand tu parcoures :
FOR EACH MATEMPTABLE

END.
parce que progress stockes les enregistrements comme il l'entend (donc suivant les indexes),
pour parcourir la temp table comme tu l'entends, il faut

 */

/* dyanmic query */
def var hTable as handle no-undo.
def var hBuffer as handle no-undo.
def var str as char no-undo.
def var i as integer no-undo.
def var hQuery as handle no-undo.
create temp-table hTable.
hTable:add-new-field("a", "character").
hTable:add-new-field("b", "character").
hTable:add-new-field("c", "character").
hTable:add-new-field("d", "character").
hTable:temp-table-prepare("newTable").
hBuffer = hTable:default-buffer-handle.
input from c:\temp\test.csv.
repeat:
  import unformatted str.
  hBuffer:buffer-create.
  do i = 1 to num-entries(str):
    hBuffer:buffer-field(i):buffer-value = entry(i, str).
  end.
end.
input close.
create query hQuery.
hQuery:set-buffers(hBuffer).
hQuery:query-prepare("for each " + hBuffer:name).
hQuery:query-open().
hQuery:get-first().
do while not hQuery:query-off-end with frame a:
  disp hBuffer:buffer-field(1):buffer-value.
  down.
  hQuery:get-next().
end.
hQuery:query-close().
delete object hQuery.
delete object hTable.

/* read xml dynamically */
CREATE TEMP-TABLE lhTT.
lhTT:READ-XML("LONGCHAR", llcErrorSerialized, "EMPTY", ?, ?, ?, "STRICT").
lhTT:DEFAULT-BUFFER-HANDLE:FIND-FIRST("", NO-LOCK) NO-ERROR.
lcWSMess = lhTT:DEFAULT-BUFFER-HANDLE:BUFFER-FIELD("errorMessage"):BUFFER-VALUE.
DELETE OBJECT lhTT.

/* dynamic query on table */
CREATE QUERY lh_query.
CREATE BUFFER lh_buffer FOR TABLE ipc_tableName.
lh_query:SET-BUFFERS(lh_buffer).
lh_query:QUERY-PREPARE("for each " + lc_curTable).
lh_query:QUERY-OPEN().
lh_query:GET-FIRST().
DO WHILE NOT lh_query:QUERY-OFF-END:
    REPEAT li_i = 1 TO lh_buffer:NUM-FIELDS:
        lh_field = lh_buffer:BUFFER-FIELD(li_i).
        MESSAGE STRING(lh_field:BUFFER-VALUE).
    END.
    lh_query:GET-NEXT().
END.
lh_query:QUERY-CLOSE().
DELETE OBJECT lh_query.

RUN pi_replaceInFile (INPUT lc_pathAppli, INPUT "*.ini", INPUT "client" + gc_codeOrgOld, INPUT "client" + gc_codeOrgNew).
PROCEDURE pi_replaceInFile :
/*------------------------------------------------------------------------------
  Purpose:  replace in chaine par une autre dans un fichier donné
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER ipc_dirPath AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipc_fileNameMatch AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipc_replaceFrom AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipc_replaceTo AS CHARACTER NO-UNDO.

    DEFINE VARIABLE llg_content AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE lc_fileName AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc_filePath AS CHARACTER NO-UNDO.

    /* on s'assure que le dossier finisse par / */
    ASSIGN
        ipc_dirPath = REPLACE(ipc_dirPath, "~\", "~/")
        ipc_dirPath = ipc_dirPath + IF (R-INDEX(ipc_dirPath, "~/") <> LENGTH(ipc_dirPath)) THEN "~/" ELSE "".

    /* Loop sur les fichiers du dossier */
    INPUT FROM OS-DIR(ipc_dirPath).
    REPEAT:
        IMPORT lc_fileName.
        IF lc_fileName MATCHES ipc_fileNameMatch THEN DO:
            ASSIGN lc_filePath = ipc_dirPath + lc_fileName.
            fi_log(INPUT "  | fichier : " + lc_filePath).
            COPY-LOB FROM FILE lc_filePath TO OBJECT llg_content.
            ASSIGN llg_content = REPLACE(llg_content, ipc_replaceFrom, ipc_replaceTo).
            COPY-LOB FROM OBJECT llg_content TO FILE lc_filePath.
        END.
    END.

    RETURN "".

END PROCEDURE.

PROCEDURE pi_createdynamicDataset PRIVATE:
/*------------------------------------------------------------------------------
  Purpose:  Permet de créer un dataset dynamique contenant des temp-tables elles-aussi
  créées dynamiquement à partir des buffers utilisés dans les différentes QUERY
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER opc_matchTable AS CHARACTER NO-UNDO.
    DEFINE INPUT-OUTPUT PARAMETER DATASET-HANDLE ioph_dataset.

    DEFINE VARIABLE li_i AS INTEGER NO-UNDO.
    DEFINE VARIABLE ll_ok AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lc_unique AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc_curTable AS CHARACTER NO-UNDO.

    /* pour chaque buffer utilisé dans les QUERY, on crée une temp table LIKE le buffer et on le met dans le dataset */
    FOR EACH tt_query:
        DO li_i = 1 TO NUM-ENTRIES(tt_query.BUFFERSLIST):
            ASSIGN lc_curTable = ENTRY(li_i, tt_query.BUFFERSLIST).

            IF LOOKUP(lc_curTable, lc_unique) = 0 THEN DO:
                CREATE tt_handle.
                ASSIGN tt_handle.TTNAME = "tt__" + lc_curTable.
                CREATE TEMP-TABLE tt_handle.VAL.
                ASSIGN ll_ok = tt_handle.VAL:CREATE-LIKE(lc_curTable) NO-ERROR.
                IF NOT ll_ok OR ERROR-STATUS:ERROR THEN
                    RETURN ERROR "Impossible de créer une temp table LIKE " + QUOTER(lc_curTable) + ", vérifiez l'existance de la table. " + ERROR-STATUS:GET-MESSAGE(1).

                ASSIGN ll_ok = tt_handle.VAL:TEMP-TABLE-PREPARE(tt_handle.TTNAME) NO-ERROR.
                IF NOT ll_ok OR ERROR-STATUS:ERROR THEN
                    RETURN ERROR "Impossible de préparer une temp table LIKE " + QUOTER(lc_curTable) + ", vérifiez l'existance de la table. " + ERROR-STATUS:GET-MESSAGE(1).

                ASSIGN ll_ok = ioph_dataset:ADD-BUFFER(tt_handle.VAL) NO-ERROR.
                IF NOT ll_ok OR ERROR-STATUS:ERROR THEN
                    RETURN ERROR "Impossible d'ajouter la table " + QUOTER(lc_curTable) + " dans le dataset de sortie. " + ERROR-STATUS:GET-MESSAGE(1).

                ASSIGN
                    opc_matchTable = opc_matchTable + lc_curTable + "," + tt_handle.TTNAME + ","
                    lc_unique = lc_unique + lc_curTable + ",".
                RELEASE tt_handle.
            END.
        END.
    END.

    ASSIGN opc_matchTable = TRIM(opc_matchTable, ",").

END.


/*********************************************/

/* STRINGS FUNCTIONS */
STRING : conversion
QUOTER : citation
BEGINS : opérateur
MATCHES : opérateur
CHR : Chr ASCII
CAPS : To upper case
LC : To lower case
FILL : Fill the string
TRIM : trim from char
LENGTH
LEFT-TRIM
RIGHT-TRIM
NUM-ENTRIES("{&FILE-NAME}","\") /* nombre d'index de split : */
ENTRY(1, mydate_char, '/'). /* index, chaine, separateur > return l'entree 1 de la liste */
LOOKUP(tt_resultat.motiden, "ERSAI,ENREG") > 0 /* Returns an INTEGER value giving the position of an expression in a list. */
INDEX : string position in another string
R-INDEX : idem from right
SUBSTRING
SUBSTITUTE : substitute in string
REPLACE : replace in string
ENCODE

/*********************/

/* mex XML */
tthTmp:WRITE-XML("FILE","c:\temp\tt.xml", TRUE).

/* OUTPUT TO JSON */
DEFINE TEMP-TABLE ttTmp
  FIELD FieldA          AS CHAR
  FIELD FieldB          AS CHAR.

CREATE ttTmp.
ASSIGN ttTmp.FieldA = "A"
      ttTmp.FieldB = "B".

DEFINE VARIABLE tthTmp AS HANDLE  NO-UNDO. /* Handle to temptable */
DEFINE VARIABLE lReturnValue AS LOGICAL NO-UNDO.
tthTmp = TEMP-TABLE ttTmp:HANDLE.
lReturnValue = tthTmp:WRITE-JSON("FILE", "c:\temp\tthTmp.txt", TRUE, ?).

/*
Output File tthTmp.txt
{"ttTmp": [
  {
    "FieldA": "A",
    "FieldB": "B"
  }
]}
Output File tthTmp.txt
*/

/**************************
// READ THE .INI (CURRENT ENVIRONMENT!!!) */
GET-KEY-VALUE SECTION "RTB-CNAF" KEY "" VALUE lclesectionrtbcnaf.
DO iclesectionrtbcnaf = 1 TO NUM-ENTRIES(lclesectionrtbcnaf):
  CREATE ttperso.
  ASSIGN
      ttperso.nomperso = ENTRY(iclesectionrtbcnaf,lclesectionrtbcnaf).

  GET-KEY-VALUE SECTION "RTB-CNAF" KEY ttperso.nomperso VALUE ttperso.activation.
  ttperso.activation = LC(ttperso.activation).
  GET-KEY-VALUE SECTION ttperso.nomperso KEY "rtbpath"      VALUE ttperso.path.
  GET-KEY-VALUE SECTION ttperso.nomperso KEY "init"         VALUE ttperso.procinit.
  GET-KEY-VALUE SECTION ttperso.nomperso KEY "AllEvents"    VALUE ttperso.procallevents.
  GET-KEY-VALUE SECTION ttperso.nomperso KEY "trace"        VALUE ttperso.trace.
END.

FOR EACH ttperso WHERE ttperso.activation = "oui":
  IF ttperso.trace = "oui" THEN DO:
      ttperso.fictrace = SESSION:TEMP-DIRECTORY + "rtbevent-" + ttperso.nomperso + "-trace.txt".
      OUTPUT TO VALUE(ttperso.fictrace).
      OUTPUT CLOSE.
      RUN tracePersoCnaf IN THIS-PROCEDURE
          ("LoadPersoCnaf", ttperso.nomperso,  "", ttperso.trace, ttperso.fictrace, ttperso.procinit, ttperso.procallevents).
  END.
  IF pathperso = "" THEN pathperso = ttperso.path.
  ELSE DO:
      DO ipath = 1 TO NUM-ENTRIES(ttperso.path) :
          IF LOOKUP(ENTRY(ipath,ttperso.path),pathperso) = 0 THEN
              pathperso = pathperso + "," + ENTRY(ipath,ttperso.path).
      END.
  END.
END.


/*******************************************/
/* GET */
DEFINE TEMP-TABLE tt_planning {include_planning.i}.

DEFINE INPUT PARAMETER ipc_mail AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER TABLE FOR tt_planning.

EMPTY TEMP-TABLE tt_planning.

FOR EACH planning NO-LOCK
    WHERE planning.email = (IF ipc_mail = "" OR ipc_mail = ? THEN planning.email ELSE ipc_mail) :

    /* Valorisation de la table temporaire de planning */
    BUFFER-COPY planning TO tt_planning NO-ERROR.
    VALIDATE tt_planning NO-ERROR.
    RELEASE tt_planning NO-ERROR.

    IF ERROR-STATUS:ERROR THEN
        RETURN ERROR "Failed to feed table planning." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).
END.

/*********************************************/
/* CREATE / MODIFY */
myTransaction:
DO TRANSACTION:
    FIND employe NO-LOCK WHERE
        employe.ID = (IF vId = ? THEN employe.ID ELSE vId) AND employe.SEXE = (IF vSexe = ? THEN employe.SEXE ELSE vSexe)  NO-ERROR.

    /* NOT AVAILABLE */
    IF NOT AVAILABLE (employe) THEN DO:
        /* AMBIGUOUS */
        IF AMBIGUOUS (employe) THEN DO:
            MESSAGE "Ambiguous query. Please review and try again later." VIEW-AS ALERT-BOX WARNING BUTTONS OK.
            NEXT.
        END.
        ELSE
            /* CREATE */
            CREATE employe NO-ERROR.
            IF ERROR-STATUS:ERROR THEN DO:
                MESSAGE "Failed to create employee." SKIP "Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)) VIEW-AS ALERT-BOX ERROR BUTTONS OK.
                NEXT.
            END.

            /* NEXT-VALUE IN SEQUENCE */
            ASSIGN employe.id = NEXT-VALUE(SEQ_EMPLOYE) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN DO:
                MESSAGE "Failed to give Id to employee." SKIP "Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)) VIEW-AS ALERT-BOX ERROR BUTTONS OK.
                DELETE employe NO-ERROR.    /* Pas de gestion d'erreur car on est au bout des actions possibles */
                NEXT.
            END.
        END.
    END.
    /* IS AVAILABLE */
    ELSE DO:
        /* FIND CURRENT EXCLUSIVE-LOCK */
        FIND CURRENT employe EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

        /* LOCKED */
        IF LOCKED(employe) THEN DO:
            MESSAGE "Failed to acquire full accesses to employee." SKIP "Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)) VIEW-AS ALERT-BOX ERROR BUTTONS OK.
            NEXT.
        END.
        /* DELETED */
        ELSE IF NOT AVAILABLE(employe) THEN DO:
            MESSAGE "Record employee appears to be killed :(." SKIP "Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)) VIEW-AS ALERT-BOX ERROR BUTTONS OK.
            NEXT.
        END.
    END.

    /* ASSIGN */
    ASSIGN  employe.nom = vNom NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE "Failed with UPDATE." SKIP "Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)) VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        IF NEW(employe) THEN
            DELETE employe NO-ERROR.    /* Pas de gestion d'erreur car on est au bout des actions possibles */
        ELSE
            RELEASE employe NO-ERROR.   /* Pas de gestion d'erreur car on est au bout des actions possibles */
        IF ERROR-STATUS:ERROR THEN
            UNDO myTransaction, LEAVE myTransaction.
    END.

    /* VALIDATE */
    VALIDATE employe NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE "Failed with VALIDATE." SKIP "Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)) VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        IF NEW(employe) THEN
            DELETE employe NO-ERROR.    /* Pas de gestion d'erreur car on est au bout des actions possibles */
        ELSE
            RELEASE employe NO-ERROR.   /* Pas de gestion d'erreur car on est au bout des actions possibles */
        IF ERROR-STATUS:ERROR THEN
            UNDO myTransaction, LEAVE myTransaction.
    END.

    /* RELEASE */
    RELEASE employe NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE "Failed with RELEASE." SKIP "Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)) VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        IF NEW(employe) THEN
            DELETE employe NO-ERROR.    /* Pas de gestion d'erreur car on est au bout des actions possibles */
        IF ERROR-STATUS:ERROR THEN
            UNDO myTransaction, LEAVE myTransaction.
    END.
END.


/*********************************************/
/*- DELETE / CREATE / MODIFY */
DEFINE TEMP-TABLE tt_set_planning_bef {include_planning.i}.
DEFINE TEMP-TABLE tt_set_planning_aft {include_planning.i}.

DEFINE INPUT PARAMETER TABLE FOR tt_set_planning_bef.
DEFINE INPUT PARAMETER TABLE FOR tt_set_planning_aft.
DEFINE BUFFER bf_planning FOR planning.

DEFINE VARIABLE ll_equals AS LOGICAL NO-UNDO.

myTransaction:
DO TRANSACTION:

    FIND FIRST tt_set_planning_bef NO-WAIT NO-ERROR.
    FIND FIRST tt_set_planning_aft NO-WAIT NO-ERROR.

    /* Delete */
    IF AVAILABLE(tt_set_planning_bef) AND NOT AVAILABLE(tt_set_planning_aft) THEN DO:

        /* on se positionne sur la bonne date */
        FIND FIRST bf_planning WHERE bf_planning.dtcrois = tt_set_planning_bef.dtcrois AND
            bf_planning.equipe = tt_set_planning_bef.equipe EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
        IF NOT AVAILABLE(bf_planning) THEN
            UNDO myTransaction, RETURN ERROR "Failed to find the date to delete." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

        BUFFER-COMPARE bf_planning TO tt_set_planning_bef SAVE RESULT IN ll_equals NO-ERROR.
        IF NOT ll_equals THEN
            UNDO myTransaction, RETURN ERROR "The planning has been updated since you started deleting it" + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

        /* on le delete! */
        DELETE bf_planning NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
            UNDO myTransaction, RETURN ERROR "Failed to delete bf_planning." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

    END.

    ELSE DO:

        IF NOT AVAILABLE(tt_set_planning_bef) THEN DO:
            /* CREATION */
            CREATE bf_planning NO-ERROR.
            IF ERROR-STATUS:ERROR THEN
                UNDO myTransaction, RETURN ERROR "Failed to create planning." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).
        END.
        ELSE DO:
            /* MODIF, on se positionne sur le bon collab */
            FIND FIRST bf_planning WHERE bf_planning.dtcrois = tt_set_planning_bef.dtcrois AND
                bf_planning.equipe = tt_set_planning_bef.equipe EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF NOT AVAILABLE(bf_planning) THEN
                UNDO myTransaction, RETURN ERROR "Failed to find planning." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

            BUFFER-COMPARE bf_planning TO tt_set_planning_bef SAVE RESULT IN ll_equals NO-ERROR.
            IF NOT ll_equals THEN
                UNDO myTransaction, RETURN ERROR "The planning has been updated since you started modifying it" + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

        END.

        ASSIGN bf_planning.dtcrois = tt_set_planning_aft.dtcrois
            bf_planning.email = tt_set_planning_aft.email
            bf_planning.equipe = tt_set_planning_aft.equipe
            bf_planning.raison = tt_set_planning_aft.raison
            bf_planning.valide = tt_set_planning_aft.valide NO-ERROR.

        IF ERROR-STATUS:ERROR THEN
            UNDO myTransaction, RETURN ERROR "Failed to feed planning." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

        VALIDATE bf_planning NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
            UNDO myTransaction, RETURN ERROR "Failed to validate planning." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

        RELEASE bf_planning NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
            UNDO myTransaction, RETURN ERROR "Failed to release planning." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).

    END.

    IF AVAILABLE(tt_set_planning_bef) THEN DO:
        RELEASE tt_set_planning_bef NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
                UNDO myTransaction, RETURN ERROR "Failed to release tt_set_planning_bef." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).
    END.
    IF AVAILABLE(tt_set_planning_aft) THEN DO:
        RELEASE tt_set_planning_aft NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
                UNDO myTransaction, RETURN ERROR "Failed to release tt_set_planning_aft." + " Error is " + QUOTER(ERROR-STATUS:GET-MESSAGE(1)).
    END.
END.

RETURN "".

