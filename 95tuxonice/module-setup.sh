#!/bin/bash

install() {
  # install userui
  [ -x /sbin/tuxoniceui ] && inst tuxoniceui
  [ -x /sbin/tuxoniceui_text ] && inst tuxoniceui_text
  
  # install splash graphics if exists
  my_inst_dir() {
    inst_dir $1
    for i in $1/*; do
      if [ -d "$i" ]; then
        my_inst_dir "$i"
      else
        inst "$i"
      fi
  done
  }
  [ -e /etc/splash/tuxonice ] && my_inst_dir /etc/splash/tuxonice
  [ -e /etc/splash/suspend2 ] && my_inst_dir /etc/splash/suspend2
  
  inst_hook pre-udev 30 "$moddir/tuxonice-prepare.sh"
  inst_hook pre-mount 30 "$moddir/tuxonice-lvmfix.sh"
  inst "$moddir"/tuxonice-resumecheck.sh /sbin/tuxonice-resumecheck.sh
}
