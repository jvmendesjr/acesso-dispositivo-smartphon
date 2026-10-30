#!/data/data/com.termux/files/usr/bin/sh
# Watchdog ADB: a cada 180s, descobre a porta via mDNS e atualiza
# ~/adb-endpoint.txt e ~/adb-status.txt. Nao conecta em ADB, nao faz
# varredura de portas, nao altera configuracao. Se nao achar, espera:
# a depuracao pode estar desligada e o MacroDroid a religa a cada 15 min.
while true; do
  termux-wake-lock 2>/dev/null
  python3 "$HOME/adb-discover.py" >> "$HOME/ensure-adb.log" 2>&1
  sleep 180
done
