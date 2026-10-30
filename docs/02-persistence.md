# 02 — Persistência

Objetivo: em condições normais (celular ligado, com rede/internet,
carregado e conectado), o acesso volta sozinho ou se mantém sem
intervenção do dono.

## O que foi instalado no Termux (2026-10-29)

| Peça | Local no celular | Função |
|---|---|---|
| Script de boot | `~/.termux/boot/boot-sshd.sh` | Sobe sshd + watchdog no boot do celular |
| Watchdog | `~/ensure-sshd.sh` | A cada 60 s, religa o sshd se ele morreu |
| Auto-start | `~/.bashrc` | Ao abrir o Termux, sobe sshd + watchdog + wake lock |

Scripts completos em `scripts/termux/`. O script de boot só roda se o
app Termux:Boot estiver instalado — verificado como instalado em
2026-10-29, após o dono concluir os passos manuais.

## O que foi feito no Android (passos manuais do dono, 2026-10-29)

- Termux:Boot instalado, da mesma fonte do Termux (assinatura precisa
  coincidir, senão o boot não roda).
- Bateria irrestrita para Termux e Tailscale, e ambos em "apps que
  nunca dormem" (Samsung).
- Tailscale com VPN sempre ativa: Configurações → Conexões → VPN →
  engrenagem do Tailscale → VPN sempre ativa.

## Testes de persistência realizados

- `sshd` morto de propósito: watchdog o reiniciou e o SSH voltou a
  funcionar (intervalo da ordem de 1 minuto).
- Queda de rede: o `sshd` continua escutando; a conexão volta quando a
  rede volta, porque o endereço Tailscale não depende do Wi-Fi local.
- Reboot: coberto pelo Termux:Boot + VPN sempre ativa, desde que os
  passos manuais acima continuem ativos.

## Limites honestos

- Se o Android matar o Termux por pressão de memória, o watchdog morre
  junto. Só volta abrindo o Termux de novo (o `.bashrc` religa tudo)
  ou reiniciando o celular (Termux:Boot).
- Persistência via shell do Termux **não** consegue alterar
  configurações de sistema do Android (VPN sempre ativa, otimização de
  bateria). Tentativa feita em 2026-10-29 foi negada pelo Android por
  falta de permissão. Essas configurações são manuais, na tela.
- Nada disso garante acesso se o celular estiver desligado, sem bateria,
  sem internet, ou se o dono revogar o dispositivo do agente na Tailscale.
