# 08 — PC como ponto de execução do ADB

Decidido e provado em 2026-11-01, entre 11:07 e 12:44, pelo
usuário e pelo agente, sem push para o GitHub nesta atualização.

## Decisão

- O PC, não a VM, é o ponto de execução do ADB para o teste
  do Stories e para o trabalho futuro. Motivo: um agente do
  Paperclip no PC vai assumir essa tarefa no futuro, e o ADB
  deve morar onde o agente vai morar. O S10 continua sendo o
  aparelho principal; o PC é só onde o `adb` roda.
- O binário `adb` não foi encontrado nem nesta VM nem no PC
  na checagem de 2026-11-01 ~11:07-11:08. Escolher o PC
  resolveu a arquitetura, não a ferramenta.

## Instalação no PC (isolada, sem mexer no sistema)

- Com aprovação do usuário, o zip oficial do platform-tools
  foi baixado e descompactado isolado em `~/platform-tools`
  no PC, sem apt e sem alteração de sistema.
- Verificado: `adb` 1.0.41 / 37.0.1, `~/platform-tools/adb`.
- O PC é alcançado por SSH via o mesmo proxy de túnel
  Tailscale usado para o S10, usuário `pc`, pasta de
  projetos `Workspace` (W maiúsculo).

## Pareamento: é por chave de cada máquina

- A primeira conexão do PC falhou, com lista de dispositivos
  vazia, mesmo com o endpoint fresco do telefone. Causa mais
  provável, confirmada pelo passo seguinte: a chave nova do
  `adb` do PC ainda não estava pareada no telefone.
- A lista de pareados na tela do S10 mostrava só o Termux
  local e outro computador; nenhum `pc`. Uma chave nova
  sempre precisa do seu próprio pareamento; parear na VM
  não pareia o PC, e vice-versa.
- Fluxo usado, com o dono na tela:
  1. No S10, Depuração por Wi-Fi, tocar "Parear o
     dispositivo com um código de pareamento".
  2. O telefone mostra um código de seis dígitos e uma
     porta de pareamento. Os dois expiram rápido; mandar
     os dois logo em seguida.
  3. A porta de pareamento também pode ser descoberta por
     mDNS no telefone, serviço `_adb-tls-pairing._tcp`,
     com o mesmo script de descoberta adaptado — o valor
     achado por mDNS bateu com o da tela nesta sessão.
  4. No PC: `adb pair <ip>:<porta-de-pareamento> <código>`.
     Sucesso aqui: "Successfully paired".
  5. Depois: `adb connect <ip>:<porta-principal>`, usando
     a porta principal mostrada na tela do S10.
- Código de pareamento nunca é registrado aqui nem em
  nenhum outro repositório: é efêmero e expira.

## Porta efêmera, com churn real

- A porta principal mudou de novo logo após o pareamento.
  O arquivo de endpoint no telefone, atualizado por mDNS,
  mudou junto, e o PC reconectou na porta nova como
  `device`, modelo SM-G770F confirmado. O `adb` do PC
  também passou a listar o aparelho por descoberta mDNS.
- Observação honesta desta sessão, sem causa estabelecida:
  às 12:02, a porta principal mostrada na tela do S10 não
  batia com a porta do serviço `_adb-tls-connect` no mDNS
  naquele momento, e a conexão na porta da tela funcionou
  enquanto a anterior, na porta do mDNS, tinha falhado.
  Não fixar nenhuma das duas como permanente. Regra para o
  agente sucessor: reler `~/adb-endpoint.txt` /
  `~/adb-status.txt` no telefone, ou a tela do S10, antes
  de cada conexão; se a conexão cair no meio de uma sessão,
  reler o endpoint antes de concluir que o aparelho falhou.
- Endpoint vivo, IP vivo e porta viva nunca vão para este
  repositório. O que vale é o caminho para descobrir, não
  o valor do momento.

## Publicação via PC — primeira prova

- Stories 9:16 do piloto publicado em 2026-11-01
  ~12:43-12:44, via ADB do PC, após o usuário dizer
  "já pode publicar" às 12:37, substituindo o checkpoint
  só-de-prévia. Publicação do Feed pelo ADB já estava
  provada desde 2026-11-01 ~01:49; esta é a primeira
  publicação provada com o PC como ponto de execução.
- Passos verificados por captura de tela, um de cada vez:
  Facebook aberto como TuttiBom, Criar story, primeira
  miniatura da galeria era a arte do piloto, prévia
  conferida em 9:16 cheio, rótulo de IA estava desligado
  e foi ligado antes de compartilhar, Público,
  compartilhamento no WhatsApp desativado, Compartilhar
  tocado, pedido de atalho na tela inicial recusado com
  "Agora não" (nenhum atalho adicionado).
- Confirmação no Feed: fileira de stories com "Seu story"
  e a miniatura da arte do piloto. Telefone deixado no
  Feed, bateria 85% às 12:46.
- Nota de observação: tocar em "Seu story" abriu o
  visualizador, mas a foto de 5 s avançou sozinha para o
  story seguinte antes da captura, então a prova é o
  cartão "Seu story" no Feed, não a captura do
  visualizador. Capturas com conteúdo de terceiros no
  Feed foram apagadas após a checagem, como nas sessões
  anteriores.
- Responder a interessado via ADB segue não provado.

## Para o agente sucessor / para o agente do Paperclip

- Reutilizar o mesmo ponto de execução: `~/platform-tools/adb`
  no PC, chave já pareada no PC, descoberta de endpoint por
  mDNS no telefone. Não recriar um caminho na VM que o
  agente do Paperclip não conseguiria usar.
- A chave pareada mora no PC, em `~/.android` do usuário
  `pc`. Se ela for regenerada, ou o PC for reconstruído, o
  pareamento precisa ser refeito na tela do telefone, com
  código novo.
- Regra de tela continua valendo: antes de qualquer passo
  de interface, verificar vigília, acordar com keyevent
  224 quando preciso, confirmar Awake e só então tocar ou
  capturar; recapturar se voltar preta.
- Publicação só após aprovação do usuário ao texto exato /
  à arte. Nada muda nisso por o ponto de execução ser o PC.
