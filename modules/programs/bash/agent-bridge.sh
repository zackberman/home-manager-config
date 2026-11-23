#!/usr/bin/env bash

# Source: https://dev.to/d4vsanchez/use-1password-ssh-agent-in-wsl-2j6m
#
# I've modified this for Nix by:
#
#   * Moving `export SSH_AUTH_SOCK...` into programs.nix. As a result, this file
#     can be executed directly as a bash script rather than sourced.
#
#   * Replacing the original `ps -auxww | grep` process check with a `flock`
#     held by the listener so concurrent shells start only one bridge. If a
#     socket already exists, `ss` checks for a listener before the script
#     removes it.
#
#   * Removed echo calls for quieter shell startup

# Code extracted from https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows/ with minor modifications

exec 9>"$SSH_AUTH_SOCK.lock"
flock -n 9 || exit 0

if [[ -S $SSH_AUTH_SOCK ]]; then
    listener=$(ss -Hxl "src = $SSH_AUTH_SOCK")
    [[ -z $listener ]] || exit 0
    rm -f -- "$SSH_AUTH_SOCK"
fi

setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"$NPIPERELAY -ei -s //./pipe/openssh-ssh-agent",nofork </dev/null >/dev/null 2>&1 &
