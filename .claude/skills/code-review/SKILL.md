---
name: code-review
description: Revisão de código com checklist padronizado. Use quando o usuário pedir review, revisão, CR, ou "olha esse código". Também ativa automaticamente quando o contexto sugere análise de qualidade de código, segurança ou performance.
allowed-tools: Read, Grep, Glob, Bash(git diff:*)
---

# Code Review

Realize uma revisão de código estruturada e acionável.

## Contexto

Se `$ARGUMENTS` foi fornecido, trate como path ou referência git (branch, commit, PR).

Caso contrário, revise o diff atual:
```bash
git diff --cached  # staged changes
git diff           # unstaged changes
```

Se não há diff, peça ao usuário o que revisar.

## Checklist de revisão

Avalie cada item e reporte apenas os que têm problemas ou merecem destaque positivo:

### Correção
- A lógica está correta?
- Edge cases estão cobertos?
- Tratamento de erros é adequado?

### Segurança
- Inputs são validados e sanitizados?
- Há exposição de dados sensíveis?
- SQL injection, XSS, ou outras vulnerabilidades?

### Performance
- Queries N+1 ou loops desnecessários?
- Alocações de memória excessivas?
- Oportunidades de caching?

### Manutenibilidade
- Código é legível sem comentários?
- Nomes são descritivos?
- Duplicação desnecessária?
- Complexidade ciclomática aceitável?

### Testes
- Testes acompanham as mudanças?
- Cenários relevantes estão cobertos?
- Testes são determinísticos?

### Convenções
- Segue as convenções do CLAUDE.md do projeto?
- Formatação e estilo consistentes?

## Formato da saída

Para cada achado, indique:
- **Severidade**: 🔴 Bloqueante | 🟡 Sugestão | 🟢 Elogio
- **Arquivo e linha**: referência direta
- **Descrição**: o que foi encontrado
- **Sugestão**: como resolver (com código quando aplicável)

Finalize com um resumo: total de achados por severidade e uma recomendação (aprovar, aprovar com ressalvas, ou solicitar mudanças).
