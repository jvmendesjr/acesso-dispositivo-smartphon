#!/data/data/com.termux/files/usr/bin/sh
# Termux:Boot - inicia o watchdog ADB. Nao mexe em boot-sshd.sh.
termux-wake-lock 2>/dev/null
if ! pgrep -f ensure-adb.sh >/dev/null 2>&1; then
  nohup sh "$HOME/ensure-adb.sh" >/dev/null 2>&1 &
fi
