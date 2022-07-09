#!/bin/bash
##/bin/sh
set -e # stop on all errors

# Docs:
# https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html

#-----
# VARIABLES
#-----

# multiline variables
CERTIFICATE_SSG_0_ROOT=$(cat <<-END
-----BEGIN CERTIFICATE-----
MIIFkjCCA3qgAwIBAgIQM83GY6BreYxBmx5qMXoxZTANBgkqhkiG9w0BAQsFADBI
kgpeZrNW7Fqa9L+nYzL+8RldB9kP7cXyPyflGey03NaqRpWmJig=
-----END CERTIFICATE-----
END
)

# default value
otherdefaultvar=coucou
echo "${notexistingvar:-defaultvalue}" # defaultvalue
echo "${notexistingvar:-${otherdefaultvar}}" # coucou

# variable substitutionvariable substitution: https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_03.html
# replace string in var
STRING="thisisaverylongname"
echo "${STRING//name/string}" # thisisaverylongstring
echo "$STRING" | sed 's/name/string/g' # thisisaverylongstring

# arithmetic operation
maxSessionMemoryAll=$(( maxSessionMemory > maxSessionMemoryAll ? maxSessionMemory : maxSessionMemoryAll ))
echo "9.45 / 2.327" | bc

# length of var
BASE_GROUP_PATH_LEN
(("BASE_GROUP_PATH_LEN=${#GROUP_FULL_PATH} + 2"))
GROUP_PATH=$(echo "${GROUP_PATH}" | cut -c "${BASE_GROUP_PATH_LEN}-")

# eval
check_mandatory_variables()
{
    for var in DEFECTDOJO_URL DEFECTDOJO_BUILD_NUMBER
    do
        val="$(eval echo -n "\$$var")"
        if [ -z "$val" ]; then echo "Variable $var should be defined"; fi
    done
}

path="/temp/dir/myfile.txt"
# remove pattern at the beggining of the var
filename="${path##*/}"
# remove pattern at the end of the var
dirpath="${path%%"/${filename}"}"
extension="${filename##*.}"
echo "$path $filename $dirpath $extension"

# remove trailing / from url
NEXUS_SOURCE_URL="${NEXUS_SOURCE_URL%%/}"




#---------
# STRING MANIPULATION
#---------

# count number of lines
#cat file | wc -l
< file wc -l

# tail and head used to remove first and last chars
path=$( echo "aaWordaa" | tail -c +2 | head -c -2) 

# sed
engagement_tags="[\"$(echo "${DEFECTDOJO_ENGAGEMENT_TAGS}" | tr ',' '\n' | cut -c1-25 | tr '\n' ',' | sed 's/,*$//' | sed 's/,/","/g')\"]"
PROJECT_PATH_ESCAPED=$(echo "${PROJECT_PATH}" | sed -e "s/\//%2F/g")

# extract part of string from delimiter
VERSION=$(grep -i '^FROM' Dockerfile | tail -1 | cut -d':' -f2)

# replace string
echo "bla blo blouh blo bli" | sed "s/ blo//g"
echo "bla blo blouh blo bli" | tr " " "\n"

# jq
COUNT=$(jq '.count' ${PRODUCT_FILE})
PRODUCT_ID=$(jq --arg DEFECTDOJO_PRODUCT_NAME "$DEFECTDOJO_PRODUCT_NAME" '.results | .[] | select(.name == $DEFECTDOJO_PRODUCT_NAME).id' $PRODUCT_FILE)
TEST_TYPE_ID=$(jq '.results[0].id' ${CURL_OUTPUT})
curl  -x "" -H "Private-Token: $GITLAB_ACCESS_TOKEN" "${GITLAB_INSTANCE}/api/v4/projects/${id}/variables"  | jq -r '[.[] | select(.key | contains("key") or contains("KEY") or contains("token") or contains("TOKEN") or contains("ssh") or contains("SSH") or contains("secret") or contains("SECRET"))]'
RUNNER_DETAILS=$(curl -s "${GITLAB_URL}/api/v4/runners/${RUNNER_ID}?private_token=${GITLAB_PRIVATE_TOKEN}" \
		| jq --raw-output '{ "id": .id, "name": .name, "description": .description, "active": .active, "online": .online, "status": .status, "run_untagged": .run_untagged, "version": .version, "tag_list": [ .tag_list[] ] | join(", "), "projects": [ .projects[] | .web_url? ] | join(", "), "groups": [ .groups[] | .web_url? ] | join(", ") }')
ALL_SUBGROUPS=$(curl -s "${BASE_URL}api/v4/groups/${GROUP_ID}/subgroups?private_token=${GITLAB_PRIVATE_TOKEN}&per_page=999" \
		| jq --raw-output --compact-output ".[] | { "path": .full_path, "avatar": .avatar_url, "id": .id }")
GROUP_PATH=$(echo "${GROUP}" | jq -r ".path")

# grep
# grep -E treats ^ $ +, ?, |, (, and ) as meta-characters.
# better use -E than -P, more compatibility
nbRequests=$(echo "${status}" | grep -oE '"requests"\s*:\s*[0-9]+' | head -1 | grep -oE '[0-9]+')

# extract json value without JQ
nbRequests=$(echo "{\"studd\":\"coucou\",\"requests\":89}" | grep -oE '"requests"\s*:\s*[0-9]+' | head -1 | grep -oE '[0-9]+')

extension="$(echo "${filepath}" | grep -oE '[^.]*$')"



#---------
# pipe redirections
#---------

# redirect both std (1) and err (2) stream
echo "will not display anything" &> /dev/null

# redirect err (2) to nothing
rm notexist 2> /dev/null

# redirect 2 to std output
where java 2>&1

# refirect std output to err output
echo 'Error: oops' >&2

# redirect command output to variable or file
series | of | commands | (read string; mystic_command --opt "$string" /path/to/file) | handle_mystified_file
mystic_command --opt "$(series | of | commands)" /path/to/file | handle_mystified_file

# using process substitution - Process substitution allows a process’s input or output to be referred to using a filename
vimdiff /etc/sysconfig/iptables <(iptables-save)
read -r myvar < <(printf "coucou\nderp" | head -n 1)
echo $myvar
# basically <(printf "coucou\nderp") is equal to passing a file path containing "coucou\nderp"
# example to view the lines unique to file a and file b
comm -3 <(sort a | uniq) <(sort b | uniq)


#---------
# TESTS
#---------

# command exists
if ! command -v java &> /dev/null; then echo "java is not a command"; fi

# test if a variable is set
echo "${TESTVAR:?"The variable TESTVAR does not exist..."}"
echo "TESTVAR is set, we can proceed."
[ -n "${TESTVAR}" ] && echo "TESTVAR is defined"
[ -z "${TESTVAR}" ] && echo "TESTVAR is blank or undefined"

# files/dir
[ -f "myfile" ] && echo "myfile exists"
[ -d "mydir" ] && echo "mydir exists"
[ -L "mylink" ] && echo "my link exists"

# is root
[ "$EUID" == "0" ] && echo "im groot"

# is host reachable
if ping -c 1 "${PROXY_HOST}" &> /dev/null; then echo "reachable"; fi

# variable contains a string
# wildcard
if [[ "$STR" == *"$SUB"* ]]; then
  echo "It's there."
fi
# regex
if [[ "$STR" =~ .*"$SUB".* ]]; then
  echo "It's there."
fi
# using grep
if grep -q "$SUB" <<< "$STR"; then
  echo "It's there"
fi



#-----------
# LOOPS and ARRAYS
#-----------

# loop over number
i=0
while [[ $i -lt 5 ]]
do
  echo "Number: $i"
  ((i=i+1))
  if [[ $i -eq 2 ]]; then
    break
  fi
  continue
done
echo 'All Done!'


# loop on files matching pattern (works with spaces in name)
find . -type f -iname "*.mustache" |
while read -r file; do
    echo "$file"
done

# find files and apply a command: {} represents the file path
find . -type f -iname "*.mustache" -exec rm {} \;

# dates
echo "now: $(date +%Y-%m-%d_%H.%M.%S)"

# output to console and to file
echo "coucou" | tee -a "myfile.txt"

# arrays
agentsArray=($(echo "${agents}" | grep -oP '"agentId"\s*:\s*"[a-zA-Z0-9_-]+"'))
myArray=( val1 val2 "val3 with spaces" )
printf "Group file in Linux or Unix: %s\n" "${myArray[1]}"

# associative arrays
declare -A fruits
fruits[south]="Banana"
fruits[north]="Orange"
fruits[west]="Passion Fruit"
fruits[east]="Pineapple"
printf "fruit: %s\n" "${fruits[south]}"

# loop over array
for i in "${fruits[@]}"
do
   echo "$i"
done

# lenght of an array
length=${#myArray[@]}
echo "Bash array '\${myArray}' has total ${length} element(s) (length)"

# for loop on array
for (( j=0; j<length; j++ ));
do
  printf "Current index %d with value %s\n" "$j" "${myArray[$j]}"
done

# read .csv
echo "
#Company name|Address|Telephone|Email|Data1|Data2
   Foo bar  |Foo road  |123-5767|foo@example.com|32535|56568
  DB CO      Foo  |   Street somewhere |   123-5767|   bar@example.com|32535|56568
"
# Removing all white spaces from input string
# I am reading data into array for further processing if needed and it is safe 
trim_all_white_spaces() {
	mapfile -t input_array<<<"$*"
	[[ ${#input_array[@]} -eq 0 ]] && { echo "Input data missing"; exit 1; }
	set -- ${input_array[@]}
	printf '%s\n' "$*"
} 
[ ! -f "$input" ] && { echo "$0 - $input file not found"; exit 1; }
 while IFS='|' read -r cname cadd ctel cemail cd1 cd2
do 
	# ignore comment line 
	# see if $cname starts with '#' and if so read next line
	[[ $cname == \#* ]] && continue 
	echo "|$( trim_all_white_spaces "$cname" )|"; 
	echo "|$( trim_all_white_spaces "$cadd" )|"; 
done < "$input"



#-----------
# FLOW
#-----------

# case
case $1 in
    "apt")
        if $SUDO ping -c 1 "${PROXY_HOST}" &> /dev/null; then
            enable_apt
        fi
        ;;
    "disable")
        disable_all
        ;;
    *)
        usage
        ;;
esac


#-----------
# FILE MANIPULATION
#-----------

# write to file from script with sudo
SUDO=''
if [[ "$EUID" != 0 ]]; then # test if not root
    SUDO='sudo'
fi
$SUDO tee -a /etc/sudoers.d/proxy-ssg > /dev/null <<EOT
ALL ALL = (root) NOPASSWD: /usr/local/bin/proxy-ssg
EOT

# get realpath of file
java_path="$(realpath "$(command -v java)")"
java_home_dir="$(realpath "${java_path: 0:-4}..")"

# compare 2 directories
diff <(ls $first_directory) <(ls $second_directory)

#-----------
# CURL
#-----------

check_rc()
{   
    if [ "$1" != "0" ] && [ -n "$1" ]; then
        shift
        printf "${COLOR_RED}[ERRO] %s${COLOR_DEFAULT}" "$*"
        exit 1
    fi
}

# Send a curl and correctly handle error + status code
# Usage:
# kurl ACCEPTABLE_STATUS_CODES [CURL_OPTIONS] URL
# Example:
# kurl 200,400 --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}a" "${GITLAB_URL}/api/v4/runners"
# Output:
# body of the response or error message describing the issue if the command failed
# return code:
# 0 if ok, response status code /10 or error code otherwise
kurl()
{   
    local acceptable_status_codes="${1}"
    shift
    local tmp_file
    if command -v mktemp &> /dev/null; then tmp_file="$(mktemp)"; else tmp_file="/tmp/kurl-output"; fi
    local status_code
    status_code=$(curl -s --show-error -o "${tmp_file}" -w "%{http_code}" "$@" || echo $?)
    local exit_code
    if [[ ",${acceptable_status_codes}," == *",${status_code},"* ]]; then
        cat "${tmp_file}"
        exit_code=0
    else
        printf "Expected code %s but got %s, here is the response body:\n%s" "${acceptable_status_codes}" "${status_code}" "$(cat "${tmp_file}")"
        ((exit_code=0+status_code/10))
    fi
    rm -f "${tmp_file}" &> /dev/null
    return $exit_code
}

json=$(kurl 200,400 --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" "${GITLAB_URL}/api/v4/runners") || rc=$?
check_rc "$rc" "$json"


# post data
function create_product_generate_post_data
{
    cat <<EOF
    {
          "name":"${DEFECTDOJO_PRODUCT_NAME}",
          "description": "${DEFECTDOJO_PRODUCT_DESCRIPTION}",
          "prod_type": "${DEFECTDOJO_PRODUCT_TYPE_ID}"
    }
EOF
}
curl --fail -s -X PUT --show-error -o ${ENGAGEMENTS_FILE} \
    --header "Authorization: Token ${DEFECTDOJO_TOKEN}" \
    "${DEFECTDOJO_URL}/api/v2/engagements/${ENGAGEMENT_ID}/" \
    --data "$(create_product_generate_post_data)"

# retry
CURL_RETRY='--connect-timeout 5 --max-time 10 --retry 3 --retry-delay 5 --retry-max-time 60'

# download a file
curl --fail -s -X GET --show-error -o localfile $URL


#-----------
# MISC
#-----------

# get max value from file
sessionsMemory=$(grep -oP '"SessionMemory"\s*:\s*[0-9]+' myfile | grep -oP '[0-9]+')
maxSessionMemory=$(echo "${sessionsMemory[*]}" | sort -nr | head -n1)
maxSessionMemoryAll=$(( maxSessionMemory > maxSessionMemoryAll ? maxSessionMemory : maxSessionMemoryAll ))

# Check return code
# $0: the return code
# $1+ : the error message to display in case of error
check_RC()
{   
  if [ "$1" != "0" ]; then
    shift
    do_log_error "$*"
    exit 1
  fi
}
check_RC $? "Error while checking if the product $PRODUCT_ID exists. Response: '$(cat ${PRODUCT_FILE})'"

# colors
COLOR_DEFAULT="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[32m"
COLOR_CYAN="\033[0;36m"
COLOR_GRAY="\033[0;37m"
printf "${COLOR_GRAY}[DEBG] %s${COLOR_DEFAULT}" "coucou"
printf "${COLOR_CYAN}[INFO] %s${COLOR_DEFAULT}" "coucou"
printf "${COLOR_RED}[ERRO] %s${COLOR_DEFAULT}" "coucou"
printf "${COLOR_GREEN}[SUCC] %s${COLOR_DEFAULT}" "coucou"
echo -e "${COLOR_GRAY}[DEBG] coucou${COLOR_DEFAULT}"


# progress bar
ProgressBar() {
# Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:                           
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"

}