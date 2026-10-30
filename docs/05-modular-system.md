# 05 — Sistema modular (como plugar o laboratório)

O objetivo do dono é entregar este projeto a outras pessoas/agentes.
Este repositório é a fundação de acesso. Cada tarefa do laboratório
deve ser um módulo independente, em repositório próprio, que usa os
módulos de base abaixo e não os reimplementa — e não mistura
experimento de laboratório com a fundação de acesso.

## Módulos de base (já prontos)

1. **access** — `docs/01-access.md` + `scripts/ssh_s10.sh`.
   Entrada: comando a rodar no Termux. Saída: stdout/stderr do comando.
2. **persistence** — `docs/02-persistence.md`.
   Entrada: nenhuma (já instalada). Saída: sshd + watchdog vivos.
3. **adb-control** — `docs/03-adb-navigation.md`.
   Entrada: comando `adb …` via SSH. Saída: estado do dispositivo.
4. **navigation** — padrão screencap → input → recaptura.
   Entrada: objetivo na tela. Saída: captura confirmando o estado final.
5. **recovery** — `docs/04-recovery.md`.
   Entrada: sintoma de falha. Saída: procedimento de restauração.

## Como criar um módulo de tarefa do laboratório (no repositório do laboratório)

Cada nova tarefa deve ser um documento próprio no repositório do
laboratório (não neste), com:

- **Objetivo** em uma frase, em linguagem do dono.
- **Pré-condições**: acesso SSH ok, ADB conectado, tela acordada.
- **Passos**: cada passo = uma captura + um input + uma confirmação.
- **Critério de pronto**: o que a captura final precisa mostrar.
- **Rollback**: como voltar ao estado anterior se algo sair do esperado.
- **Evidências**: capturas e saídas de comando salvas com data, sem
  credenciais.

Nenhum módulo de tarefa deve conter chave privada, código de
pareamento, PIN, senha ou porta efêmera fixa. Portas e códigos são
entradas do momento, não constantes do repositório.

## Handover para o agente sucessor

O agente sucessor deve, na primeira sessão:

1. Ler este README e os docs 01 a 04.
2. Rodar a verificação rápida do README e registrar o resultado.
3. Só então abrir o primeiro módulo de tarefa em `tasks/`.

Se qualquer verificação falhar, o handover está incompleto e o
primeiro trabalho do sucessor é a recuperação (doc 04), não a tarefa
do laboratório.

## Itens em aberto (a definir pelo dono)

- As tarefas do laboratório em si, em repositório próprio (ainda não
  especificadas nesta entrega inicial).
- O repositório remoto deste acesso: GitHub privado, nome proposto
  `acesso-dispositivo-smartphon` — o repositório local já está pronto
  para push, mas a criação remota pelo agente falhou com 403 (ver
  abaixo), então o dono precisa criá-lo vazio no GitHub e dar acesso
  ao app do Muse nele, ou informar o nome do repositório já criado.
- Política de desbloqueio de tela, se alguma tarefa exigir tela
  desbloqueada além do estado atual.
