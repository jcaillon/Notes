# LINUX

## Bash Commands

uname -a    Show system and kernel
head -n1 /etc/issue Show distribution
mount   Show mounted filesystems
date    Show system date
uptime  Show uptime
whoami  Show your username
man command Show manual for command

## Bash Shortcuts

| CTRL-c   | Stop current command                         |
|----------|----------------------------------------------|
| CTRL-z   | Sleep program                                |
| CTRL-a   | Go to start of line                          |
| CTRL-e   | Go to end of line                            |
| CTRL-u   | Cut from start of line                       |
| CTRL-k   | Cut to end of line                           |
| CTRL-r   | Search history                               |
| !!       | Repeat last command                          |
| !abc     | Run last command starting with abc           |
| !abc:p   | Print last command starting with abc         |
| !$       | Last argument of previous command            |
| ALT-.    | Last argument of previous command            |
| !*       | All arguments of previous command            |
| ^abc^123 | Run previous command, replacing abc with 123 |

## Bash Variables

| env Show environment variables             |
|--------------------------------------------|
| echo $NAME  Output value of $NAME variable |
| export NAME=value   Set $NAME to value     |
| $PATH   Executable search path             |
| $HOME   Home directory                     |
| $SHELL  Current shell                      |

## IO Redirection

cmd < file
Input of cmd from file
cmd1 <(cmd2)
Output of cmd2 as file input to cmd1
cmd > file
Standard output (stdout) of cmd to file
cmd > /dev/null
Discard stdout of cmd
cmd >> file
Append stdout to file
cmd 2> file
Error output (stderr) of cmd to file
cmd 1>&2
stdout to same place as stderr
cmd 2>&1
stderr to same place as stdout
cmd &> file
Every output of cmd to file
cmd refers to a command.

## Pipes

cmd1 | cmd2
stdout of cmd1 to cmd2
cmd1 |& cmd2
stderr of cmd1 to cmd2

## Command Lists

cmd1 ; cmd2
Run cmd1 then cmd2
cmd1 && cmd2
Run cmd2 if cmd1 is successful
cmd1 || cmd2
Run cmd2 if cmd1 is not successful
cmd &
Run cmd in a subshell

## Directory Operations

pwd
Show current directory
mkdir dir
Make directory dir
cd dir
Change directory to dir
cd ..	Go up a directory
ls
List files

## ls Options

-a	Show all (including hidden)
-R	Recursive list
-r	Reverse order
-t	Sort by last modified
-S	Sort by file size
-l	Long listing format
-1	One file per line
-m	Comma-¬sep¬arated output
-Q	Quoted output

## Search Files

grep pattern files
Search for pattern in files
grep -i	Case insens¬itive search
grep -r	Recursive search
grep -v	Inverted search
grep -o	Show matched part of file only
find /dir/ -name name*
Find files starting with name in dir
find /dir/ -user name	Find files owned by name in dir
find /dir/ -mmin num	Find files modifed less than num minutes ago in dir
whereis command
Find binary / source / manual for command
locate file
Find file (quick search of system index)

## File Operations

touch file1
Create file1
cat file1 file2
Concat¬enate files and output
less file1
View and paginate file1
file file1
Get type of file1
cp file1 file2
Copy file1 to file2
mv file1 file2
Move file1 to file2
rm file1
Delete file1
head file1
Show first 10 lines of file1
tail file1
Show last 10 lines of file1
tail -F file1
Output last lines of file1 as it changes

## Watch a Command

watch -n 5 'ntpq -p'
Issue the 'ntpq -p' command every 5 seconds and display output

## Process Management

ps
Show snapshot of processes
top
Show real time processes
kill pid
Kill process with id pid
pkill name
Kill process with name name
killall name
Kill all processes with names beginning name
File Permis¬sions
chmod 775 file
Change mode of file to 775
chmod -R 600 folder
Recurs¬ively chmod folder to 600
chown user:group file
Change file owner to user and group to group

## File Permission Numbers

First digit is owner permis¬sion, second is group and third is everyone.
Calculate permission digits by adding numbers below.
4	read (r)
2	write (w)
1	execute (x)

## Text manipulation

sed 's/string1/string2/g'	Replace string1 with string2
sed 's/\(.*\)1/\12/g'	Modify anystring1 to anystring2
sed '/^ *#/d; /^ *$/d'	Remove comments and blank lines
sed ':a; /\\$/N; s/\\\n//; ta'	Concatenate lines with trailing \
sed 's/[ \t]*$//'	Remove trailing spaces from lines
sed 's/\([`"$\]\)/\\\1/g'	Escape shell metacharacters active within double quotes
seq 10 | sed "s/^/      /; s/ *\(.\{7,\}\)/\1/"	Right align numbers
seq 10 | sed p | paste - -	Duplicate a column
sed -n '1000{p;q}'	Print 1000th line
sed -n '10,20p;20q'	Print lines 10 to 20
sed -n 's/.*<title>\(.*\)<\/title>.*/\1/ip;T;q'	Extract title from HTML web page
sed -i 42d ~/.ssh/known_hosts	Delete a particular line
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n	Sort IPV4 ip addresses
echo 'Test' | tr '[:lower:]' '[:upper:]'	Case conversion
tr -dc '[:print:]' < /dev/urandom	Filter non printable characters
tr -s '[:blank:]' '\t' </proc/diskstats | cut -f4 	cut fields separated by blanks
history | wc -l 	Count lines
seq 10 | paste -s -d ' '	Concatenate and separate line items to a single line
 file searching
alias l='ls -l --color=auto'	quick dir listing. See also l
ls -lrt	List files by date. See also newest and find_mm_yyyy
ls /usr/bin | pr -T9 -W$COLUMNS	Print in 9 columns to width of terminal
find -name '*.[ch]' | xargs grep -E 'expr' 	Search 'expr' in this dir and below. See also findrepo
find -type f -print0 | xargs -r0 grep -F 'example' 	Search all regular files for 'example' in this dir and below
find -maxdepth 1 -type f | xargs grep -F 'example' 	Search all regular files for 'example' in this dir
find -maxdepth 1 -type d | while read dir; do echo $dir; echo cmd2; done  	Process each item with multiple commands (in while loop)
find -type f ! -perm -444  	Find files not readable by all (useful for web site)
find -type d ! -perm -111 	Find dirs not accessible by all (useful for web site)
locate -r 'file[^/]*\.txt'  	Search cached index for names. This re is like glob *file*.txt
look reference  	Quickly search (sorted) dictionary for prefix
grep --color reference /usr/share/dict/words 	Highlight occurances of regular expression in dictionary
