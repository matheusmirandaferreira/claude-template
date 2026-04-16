---
name: code-review
description: Revisão de código com checklist padronizado. Use quando o usuário pedir review, revisão, CR, ou "olha esse código". Também ativa automaticamente quando o contexto sugere análise de qualidade de código, segurança ou performance.
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

Avalie cada item e reporte apenas os que têm problemas:

### Segurança
- [ ] Inputs validados
- [ ] Sem SQL injection (queries parametrizadas / ORM)
- [ ] Sem XSS (dados sanitizados)
- [ ] Auth em rotas protegidas
- [ ] Sem secrets hardcoded
- [ ] Sem dados sensíveis em logs/responses

### Correção
- [ ] Lógica correta
- [ ] Edge cases tratados (null, empty, overflow)
- [ ] Error handling adequado
- [ ] Status codes corretos
- [ ] Tipagem correta

### Qualidade
- [ ] Funções com responsabilidade única
- [ ] Nomes descritivos
- [ ] Sem código morto
- [ ] Sem duplicação
- [ ] Arquivos < 300 linhas
- [ ] Complexidade ciclomática aceitável

### Performance
- [ ] Sem N+1 queries
- [ ] Sem computações pesadas em hot paths
- [ ] Sem alocações de memória excessivas

### Testes
- [ ] Testes acompanham as mudanças
- [ ] Cenários relevantes cobertos
- [ ] Testes determinísticos

### Convenções
- [ ] Segue convenções do CLAUDE.md do projeto
- [ ] Formatação e estilo consistentes

## Formato da saída

Para cada issue:
```
### [🔴|🟡|🔵] Arquivo:linha — Título
Problema: ...
Risco: ...
Sugestão: ...
```

Severidades: 🔴 Bloqueante | 🟡 Importante | 🔵 Sugestão

Final: total por severidade + veredicto (aprovado / aprovado com ressalvas / requer mudanças)
