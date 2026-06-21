#!/bin/bash
inotifywait -m -e create,modify,close_write ~/.config/waybar/ | while read; do
    killall -SIGUSR2 waybar
done

