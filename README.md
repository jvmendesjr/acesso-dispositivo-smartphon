# Acesso ao dispositivo smartphone — S10 Lite

Repositório único de manutenção, acesso, bot e ADB do S10 Lite.
Objetivo: ajudar qualquer agente a se conectar ao S10 Lite, com
acesso persistente em condições normais (celular ligado, com
rede/internet, carregado e conectado). As tarefas de vendas em si
vão para um repositório próprio, separado, que usará este aqui
como base — mas nada de manutenção, acesso, bot ou ADB vive
fora daqui.

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
| 06 Conexão estável | `docs/06-conexao-estavel.md` | Caminho estável via proxy, o que falhou e o que prova conexão |
| 07 Bot de recuperação | `docs/07-bot-recuperacao.md` | Bot instalado 2026-10-30: MacroDroid + mDNS + watchdog |
| 08 PC como ponto de execução do ADB | `docs/08-pc-adb-ponto-execucao.md` | PC como ponto de execução, pareamento por chave, porta efêmera, Stories publicado via PC em 2026-11-01 |
| Navegação | `skills/s10-navegacao/SKILL.md` | Loop observar-agir-verificar-registrar e escada de destravamento |
| Watchdog ADB | `scripts/ensure-adb.sh` | Watchdog do ADB instalado no celular, loop 180 s |
| Descoberta mDNS | `scripts/adb-discover.py` | Descobre a porta via mDNS, atualiza endpoint e status |
| Boot ADB | `scripts/boot-adb.sh` | Termux:Boot, inicia o watchdog ADB sem tocar boot-sshd |

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
- `scripts/adb-discover.py` — descoberta mDNS da porta ADB, instalado no celular em `~/adb-discover.py`.
- `scripts/ensure-adb.sh` — watchdog ADB, instalado no celular em `~/ensure-adb.sh`.
- `scripts/boot-adb.sh` — boot ADB, instalado no celular em `~/.termux/boot/boot-adb.sh`.

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

## Atualização 2026-10-30 — rascunho pendente de aprovação para push

Verificado em 2026-10-30, sem toques na tela durante a checagem:

- SSH via Tailscale sobreviveu a cerca de 7 h parado e ao retorno
  de uma queda de energia e internet, sem intervenção manual:
  o watchdog do sshd estava rodando e a sessão respondeu.
- ADB não sobreviveu ao mesmo período: `adb devices` ficou vazio
  e continuou vazio após reiniciar o servidor ADB via SSH.
  A porta antiga da depuração sem fio passou a recusar conexão,
  e o Termux não consegue descobrir a porta nova: acesso a
  configurações e dumps do sistema é negado por falta de
  permissão, e esta versão do ADB não suporta descoberta por mDNS.
- Auditoria de persistência: o que está de fato configurado no
  celular é só o sshd — script de boot do Termux:Boot, auto-start
  e watchdog a cada 60 s, todos para o sshd. Não há watchdog de
  ADB, nem watchdog de Tailscale no Termux, nem cron, e a
  configuração do Termux está no padrão, sem apps externos
  autorizados.
- O S10 não tem chip SIM: usa só Wi-Fi. Por isso um gatilho por
  SMS não é viável; qualquer gatilho por mensagem precisa ser
  por internet/Wi-Fi, observando e aguardando o retorno da rede.
- Conclusão de viabilidade: navegação por ADB está provada para
  pesquisa, monitoramento, triagem e preparo de rascunho, em
  leitura. Publicar e responder ainda não estão provados e
  dependem de testes de rascunho com aprovação.
- Rascunho de bot de recuperação (não instalado no celular):
  ideia consolidada neste repositório único, em
  `docs/07-bot-recuperacao.md` e `scripts/ensure-adb.sh`, com loop de
  vigilância parecido com o do sshd, arquivo de status lido via
  SSH e reconexão só para um endpoint confirmado manualmente —
  sem varredura de portas, sem acordar a tela só pelo Termux e
  sem credenciais ou portas por mensagem pública.

## Atualização 2026-10-30 — recuperação instalada

Verificado em 2026-10-30, com o ADB online no endpoint
atual via Tailscale (porta efêmera, não fixar, e não
registrada neste repositório — o endpoint vivo fica
só em `~/adb-endpoint.txt` no celular):

- MacroDroid, macro `LigarDepuracaoWifi`, ligada, com
  gatilhos Intervalo regular 00:15:00 e Dispositivo
  inicializado, e ação Configuração do Sistema [Global]
  adb_wifi_enabled = 1. A macro já executou sozinha
  pelo intervalo ("Executada Há 6 minutos" e depois
  "Há 8 minutos" na lista do MacroDroid).
- Descoberta da porta via mDNS provada: Python 3.14.8 e
  zeroconf 0.151.5 no Termux, script `adb-discover.py`
  achando, via `_adb-tls-connect._tcp`, a mesma porta
  do endpoint via Tailscale na hora do teste.
  Dependências no Termux: `pkg install python` e
  `pip install zeroconf` (o zeroconf traz o ifaddr,
  usado para detectar o IP do Tailscale).
- Watchdog `ensure-adb.sh` rodando no celular, loop
  180 s, atualizando `~/adb-endpoint.txt` e
  `~/adb-status.txt`, com boot em `boot-adb.sh` via
  Termux:Boot, sem alterar `boot-sshd.sh`.
- Entrega do endereço novo: o watchdog escreve o
  endpoint em arquivo lido via SSH, que funciona mesmo
  com o ADB caído. Reserva: o app da Muse.AI está no
  S10, logado com a mesma conta desta conversa, e pode
  passar o endpoint manualmente se a automação falhar.
- Ainda não testado: queda real da depuração com o
  sistema no ar, reboot real e mudança de rede. Ver
  `docs/07-bot-recuperacao.md`, seção final.

## Atualização 2026-10-30 noite — rede nova

- O celular voltou de um período fora de área numa
  rede Wi-Fi nova. SSH via Tailscale voltou, o IP do
  Tailscale não mudou, o IP do Wi-Fi mudou, e o ADB
  ficou fora por horas, com o watchdog só em
  NOT-FOUND.
- Causa: o Android pede autorização por rede para a
  depuração por Wi-Fi numa rede nova, e enquanto o
  diálogo não é respondido o serviço não aparece.
  O dono marcou "sempre permitir" desde a primeira
  vez, e o diálogo mesmo assim repetiu no ciclo
  seguinte — motivo interno ainda não estabelecido.
- Recuperação: após a permissão mais recente, o
  watchdog redescobriu a porta e o ADB reconectou
  como `device`. Estabilidade nesta rede nova ainda
  não está provada; observar os próximos ciclos.
- Regra: rede nova = verificar o diálogo de
  autorização na tela antes de concluir falha do
  bot. Nome de rede, endereço de rede e endpoint
  vivo nunca vão para este repositório. Ver
  `docs/07-bot-recuperacao.md`, seção final.

## Atualização 2026-11-01 — PC como ponto de execução do ADB

Verificado em 2026-11-01, entre 11:07 e 12:44, sem push para o
GitHub nesta atualização (local apenas):

- O PC passou a ser o ponto de execução do ADB, decidido pelo
  usuário porque um agente do Paperclip no PC vai assumir essa
  tarefa no futuro. Platform-tools oficial instalado isolado
  em `~/platform-tools` no PC, sem apt e sem mexer no sistema:
  adb 1.0.41 / 37.0.1.
- Pareamento é por chave de cada máquina: a chave nova do PC
  precisou de pareamento próprio, com código na tela do S10 e
  porta de pareamento descoberta por mDNS. Depois disso, a
  conexão na porta principal da tela funcionou como `device`,
  modelo SM-G770F confirmado.
- A porta principal mudou de novo logo após o pareamento; o
  endpoint no telefone foi atualizado por mDNS e o PC
  reconectou na porta nova. Endpoint vivo, código de
  pareamento e portas nunca são registrados neste repositório.
- Stories 9:16 do piloto publicado via ADB do PC em
  2026-11-01 ~12:43-12:44, após aprovação do usuário às
  12:37, com rótulo de IA ligado, Público, WhatsApp
  desativado, e confirmação no Feed como "Seu story".
  Correção ao estado de 2026-10-30 acima: publicar pelo ADB
  agora está provado (Feed e Stories); responder a
  interessado segue não provado. Ver
  `docs/08-pc-adb-ponto-execucao.md`.
