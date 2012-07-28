#!/bin/sh

if [ "$2" = "suspend" ]; then
  echo "<3>Dracut: found ToI/suspend signature in $1, trying to resume" > /dev/kmsg
  OLDDEV=$(cat /sys/power/tuxonice/resume)
  echo "swap:$1" >/sys/power/tuxonice/resume
  echo 1 >/sys/power/tuxonice/do_resume
  echo "<3>Dracut: no resume operation occured, restoring old value ($OLDDEV)" >/dev/kmsg
  echo "$OLDDEV" >/sys/power/tuxonice/resume
elif [ "$2" = "swap" ]; then
  echo "<3>Dracut: found swap signature in $1, using for ToI" > /dev/kmsg
  CURDEV=$(cat /sys/power/tuxonice/resume)
  [ -z "$CURDEV" ] && echo "swap:$1" >/sys/power/tuxonice/resume
elif [ "$2" = "resume" ]; then
  echo "<3>Dracut: found resume parameter device in $1, trying to resume" > /dev/kmsg
  OLDDEV=$(cat /sys/power/tuxonice/resume)
  resume_dev="$1"
  resume_type="$(echo $OLDDEV | sed 's/\([^:]*\):\([^:]*\):\([^:]*\)/\1/')"
  resume_file="$(echo $OLDDEV | sed 's/\([^:]*\):\([^:]*\):\([^:]*\)/\3/')"
  resume="$resume_type:$1"
  if [ -n $resume_file ]; then
    resume="$resume:$resume_file"
  fi
  echo "$resume" >/sys/power/tuxonice/resume
  echo 1 >/sys/power/tuxonice/do_resume
  echo "<3>Dracut: no resume operation occured, restoring old value ($OLDDEV)" >/dev/kmsg
  echo "$OLDDEV" >/sys/power/tuxonice/resume
fi

