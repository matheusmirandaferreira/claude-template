Aplique a seguinte melhoria: $ARGUMENTS

## Processo

### 1. Análise de impacto
- Identifique todos os arquivos e dependências afetados
- Classifique: **Baixo** (interno) | **Médio** (interface, backward compatible) | **Alto** (breaking)
- Para impacto Alto: apresente plano e PARE até aprovação

### 2. Implementação
- Refatore incrementalmente (commits pequenos)
- Mantenha testes passando a cada commit
- Se adicionar dependência, justifique

### 3. Validação
- Rode todos os testes
- Verifique que nenhuma funcionalidade foi perdida

### 4. Finalização
- Se alterou arquitetura: atualize `docs/architecture.md`
- Se alterou API: atualize `docs/api-contracts.md`
- Atualize `docs/changelog.md`
- Commit: `refactor: [descrição]`
