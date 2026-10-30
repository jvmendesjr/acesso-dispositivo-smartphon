# 03 — ADB e navegação

## Instalação no Termux (2026-10-29)

- Pacote: `android-tools` 37.0.0 (`pkg install -y android-tools`).
- Problema encontrado e resolvido: a primeira instalação falhou ao
  executar o `adb` com erro de link (`cannot locate symbol
  "__ndk1…__hash_memory"`). Causa: `libc++` desatualizado.
  Correção: `pkg install -y "libc++"` (27c → 30). Depois disso,
  `adb version` respondeu `1.0.41 / 37.0.0p1-android-tools`.

## Pareamento e conexão (depuração sem fio, Android 13)

Pré-requisito no celular: modo desenvolvedor ativado (tocar 7 vezes em
Número da compilação) e Depuração sem fio ligada em Opções do
desenvolvedor.

Passo a passo usado em 2026-10-29 (repetir se a conexão cair ou a porta mudar):

1. No celular: Depuração sem fio → Parear dispositivo com código de
   pareamento. A tela mostra IP:porta de pareamento e um código de
   6 dígitos, que expira rápido.
2. No Termux (via SSH): `adb pair <IP>:<porta-de-pareamento> <código>`
   — esperado: `Successfully paired to …`.
3. No celular: voltar à tela de Depuração sem fio e anotar o
   **Endereço IP e porta** principal (porta diferente da de pareamento).
4. No Termux: `adb connect <IP>:<porta-principal>` — esperado:
   `connected to …`, e `adb devices` listando o dispositivo como `device`.

Notas importantes:

- O endereço mostrado pelo celular foi o endereço Tailscale do
  dispositivo, não o IP do Wi-Fi local. Por isso o pareamento e a
  conexão funcionaram a partir do próprio Termux, via Tailscale.
- O código de pareamento é efêmero. Não armazená-lo em repositório,
  memória ou log. Usar e descartar.
- A porta principal é efêmera. Após reboot ou ao desligar/ligar a
  depuração sem fio, ela muda. Nunca fixá-la em script.

## Navegação validada (2026-10-29)

- `adb shell id` → usuário `shell` (uid 2000), com grupos de input, log,
  adb e armazenamento. É o nível de privilégio do ADB, não root.
- `adb shell wm size` → 1080x2400.
- `adb exec-out screencap -p > ~/adb-screenshot.png` → PNG válido,
  legível pelo agente. Primeira captura mostrou a tela de Depuração
  por Wi-Fi, com o Termux listado como conectado.
- `adb shell input keyevent 4` (voltar) e `input keyevent 26` (ligar
  tela) → efeito confirmado por nova captura, voltando à mesma tela
  de Depuração por Wi-Fi. Ou seja: input funciona.

## Limitação conhecida

`adb shell uiautomator dump` falhou neste aparelho com
`ERROR: null root node returned by UiTestAutomationBridge`, e o arquivo
de dump não foi criado. Portanto, neste dispositivo, a navegação deve
ser feita por **visão (screencap) + input (tap/swipe/keyevent)**,
com recaptura após cada ação, e não pela árvore XML do uiautomator.

## Padrão de navegação recomendado

1. Capturar a tela.
2. Decidir a ação a partir do que a captura mostra.
3. Executar um único input (`tap`, `swipe` ou `keyevent`).
4. Capturar de novo e confirmar o efeito antes do próximo passo.
5. Nunca encadear vários toques "no escuro" sem recapturar.
