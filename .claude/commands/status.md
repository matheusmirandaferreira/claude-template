Gere um relatório de status do projeto.

## O que analisar

### 1. Estrutura
```bash
# Listar estrutura do projeto
find . -type f -name "*.py" -o -name "*.ts" -o -name "*.tsx" | head -100
```

### 2. Backend
```bash
# Models existentes
find */app/models -name "*.py" ! -name "__init__.py" ! -name "base.py" 2>/dev/null

# Routes existentes
find */app/routes -name "*.py" ! -name "__init__.py" 2>/dev/null

# Migrations
ls */alembic/versions/*.py 2>/dev/null

# Testes
find */tests -name "test_*.py" 2>/dev/null
```

### 3. Frontend
```bash
# Páginas
find */src/pages -name "*.tsx" 2>/dev/null

# Componentes (excluindo ui/)
find */src/components -name "*.tsx" ! -path "*/ui/*" 2>/dev/null

# Hooks customizados
find */src/hooks -name "*.ts" 2>/dev/null

# Testes
find */src/__tests__ -name "*.test.*" 2>/dev/null
```

### 4. Saúde do Código
```bash
# Arquivos grandes (> 300 linhas)
find . -name "*.py" -o -name "*.ts" -o -name "*.tsx" | xargs wc -l 2>/dev/null | sort -rn | head -20

# TODOs e FIXMEs
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.py" --include="*.ts" --include="*.tsx" 2>/dev/null

# any no TypeScript
grep -rn ": any" --include="*.ts" --include="*.tsx" 2>/dev/null
```

## Formato do Relatório

```
## Status do Projeto — [data]

### Resumo
- Entidades: X models
- Endpoints: Y rotas
- Páginas: Z páginas
- Testes: W arquivos de teste

### Backend
| Entidade | Model | Schema | Service | Route | Tests |
|----------|-------|--------|---------|-------|-------|
| User     | ✅    | ✅     | ✅      | ✅    | ✅    |
| Product  | ✅    | ✅     | ✅      | ⚠️    | ❌    |

### Frontend
| Feature  | Types | API | Hooks | Components | Page | Tests |
|----------|-------|-----|-------|------------|------|-------|
| Users    | ✅    | ✅  | ✅    | ✅         | ✅   | ⚠️    |

### Alertas
- 🔴 [arquivos sem teste]
- 🟡 [arquivos grandes para dividir]
- 🔵 [TODOs pendentes]

### Próximos Passos Sugeridos
1. [baseado nos gaps encontrados]
```
