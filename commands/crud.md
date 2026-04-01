Crie um CRUD completo para a entidade: $ARGUMENTS

## Processo

### 1. Backend
Siga a ordem de implementação do CLAUDE.md do diretório backend. Gere:
- Entidade/model com id, timestamps, campos, constraints, relationships
- Migration da tabela
- Validação de input (create e update parcial)
- Serialização de output (response, list response paginada)
- Service com: create, get_by_id (404 se não existe), list (paginado), update parcial, delete
- Rotas REST: POST (201), GET by id (200), GET list (200), PATCH (200), DELETE (204)
- Testes para cada rota (sucesso + erro)
- Registre as rotas no entry point da app

### 2. Frontend (se houver)
Siga a ordem de implementação do CLAUDE.md do diretório frontend. Gere:
- Types espelhando o backend
- Validação client-side
- Funções de API
- Hooks/state management com cache invalidation
- Componentes: lista paginada, formulário create/edit, detalhe
- Registre as rotas/páginas

### 3. Finalização
- Atualize `docs/api-contracts.md`
- Atualize `docs/changelog.md`
- Commit: `feat: add [entidade] CRUD`
