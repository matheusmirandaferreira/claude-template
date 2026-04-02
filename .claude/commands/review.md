
Faça uma revisão de código: $ARGUMENTS

Se $ARGUMENTS estiver vazio, revise staged files ou último commit.

## Checklist

### Contexto
- Faça análise de qualidade de código, segurança ou performance atendento as etapas a seguir.

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

### Performance
- [ ] Sem N+1 queries
- [ ] Sem computações pesadas em hot paths

## Formato

Para cada issue:
```
### [🔴|🟡|🔵] Arquivo:linha — Título
Problema: ...
Risco: ...
Sugestão: ...
```

Final: total por severidade + veredicto (aprovado / com ressalvas / requer mudanças)
