Relatório de status do projeto.

## Analise

1. Identifique a stack de cada subprojeto pelo CLAUDE.md
2. Liste entidades/models, rotas, páginas, testes
3. Encontre gaps (entidade sem teste, rota sem validação)

```bash
# Arquivos grandes (> 300 linhas)
find . -name "*.py" -o -name "*.php" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" | grep -v node_modules | grep -v vendor | xargs wc -l 2>/dev/null | sort -rn | head -20

# TODOs pendentes
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.py" --include="*.php" --include="*.ts" --include="*.tsx" --include="*.js" . 2>/dev/null | grep -v node_modules | grep -v vendor

# Tipagem fraca
grep -rn ": any" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v node_modules
```

## Relatório

```
## Status — [data]

### Resumo
- Entidades: X | Endpoints: Y | Páginas: Z | Testes: W

### Completude por entidade
| Entidade | Model | Validação | Service | Route | Tests |
|----------|-------|-----------|---------|-------|-------|

### Alertas
- 🔴 [sem teste]
- 🟡 [arquivos grandes]
- 🔵 [TODOs]

### Próximos passos sugeridos
```
