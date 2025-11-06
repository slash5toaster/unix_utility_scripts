#!/usr/bin/env bash

#sets up the virtual Environment  N.B.  This *must* use python3

VENV_NAME=".venv"

# make sure python3 is availabe
if [[ $(type -p python3) ]]; then
  PY3_BIN=$(type -p python3)
else
  echo "python3 is not available, Please install it to continue"
  exit 4
fi

if [[ -e "${VENV_NAME}/bin/activate" ]]; then
  echo -e "Run \n\t source ${VENV_NAME}/bin/activate \n\nto start your virtual environment"
else
  ${PY3_BIN} -m venv ${VENV_NAME}
  source "${VENV_NAME}/bin/activate"
  if [[ -e requirements.txt ]]; then
    pip3 install --upgrade -r requirements.txt
  else
    echo "Requirements file not found, please manually install pip packages"
  fi
fi

# End of file, if this is missing the file is truncated
###################################################################################################
