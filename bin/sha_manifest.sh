#!/usr/bin/env bash

[[ $DEBUG ]] && set -x
set -e
set -u
IFS=$'\n\t'
# VERBOSE=0

#---------------------------------------------------------------
PARALLELBIN=$(type -p parallel || echo "nada")
SHASUMBIN=$(type -p sha1sum || type -p shasum )
PARALLEL_OPTS="--xarg"

# set TMP to TMPDIR else fall back to /tmp
if [[ -d /dev/shm/ ]]; then
  TMP="/dev/shm/"
fi
TMP=${TMP:-$TMPDIR}
TMP=${TMP:-"/tmp"}

#check to see if we have perl installed - a requirement for parallel
if [[ ! $(type -p perl) ]]; then
   PARALLELBIN="nada"
fi

# default to current directory if one isn't given on the command line.  We only do the first labeled
TARGETDIR=${1:-"."}
if [ -e "${TARGETDIR}" ] ; then
   pushd "${TARGETDIR}" #> /dev/null
   # get the foldername and strip the leading period
   FOLDERNAME=$(basename $(pwd))
   FOLDERNAME=${FOLDERNAME/#./}

   if [[ -e ${PARALLELBIN} ]]; then
     find . -depth -type l -or -type f \
       | grep -iv sha1$ \
       | grep -iv "*.dmg$" \
       | grep -iv "\.DocumentRevisions-V100" \
       | grep -iv "\.DS_Store" \
       | grep -iv "\.git" \
       | grep -iv "\.snapshots" \
       | grep -iv "\.svn" \
       | grep -iv "\.venv" \
       | grep -iv "\.TemporaryItems" \
       | grep -iv "\.Trashes" \
       | ${PARALLELBIN} -j 60 ${PARALLEL_OPTS} "${SHASUMBIN}" {} \
       | sed -e 's/\.\///' \
       | sort -k2 -T "$TMP" > "${FOLDERNAME}".sha1
  else
     for f in $( find . -depth -type l -or -type f \
                 | grep -iv sha1$ \
                 | grep -iv "*.dmg$" \
                 | grep -iv "\.DocumentRevisions-V100" \
                 | grep -iv "\.DS_Store" \
                 | grep -iv "\.git" \
                 | grep -iv "\.snapshots" \
                 | grep -iv "\.svn" \
                 | grep -iv "\.venv" \
                 | grep -iv "\.TemporaryItems" \
                 | grep -iv "\.Trashes" \
                 | sort
               ); do
       ${SHASUMBIN} "${f}" \
       | sed -e 's/\.\///' \
       | sort -k2 > "${FOLDERNAME}".sha1
     done
  fi

   popd #> /dev/null
else
   echo "${TARGETDIR} does not exist"
fi

# End of file, if this is missing the file is truncated
###################################################################################################
