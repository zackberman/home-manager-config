#!/usr/bin/env bash

# Source: https://dev.to/d4vsanchez/use-1password-ssh-agent-in-wsl-2j6m
#
# I've modified this for Nix by:
#
#   * Moving `export SSH_AUTH_SOCK...` into programs.nix. As a result, this file
#     can be executed directly as a bash script rather than sourced.
#
#   * Replacing "ps -auxww | grep..." with "pgrep -f..." (as suggested
#     by shellcheck)
#
#   * Removed echo calls for quieter shell startup

# Code extracted from https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows/ with minor modifications

# Configure ssh forwarding
# use square brackets to generate a regex match for the process we want but that doesn't match the grep command running it!
ALREADY_RUNNING=$(pgrep -f "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent" >/dev/null; echo $?)
if [[ $ALREADY_RUNNING != "0" ]]; then
    if [[ -S $SSH_AUTH_SOCK ]]; then
        # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
        rm "$SSH_AUTH_SOCK"
    fi
    # setsid to force new session to keep running
    # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then forwards to openssh-ssh-agent on windows
    (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/home/zberman/moop.txt 2>&1
fi
