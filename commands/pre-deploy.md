Checklist pré-deploy.

## Executar em cada subprojeto

Use os comandos documentados na seção "Comandos" do CLAUDE.md de cada subprojeto:

1. **Testes** — rode e verifique que passam
2. **Type check** — rode se disponível (tsc, mypy, phpstan)
3. **Lint** — rode e corrija warnings
4. **Build** — verifique que compila sem erro
5. **Segurança** — busque secrets expostos, rode audit de deps
6. **Migrations** — verifique que estão sincronizadas
7. **Docs** — api-contracts.md e changelog.md atualizados

Se qualquer item falhar: PARE e reporte.

## Relatório

```
## Deploy Checklist — [data]

| Check         | Status | Detalhes |
|---------------|--------|----------|
| Testes        | ✅/❌  |          |
| Type check    | ✅/❌  |          |
| Lint          | ✅/❌  |          |
| Build         | ✅/❌  |          |
| Secrets       | ✅/❌  |          |
| Deps audit    | ✅/⚠️  |          |
| Migrations    | ✅/❌  |          |
| Docs          | ✅/⚠️  |          |

### Veredicto: ✅ PRONTO | ❌ REQUER CORREÇÕES
```
