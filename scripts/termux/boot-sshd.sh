#!/data/data/com.termux/files/usr/bin/sh
# Termux:Boot script - runs on device boot, ONLY if Termux:Boot app is installed.
# Keeps the phone reachable: wake lock + sshd (port 8022).
termux-wake-lock 2>/dev/null
if ! pgrep -x sshd >/dev/null 2>&1; then
  sshd
fi
# Start the watchdog that restarts sshd if it ever dies while Termux lives.
if ! pgrep -f ensure-sshd.sh >/dev/null 2>&1; then
  nohup sh "$HOME/ensure-sshd.sh" >/dev/null 2>&1 &
fi
