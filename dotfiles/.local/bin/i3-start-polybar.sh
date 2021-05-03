#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

desktop=$(echo $DESKTOP_SESSION)

case $desktop in
	i3)
	if type "xrandr" > /dev/null; then
		for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
			echo "---" | tee -a /tmp/poly-general.log
			MONITOR=$m polybar --reload general >>/tmp/poly-general.log 2>&1 &
		done
	else
		polybar --reload general >>/tmp/poly-general.log 2>&1 &
	fi
	;;
	*)
	echo "Polybar cant start on this desktop session {${desktop}}"
	;;
esac

echo "Bars launched..."
