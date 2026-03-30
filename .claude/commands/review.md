Faça uma revisão de código dos arquivos alterados: $ARGUMENTS

Se $ARGUMENTS estiver vazio, revise os arquivos alterados no último commit ou staged files.

## O que Revisar

### Segurança (Prioridade Máxima)
- [ ] Inputs validados (Pydantic/Zod)
- [ ] Sem SQL injection (queries parametrizadas)
- [ ] Sem XSS (dados sanitizados antes de render)
- [ ] Auth/authz em todas as rotas protegidas
- [ ] Sem secrets hardcoded
- [ ] Sem dados sensíveis em logs ou responses
- [ ] Rate limiting onde necessário

### Correção
- [ ] Lógica de negócio está correta
- [ ] Edge cases tratados (null, empty, overflow)
- [ ] Error handling adequado (não engole erros)
- [ ] Status codes HTTP corretos
- [ ] Tipos TypeScript corretos (sem `any`)

### Qualidade
- [ ] Funções com responsabilidade única
- [ ] Nomes descritivos (variáveis, funções, classes)
- [ ] Sem código morto ou comentado
- [ ] Sem duplicação desnecessária
- [ ] Complexidade ciclomática aceitável (< 10)
- [ ] Arquivos com tamanho razoável (< 300 linhas)

### Performance
- [ ] Sem N+1 queries
- [ ] Sem re-renders desnecessários no React
- [ ] Sem computações pesadas no render
- [ ] Índices no banco para queries frequentes

### Testes
- [ ] Testes existem para mudanças críticas
- [ ] Testes cobrem happy path e error cases
- [ ] Testes são independentes e determinísticos

## Formato da Revisão

Para cada problema encontrado, reporte:

```
### [SEVERIDADE] Arquivo:linha — Título curto

**Problema**: Descrição do que está errado
**Risco**: O que pode dar errado
**Sugestão**: Como corrigir (com código se possível)
```

Severidades: 🔴 CRITICAL | 🟡 WARNING | 🔵 SUGGESTION

No final, dê um resumo:
- Total de issues por severidade
- Avaliação geral (aprovado / aprovado com ressalvas / requer mudanças)
