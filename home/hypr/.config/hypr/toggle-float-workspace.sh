#!/usr/bin/env bash
WS_ID=$(hyprctl activeworkspace -j | jq '.id')
STATE_FILE="/tmp/hypr-float-ws-${WS_ID}"
ADDRS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $WS_ID) | .address")

if [ -f "$STATE_FILE" ]; then
    # Disable float rule for new windows
    hyprctl keyword "windowrule[float-ws-${WS_ID}]:enable false"
    # Tile all existing windows
    for addr in $ADDRS; do
        hyprctl dispatch settiled "address:$addr"
    done
    rm "$STATE_FILE"
else
    # Enable float rule for new windows
    hyprctl keyword "windowrule[float-ws-${WS_ID}]:enable true"
    # Float all existing windows
    for addr in $ADDRS; do
        hyprctl dispatch setfloating "address:$addr"
    done
    touch "$STATE_FILE"
fi
