Crie ou gerencie migrations do Alembic: $ARGUMENTS

## Comandos

### Se $ARGUMENTS = "generate" ou "auto":
```bash
cd [projeto]-backend
alembic revision --autogenerate -m "[descrição baseada nos models alterados]"
```
Após gerar, REVISE o arquivo de migration:
- Verifique que o upgrade() está correto
- Verifique que o downgrade() desfaz corretamente
- Adicione índices se necessário
- Adicione dados default se necessário (seeds)

### Se $ARGUMENTS = "up" ou "upgrade":
```bash
cd [projeto]-backend
alembic upgrade head
```

### Se $ARGUMENTS = "down" ou "downgrade":
```bash
cd [projeto]-backend
alembic downgrade -1
```

### Se $ARGUMENTS = "history":
```bash
cd [projeto]-backend
alembic history --verbose
```

### Se $ARGUMENTS = "current":
```bash
cd [projeto]-backend
alembic current
```

### Se $ARGUMENTS contiver uma descrição de mudança:
1. Identifique quais models foram alterados
2. Gere migration com mensagem descritiva
3. Revise o arquivo gerado
4. Reporte o que a migration faz

## Regras
- Mensagens de migration sempre em inglês: `feat: add users table`, `alter: add email index to users`
- Nunca edite migrations já aplicadas em produção
- Sempre inclua downgrade funcional
- Para dados default, use `op.bulk_insert()`
- Para mudanças destrutivas (drop column), avise antes de aplicar
