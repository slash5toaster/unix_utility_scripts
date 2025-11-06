#!/usr/bin/env bash

type -p parallel > /dev/null || (echo "Can't run - need to have parallel https://www.gnu.org/software/parallel/"  && exit)

THISFOLDER=$(basename "$(pwd)"|sed -e 's/^\.//')
if [[ -e ${THISFOLDER}.sha1 ]]; then
  # shellcheck disable=SC2002
  cat "${THISFOLDER}.sha1" \
  | cut -d ' ' -f1 \
  | sort \
  | uniq -c \
  | sort -nr \
  | tr -s ' ' \
  | grep -v '^ 1' \
  | tr -s ' ' \
  | cut -d' ' -f 3 \
  | parallel "grep {} ${THISFOLDER}.sha1" \
  | tee "${THISFOLDER}".dup.sha1
else
  exit 44
fi

# End of file, if this is missing the file is truncated
###################################################################################################
