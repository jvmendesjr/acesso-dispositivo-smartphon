#!/data/data/com.termux/files/usr/bin/sh
# Watchdog: every 60s, restart sshd if it died. Survives network drops
# (sshd itself does not depend on an IP address) but NOT a phone reboot
# or a force-stop of Termux - that is what Termux:Boot is for.
while true; do
  termux-wake-lock 2>/dev/null
  if ! pgrep -x sshd >/dev/null 2>&1; then
    sshd 2>/dev/null
  fi
  sleep 60
done
