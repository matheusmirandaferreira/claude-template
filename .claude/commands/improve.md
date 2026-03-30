Aplique a seguinte melhoria: $ARGUMENTS

## Processo Obrigatório

### Fase 1: Análise de Impacto
1. Identifique todos os arquivos e módulos afetados
2. Verifique dependências (quem importa/usa o que vai mudar)
3. Classifique o impacto:
   - **Baixo**: Mudança interna, sem alteração de interface
   - **Médio**: Alteração de interface mas backward compatible
   - **Alto**: Breaking change

4. Para impacto Alto, apresente o plano e PARE até receber aprovação

### Fase 2: Implementação
1. Crie branch: `refactor/[nome-da-melhoria]`
2. Refatore incrementalmente (commits pequenos e atômicos)
3. Mantenha os testes passando a cada commit
4. Se adicionar dependência nova, justifique

### Fase 3: Validação
1. Rode todos os testes
2. Verifique que nenhuma funcionalidade foi perdida
3. Compare performance se relevante (DB queries, bundle size)

### Fase 4: Documentação
1. Se alterou arquitetura: atualize `docs/architecture.md`
2. Se alterou API: atualize `docs/api-contracts.md`
3. Atualize `docs/changelog.md`:
   ```
   ### Improvement
   - **[módulo]**: [o que melhorou e por quê]
   ```
4. Commit: `refactor: [descrição concisa]`

## Tipos Comuns de Melhoria
- **Performance**: Otimizar queries, adicionar índices, lazy loading, memoização
- **Code Quality**: Extrair funções, reduzir complexidade, eliminar duplicação
- **DX**: Melhorar tipos, adicionar validações, melhorar error messages
- **Security**: Adicionar validações, sanitização, headers
- **Acessibilidade**: ARIA labels, keyboard navigation, contraste
