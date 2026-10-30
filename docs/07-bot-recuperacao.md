# Bot de recuperação pós-queda — observador, não substituto da rede

> Rascunho, 2026-10-30. NÃO instalado no celular ainda.
> Escrito em paralelo à recuperação manual do ADB pelo usuário,
> sem tocar na tela nem no ADB do aparelho durante essa recuperação.

## Por que este bot existe

Teste de retorno após horas parado, 2026-10-30:

- S10 deixado parado às 02:50 -03, Facebook no Marketplace,
  bateria 91%, sem carregamento, sem stayon.
- No período, a única alteração foi queda e retorno de energia
  e de internet (informado pelo usuário, 2026-10-30 ~10:04 -03).
- Na volta, por volta das 10:00 -03: SSH via Tailscale voltou
  sozinho (usuário u0_a419, sshd + watchdog rodando), bateria
  99% descarregando, mas `adb devices` veio vazio e continuou
  vazio após `adb kill-server` / `adb start-server` via SSH.
- A porta antiga da depuração sem fio (38607) passou a dar
  conexão recusada. A porta é efêmera e muda com reboot ou
  com a depuração sendo desligada/ligada.

Auditoria de persistência feita no mesmo dia, via SSH, sem UI:

- O que existe hoje é só para sshd: Termux:Boot
  (`boot-sshd.sh`), `.bashrc` e `ensure-sshd.sh` a cada 60 s.
- NÃO existe watchdog de ADB, watchdog de Tailscale no Termux,
  cron, nem descoberta automática de porta nova.
- `termux.properties` está no padrão, com
  `allow-external-apps` desativado.
- O Termux, como usuário de app, NÃO consegue ler o estado da
  tela nem as configurações do sistema: `dumpsys power` é
  negado (falta DUMP) e `settings get` é negado (falta
  INTERACT_ACROSS_USERS). Esta versão do adb (37.0.0) diz que
  mdns não é suportado.
- O aparelho está sem chip, só Wi-Fi (informado pelo usuário).
  SMS, portanto, NÃO é um gatilho viável aqui.

Conclusão honesta: a persistência do SSH estava programada, a
do ADB não. O bot abaixo fecha exatamente essa lacuna, sem
prometer o que não pode fazer.

## Conceito, nas palavras do usuário, precisado

O bot não substitui a rede e não funciona sem internet. Ele
observa e espera a internet voltar. Quando volta, ele verifica
o sistema, aciona o que for necessário e entrega o estado de
acesso — porta e status — por um canal já autenticado
(arquivo de status lido via SSH, ver abaixo), não por mensagem
pública com credencial ou porta.

Se o aparelho reiniciar, o mesmo watchdog deve subir junto
com o sshd, via Termux:Boot, e refazer a verificação.

## Componentes

### 1. Watchdog no Termux: `ensure-adb.sh` (rascunho em `scripts/`)

Mesmo padrão do `ensure-sshd.sh`, sem inventar permissão nova:

- Iniciado por Termux:Boot e por `.bashrc`, com guarda contra
  duplicata (`pgrep -f ensure-adb.sh`).
- Loop a cada 60 s, com `termux-wake-lock`.
- Ordem de verificação, uma por vez, sem rajada:
  1. sshd está rodando? (se não, o watchdog do sshd já cuida;
     este script só registra, não duplica o trabalho dele).
  2. `adb devices` lista algum aparelho?
     - Sim: grava status PRONTO e dorme.
     - Não: tenta reconectar, ver item 2 abaixo.
  3. Grava sempre um arquivo de status, com data/hora, resultado
     do `adb devices`, última porta tentada e último erro.
     Esse arquivo é o que a VM lê via SSH para saber se o
     aparelho está pronto — é a “entrega” de porta/status,
     sem expor porta ou chave em mensageria pública.

### 2. Como reconectar, em ordem — e o que NÃO fazer

1. **Endpoint registrado:** se existir `~/adb-endpoint.txt`
   com o endpoint da última recuperação manual bem-sucedida,
   no formato `host:porta`, tentar `adb connect` nele uma vez.
   O endpoint novo que o usuário está recuperando manualmente
   agora deve ser anotado aqui, depois que ele confirmar.
2. **Descoberta — ainda a validar, não prometer:** testar
   descoberta mDNS por outro caminho (por exemplo, biblioteca
   Python de mDNS no Termux) para achar o serviço
   `_adb-tls-connect._tcp` na rede Wi-Fi local. Até validar,
   isto é hipótese, não solução.
3. **App de automação — caminho alternativo, se a descoberta
   falhar:** um app com permissão de configurações seguras,
   concedida uma única vez enquanto o ADB ainda funciona,
   poderia ler/ligar a depuração sem fio e informar a porta.
   Isto exige instalação e concessão manual prévia, fora do
   Termux, e só entra com aprovação explícita do usuário.
4. **NÃO fazer:** varredura bruta de portas, injetar tecla,
   mudar configuração de sistema, logar, publicar, enviar,
   pagar ou aceitar termos para “destravar”. Se a depuração
   sem fio estiver desligada, o bot para e registra
   “precisa ligar manualmente em Opções do desenvolvedor” —
   nível 3, chama o humano.

### 3. Gatilho por mensageria (secundário, só por internet)

O watchdog autônomo acima é o principal: ele já observa a
volta da rede sozinho, sem precisar de mensagem externa.

A mensageria entra como gatilho secundário, para quando o
usuário estiver longe da VM e quiser deixar o aparelho
pronto antes de uma sessão:

- Canal: internet/Wi-Fi apenas (Telegram, WhatsApp ou outro
  mensageiro por internet). Sem chip, SMS está fora.
- Mensagem de gatilho: mínima, por exemplo “acorda”, só de
  remetente autorizado (lista fechada, um número/conta).
- Resposta do bot: mínima também, por exemplo “pronto” ou
  “precisa de intervenção manual”, SEM porta, chave ou
  credencial na mensagem. Detalhe só via SSH.
- Se a VM já estiver com SSH funcionando, o gatilho por
  mensageria é redundante: a VM aciona o watchdog direto
  por SSH. Não criar dois caminhos para a mesma ação sem
  necessidade.

### 4. Na reinicialização

- Termux:Boot deve subir `ensure-sshd.sh` E `ensure-adb.sh`.
- O app Tailscale (Android) deve estar sem otimização de
  bateria, assim como o Termux, para voltar sozinho com a
  internet. O Tailscale voltou sozinho neste teste — manter
  essa configuração, não assumir que ela se mantém sozinha
  após atualização do app.
- Após reboot, a porta do ADB quase certamente muda. O bot
  não deve reutilizar a porta antiga como se fosse fixa;
  deve passar pela ordem de reconexão acima e registrar a
  nova porta.

## O que o bot NÃO pode fazer

- Funcionar sem energia, sem bateria, com o aparelho
  desligado ou sem Wi-Fi/internet. Ele espera a volta, não
  a substitui.
- Acordar a tela sozinho a partir do Termux, sem um app com
  permissão para isso. `keyevent 224` via ADB só funciona
  quando o ADB já está conectado — é o problema, não a
  solução, neste cenário.
- Descobrir a porta nova sozinho com as permissões atuais
  do Termux. Essa parte precisa da validação do item 2 ou
  do app do item 3.
- Substituir a checagem manual da primeira recuperação: a
  porta nova de agora deve vir do usuário, na tela, e ser
  registrada antes de qualquer automação confiar nela.

## Atualização 2026-10-30 — depuração desligada, queda de rede e mudança de rede

Requisito novo do dono, 2026-10-30: o bot tem que perceber
se a depuração sem fio estiver desligada e ajustar, fazendo
todo o processo, também quando a internet cair ou a rede mudar.

Restauração feita no mesmo dia, antes desta atualização:

- O dono encontrou a depuração sem fio desligada, ligou
  manualmente na tela e a depuração voltou a mostrar
  Ativado, com o aparelho pareado e conectado no momento.
- O ADB foi reconectado pelo Termux ao endpoint principal
  confirmado na tela, e o endpoint foi registrado em
  `~/adb-endpoint.txt` no celular, para o watchdog usar.
  Nenhum código de pareamento foi guardado em documento,
  memória ou repositório: código efêmero é usado e descartado.

Limite honesto, que continua valendo até a validação abaixo:

- Sozinho, o Termux NÃO consegue ler se a depuração está
  ligada ou desligada, nem ligá-la: a leitura de
  configurações é negada para ele, e acordar a tela por
  ADB só funciona quando o ADB já está conectado.
- O que o watchdog consegue fazer hoje, sem permissão nova,
  é classificar a falha e esperar, sem rajada:
  - `adb devices` vazio + `adb connect` no endpoint
    registrado devolvendo conexão recusada: provável
    depuração desligada, porta mudada ou adbd sem escuta.
    Registrar `PRECISA_INTERVENCAO_MANUAL` e parar de
    tentar a mesma porta como se fosse fixa.
  - `adb devices` vazio + timeout / sem rota: provável
    internet ou Tailscale ainda fora do ar. Esperar a
    volta, sem ação durante a queda, e só retomar quando
    a rede voltar.
  - Mudança de rede: o host da tailnet não muda com a
    rede Wi-Fi local, mas a porta do ADB pode mudar.
    Por isso, após falha, o bot não reutiliza a porta
    antiga como fixa e não varre portas.

Caminho para o bot realmente ligar a depuração, pendente
de aprovação explícita do dono e de validação enquanto o
ADB ainda funciona (agora):

1. Conceder, uma única vez, permissão de configurações
   seguras a um componente pré-aprovado — por exemplo,
   conceder `WRITE_SECURE_SETTINGS` ao Termux via ADB, ou
   usar um app de automação com essa permissão — e testar
   se esse componente consegue ler e ligar a depuração
   sem fio e informar o estado.
2. Só se o teste 1 passar, o watchdog passa a ter um
   passo "ligar depuração via componente aprovado" antes
   de registrar intervenção manual. Sem esse teste, o
   bot continua apenas detectando por falha e pedindo
   intervenção manual — não prometer que ele liga
   sozinho.
3. Mesmo com esse componente, a porta nova depois de
   religar ainda precisa ser confirmada: o bot não
   descobre a porta nova sozinho até a validação de
   mDNS ou do app do item 3 da seção de reconexão.

Teste de concessão adiado por queda do ADB, 2026-10-30 ~10:25 -03:

- Baseline confirmada antes da concessão: `settings get`
  no Termux devolve `SecurityException` exigindo
  `INTERACT_ACROSS_USERS`, como na auditoria anterior.
- Antes de rodar o `pm grant`, o ADB já estava `offline`
  e, em seguida, a conexão ao endpoint registrado passou
  a dar conexão recusada e a lista ficou vazia. SSH
  continuava funcionando e não houve reboot (uptime
  alto), então a queda foi só do listener sem fio.
- Conclusão: conceder `WRITE_SECURE_SETTINGS` via ADB
  exige ADB online no momento da concessão — é o mesmo
  problema ovo-galinha da depuração. O teste só pode
  ser feito numa janela em que o ADB esteja online, e
  logo em seguida, sem esperar a tela apagar.
- Ponto a investigar na próxima reativação: por que o
  listener caiu minutos depois de voltar, se a tela
  estava acordada e o celular não reiniciou. Hipóteses
  a checar na tela, não a assumir: depuração desligada
  de novo, Wi-Fi adormecido com a tela, ou sessão sem
  fio expirada ao sair da tela de depuração.

Teste de concessão, resultado, 2026-10-30 ~10:34 -03:

- O dono ligou a depuração manualmente de novo e informou
  o novo endpoint principal na tela. A primeira tentativa
  de `adb connect` falhou, um teste TCP no endpoint
  confirmado respondeu, e a tentativa seguinte conectou
  como `device`. Lição: não desistir na primeira falha
  de connect após religar; tentar de novo após alguns
  segundos, sem rajada.
- Novo endpoint registrado em `~/adb-endpoint.txt`.
- `pm grant com.termux WRITE_SECURE_SETTINGS` executado
  com sucesso, confirmado por dumpsys: granted=true.
- Referência via ADB: `adb_wifi_enabled=1`,
  `screen_off_timeout=300000` (5 min, como esperado).
- Resultado negativo importante: mesmo com
  `WRITE_SECURE_SETTINGS` concedido, o comando
  `settings get/put` dentro do Termux continua negado,
  agora e antes, por `INTERACT_ACROSS_USERS`. O
  comando `settings` passa por um handler de shell que
  exige essa outra permissão, independente da permissão
  de configurações seguras.
- Conclusão: conceder só `WRITE_SECURE_SETTINGS` ao
  Termux NÃO basta para o bot ligar a depuração pelo
  comando `settings` no shell. Caminhos restantes, a
  validar com aprovação explícita, um por vez:
  1. conceder também `INTERACT_ACROSS_USERS` ao Termux
     via ADB e testar de novo — permissão forte,
     não concedida neste teste;
  2. usar um app que chama a API de configurações
     diretamente (por exemplo, app de automação com
     `WRITE_SECURE_SETTINGS`), em vez do comando
     `settings` no shell — esse caminho não depende
     do handler de shell;
  3. escrever um pequeno app próprio que chame
     `Settings.Global.putInt` com a permissão já
     concedida ao Termux não é possível pelo shell;
     seria um app separado, com a mesma concessão.
- Até um desses caminhos passar, o bot continua sem
  ligar a depuração sozinho, só classificando a falha
  e pedindo intervenção manual.

Teste com app de automação (MacroDroid), em andamento, 2026-10-30 ~10:39 -03:

- App escolhido primeiro por ser gratuito, com ação de
  configuração de sistema documentada e concessão via
  ADB conhecida: MacroDroid (ArloSoft). Instalado via
  Play Store (sem compra), com `WRITE_SECURE_SETTINGS`
  e `CHANGE_CONFIGURATION` concedidos e confirmados
  (granted=true), onboarding concluído, notificações
  permitidas, tela principal com Ativado.
- Criação da macro iniciada (tela Adicionar macro,
  Gatilhos/Ações/Restrições), mas NÃO salva: o ADB
  caiu de novo por volta das 10:46, durante a escolha
  do gatilho, com conexão recusada ao endpoint
  registrado. A macro que ligaria a depuração ainda
  não existe.
- Lição para a próxima janela: terminar a macro com
  menos passos de verificação intermediária, usando
  coordenadas já conhecidas, porque a janela do ADB
  tem durado poucos minutos e cada captura atrasa.
- Próximo passo: nova reativação manual, novo endpoint
  da tela, e terminar a macro na mesma janela: gatilho
  (inicialização do dispositivo e/ou Wi-Fi conectado),
  ação Configuração do sistema, Global,
  adb_wifi_enabled=1, salvar e testar a ação
  manualmente antes de qualquer teste de queda.

Teste de `INTERACT_ACROSS_USERS`, resultado, 2026-10-30 ~10:37 -03:

- ADB ainda online no endpoint registrado, sem nova
  recuperação manual entre o teste anterior e este.
- `pm grant com.termux INTERACT_ACROSS_USERS` falhou
  com erro do sistema: o pacote com.termux não solicitou
  essa permissão. Ou seja, não é uma negação que o dono
  possa contornar por aprovação: o Termux, pelo
  manifesto dele, não pode receber essa permissão via
  `pm grant`.
- `settings get/put` no Termux continua negado pelo
  mesmo motivo. Caminho do Termux sozinho, pelo comando
  `settings`, está fechado, não por falta de tentativa.
- Caminho restante, a validar: um app que declare
  `WRITE_SECURE_SETTINGS` no manifesto, receba a
  concessão via ADB uma única vez e chame a API de
  configurações diretamente (não o comando `settings`
  no shell). Um app assim roda como app Android, não
  depende do ADB estar online para rodar, e por isso
  pode religar a depuração depois que ela cai. Exemplos
  a testar, um por vez: app de automação (Tasker,
  MacroDroid, Automate ou similar) com ação de
  configuração segura, disparado por boot ou Wi-Fi
  conectado, com otimização de bateria desativada.

Fluxo pós-queda / pós-mudança de rede, com o bot:

1. SSH e Tailscale voltam sozinhos (sshd + app Tailscale,
   já existentes). O bot espera, não age durante a queda.
2. Rede de volta: watchdog verifica `adb devices`, tenta
   o endpoint registrado uma vez.
3. Se voltar: status PRONTO, sem tocar na tela.
4. Se falhar: classifica conforme acima, grava o status
   em `~/adb-status.txt`, e — só se o componente do
   passo 1 existir e estiver validado — tenta ligar a
   depuração por ele, uma vez por ciclo, e aguarda o
   novo endpoint confirmado. Caso contrário, pede
   intervenção manual na tela, como foi feito em
   2026-10-30.

## Validação, em ordem, com aprovação em cada passo

1. Recuperação manual do ADB agora, pelo usuário, sem
   interferência da VM. Anotar a porta nova confirmada.
2. Instalar o rascunho do watchdog (só após aprovação),
   sem mudar o `boot-sshd.sh` existente antes disso.
3. Teste 1: matar o servidor adb via SSH e ver se o
   watchdog reconecta na porta registrada, sem tocar na tela.
4. Teste 2: desligar e ligar o Wi-Fi e ver se ele espera
   a volta e reconecta, sem intervenção manual.
5. Teste 3: reiniciar o aparelho e ver se Termux:Boot sobe
   sshd + watchdog e o ADB volta, com a porta nova
   registrada.
6. Só depois desses três testes, considerar o bot provado
   para queda de internet, queda de energia e reinício.
   Antes disso, é rascunho, não solução.

## Arquivos

- Este documento: `docs/07-bot-recuperacao.md`
- Rascunho do watchdog: `scripts/ensure-adb.sh` (local,
  NÃO instalado no celular, NÃO adicionado ao Boot ainda)
- Status no celular, quando instalado:
  `~/adb-status.txt` e `~/ensure-adb.log`
- Endpoint registrado manualmente: `~/adb-endpoint.txt`
  (só com o endpoint confirmado pelo usuário, nunca adivinhado)

## Atualização 2026-10-30 — instalado e validado (com depuração ligada)

Esta seção supersede o status "rascunho, não instalado" acima
para os componentes listados aqui. O que ainda NÃO foi testado
está no final, separado, para não virar promessa.

### MacroDroid — macro salva e executando

- Macro: `LigarDepuracaoWifi`, ligada, lista Macros 1, Ativadas.
- Gatilhos (OU, confirmado pelo diálogo "Triggers múltiplos"):
  Intervalo regular 00:15:00 e Dispositivo inicializado (boot).
- Ação: Configuração do Sistema [Global] adb_wifi_enabled = 1.
- Permissões do MacroDroid, confirmadas: WRITE_SECURE_SETTINGS
  e CHANGE_CONFIGURATION granted=true; permissão de alterar
  o sistema dada pelo dono em 2026-10-30 ~10:56 -03.
- Gatilho de Wi-Fi conectado NÃO foi usado: ele pedia
  permissão de localização, que foi cancelada, não concedida.
- Prova de execução: na lista do MacroDroid, 11:21 -03,
  "Executada Há 6 minutos" e, após a edição do boot,
  "Executada Há 8 minutos". A macro já rodou sozinha pelo
  intervalo, sem toque manual na ação.

### Descoberta da porta via mDNS — provada

- `adb mdns` continua não suportado nesta versão do adb
  (37.0.0) e `/proc/net/tcp` é permissão negada no Termux.
- Python 3.14.8 instalado no Termux e zeroconf 0.151.5
  instalado via pip (a instalação concluiu mesmo com um
  timeout do SSH no meio).
- Script instalado no celular: `~/adb-discover.py`.
  Ele procura `_adb-tls-connect._tcp.local.` por 20 s,
  pega a porta, detecta o IP do Tailscale via ifaddr
  (não fixado no script) e o IP Wi-Fi do anúncio mDNS.
- Teste, 2026-10-30 ~11:12 -03, com ADB online:
  achou `adb-RX8N70GY0ZB-QdWXwb._adb-tls-connect._tcp.local.`
  porta 41735, Wi-Fi 192.168.0.8, Tailscale 100.87.79.94 —
  porta exatamente igual ao endpoint atual via Tailscale.
  Ou seja: a porta do mDNS é a porta do ADB, qualquer que
  seja a interface de conexão.
- Saídas: `~/adb-endpoint.txt` (IP Tailscale:porta) e
  `~/adb-status.txt` (data, serviço, porta, Wi-Fi,
  Tailscale, endpoint, fonte=mdns). Log em
  `~/adb-discover.log`.

### Watchdog ADB — instalado e rodando

- Script instalado no celular: `~/ensure-adb.sh`, loop a
  cada 180 s, com `termux-wake-lock`, rodando
  `~/adb-discover.py` e registrando em `~/ensure-adb.log`.
  Ele NÃO conecta em ADB, NÃO varre portas e NÃO altera
  configuração. Se o mDNS não achar nada, ele registra
  NOT-FOUND e espera — a depuração pode estar desligada
  e o MacroDroid a religa a cada 15 min.
- Boot: `~/.termux/boot/boot-adb.sh` inicia o watchdog
  no boot, sem tocar em `boot-sshd.sh`.
- Verificação, 2026-10-30 ~11:21 -03: log do watchdog
  com FOUND 100.87.79.94:41735, endpoint e status
  atualizados, `adb devices` = device, adb_wifi_enabled=1.
- Whitelist de Doze, confirmada via dumpsys: com.termux,
  com.termux.boot, com.arlosoft.macrodroid e
  com.tailscale.ipn estão na lista de exceções.

### Entrega do endereço novo — requisito do dono

- Requisito, 2026-10-30 ~10:59 -03: se o endereço mudar,
  a automação tem que garantir que a Muse receba isso.
- Na prática, o IP do Tailscale tem ficado estável
  (100.87.79.94) e o que muda é a porta. O watchdog
  descobre a porta via mDNS e escreve o endpoint novo
  em `~/adb-endpoint.txt`, que a VM lê via SSH — SSH
  funciona mesmo com o ADB caído, porque depende só
  do sshd e do Tailscale, não do ADB.
- Reserva autenticada, registrada pelo dono em
  2026-10-30 ~11:01 -03: o app da Muse.AI está instalado
  no S10 e logado com a exata mesma conta desta
  conversa. Mesmo com o ADB caído, o dono pode abrir
  o app no telefone e passar o endpoint novo para a
  Muse, porque o app usa internet, não ADB. O pacote
  do app não foi identificado com certeza via pm list,
  então nenhum pacote é afirmado aqui.

### O que ainda NÃO foi testado (não prometer)

- Queda real da depuração com a macro + watchdog no ar:
  ainda não desligamos a depuração de propósito para
  ver a recuperação completa (macro religa em até
  15 min, watchdog descobre a porta em até 3 min).
- Reboot real com Termux:Boot subindo boot-adb.sh.
- Mudança de rede Wi-Fi com o watchdog no ar.
- Até esses testes, o sistema está instalado e validado
  por componente (macro executando, mDNS achando a
  porta, watchdog atualizando o endpoint), não por
  recuperação completa de ponta a ponta.
