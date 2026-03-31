Rode os testes e reporte o resultado: $ARGUMENTS

## Comportamento

### Se $ARGUMENTS estiver vazio:
Rode TODOS os testes de ambos os projetos:

```bash
# Backend
cd [projeto]-backend && python -m pytest tests/ -v --tb=short 2>&1

# Frontend
cd [projeto]-frontend && npm run test -- --reporter=verbose 2>&1
```

### Se $ARGUMENTS contiver um módulo específico:
Rode apenas os testes daquele módulo.

### Se $ARGUMENTS for "coverage":
```bash
# Backend
cd [projeto]-backend && python -m pytest tests/ -v --cov=app --cov-report=term-missing 2>&1

# Frontend
cd [projeto]-frontend && npm run test -- --coverage 2>&1
```

## Relatório

Após rodar, apresente:

```
## Resultado dos Testes

### Backend
- Total: X | ✅ Passou: Y | ❌ Falhou: Z | ⏭ Pulou: W
- Tempo: Xs
- [Se coverage] Cobertura: X%

### Frontend
- Total: X | ✅ Passou: Y | ❌ Falhou: Z
- Tempo: Xs
- [Se coverage] Cobertura: X%

### Falhas (se houver)
[Detalhes de cada teste que falhou com stack trace resumido]

### Recomendações
[Sugestões para corrigir falhas ou melhorar cobertura]
```

## Se testes falharem
1. Analise a causa da falha
2. Classifique: bug no código ou bug no teste
3. Sugira a correção (não aplique sem permissão)
