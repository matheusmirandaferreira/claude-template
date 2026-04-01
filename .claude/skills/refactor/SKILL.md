---
name: refactor
description: Refatoração guiada com análise de impacto. Use quando o usuário pedir para refatorar, melhorar, limpar, simplificar código, reduzir complexidade, ou eliminar duplicação. Ativa com "refatora", "clean up", "simplifica isso", "tá muito complexo".
allowed-tools: Read, Write, Grep, Glob, Bash
---

# Refactor

Refatora código de forma segura, com análise de impacto e preservação de comportamento.

## Análise prévia

Antes de qualquer mudança:

1. **Entenda o contexto**: leia o código, seus chamadores e dependências.
```bash
# Quem usa esse código?
grep -rn "import.*<modulo>" --include="*.{ts,tsx,js,jsx,py}" .
grep -rn "<funcao>" --include="*.{ts,tsx,js,jsx,py}" .
```

2. **Verifique testes existentes**:
```bash
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) | xargs grep -l "<modulo_ou_funcao>"
```

3. **Rode os testes antes** para ter uma baseline:
```bash
npm test 2>&1 | tail -5
# ou pytest -x 2>&1 | tail -5
```

## Tipos de refatoração

Identifique e aplique o padrão mais adequado:

- **Extract**: função/método muito longo → extraia responsabilidades.
- **Inline**: abstração desnecessária → simplifique.
- **Rename**: nomes confusos → torne descritivos.
- **Move**: código no lugar errado → mova para módulo correto.
- **Decompose conditional**: if/else complexo → simplifique lógica.
- **Replace temp with query**: variável temporária → método/função.
- **Reduce duplication**: código repetido → abstraia.

## Regras

- **Uma mudança por vez**. Não misture refatorações.
- **Preserve comportamento**. Testes devem continuar passando.
- **Prefira mudanças pequenas e incrementais** sobre reescritas.
- **Rode testes após cada mudança**.
- Se não há testes, sugira criá-los primeiro com `/test-gen`.

## Saída

Para cada refatoração aplicada:
1. O que foi feito e por quê.
2. Arquivos afetados.
3. Resultado dos testes antes/depois.

Se `$ARGUMENTS` indicar um arquivo ou módulo específico, foque nele. Caso contrário, pergunte o que refatorar.
