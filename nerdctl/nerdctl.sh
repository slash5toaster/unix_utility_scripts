#!/usr/bin/env bash

# These must be run at least once for each user
# systemctl --user start dbus
# systemctl --user enable dbus
# containerd-rootless-setuptool.sh install
# containerd-rootless-setuptool.sh install-buildkit
# systemctl --user enable buildkit
# systemctl --user start buildkit

# setup containerd
if [[ ! -e  $HOME/.config/systemd/user/containerd.service ]]; then 
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
