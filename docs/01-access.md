# 01 — Acesso

## Cadeia completa

```
Agente (VM Muse)
  → proxy Tailscale (porta 3130, via HTTPS_PROXY da VM)
  → ProxyCommand scripts/proxy_connect.py
  → SSH porta 8022
  → Termux no S10 Lite (s10-lite-de-tutti)
    → adb local (Termux) → depuração sem fio do Android
```

Regras do túnel Tailscale (válidas para o agente construtor e para o sucessor):

- A rede comum não alcança a tailnet. Só TCP através do proxy funciona;
  ping/ICMP/UDP não provam nada.
- O primeiro acesso a um endereço novo pede aprovação do dono. Depois de
  aprovado, a aprovação cobre outras portas/serviços naquele mesmo
  endereço, pelo tempo escolhido.
- Aparecer na lista da tailnet não significa serviço acessível. Só uma
  conexão TCP bem-sucedida prova alcance.

## SSH Termux

- Host Tailscale: `s10-lite-de-tutti`
- Porta: `8022`
- Usuário para conexão: qualquer um funciona no Termux (single-user);
  o agente construtor usou `test@`. O usuário real do Termux é `u0_a419`.
- Autenticação: **somente chave**. O `sshd` do Termux não aceita senha.
- Chave pública autorizada em `~/.ssh/authorized_keys` no Termux:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtADAvhYcXwyXjpxscnVLMwgjthVKXfvcG6VrOj2o/L hatch
```

- Comando de instalação da chave (uma linha, no Termux do celular):

```
pkg install -y openssh; mkdir -p ~/.ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys; grep -qxF 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtADAvhYcXwyXjpxscnVLMwgjthVKXfvcG6VrOj2o/L hatch' ~/.ssh/authorized_keys || echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtADAvhYcXwyXjpxscnVLMwgjthVKXfvcG6VrOj2o/L hatch' >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys; pkill sshd 2>/dev/null; sshd; echo "sshd ligado - porta 8022"
```

- Helper do agente construtor: `scripts/ssh_s10.sh '<comando>'`. Ele usa a
  chave privada do agente construtor em `~/.ssh/id_ed25519` na VM.
  **O agente sucessor deve gerar/usar sua própria chave** e repetir o
  comando acima com a sua chave pública, ou receber a chave privada
  por um canal seguro do dono — nunca commitar chave privada aqui.

## Verificação rápida

```
scripts/ssh_s10.sh 'whoami; pgrep -x sshd; adb devices'
```

Esperado: usuário Termux, um PID de `sshd`, e (se o ADB estiver
conectado) um dispositivo `device` em `adb devices`.
