#!/bin/sh
# prepare parameters for ToI

. /lib/dracut-lib.sh
info "TuxOnIce premodule started"

# first check if ToI support is available
if [ ! -d /sys/power/tuxonice ]; then
  info "Kernel has no tuxonice support, aborting"
  return 0
else
  info "Kernel has tuxonice support, continuing"
fi

if getarg noresume2; then
  warn "noresume2 was specified, aborting"
  return 0
fi

# prepare UserUI
info "Setting up UserUI"
UI=""
UIOPTS=""

if [ -e "/sbin/tuxoniceui" ]; then
  UI="/sbin/tuxoniceui"
elif [ -e "/sbin/tuxoniceui_text" ]; then
  UI="/sbin/tuxoniceui_text"
fi

if [ -e "/sys/class/graphics/fb0/state" -a -e "/etc/splash/tuxonice/" ]; then
  UIOPTS="$UIOPTS -f"
fi

if [ -n "$UI" ]; then
  info "Using $UI with $UIOPTS"
  echo "$UI $UIOPTS" >/sys/power/tuxonice/user_interface/program
  echo 1 >/sys/power/tuxonice/user_interface/enabled
else
  warn "$UI is not available"
  echo 0 >/sys/power/tuxonice/user_interface/enabled
fi

# install udev rule for resume parameter
if resume=$(getarg resume=) && ! getarg noresume; then
  resume_type="$(echo $resume | cut -d':' -f1)"
  resume_dev="$(echo $resume | cut -d':' -f2)"
  resume_file="$(echo $resume | cut -d':' -f3)"
  export resume_type
  export resume_dev
  export resume_file
else
  unset resume
fi

info "Installing udev rule for resume parameter"
case "$resume_dev" in
  LABEL=*) \
    resume_dev="$(echo $resume_dev | sed 's,/,\\x2f,g')"
    {
    echo "SUBSYSTEM==\"block\", ACTION==\"add|change\", ENV{ID_FS_LABEL}==\"${resume_dev#LABEL=}\", " \
         " RUN+=\"/sbin/tuxonice-resumecheck.sh '/dev/%k' 'resume'\"";
    } >> /etc/udev/rules.d/99-tuxonice.rules
    ;;
  UUID=*) \
    {
    echo "SUBSYSTEM==\"block\", ACTION==\"add|change\", ENV{ID_FS_UUID}==\"${resume_dev#UUID=}\", " \
         " RUN+=\"/sbin/tuxonice-resumecheck.sh '/dev/%k' 'resume'\"";
    } >> /etc/udev/rules.d/99-tuxonice.rules
    ;;
  PARTUUID=*) \
    {
    echo "SUBSYSTEM==\"block\", ACTION==\"add|change\", ENV{ID_PART_ENTRY_UUID}==\"${resume_dev#PARTUUID=}\", " \
         " RUN+=\"/sbin/tuxonice-resumecheck.sh '/dev/%k' 'resume'\"";
    } >> /etc/udev/rules.d/99-tuxonice.rules
    ;;
esac


# install udev rule for resuming
info "Installing udev rule for ToI resume"
{
echo "SUBSYSTEM==\"block\", ACTION==\"add|change\", ENV{ID_FS_TYPE}==\"suspend|swsuspend|swsupend\", " \
     " RUN+=\"/sbin/tuxonice-resumecheck.sh '/dev/%k' 'suspend'\"";
} >> /etc/udev/rules.d/99-tuxonice.rules

# install udev rule to add swapdevice as hibernation target
info "Installing udev rule for ToI swap detection"
{
echo "SUBSYSTEM==\"block\", ACTION==\"add|change\", ENV{ID_FS_TYPE}==\"swap\", " \
     " RUN+=\"/sbin/tuxonice-resumecheck.sh '/dev/%k' 'swap'\"";
} >> /etc/udev/rules.d/99-tuxonice.rules

