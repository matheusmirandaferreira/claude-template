---
name: pr-description
description: Gera descrição de Pull Request com contexto, mudanças e checklist. Use quando o usuário pedir para criar PR, descrever PR, gerar descrição de merge request, ou preparar código para review. Ativa com "abre um PR", "prepara o PR", "MR description".
allowed-tools: Read, Grep, Glob, Bash(git *)
---

# PR Description

Gera uma descrição de PR completa e padronizada.

## Coleta de contexto

```bash
# Branch atual e base
git branch --show-current
git log --oneline develop..HEAD  # ou main..HEAD

# Diff completo contra a base
git diff develop --stat
git diff develop
```

Se `$ARGUMENTS` especificar a branch base, use-a no lugar de `develop`.

## Template de saída

```markdown
## O que muda

<Resumo em 2-3 frases: o que foi feito e por quê.>

## Mudanças

- <mudança 1: arquivo/módulo + o que mudou>
- <mudança 2>
- ...

## Como testar

1. <passo 1>
2. <passo 2>
3. <resultado esperado>

## Screenshots / Evidências

<Se aplicável, indique que screenshots devem ser adicionadas.>

## Checklist

- [ ] Testes adicionados/atualizados
- [ ] Documentação atualizada
- [ ] Sem secrets ou credenciais no código
- [ ] Sem código comentado ou debug logs
- [ ] Build passa localmente
- [ ] Migration necessária? Se sim, está incluída.

## Notas para o reviewer

<Pontos de atenção, trade-offs, ou contexto extra.>
```

## Regras

- Seja objetivo. Não repita o diff inteiro.
- Agrupe mudanças por área funcional, não por arquivo.
- Se houver breaking changes, destaque no topo.
- Se houve decisões de design, explique brevemente o racional.
