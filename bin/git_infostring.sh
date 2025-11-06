#!/usr/bin/env bash

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# set bash prompt to show the git branch
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
git_infostring()
{
  local COMMIT_AHEAD=""
  local COMMIT_BEHIND=""
  local COMMIT_COUNT=0
  local COMMIT_FLAG=""
  local CONFLICT_COUNT=0
  local DIRTY_COUNT=0
  local DIRTY_FLAG=""
  local DIRTY_OR_STAGED="STAGED"
  local GIT_BRANCH=""
  local GIT_INFO=""
  local STAGED_COUNT=0
  local TAG_NAME=""
  local UNSTAGED_COUNT=0
  # maps to lines in the git branch output, N.B. 4 if on remote,
  local branch_oid=0
  local branch_head=1
  local branch_upstream=2
  local branch_ab=3
  local branch_ref

  declare -a PORCELAIN_STATUS

  # Get status information - see https://git-scm.com/docs/git-status
  # for a detailed description of git status v2 format
  # see mapfile at https://linux.die.net/man/1/bash

  mapfile PORCELAIN_STATUS < <(git status --porcelain=v2 \
                                          --untracked-file=no \
                                          --branch 2>/dev/null )
  # if we have no status then return
  if [[ -z ${PORCELAIN_STATUS[*]} ]]; then
     [[ $DEBUG_BGI ]] && echo "not in repo"
     return
  fi

  if [[ $DEBUG_BGI ]]; then
    echo "status ${PORCELAIN_STATUS[*]}"
    for i in "${!PORCELAIN_STATUS[@]}"; do
      echo "$i" "${PORCELAIN_STATUS[$i]}"
    done
  fi

  GIT_BRANCH=$(echo "${PORCELAIN_STATUS[$branch_head]}" | cut -d ' ' -f 3 | tr -d '()')

  # if we have a long branch name, truncate it
  if [[ ${#GIT_BRANCH} -gt 20 ]]; then
    GIT_BRANCH="${GIT_BRANCH:0:14}...${GIT_BRANCH: -4}"
    [[ $DEBUG_BGI ]] && echo "truncated branch to ${GIT_BRANCH}"
  fi

  # Sanity check to see if we need to do anything at all
  if [[ ${#GIT_BRANCH} -gt 0 ]] ; then
    # relies on branch.ab and converts to a number - if anything other than 00
    # we're not in sync.

    # determine if an upstream is set, if not we are detached
    if [[ $(echo "${PORCELAIN_STATUS[@]}" | grep -c "branch.upstream") -gt 0 ]]; then
      if [[ $(echo "${PORCELAIN_STATUS[$branch_ab]}" | cut -d ' ' -f 3 ) -gt 0 ]]; then
        COMMIT_AHEAD=$(echo "${PORCELAIN_STATUS[$branch_ab]}" \
                       | cut -d ' ' -f 3)
        COMMIT_BEHIND=$(echo "${PORCELAIN_STATUS[$branch_ab]}" \
                        | cut -d ' ' -f 4)
        COMMIT_COUNT=$(( ${COMMIT_AHEAD} - ${COMMIT_BEHIND} ))
      fi
    else
      branch_ref=$(echo "${PORCELAIN_STATUS[$branch_oid]}" | cut -d ' ' -f 3)
      # catch initial branch ref
      if [[ $branch_ref != "(initial)" ]]; then
        TAG_NAME=$(git tag --points-at "$branch_ref" | head -n 1)
        if [[ -n $TAG_NAME ]] ; then
          COMMIT_FLAG=" tags/${TAG_NAME}"
        else
          COMMIT_FLAG=" ${branch_ref:0:7}"
        fi
      fi
    fi

    # count the files that are in the queue
    # needed inverse logic for counting staged/unstaged changes.
    for i in "${!PORCELAIN_STATUS[@]}"; do
      # skip the branch lines that start with #
      [[ $DEBUG_BGI ]] && echo "${i}" "${PORCELAIN_STATUS[$i]}"
      if [[ $(echo ${PORCELAIN_STATUS[$i]} | grep -c ^\#) -eq 0 ]]; then
        echo ${PORCELAIN_STATUS[$i]} \
             | egrep -c "^1|^2|^u" >/dev/null \
             && ((DIRTY_COUNT++))
        echo ${PORCELAIN_STATUS[$1]} \
             | grep -c '^u' > /dev/null \
             && ((UNMERGECOUNT++))
        echo ${PORCELAIN_STATUS[$i]} \
             | cut -d' '  -f2 \
             | grep -cv '^\.' > /dev/null \
             && ((STAGED_COUNT++))
        echo ${PORCELAIN_STATUS[$i]} \
             | cut -d' '  -f2 \
             | grep -cv '\.$' > /dev/null \
             && ((UNSTAGED_COUNT++))
        echo ${PORCELAIN_STATUS[$i]} \
             | cut -d' '  -f2 \
             | grep -c 'UU' > /dev/null \
             && ((CONFLICT_COUNT++))
      fi
      [[ $DEBUG_BGI ]] && echo "--- dirty ${DIRTY_COUNT} unmerged ${UNMERGECOUNT} staged ${STAGED_COUNT} unstaged ${UNSTAGED_COUNT} conflict ${CONFLICT_COUNT} ${PORCELAIN_STATUS[$branch_upstream]}"
    done

    # Add the unstaged and unmerged
    UNSTAGED_COUNT=$(( ${UNMERGECOUNT} + ${UNSTAGED_COUNT} ))

    if [[ ${DIRTY_COUNT} -gt 0 ]]; then
      # change the DIRTY_OR_STAGED flag to what you want - defaults to # of files
       if [[ ${DIRTY_OR_STAGED} == "STAGED" ]]; then
          DIRTY_FLAG=" ${STAGED_COUNT}S-${UNSTAGED_COUNT}U"
          if [[ ${CONFLICT_COUNT} -gt 0 ]]; then
            DIRTY_FLAG="${DIRTY_FLAG}-${CONFLICT_COUNT}C"
          fi
       elif [[ ${DIRTY_OR_STAGED} == "DIRTY" ]]; then
          DIRTY_FLAG=" *"
       else
         DIRTY_FLAG=" ${DIRTY_COUNT}"
       fi
    fi

    if [[ ${COMMIT_COUNT} -ne 0 ]] ; then
       COMMIT_FLAG=" ${COMMIT_AHEAD}${COMMIT_BEHIND}"
    fi

    GIT_INFO="(${GIT_BRANCH}${COMMIT_FLAG}${DIRTY_FLAG})"

    echo "${GIT_INFO}"
  else
    echo "${GIT_INFO}"
  fi

}
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

[[ $DEBUG_BGI ]] && git_infostring "$@"
# PS1="\u@\h:\W \$(git_infostring)\[\033[00m\] % "

###############################################################
# End of File,  if this is missing the file has been truncated
