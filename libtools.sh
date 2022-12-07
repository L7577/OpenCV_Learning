#!/bin/bash

# The bash libraries
#
set -eu

use_pipefail() {
set -o pipefail
# if use set -o pipefail , can't run with sh command and Dockerfile RUN 
}

use_debug()
{
# if need debug , set -x
set -x
}

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

err(){
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

check_file(){
local files=$(ls -a | grep "^$1" 2>/dev/null)
	[[ -e ${files} ]]
}


remove_files(){
local filename=($(ls -a | grep "^$@" 2>/dev/null))
if [[ "$#" > "0" ]] && [[ -n "${filename[@]}" ]];
then
   for file in ${filename[@]}; do
   if [[ -e ${file} ]];then
      printf "remove ${file}\n"
#      rm -rf ${file}
   else
      printf "${filename} is not a directory or file ,please check it \n"
   fi
   done
fi

}

check_tool() {
    for tool in "${NEEDED_TOOLS[@]}"
    do
        if ! which ${tool} &>/dev/null ; then
          MISSING_TOOLS+=($tool)
		  printf "${tool}"
        fi
    done
    if [[ ${#MISSING_TOOLS[@]} -gt 0 ]] ; then
	   printf "missing some tools: ${MISSING_TOOLS[@]}\n"
       exit 4
    fi 
}

need_root(){
   if ! [[ "$(id -un 2>/dev/null)" == "root" ]]; then
     err " This bash script need root privileges.  Please use root user or sudo command !"
   exit 1
   fi
}

checking(){
   if [[ "$#" != "0" ]];then
		main $@
   else
        err " No input!  Usage: bash $0 [help] ... "
   fi
}
