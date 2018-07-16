```bash
GIT_MESSAGE_FILE=$(realpath ${SCRIPT_HOOK_DIR}/../.gitmessage.txt)

echo "PARAM... <${THIS_SCRIPT_HOOK}> <$(realpath ${1})> <${2}> <${GIT_MESSAGE_FILE}>"

# exec ${BIN_HOOK_DIR}/clitoe.exe "$@"

CURRENT_BRANCH=$(git branch | grep "^\\*" | cut -d " " -f 2)

# the 2nd argument (COMMIT_SOURCE) equals "message" then the option -m was used for git commit
# it is empty otherwise
if [ "${COMMIT_SOURCE}" == "message" ] ; then 
    echo -e "$(git currentbranch) $(cat ${COMMIT_MSG_FILE})" > ${COMMIT_MSG_FILE}
    exit 0
fi

TEMPLATE_CONTENT=$(cat ${GIT_MESSAGE_FILE} | sed -e "s/@{BRANCH}/${CURRENT_BRANCH}/g" | sed -e "s/@{SHORT_MESSAGE}//g" | sed -e "s/@{BODY}//g")

echo -e "${TEMPLATE_CONTENT}" > ${COMMIT_MSG_FILE}
```