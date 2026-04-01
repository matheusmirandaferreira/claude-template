Rode os testes e reporte: $ARGUMENTS

## Comportamento

- Se vazio: rode todos os testes de todos os subprojetos
- Se contiver módulo: rode apenas aquele
- Se "coverage": rode com relatório de cobertura
- Use os comandos de teste documentados na seção "Comandos" do CLAUDE.md de cada subprojeto

## Relatório

```
## Resultado — [subprojeto]
- Total: X | ✅ Y | ❌ Z | ⏭ W
- Tempo: Xs
- Cobertura: X% (se solicitado)

### Falhas
[Stack trace resumido de cada falha]

### Recomendações
[Sugestões]
```

Se testes falharem: analise a causa, classifique (bug no código ou no teste), sugira correção sem aplicar.
