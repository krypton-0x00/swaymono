#!/bin/sh
# Per-output workspaces for Sway.
#
# Workspaces are named "<number>:<output>" (e.g. "3:eDP-1"), which gives every
# monitor its own independent set of workspaces 1-10.
#
# Usage:
#   workspace.sh switch <number>   # focus workspace <number> of the focused output
#   workspace.sh move   <number>   # move focused container to that workspace

set -eu

action="${1:-}"
number="${2:-}"

case "$action" in
    switch|move) ;;
    *)
        echo "usage: $0 {switch|move} <workspace-number>" >&2
        exit 2
        ;;
esac

case "$number" in
    ''|*[!0-9]*)
        echo "invalid workspace number: $number" >&2
        exit 2
        ;;
esac

# Output that currently has focus (falls back to the focused workspace's output).
output="$(swaymsg -t get_outputs -r |
    jq -r 'first(.[] | select(.focused) | .name) // empty')"

if [ -z "$output" ]; then
    output="$(swaymsg -t get_workspaces -r |
        jq -r 'first(.[] | select(.focused) | .output) // empty')"
fi

if [ -z "$output" ]; then
    echo "could not determine focused output" >&2
    exit 1
fi

name="${number}:${output}"

case "$action" in
    switch)
        swaymsg "workspace --no-auto-back-and-forth \"$name\"" >/dev/null
        ;;
    move)
        swaymsg "move container to workspace \"$name\"" >/dev/null
        ;;
esac
