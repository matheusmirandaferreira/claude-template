Execute o checklist pré-deploy: $ARGUMENTS

## Checklist Automatizado

### 1. Testes
```bash
# Backend
cd [projeto]-backend && python -m pytest tests/ -v --tb=short 2>&1
echo "---"

# Frontend
cd [projeto]-frontend && npm run test 2>&1
echo "---"

# Type check frontend
cd [projeto]-frontend && npx tsc --noEmit 2>&1
```

Se algum teste falhar: PARE e reporte. Não prossiga.

### 2. Lint e Formatação
```bash
# Backend
cd [projeto]-backend && ruff check app/ tests/ 2>&1
cd [projeto]-backend && ruff format --check app/ tests/ 2>&1

# Frontend
cd [projeto]-frontend && npm run lint 2>&1
```

### 3. Build
```bash
# Frontend build (verifica se compila)
cd [projeto]-frontend && npm run build 2>&1

# Docker build (se houver)
docker compose build 2>&1
```

### 4. Segurança (rápido)
```bash
# Secrets expostos
grep -rn "password.*=.*['\"]" --include="*.py" --include="*.ts" --include="*.env" . 2>/dev/null | grep -v ".example" | grep -v "test" | grep -v "__pycache__"

# .env no git
git ls-files | grep "\.env$" | grep -v ".example"

# npm audit
cd [projeto]-frontend && npm audit --production 2>&1
```

### 5. Migrations
```bash
# Verificar migrations pendentes
cd [projeto]-backend && alembic current 2>&1
cd [projeto]-backend && alembic check 2>&1
```

### 6. Documentação
- Verificar se `docs/api-contracts.md` está atualizado
- Verificar se `docs/changelog.md` tem a versão atual
- Verificar se `README.md` reflete o estado atual

## Relatório

```
## Deploy Checklist — [data]

| Check              | Status | Detalhes           |
|--------------------|--------|--------------------|
| Backend tests      | ✅/❌  | X passed, Y failed |
| Frontend tests     | ✅/❌  | X passed, Y failed |
| Type check         | ✅/❌  |                    |
| Backend lint       | ✅/❌  |                    |
| Frontend lint      | ✅/❌  |                    |
| Frontend build     | ✅/❌  |                    |
| Docker build       | ✅/❌  |                    |
| No secrets exposed | ✅/❌  |                    |
| No .env in git     | ✅/❌  |                    |
| npm audit          | ✅/⚠️  | X vulnerabilities  |
| Migrations synced  | ✅/❌  |                    |
| Docs updated       | ✅/⚠️  |                    |

### Veredicto: ✅ PRONTO PARA DEPLOY / ❌ REQUER CORREÇÕES
[Lista de itens bloqueantes se houver]
```
