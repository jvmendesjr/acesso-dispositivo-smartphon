# Conexão estável e direta com o S10

> Atualizado em 2026-10-30, após a conexão voltar a funcionar. Sem
> pressa, sem rajada: um teste por vez, com verificação.

## "Online" tem três significados diferentes — não confundir

1. **Na lista da tailnet:** o S10 aparece registrado na tailnet.
   Isso só prova que ele já entrou na rede, não que está acordado,
   com Tailscale ativo ou com sshd rodando agora.
2. **No pareamento do Muse:** o S10 pode estar offline por esse
   canal e, ao mesmo tempo, acessível por Tailscale. São canais
   diferentes.
3. **Alcançável de fato:** TCP até a porta 8022 responde e o sshd
   autentica com a chave `id_s10`. Só isso prova conexão.

Em 2026-10-30, o caso era o 1 + 3: o S10 estava na lista da tailnet
e o sshd respondia — o problema não era o aparelho estar "fora",
era o caminho da VM até ele.

## Por que falhou antes (e o que foi corrigido)

- **SSH direto não alcança a tailnet.** A VM só alcança a tailnet
  pelo proxy de túnel, na porta 3130. SSH direto dá "Operation not
  permitted" — e ping também falha sempre, por ser ICMP, não por o
  aparelho estar fora.
- **Host desconhecido + BatchMode = falha.** Com `BatchMode yes` e
  chave de host desconhecida, o SSH falha sem perguntar. Isso não
  era chave trocada: era chave ainda não registrada.
- **Proxy sem autenticação / com buffer travava.** O `nc` sem
  autenticação do proxy e um encaminhador com buffer faziam a
  conexão travar na troca de chaves. Corrigido com um encaminhador
  em Python sem buffer (leitura com `os.read`), que envia o
  `CONNECT` com autenticação do proxy lida do ambiente, sem guardar
  credencial em arquivo.

## Caminho estável (VM)

Arquivos duráveis, em `~/.ssh/` e no workspace (que sobrevivem a
troca de VM — ao contrário de `/root/.ssh/`):

- Chave: `~/.ssh/id_s10` (só a pública foi para o celular).
- Chave de host do aparelho: `~/.ssh/known_hosts_s10`.
- Config: `~/.ssh/config`, entrada `s10`, com caminhos absolutos
  (o SSH usa o diretório do usuário `root` para `~`, não o `$HOME`
  da shell — por isso caminhos relativos falhavam).
- Encaminhador: `~/workspace/s10-tunnel-proxy.py`, lendo o proxy do
  ambiente e trocando só a porta para 3130.

Comando estável, um só:

```
ssh -F ~/.ssh/config s10 'whoami; adb devices'
```

O `-F` é obrigatório: sem ele, o SSH não lê o config guardado em
`/home/hatch/.ssh/`. Keepalive de 30 s mantém a sessão viva em rede
instável; `BatchMode yes` impede trava pedindo senha.

## Verificação da chave do host (pedir ao usuário confirmar)

Impressão digital do host aceita em 2026-10-30 (ED25519):

```
SHA256:A3Mj9uWEV6SjUr52GivW2hQRbrBn2yIlOX3mZLlQ4Hg
```

Para confirmar no celular, no Termux:

```
ssh-keygen -lf $PREFIX/etc/ssh/ssh_host_ed25519_key.pub
```

Se não bater, parar, apagar `~/.ssh/known_hosts_s10` e não usar a
conexão até entender o que mudou (reinstalação do Termux troca a
chave — por isso não reinstalar o Termux sem avisar).

## Lado do celular (já em grande parte pronto)

Verificado em 2026-10-30 via SSH, sem tocar na tela:

- `sshd` rodando, com watchdog `~/ensure-sshd.sh` (a cada 60 s,
  reinicia o sshd se ele morrer; não sobrevive a reboot nem a
  force-stop do Termux).
- Termux:Boot instalado, com `~/.termux/boot/boot-sshd.sh` e
  `ensure-sshd.sh` — é o que faz o sshd voltar após reboot.
- Tailscale (`com.tailscale.ipn`), Facebook (`com.facebook.katana`)
  e Messenger (`com.facebook.orca`) instalados.

O que o usuário mantém no celular, manualmente, uma vez:

- Tailscale: sempre ativo, sem otimização de bateria para o app.
- Termux: sem otimização de bateria, com wake lock durante sessões.
- Durante sessões, celular carregando.
- Não reinstalar o Termux nem limpar seus dados sem avisar (troca a
  chave do host e a chave autorizada).

## O que ainda pode quebrar — e o que fazer

- Android matar o Termux em segundo plano: voltar ao app, abrir o
  Termux, verificar `sshd` e tentar de novo, sem pressa.
- Reboot: aguardar o Termux:Boot reiniciar o sshd; se não voltar,
  abrir o Termux manualmente.
- Porta do ADB mudar: o `adb devices` no Termux mostra a porta atual;
  ela é efêmera, não fixar em documento como se fosse permanente.
- Tela em Dozing: regra de vigília continua valendo para qualquer
  passo de UI (ver skills/s10-navegacao/SKILL.md).

## Estado em 2026-10-30

Conexão SSH via túnel funcionando em ~3 s, `whoami` retornando
`u0_a419` e `adb devices` listando o próprio aparelho. Pesquisa no
app do Facebook no Cariri concluída em leitura (ver
experimento de pesquisa no Cariri, no repo de vendas).

## Teste pendente: retorno após horas parado

Proposto pelo usuário em 2026-10-30: deixar o S10 parado por horas
e testar se a conexão volta sem intervenção manual. Estado ao
encerrar: Facebook parado na tela de resultados do Marketplace,
tela para apagar sozinha em 5 minutos, bateria em 91%, sem
carregamento, sem `stayon`, sem trabalho não salvo. Verificar na
volta: SSH responde? `adb devices` lista o aparelho? O Termux
sobreviveu ou o Android o matou? Se não voltar, o passo é abrir o
Termux manualmente no aparelho — sem forçar nada remotamente.
