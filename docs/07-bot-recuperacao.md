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
