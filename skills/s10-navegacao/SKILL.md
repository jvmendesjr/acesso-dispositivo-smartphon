# Skill: s10-navegacao

Navegação determinística no Galaxy S10 Lite via ADB. Esta skill é o
executor do experimento: nenhuma outra skill toca na tela sem passar
por este loop.

## Dispositivo e acesso

- Aparelho: Samsung Galaxy S10 Lite, via Termux + Tailscale + SSH.
- ADB roda no próprio aparelho (o `adb devices` do Termux já lista o
  próprio telefone). A porta do ADB pode mudar após reboot.
- Ações por SSH não mudam a tela; toques, teclas e aberturas de app via
  ADB são toques reais e visíveis.

## Regra da tela (antes de qualquer passo de UI)

1. Checar vigília. Desbloqueado não significa acordado.
2. Se estiver em Dozing ou a captura voltar preta: `keyevent 224`,
   verificar acordado, recapturar.
3. Timeout de tela: 5 minutos. Após idle, a regra continua valendo.
4. Durante sessão com carregador, `stayon true` pode ser usado
   temporariamente e deve voltar a `false` no fim.

## Loop obrigatório por passo

Observar → agir (um passo) → verificar (reler tela/árvore) → registrar.
Nunca agir sobre tela em cache. Nunca repetir o mesmo toque às cegas.

## Rotinas e destravamento

Toda tarefa usa uma rotina nomeada do app em uso (no repo de vendas, `docs/rotinas-deterministicas.md`). Este repo de acesso define só o loop e a escada abaixo; as rotinas de cada app vivem no repo do app.
Quando travar, o agente sobe a escada de destravamento:

- Nível 0: esperar 5 s e reler.
- Nível 1: fechar teclado, rolar, voltar 1 passo, mover foco pelo
  teclado, colar via clipboard em vez de digitar.
- Nível 2: voltar ao ponto seguro (Feed) ou reabrir o app — mas nunca
  descartar rascunho ou texto não salvo; se não der para salvar, parar.
- Nível 3: parar e chamar o humano. Login, verificação, captcha,
  pagamento, exclusão, publicar/enviar fora do objetivo, fechar app
  com trabalho não salvo, reiniciar o aparelho.

Limites: no máximo 3 tentativas alternativas por passo; no máximo 1
retorno ao ponto seguro por tarefa, salvo registro explícito de
recomeço. Objetivo da tarefa nunca muda em recuperação.

## Texto em português

Preferir colar via clipboard a digitar, para não perder acentos.
Confirmar o texto na tela depois de colar, antes de avançar.

## Registro

Cada sessão registra: rotina, passo, tela esperada, tela obtida,
ação de destravamento (se houve) e resultado — no registro da sessão do app em uso. Capturas brutas e dumps com dados
pessoais não vão para o repositório (ver `.gitignore`).
