#!/data/data/com.termux/files/usr/bin/sh
# ensure-adb.sh — RASCUNHO, NÃO INSTALADO AINDA (2026-10-30)
#
# Bot observador de recuperação do ADB no S10, no mesmo padrão do
# ensure-sshd.sh: loop, wake lock, sem rajada, sem tocar em tela,
# sem publicar/enviar, sem mudar configuração de sistema.
#
# O que ele faz:
#   - a cada 60 s, verifica se `adb devices` lista o aparelho;
#   - se sim, grava status PRONTO em ~/adb-status.txt;
#   - se não, tenta UMA reconexão no endpoint registrado em
#     ~/adb-endpoint.txt (formato host:porta, preenchido só
#     com um endpoint confirmado manualmente);
#   - se a depuração sem fio estiver desligada ou o endpoint
#     for desconhecido, NÃO varre portas, NÃO injeta tecla, só
#     registra "precisa de intervenção manual" e espera.
#
# O que ele NÃO faz (por falta de permissão / por guarda):
#   - descobrir o endpoint novo sozinho (Termux não tem DUMP
#     nem INTERACT_ACROSS_USERS; mdns desta build do adb
#     não é suportado) — essa descoberta é um passo de
#     validação separado, ver docs/bot-recuperacao.md;
#   - acordar a tela: keyevent 224 via ADB só funciona quando
#     o ADB já está conectado, ou seja, não resolve este caso;
#   - enviar porta, chave ou credencial por mensageria pública.
#     A entrega é o arquivo ~/adb-status.txt, lido via SSH.
#
# Instalação (SÓ após aprovação explícita, e só após a
# recuperação manual atual do ADB, com o endpoint novo anotado):
#   1. copiar este arquivo para ~/ensure-adb.sh no celular;
#   2. iniciar com guarda de duplicata, como no .bashrc do sshd;
#   3. só depois, com aprovação, adicionar ao Termux:Boot.
# Não adicionar ao Boot antes dos testes 1-3 de
# docs/bot-recuperacao.md.

STATUS_FILE="$HOME/adb-status.txt"
ENDPOINT_FILE="$HOME/adb-endpoint.txt"
LOG_FILE="$HOME/ensure-adb.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

while true; do
  termux-wake-lock 2>/dev/null

  DEVICES="$(adb devices 2>&1)"
  if echo "$DEVICES" | grep -q "device$"; then
    {
      echo "PRONTO $(date '+%Y-%m-%d %H:%M:%S')"
      echo "$DEVICES"
    } > "$STATUS_FILE"
  elif [ -f "$ENDPOINT_FILE" ]; then
    ENDPOINT="$(cat "$ENDPOINT_FILE" 2>/dev/null | tr -d ' \n')"
    RESULT="$(adb connect "$ENDPOINT" 2>&1)"
    log "adb vazio, tentativa de reconexão em $ENDPOINT: $RESULT"
    DEVICES_AFTER="$(adb devices 2>&1)"
    if echo "$DEVICES_AFTER" | grep -q "device$"; then
      {
        echo "PRONTO $(date '+%Y-%m-%d %H:%M:%S')"
        echo "$DEVICES_AFTER"
      } > "$STATUS_FILE"
    else
      echo "AGUARDANDO $(date '+%Y-%m-%d %H:%M:%S') - reconexão falhou em $ENDPOINT" > "$STATUS_FILE"
    fi
  else
    echo "AGUARDANDO $(date '+%Y-%m-%d %H:%M:%S') - sem endpoint registrado, precisa de intervenção manual para ligar/confirmar a depuração sem fio" > "$STATUS_FILE"
  fi

  sleep 60
done
