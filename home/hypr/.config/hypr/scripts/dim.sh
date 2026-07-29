#!/bin/bash
# Gradually dim screen over 3 seconds
TARGET=10
STEPS=30
DELAY=0.1

current=$(brightnessctl g)
max=$(brightnessctl m)
current_pct=$((current * 100 / max))

step=$(( (current_pct - TARGET) / STEPS ))

for ((i=0; i<STEPS; i++)); do
    current_pct=$((current_pct - step))
    [ $current_pct -lt $TARGET ] && current_pct=$TARGET
    brightnessctl -q set "${current_pct}%"
    sleep $DELAY
done

brightnessctl -q set "${TARGET}%"
