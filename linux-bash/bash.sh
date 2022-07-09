#!/bin/bash

printf "Hello, $USER.\n\n"
echo "Today's date is `date`, this is week `date +"%V"`."
echo "These users are currently connected:"
w | cut -d " " -f 1 - | grep -v USER | sort -u
echo
echo "This is `uname -s` running on a `uname -m` processor."


which -a script_name
whereis script_name
locate script_name


#~ break, cd, continue, eval, exec, exit, export, getopts, hash, pwd, readonly, return, set, shift, test, [, times, trap, umask and unset.
#~ alias, bind, builtin, command, declare, echo, enable, help, let, local, logout, printf, read, shopt, type, typeset, ulimit and unalias.


rbash script_name.sh
sh script_name.sh
bash -x script_name.sh


# debug mode :
sh -x script.sh
set -x # activate debugging from here
w
set +x # stop debugging from here
# autres modes :
set -v # print shell inpout lines as they are read
#!/bin/bash -xv


# environnement var
printenv
PATH, USER, MAIL, HOSTNAME and HISTSIZE.
# local var (only on this shell)
diff set.sorted printenv.sorted | grep "<" | awk '{ print $2 }'


# define var
myvar="2"
uset myvar
franky ~> full_name="Franky M. Singh"
franky ~> bash
franky ~> echo $full_name
franky ~> exit
franky ~> export full_name
franky ~> bash
franky ~> echo $full_name
Franky M. Singh
franky ~> export full_name="Charles the Great"
franky ~> echo $full_name
Charles the Great
franky ~> exit
franky ~> echo $full_name
Franky M. Singh
franky ~>


$* idem que dessous en moins propre
$@ #Expands to the positional parameters, starting from one. When the expansion occurs within double quotes, each parameter expands to a separate word.
$# # Total number of arguments
$? # Expands to the exit status of the most recently executed foreground pipeline.
$- #  A hyphen expands to the current option flags as specified upon invocation, by the set built-in command, or those set by the shell itself (such as the -i).
$$ # Expands to the process ID of the shell.
$! # Expands to the process ID of the most recently executed background (asynchronous) command.
$0 # Expands to the name of the shell or shell script.
$_ # The underscore variable is set at shell startup and contains the absolute file name of the shell or script being executed as passed in the argument list. Subsequently, it expands to the last argument to the previous command, after expansion. It is also set to the full pathname of each command executed and placed in the environment exported to that command. When checking mail, this parameter holds the name of the mail file.


# This creates the archive
tar cf /var/tmp/home_franky.tar franky > /dev/null 2>&1
# First remove the old bzip2 file. Redirect errors because this generates some if the archive
# does not exist. Then create a new compressed file.
rm /var/tmp/home_franky.tar.bz2 2> /dev/null


# escape characters \
# doesn't work if followed by a end of line char
franky ~> date=20021226
franky ~> echo $date
20021226
franky ~> echo \$date
$date


#~ Single quotes ('') are used to preserve the literal value of each character enclosed within the quotes. A single quote may not occur between single quotes, even when preceded by a backslash.
franky ~> echo '$date'
$date


#~ Using double quotes the literal value of all characters enclosed is preserved, except for the dollar sign, the backticks (backward single quotes, ``) and the backslash.
franky ~> echo "$date"
20021226
franky ~> echo "`date`"
Sun Apr 20 11:22:06 CEST 2003
franky ~> echo "I'd say: \"Go for it!\""
"
I'd say: "Go for it!"
franky ~> echo "\"
More input>
franky ~> echo "\\"
\""
echo "rzegg"

# brace expansion
franky ~> echo sp{el,il,al}l
spell spill spall


# var exp
franky ~> echo ${P!*}
PATH PIPESTATUS PPID PS1 PS2 PS4 PWD

franky ~> echo $FRANKY
franky ~> echo ${FRANKY:=Franky}
Franky


# command subtitution : replace the commande by its output
$()
OR
``
franky ~> echo `date`
Thu Feb 6 10:06:20 CET 2003
OR
franky ~> echo $(date)
Thu Feb 6 10:06:20 CET 2003

# arithmetic expansion
$(( EXPRESSION ))
OR $[ EXPRESSION ] # only calculate the result and do no tests


VAR++ and VAR-- # variable post-increment and post-decrement
++VAR and --VAR #variable pre-increment and pre-decrement
- and + #unary minus and plus
! and ~ #logical and bitwise negation
** #exponentiation
*  and % #multiplication, division, remainder
+ and - #addition, subtraction
<< and >> #left and right bitwise shifts
<=, >=, < and > #comparison operators
== and != #equality and inequality
& #bitwise AND
^ #bitwise exclusive OR
| #bitwise OR
&& #logical AND
|| #logical OR
expr ? expr : expr #conditional evaluation
=, *=, =, %=, +=, -=, <<=, >>=, &=, ^= and |= #assignments
, #separator between expressions

franky ~> echo $((5*5>24?2:3))
2


# if
if [ COMMAND ]; then; COMMAND; fi
if [ COMMAND ]; then
elif
elif
else
fi
if [ -f $FILENAME ]; then
  echo "Size is $(ls -lh $FILENAME | awk '{ print $5 }')"
  echo "Type is $(file $FILENAME | cut -d":" -f2 -)"
  echo "Inode number is $(ls -i $FILENAME | cut -d" " -f1 -)"
  echo "$(df -h $FILENAME | grep -v Mounted | awk '{ print "On",$1",which is mounted as the",$6,"partition."}')"
else
  echo "File does not exist."
fi

[ -a FILE ]	True if FILE exists.
[ -b FILE ]	True if FILE exists and is a block-special file.
[ -c FILE ]	True if FILE exists and is a character-special file.
[ -d FILE ]	True if FILE exists and is a directory.
[ -e FILE ]	True if FILE exists.
[ -f FILE ]	True if FILE exists and is a regular file.
[ -g FILE ]	True if FILE exists and its SGID bit is set.
[ -h FILE ]	True if FILE exists and is a symbolic link.
[ -k FILE ]	True if FILE exists and its sticky bit is set.
[ -p FILE ]	True if FILE exists and is a named pipe (FIFO).
[ -r FILE ]	True if FILE exists and is readable.
[ -s FILE ]	True if FILE exists and has a size greater than zero.
[ -t FD ]	True if file descriptor FD is open and refers to a terminal.
[ -u FILE ]	True if FILE exists and its SUID (set user ID) bit is set.
[ -w FILE ]	True if FILE exists and is writable.
[ -x FILE ]	True if FILE exists and is executable.
[ -O FILE ]	True if FILE exists and is owned by the effective user ID.
[ -G FILE ]	True if FILE exists and is owned by the effective group ID.
[ -L FILE ]	True if FILE exists and is a symbolic link.
[ -N FILE ]	True if FILE exists and has been modified since it was last read.
[ -S FILE ]	True if FILE exists and is a socket.
[ FILE1 -nt FILE2 ]	True if FILE1 has been changed more recently than FILE2, or if FILE1 exists and FILE2 does not.
[ FILE1 -ot FILE2 ]	True if FILE1 is older than FILE2, or is FILE2 exists and FILE1 does not.
[ FILE1 -ef FILE2 ]	True if FILE1 and FILE2 refer to the same device and inode numbers.
[ -o OPTIONNAME ]	True if shell option "OPTIONNAME" is enabled.
[ -z STRING ]	True of the length if "STRING" is zero.
[ -n STRING ] or [ STRING ]	True if the length of "STRING" is non-zero.
[ STRING1 == STRING2 ]	True if the strings are equal. "=" may be used instead of "==" for strict POSIX compliance.
[ STRING1 != STRING2 ]	True if the strings are not equal.
[ STRING1 < STRING2 ]	True if "STRING1" sorts before "STRING2" lexicographically in the current locale.
[ STRING1 > STRING2 ]	True if "STRING1" sorts after "STRING2" lexicographically in the current locale.
[ ARG1 OP ARG2 ]	"OP" is one of -eq, -ne, -lt, -le, -gt or -ge. These arithmetic binary operators return true if "ARG1" is equal to, not equal to, less than, less than or equal to, greater than, or greater than or equal to "ARG2", respectively. "ARG1" and "ARG2" are integers.

[ ! EXPR ]	True if EXPR is false.
[ ( EXPR ) ]	Returns the value of EXPR. This may be used to override the normal precedence of operators.
[ EXPR1 -a EXPR2 ]	True if both EXPR1 and EXPR2 are true.
[ EXPR1 -o EXPR2 ]	True if either EXPR1 or EXPR2 is true.



SYNOPSIS
test EXPRESSION
test EXPR && COMMANDE
( EXPRESSION )
	  EXPRESSION is true
! EXPRESSION
	  EXPRESSION is false
EXPRESSION1 -a EXPRESSION2
	  both EXPRESSION1 and EXPRESSION2 are true
EXPRESSION1 -o EXPRESSION2
	  either EXPRESSION1 or EXPRESSION2 is true
-n STRING
	  the length of STRING is nonzero
STRING equivalent to -n STRING
-z STRING
	  the length of STRING is zero
STRING1 = STRING2
	  the strings are equal
STRING1 != STRING2
	  the strings are not equal
INTEGER1 -eq INTEGER2
	  INTEGER1 is equal to INTEGER2
INTEGER1 -ge INTEGER2
	  INTEGER1 is greater than or equal to INTEGER2
INTEGER1 -gt INTEGER2
	  INTEGER1 is greater than INTEGER2
INTEGER1 -le INTEGER2
	  INTEGER1 is less than or equal to INTEGER2
INTEGER1 -lt INTEGER2
	  INTEGER1 is less than INTEGER2
INTEGER1 -ne INTEGER2
	  INTEGER1 is not equal to INTEGER2
FILE1 -ef FILE2
	  FILE1 and FILE2 have the same device and inode numbers
FILE1 -nt FILE2
	  FILE1 is newer (modification date) than FILE2
FILE1 -ot FILE2
	  FILE1 is older than FILE2
-b FILE
	  FILE exists and is block special
-c FILE
	  FILE exists and is character special
-d FILE
	  FILE exists and is a directory
-e FILE
	  FILE exists
-f FILE
	  FILE exists and is a regular file
-g FILE
	  FILE exists and is set-group-ID
-G FILE
	  FILE exists and is owned by the effective group ID
-h FILE
	  FILE exists and is a symbolic link (same as -L)
-k FILE
	  FILE exists and has its sticky bit set
-L FILE
	  FILE exists and is a symbolic link (same as -h)
-O FILE
	  FILE exists and is owned by the effective user ID
-p FILE
	  FILE exists and is a named pipe
-r FILE
	  FILE exists and read permission is granted
-s FILE
	  FILE exists and has a size greater than zero
-S FILE
	  FILE exists and is a socket
-t FD  file descriptor FD is opened on a terminal
-u FILE
	  FILE exists and its set-user-ID bit is set
-w FILE
	  FILE exists and write permission is granted
-x FILE
	  FILE exists and execute (or search) permission is granted


if [ ! -z "$1" ] && echo "Argument #1 = $1" && [ ! -z "$2" ] \
&& echo "Argument #2 = $2"
then
  echo "Au moins deux arguments passés au script."
  # Toute la commande chaînée doit être vraie.
else
  echo "Moins de deux arguments passés au script."
  # Au moins une des commandes de la chaîne a renvoyé faux.
fi


commande-1 && commande-2 && commande-3 && ...
commande-n
Chaque commande s'exécute à son tour à condition que la dernière commande ait renvoyé un code de retour true (zéro). Au premier retour false (différent de zéro), la chaîne de commande s'arrête (la première commande renvoyant false est la dernière à être exécutée).

commande-1 || commande-2 || commande-3 || ...
commande-n
Chaque commande s'exécute à son tour aussi longtemps que la commande précédente renvoie false. Au premier retour true, la chaîne de commandes s'arrête (la première commande renvoyant true est la dernière à être exécutée). C'est évidemment l'inverse de la « liste ET ».



# exit
exit 0
0 is the status code, given to the parent and stored in $?



# case
Each case is an expression matching a pattern
case EXPRESSION in CASE1) COMMAND-LIST;; CASE2) COMMAND-LIST;; ... CASEN) COMMAND-LIST;; esac

case $space in
[1-6]*)
  Message="All is quiet."
  ;;
[7-8]*)
  Message="Start thinking about cleaning out some stuff.  There's a partition that is $space % full."
  ;;
9[1-8])
  Message="Better hurry with that new disk...  One partition is $space % full."
  ;;
99)
  Message="I'm drowning here!  There's a partition at $space %!"
  ;;
*)
  Message="I seem to be running with an nonexistent amount of disk space..."
  ;;
esac



# cut
echo "a%b%c" | cut -d "%" -f 1,3
ac



# echo
-e: interprets backslash-escaped characters.
-n: suppresses the trailing newline.



# read
read [options] NAME1 NAME2 ... NAMEN
-a ANAME	The words are assigned to sequential indexes of the array variable ANAME, starting at 0. All elements are removed from ANAME before the assignment. Other NAME arguments are ignored.
-d DELIM	The first character of DELIM is used to terminate the input line, rather than newline.
-e	readline is used to obtain the line.
-n NCHARS	read returns after reading NCHARS characters rather than waiting for a complete line of input.
-p PROMPT	Display PROMPT, without a trailing newline, before attempting to read any input. The prompt is displayed only if input is coming from a terminal.
-r	If this option is given, backslash does not act as an escape character. The backslash is considered to be part of the line. In particular, a backslash-newline pair may not be used as a line continuation.
-s	Silent mode. If input is coming from a terminal, characters are not echoed.
-t TIMEOUT	Cause read to time out and return failure if a complete line of input is not read within TIMEOUT seconds. This option has no effect if read is not reading input from the terminal or from a pipe.
-u FD	Read input from file descriptor FD.


# for
for NAME [in LIST ]; do COMMANDS; done

for i in `ls /sbin`; do file /sbin/$i | grep ASCII; done

LIST="$(ls *.html)"
for i in "$LIST"; do
     NEWNAME=$(ls "$i" | sed -e 's/html/php/')
     cat beginfile > "$NEWNAME"
     cat "$i" | sed -e '1,25d' | tac | sed -e '1,21d'| tac >> "$NEWNAME"
     cat endfile >> "$NEWNAME"
done


# while
while CONTROL-COMMAND; do CONSEQUENT-COMMANDS; done
break
continue

while [ $i -lt 4 ]
do
xterm &
i=$[$i+1]
done

while true; do
touch pic-`date +%s`.jpg
sleep 300
done

while read ligne; do echo $ligne; done < liste.txt


# until
until TEST-COMMAND; do CONSEQUENT-COMMANDS; done
while true; do
	DISKFUL=$(df -h $WEBDIR | grep -v File | awk '{print $5 }' | cut -d "%" -f1 -)

	until [ $DISKFUL -ge "90" ]; do

        	DATE=`date +%Y%m%d`
        	HOUR=`date +%H`
        	mkdir $WEBDIR/"$DATE"

        	while [ $HOUR -ne "00" ]; do
                	DESTDIR=$WEBDIR/"$DATE"/"$HOUR"
                	mkdir "$DESTDIR"
                	mv $PICDIR/*.jpg "$DESTDIR"/
                	sleep 3600
                	HOUR=`date +%H`
        	done

	DISKFULL=$(df -h $WEBDIR | grep -v File | awk '{ print $5 }' | cut -d "%" -f1 -)
	done

	TOREMOVE=$(find $WEBDIR -type d -a -mtime +30)
	for i in $TOREMOVE; do
		rm -rf "$i";
	done



# Loop and redirection
# This script creates a subdirectory in the current directory, to which old
# files are moved.
# Might be something for cron (if slightly adapted) to execute weekly or
# monthly.

ARCHIVENR=`date +%Y%m%d`
DESTDIR="$PWD/archive-$ARCHIVENR"

mkdir "$DESTDIR"

# using quotes to catch file names containing spaces, using read -d for more
# fool-proof usage:
find "$PWD" -type f -a -mtime +5 | while read -d $'\000' file

do
gzip "$file"; mv "$file".gz "$DESTDIR"
echo "$file archived"
done



#menu
select WORD [in LIST]; do RESPECTIVE-COMMANDS; done


c[arol@octarine testdir] cat private.sh
#!/bin/bash
echo "This script can make any of the files in this directory private."
echo "Enter the number of the file you want to protect:"

select FILENAME in *;
do
     echo "You picked $FILENAME ($REPLY), it is now only accessible to you."
     chmod go-rwx "$FILENAME"
done

[carol@octarine testdir] ./private.sh
This script can make any of the files in this directory private.
Enter the number of the file you want to protect:
1) archive-20030129
2) bash
3) private.sh
#? 1
You picked archive-20030129 (1)
#?

#!/bin/bash
echo "This script can make any of the files in this directory private."
echo "Enter the number of the file you want to protect:"

PS3="Your choice: "
QUIT="QUIT THIS PROGRAM - I feel safe now."
touch "$QUIT"

select FILENAME in *;
do
  case $FILENAME in
        "$QUIT")
          echo "Exiting."
          break
          ;;
        *)
          echo "You picked $FILENAME ($REPLY)"
          chmod go-rwx "$FILENAME"
          ;;
  esac
done
rm "$QUIT"

#sub menu
Any statement within a select construct can be another select loop, enabling (a) submenu(s) within a menu.
By default, the PS3 variable is not changed when entering a nested select loop. If you want a different prompt in the submenu, be sure to set it at the appropriate time(s).




find options | xargs [commands_to_execute_on_found_files]


# function
function FUNCTION { COMMANDS; }
FUNCTION () { COMMANDS; }

echo "This script demonstrates function arguments."
echo

echo "Positional parameter 1 for the script is $1."
echo

test ()
{
echo "Positional parameter 1 in the function is $1."
RETURN_VALUE=$?
echo "The exit code of this function is $RETURN_VALUE."
}

test other_param



#######
# VARIABLE
#######

declare OPTION(s) VARIABLE=value
-a	Variable is an array.
-f	Use function names only.
-i	The variable is to be treated as an integer; arithmetic evaluation is performed when the variable is assigned a value (see Section 3.4.6).
-p	Display the attributes and values of each variable. When -p is used, additional options are ignored.
-r	Make variables read-only. These variables cannot then be assigned values by subsequent assignment statements, nor can they be unset.
-t	Give each variable the trace attribute.
-x	Mark each variable for export to subsequent commands via the environment.

[bob in ~] readonly TUX=penguinpower
[bob in ~] TUX=Mickeysoft
bash: TUX: readonly variable


# array
ARRAY[INDEXNR]=value
ARRAY=(value1 value2 ... valueN)

[bob in ~] ARRAY=(one two three)
[bob in ~] echo ${ARRAY[*]}
one two three
[bob in ~] echo $ARRAY[*]
one[*]
[bob in ~] echo ${ARRAY[2]}
three
[bob in ~] ARRAY[3]=four
[bob in ~] echo ${ARRAY[*]}
one two three four
[bob in ~] unset ARRAY[1]
[bob in ~] echo ${ARRAY[*]}
one three four
[bob in ~] unset ARRAY
[bob in ~] echo ${ARRAY[*]}
<--no output-->


farm_hosts=(web03 web04 web05 web06 web07)

for i in ${farm_hosts[@]}; do
        su $login -c "scp $httpd_conf_new ${i}:${httpd_conf_path}"
        su $login -c "ssh $i sudo /usr/local/apache/bin/apachectl graceful"

done



# chaine de caractères : http://abs.traduc.org/abs-5.0-fr/ch09s02.html
#longueur :
nom="Paul"
${#nom} #retourne 4
echo `expr length $nom` #retourne 4

#extraction :
message="Il fait froid dehors"
echo ${message:3} # retourne fait froid dehors
echo ${message:8:5} # retourne froid
echo ${message:(-6)} # retourne dehors

message="Il fait froid dehors"
echo ${message#Il}   #fait froid dehors
echo ${message#I*d}   #dehors

#remplacer
message="Il fait froid dehors"
echo ${message/froid/chaud}   #Il fait chaud dehors
echo ${message//froid/chaud}   #Il fait chaud dehors(remplace toute les occurences




FICHIER=/chemin/vers/ma/liste/de/noms
while read line; do
   prenom=
   nom=
   for mot in $line; do
      [[ "$mot" =~ "[[:upper:]][[:upper:]]+" ]] && nom="$nom $mot" || prenom="$prenom $mot"
   done
   echo "NOM=$nom, PRENOM=$prenom"
done < "$FICHIER"

~=
# Un opérateur binaire supplémentaire, =~, est disponible, avec la même priorité que == et !=.  Lorsqu'il est utilisé, la  chaîne à  droite  de  l'opérateur  est  considérée comme une expression régulière étendue et est mise en correspondance en conséquence (comme avec regex(3)).  La valeur renvoyée est 0 si la chaîne correspond au motif, et 1 si elle ne correspond pas. Si l'expression  régulière n'est pas syntaxiquement correcte, la valeur de retour de l'expression conditionnelle est 2



######
# grep
######
cathy ~> grep root /etc/passwd
With the first command, user cathy displays the lines from /etc/passwd containing the string root.

cathy ~> grep -n root /etc/passwd
Then she displays the line numbers + line containing this search string.

cathy ~> grep -v bash /etc/passwd | grep -v nologin
With the third command she checks which users are not using bash, but accounts with the nologin shell are not displayed.

cathy ~> grep -c false /etc/passwd
Then she counts the number of accounts that have /bin/false as the shell.

cathy ~> grep -i ps ~/.bash* | grep -v history
# The last command displays the lines from all the files in her home directory starting with ~/.bash, excluding matches containing the string history, so as to exclude matches from ~/.bash_history which might contain the same string, in upper or lower cases. Note that the search is for the string "ps", and not for the command ps.



##############
# REGULAR EXPRESSIONS
##############
.	Matches any single character.
?	The preceding item is optional and will be matched, at most, once.
*	The preceding item will be matched zero or more times.
+	The preceding item will be matched one or more times.
{N}	The preceding item is matched exactly N times.
{N,}	The preceding item is matched N or more times.
{N,M}	The preceding item is matched at least N times, but not more than M times.
-	represents the range if it's not first or last in a list or the ending point of a range in a list.
^	Matches the empty string at the beginning of a line; also represents the characters not in the range of a list.
$	Matches the empty string at the end of a line.
\b	Matches the empty string at the edge of a word.
\B	Matches the empty string provided it's not at the edge of a word.
# ne pas utiliser ceux là \/ mais plutôt ^et $
\<	Match the empty string at the beginning of word.
\>	Match the empty string at the end of word.


# baisc / extended regular expression
In basic regular expressions the metacharacters "?", "+", "{", "|", "(", and ")" lose their special meaning; instead use the backslashed versions "\?", "\+", "\{", "\|", "\(", and "\)".

# Line and word anchors
cathy ~> grep ^root /etc/passwd
From the previous example, we now exclusively want to display lines starting with the string "root"

cathy ~> grep :$ /etc/passwd
If we want to see which accounts have no shell assigned whatsoever, we search for lines ending in ":"

cathy ~> grep export ~/.bashrc | grep '\<PATH'
Yo check that PATH is exported in ~/.bashrc, first select "export" lines and then search for lines starting with the string "PATH", so as not to display MANPATH and other possible paths

cathy ~> grep -w word /etc/fstab
If you want to find a string that is a separate word (enclosed by spaces), it is better use the -w, as in this example where we are looking for the line that contains "word" enclosed by spaces

# Character classes
A bracket expression is a list of characters enclosed by "[" and "]". It matches any single character in that list; if the first character of the list is the caret, "^", then it matches any character NOT in the list. For example, the regular expression "[0123456789]" matches any single digit.
Within a bracket expression, a range expression consists of two characters separated by a hyphen. It matches any single character that sorts between the two characters, inclusive, using the locale''s collating sequence and character set. For example, in the default C locale, "[a-d]" is equivalent to "[abcd]". Many locales sort characters in dictionary order, and in these locales "[a-d]" is typically not equivalent to "[abcd]"; it might be equivalent to "[aBbCcDd]", for example. To obtain the traditional interpretation of bracket expressions, you can use the C locale by setting the LC_ALL environment variable to the value "C".

Character classes can be specified within the square braces, using the syntax [:CLASS:], where CLASS is defined in the POSIX standard and has one of the values
"alnum", "alpha", "ascii", "blank", "cntrl", "digit", "graph", "lower", "print", "punct", "space", "upper", "word"
or "xdigit".
cathy ~> ls [[:digit:]]*
2 cathy
cathy ~> ls -ld [[:upper:]]*
Rtzd

# Wildcards
cathy ~> grep '\<c...h\>' /usr/share/dict/words
se the "." for a single character match. If you want to get a list of all five-character English dictionary words starting with "c" and ending in "h" (handy for solving crosswords)

cathy ~> grep '*' /etc/profile
If you want to find the literal asterisk character in a file or output, use single quotes. Cathy in the example below first tries finding the asterisk character in /etc/profile without using quotes, which does not return any lines. Using quotes, output is generated



#######
# AWK
#######
# awk PROGRAM inputfile(s)
kelly is in ~> ls -l | awk '{ print $5 $9 }'
kelly is in ~> ls -ldh * | grep -v total | awk '{ print "Size is " $5 " bytes for " $9 }'
kelly is in ~> df -h | sort -rnk 5 | head -3 | awk '{ print "Partition " $6 "\t: " $5 " full!" }'

# awk '/REGULAR EXPRESSION/ { PROGRAM }' file(s)
kelly is in ~> df -h | awk '/dev\/sd/ { print $1 "\t :" $5}'
kelly is in ~> ls -l | awk 'BEGIN { print "Files found:\n" } /\<[a|x].*\.conf$/ { print $9 }'
kelly is in ~> ls -l | awk '/\<[a|x].*\.conf$/ { print $9 } END { print "Can I do anything else for you, mistress?" }'

# awk script
kelly is in ~> cat diskrep.awk
BEGIN { print "*** WARNING WARNING WARNING ***" }
/\<[8|9][0-9]%/ { print "Partition " $6 "\t: " $5 " full!" }
END { print "*** Give money for new disks URGENTLY! ***" }

kelly is in ~> df -h | awk -f diskrep.awk
*** WARNING WARNING WARNING ***
Partition /usr : 97% full!
*** Give money for new disks URGENTLY! ***

# FS = field separetor
kelly is in ~> awk 'BEGIN { FS=":" } { print $1 "\t" $5 }' /etc/passwd

kelly is in ~> cat printnames.awk
BEGIN { FS=":" }
{ print $1 "\t" $5 }

kelly is in ~> awk -f printnames.awk /etc/passwd

# output separator
kelly@octarine ~/test> cat test
record1 data1
record2 data2

kelly@octarine ~/test> awk '{ print $1 $2}' test
record1data1
record2data2
kelly@octarine ~/test> awk '{ print $1, $2}' test
record1 data1
record2 data2

# output record separator (between 2 print command)
kelly@octarine ~/test> awk 'BEGIN { OFS=";" ; ORS="\n-->\n" } \
{ print $1,$2}' test
record1;data1
-->
record2;data2
-->

# nb of records
kelly@octarine ~/test> cat processed.awk
BEGIN { OFS="-" ; ORS="\n--> done\n" }
{ print "Record number " NR ":\t" $1,$2 }
END { print "Number of records processed: " NR }

kelly@octarine ~/test> awk -f processed.awk test
Record number 1:
record1-data1
--> done
Record number 2:
record2-data2
--> done
Number of records processed: 2
--> done

# variables
kelly@octarine ~> cat total.awk
{ total=total + $5 }
{ print "Send bill for " $5 " dollar to " $4 }
END { print "---------------------------------\nTotal revenue: " total }

kelly@octarine ~> awk -f total.awk test
Send bill for 2500 dollar to BigComp
Send bill for 2000 dollar to EduComp
Send bill for 10000 dollar to SmartComp
Send bill for 5000 dollar to EduComp
----------------------
otal revenue: 19500


cat nom_du_fichier | grep user | cut -d \" -f 2
awk -F "\"" '{ if ($1="user") print $2}' mon_fichier











# sed
commands :
a\ # Append text below current line.
c\ # Change text in the current line with new text.
d  # Delete text.
i\ # Insert text above current line.
p  # Print text.
r  # Read a file.
s  # Search and replace text.
w  # Write to a file.
options :
-e SCRIPT #  Add the commands in SCRIPT to the set of commands to be run while processing the input
f # Add the commands contained in the file SCRIPT-FILE to the set of commands to be run while processing the input.
-n # Silent mode.
-V # Print version information and exit.

