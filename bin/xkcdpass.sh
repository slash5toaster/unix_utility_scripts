#!/usr/bin/env bash

# create xkcd style passwords aka https://xkcd.com/936/

[[ $DEBUG ]] && set -x

#variables
declare -a SPCHARLIST

RNUM=0
ALLGOOD=255
DICTIONARY=/usr/share/dict/words
SPCHARLIST=("@" "#" "$" "%" "^" "&" "+" "_")

# Functions
usageHelp="Usage: ${0##*/}"
defaultHelp=" -h help "
digitsHelp="  -n Number of digits (e.g. -n 3 gives 000-999) defaults to 3, max 10"
spcharHelp="  -s Adds special characters '(${SPCHARLIST[@]})'"
badOptionHelp="Option not recognised"
#---------------------------------------------------------------
printHelpAndExit()
{
  echo "${usageHelp}"
  echo "${digitsHelp}"
  echo "${spcharHelp}"
  exit $1
}

#---------------------------------------------------------------
printErrorHelpAndExit()
{
   echo
   echo "$@"
   echo
   echo
   printHelpAndExit 1
}
#---------------------------------------------------------------

sanitycheck()
{
   if [ -s $DICTIONARY ] && [ -e $DICTIONARY ] ; then
     ALLGOOD=0
   else
     ALLGOOD=4
   fi
   return $ALLGOOD
}

getrandomword()
{
  # pick a random word from the dictionary, 32K*32K = 1 billion
  DICT_COUNT=$(wc -l $DICTIONARY \
               | tr -s ' ' \
               | sed -e 's/^\ //' \
               | cut -d' '  -f1 )
  (( STARTFROMBOTTOM = $RANDOM*$RANDOM%$DICT_COUNT ))
  RWORD="$(tail -n $STARTFROMBOTTOM $DICTIONARY \
           | head -n 1 \
           | sed -e "s/[[:punct:]]//g" \
           | tr '[[:upper:]]' '[[:lower:]]')"
}

getrandomnumber()
{
  #get a random number with digits set by NUMPWR
  NUMPWR=${1:-3}
  (( MAXNUM= 10**$NUMPWR ))
  (( MINNUM = $MAXNUM/10 ))
  while [ $RNUM -lt $MINNUM ] ;
  do
    (( RNUM = $RANDOM*$RANDOM%$MAXNUM ))
  done
  return $RNUM
}

#######################################
while getopts "hn:s" optionName; do
   case "$optionName" in
      h)  printHelpAndExit 0;;
      n)  NUMPWR="$OPTARG";;
      s)  SPCHAR=1;;
      [?])  printErrorHelpAndExit "${badOptionHelp}";;
   esac
done

# validate $NUMPWR is a digit
case $NUMPWR in
    ''|*[!0-9]*) echo "-n must be a digit (less than 10)" ; unset NUMPWR ;;
esac

if [[ ${NUMPWR} -gt 10 ]]; then
  NUMPWR=10
fi

getrandomnumber ${NUMPWR}
getrandomword

RWORD1=$RWORD
RWORD1=$(echo ${RWORD} | tr '[:upper:]' '[:lower:]')

# pick a random word from the dictionary and captialize it
getrandomword
RWORD2=$RWORD
RWORD2=$(echo ${RWORD2:0:1} | tr '[:lower:]' '[:upper:]')${RWORD2:1}

if [[ ${SPCHAR} ]]; then
  echo ${RWORD1}${RNUM}${RWORD2}${SPCHARLIST[ (( $RANDOM%${#SPCHARLIST[@]} )) ]}
else
  echo ${RWORD1}${RNUM}${RWORD2}
fi

# End of file, if this is missing the file is truncated
###################################################################################################
