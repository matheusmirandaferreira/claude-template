---
name: debug
description: Investigação guiada de bugs com análise de causa raiz. Use quando o usuário reportar um erro, bug, comportamento inesperado, exception, crash, ou pedir para investigar um problema. Ativa com "tá dando erro", "não funciona", "investiga isso", "por que isso tá quebrando?".
allowed-tools: Read, Grep, Glob, Bash
---

# Debug

Investigação sistemática de bugs com foco em causa raiz.

## Coleta de informação

1. **Reproduza o erro** (se possível):
```bash
# Rode o comando/teste que falha
# Capture output completo incluindo stack trace
```

2. **Analise o stack trace**: identifique arquivo, linha e cadeia de chamadas.

3. **Verifique mudanças recentes**:
```bash
git log --oneline -10
git diff HEAD~3 -- <arquivo_suspeito>
```

## Método de investigação

Siga esta ordem:

1. **Leia o erro**: o que a mensagem diz literalmente?
2. **Localize**: onde no código o erro ocorre?
3. **Contextualize**: o que mudou recentemente nessa área?
4. **Hipótese**: qual a causa mais provável?
5. **Verifique**: confirme a hipótese lendo código ou rodando teste.
6. **Corrija**: aplique o fix mínimo necessário.
7. **Valide**: rode testes para confirmar que o fix resolve sem quebrar outra coisa.

## Padrões comuns

Verifique primeiro:
- **Null/undefined**: acesso a propriedade de valor nulo.
- **Tipo errado**: string onde esperava number, etc.
- **Race condition**: operação assíncrona sem await.
- **Import circular**: dependência circular entre módulos.
- **Estado stale**: cache, memoization, ou closure capturando valor antigo.
- **Env/config**: variável de ambiente faltando ou errada.

## Saída

Apresente:
1. **Causa raiz**: o que causou o bug e por quê.
2. **Fix aplicado**: o que foi alterado.
3. **Prevenção**: como evitar que ocorra novamente (teste, validação, etc).

Se `$ARGUMENTS` contém uma mensagem de erro, comece a investigação a partir dela.
