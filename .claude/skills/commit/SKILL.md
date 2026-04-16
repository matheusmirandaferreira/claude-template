---
name: commit
description: Gera mensagem de commit no padrão Conventional Commits. Use quando o usuário pedir para commitar, gerar commit message, ou após concluir uma tarefa de código. Ativa automaticamente quando o usuário diz "commita", "commit isso", "salva essas mudanças".
allowed-tools: Bash(git *)
---

# Commit

Gera e (opcionalmente) executa um commit seguindo Conventional Commits.

## Passos

1. Analise as mudanças staged:

```bash
git diff --cached --stat
git diff --cached
```

2. Se não há nada staged, verifique mudanças unstaged e pergunte se deve fazer `git add`.

3. Gere a mensagem seguindo o formato:

```
<ticket>: <descrição imperativa, max 72 chars>

<corpo: o que mudou e por quê, wrap em 72 chars>
```

### Regras

- **ticket**: Opcional. ID da tarefa no click-up (pergunte se não souber). Formato: `PROJ-123`.
- **descrição**: imperativo, minúscula, sem ponto final.
- **corpo**: explique motivação e mudanças relevantes. Se o diff for trivial (rename, typo), corpo é opcional.

4. Apresente a mensagem ao usuário e pergunte se quer ajustar antes de executar.

5. Ao confirmar:

```bash
git commit -m "<mensagem formatada>"
```

## Dica

Se houver múltiplas mudanças não relacionadas, sugira dividir em commits separados (um por concerns).
