#!/bin/bash

SINK_HEADSET=$(pactl list short sinks | grep "Arctis" | awk '{print $2}')
SINK_SPEAKERS=$(pactl list short sinks | grep "pci" | grep "analog-stereo" | awk '{print $2}')

CURRENT_SINK=$(pactl get-default-sink)

if [ "$CURRENT_SINK" == "$SINK_HEADSET" ]; then
    NEW_SINK=$SINK_SPEAKERS
else
    NEW_SINK=$SINK_HEADSET
fi

pactl set-default-sink "$NEW_SINK"

# 5. Move currently playing streams to the new sink (Optional but recommended)
# This ensures music doesn't keep playing on the old device
#pactl list short sink-inputs | awk '{print $1}' | while read stream; do
#    pactl move-sink-input "$stream" "$NEW_SINK"
#done
