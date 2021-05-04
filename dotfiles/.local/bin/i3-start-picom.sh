#!/usr/bin/env bash

# If picom is running, kill it to prevent multiple instances
if ps -A | grep picom; then
    killall -q picom
fi

# Load picom
picom   --config $HOME/.config/picom/picom.conf #\
#	--experimental-backends                 \
#	--backend glx                           \
#	--xrender-sync-fence