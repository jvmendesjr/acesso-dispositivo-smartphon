# 04 — Recuperação

Ordem de diagnóstico: SSH primeiro, ADB depois. Não tentar consertar o
ADB se o SSH ainda não responde.

## SSH não responde

| Sintoma | Causa provável | Restauração |
|---|---|---|
| SSH fecha / timeout | Termux morto ou sshd parado | Abrir o Termux no celular (`.bashrc` religa sshd + watchdog) |
| SSH fecha após reboot | Termux:Boot ausente ou sem permissão | Instalar Termux:Boot da mesma fonte do Termux e reiniciar |
| SSH responde, mas sem Tailscale | VPN desligada ou dispositivo revogado | Ligar a Tailscale no celular; se revogado, nova aprovação do dono para o agente |
| SSH pede senha / chave recusada | `authorized_keys` apagado ou Termux limpo | Repetir o comando de instalação da chave em `docs/01-access.md` |

## ADB não lista dispositivo

| Sintoma | Causa provável | Restauração |
|---|---|---|
| `adb devices` vazio | Depuração sem fio desligada | Ligar Depuração sem fio no celular |
| `adb devices` vazio, depuração ligada | Porta principal mudou | Anotar a nova porta na tela de Depuração sem fio e rodar `adb connect <IP>:<nova-porta>` |
| `adb devices` vazio após reboot | Pareamento perdido / depuração desligada | Repetir pareamento (`adb pair`) e conexão, como em `docs/03-adb-navigation.md` |
| `adb` falha ao executar | `libc++` desatualizado de novo | `pkg install -y "libc++"` no Termux e testar `adb version` |

## Tela apagada / dozing

- `adb shell dumpsys power | grep mWakefulness` pode mostrar `Dozing`.
  Isso não significa perda de ADB. `adb shell input keyevent 26`
  acorda a tela; confirmar com nova captura.
- Não tentar desbloquear PIN/padrão/biometria pelo agente sem
  autorização explícita do dono e sem o credencial fornecido por ele
  por canal seguro. Desbloqueio não faz parte deste handover.

## O que nunca fazer

- Nunca rodar `tailscale down` na VM do agente sem ordem do dono: isso
  apaga a identidade do dispositivo e exige nova aprovação.
- Nunca rodar `docker compose down -v` ou apagar volumes em outro
  contexto do dono — fora do escopo deste dispositivo.
- Nunca commitar chave privada, código de pareamento, PIN ou senha.
