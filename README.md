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

## Atualização 2026-10-29 — instância Manu

Esta seção não remove o registro do agente construtor. Ela acrescenta
uma segunda instância de acesso, verificada em paralelo, em 2026-10-29.

- Tailscale: a VM do Manu está conectada à mesma tailnet como
  `muse`, e `s10-lite-de-tutti` aparece na lista dela.
- GitHub: Muse está conectado e autenticado como `jvmendesjr`.
  O nome correto do repositório é `acesso-dispositivo-smartphon`
  (sem o "e" final); a grafia com "e" final não foi encontrada.
  A renomeação para a grafia com "e" final foi adiada pelo dono.
- SSH: chave ed25519 dedicada gerada para esta instância, com
  comentário `muse-s10-lite`. Somente a chave pública foi entregue
  ao dono, para acrescentar ao `authorized_keys` do Termux, sem
  sobrescrever chaves existentes. A chave privada fica somente no
  ambiente do Manu e nunca é commitada aqui.
  Verificação: SSH via túnel Tailscale para a porta 8022 funcionou,
  retornando o usuário Termux e um processo `sshd` em execução.
- ADB: `adb devices` no Termux já listava o próprio celular como
  `device`, sem necessidade de novo pareamento naquela verificação.
  A porta do ADB sem fio é efêmera e não deve ser fixada.
- Apps verificados/instalados em 2026-10-29: o app do Facebook
  (`com.facebook.katana`) já estava presente; o Messenger
  (`com.facebook.orca`) foi instalado pela Google Play Store e
  confirmado por `pm list packages` e pela página da Play Store
  mostrando Abrir/Desinstalar. O app não foi aberto nem logado
  nessa instalação.
- Condições normais: em condições normais (celular ligado e
  carregado, com internet e Tailscale conectada, Termux vivo com
  `sshd` no ar), o acesso deve funcionar sempre que preciso.
  Isso não é uma garantia absoluta: celular desligado ou sem
  bateria, sem internet, Tailscale revogada, Termux morto por
  pressão de memória ou reboot podem interromper o acesso.

### Tela: desbloqueada não é acordada

- Problema observado: a tela estava desbloqueada, mas entrava em
  Dozing após 30 segundos de inatividade. Nesse estado, a captura
  de tela voltava preta, o que não significa perda de informação
  nem perda de ADB/SSH — apenas que a tela estava apagada.
- Regra adotada: antes de qualquer passo de interface, verificar
  se a tela está acordada, acordá-la quando preciso, confirmar
  que ficou Awake e só então tocar ou capturar. Se a captura
  voltar preta, acordar de novo e recapturar, sem encadear
  toques no escuro.
- Ajuste aplicado em 2026-10-29, a pedido do dono: o tempo de
  tela foi alterado de 30 segundos para 5 minutos
  (`screen_off_timeout` de 30000 para 300000). Isso reduz a
  frequência com que a tela apaga no meio de uma tarefa, mas
  não elimina a regra de acordar sempre: após 5 minutos sem
  uso, a tela ainda pode apagar.
- Durante uma sessão de interface, enquanto o celular estiver
  carregando, a tela pode ser mantida acesa temporariamente e
  restaurada ao comportamento normal no final da sessão.

### Ações visíveis x ações de fundo

- Ações de fundo, sem mudar a tela: consultas via SSH/Termux,
  como listar pacotes, verificar `sshd` ou tirar uma captura.
- Ações visíveis na tela: toques, teclas e abertura de apps via
  ADB são toques reais no sistema. Quem estiver olhando para o
  celular vê a Play Store abrir, o botão Instalar ser tocado e
  a página mudar para Abrir/Desinstalar, por exemplo.
