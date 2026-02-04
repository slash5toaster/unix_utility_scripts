#!/usr/bin/env bash

# These must be run at least once for each user
# systemctl --user start dbus
# systemctl --user enable dbus
# containerd-rootless-setuptool.sh install
# containerd-rootless-setuptool.sh install-buildkit
# systemctl --user enable buildkit
# systemctl --user start buildkit

# setup containerd
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}

if [[ ! -e  ${HOME}/.config/systemd/user/containerd.service ]]; then
    export XDG_RUNTIME_DIR
    containerd-rootless-setuptool.sh install
    containerd-rootless-setuptool.sh install-buildkit
fi

declare -a service_list 
service_list=(
    dbus
    buildkit
)

for svc in "${service_list[@]}"; 
do 
    if [[ $(systemctl --user is-active "${svc}") ]]; then
        : # noop
    else 
        systemctl --user start "${svc}"
        systemctl --user enable "${svc}"
    fi
done
