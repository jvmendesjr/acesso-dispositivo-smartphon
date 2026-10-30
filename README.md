# Acesso ao dispositivo smartphone — S10 Lite

Repositório de fundação de acesso, não do laboratório. Objetivo: ajudar
qualquer agente a se conectar ao S10 Lite, com acesso persistente em
condições normais (celular ligado, com rede/internet, carregado e
conectado). As tarefas do laboratório em si vão para um repositório
próprio, separado, que usará este aqui como base.

**Status verificado em 2026-10-29:** SSH no Termux funcionando, watchdog
funcionando, Termux:Boot instalado, Tailscale conectada, ADB sem fio
pareado e conectado, captura de tela legível pelo agente e input
(tecla voltar / ligar tela) funcionando.

> Segurança: este repositório deve ser **privado**. Ele descreve acesso
> remoto a um dispositivo real. Nunca commitar chave privada SSH, código
> de pareamento (efêmero, não armazenado aqui), senha ou PIN de desbloqueio.
> A chave SSH abaixo é a chave **pública** do agente construtor, que é
> feita para ser distribuída aos hosts que ele deve acessar.

## Mapa modular

| Módulo | Arquivo | O que entrega |
|---|---|---|
| 01 Acesso | `docs/01-access.md` | Cadeia Muse VM → Tailscale → SSH Termux |
| 02 Persistência | `docs/02-persistence.md` | sshd, watchdog, boot, bateria, VPN |
| 03 ADB e navegação | `docs/03-adb-navigation.md` | Pareamento, conexão, screencap, input |
| 04 Recuperação | `docs/04-recovery.md` | O que quebra, sintoma, como restaurar |
| 05 Sistema modular | `docs/05-modular-system.md` | Como plugar as tarefas do laboratório |

## Início rápido para o agente sucessor

1. Ler `docs/01-access.md` e `docs/03-adb-navigation.md` antes de qualquer ação.
2. Testar SSH: `scripts/ssh_s10.sh 'whoami; pgrep -x sshd'`
3. Testar ADB: `scripts/ssh_s10.sh 'adb devices'` — deve listar um dispositivo `device`.
4. Para navegar: `adb exec-out screencap -p` para ver a tela, depois
   `adb shell input tap x y`, `input swipe …` ou `input keyevent …`,
   e nova captura para confirmar o efeito. Nunca adivinhar o efeito de um
   toque sem recapturar a tela.
5. Se o SSH ou o ADB falhar, ir direto para `docs/04-recovery.md` antes
   de tentar qualquer outra coisa.

## Dispositivo

- Nome na Tailscale: `s10-lite-de-tutti`
- Modelo: Samsung SM-G770F (S10 Lite), Android 13 (SDK 33)
- Nome de exibição no Android: S10 Lite de Tutti
- Tela: 1080x2400
- Usuário Termux: `u0_a419`
- SSH Termux: porta 8022 (Termux não pode vincular portas < 1024)
- ADB sem fio: porta principal **efêmera** — muda após reboot ou ao
  desligar/ligar a depuração sem fio. Nunca tratá-la como fixa.

## Scripts

- `scripts/ssh_s10.sh` — SSH via proxy Tailscale para o Termux.
- `scripts/proxy_connect.py` — ProxyCommand CONNECT para o túnel Tailscale.
- `scripts/termux/boot-sshd.sh` — script de boot do Termux:Boot.
- `scripts/termux/ensure-sshd.sh` — watchdog do sshd (60 s).
- `scripts/termux/bashrc` — auto-start ao abrir o Termux.
