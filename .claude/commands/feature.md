Implemente a seguinte feature: $ARGUMENTS

## Processo Obrigatório

### Fase 1: Planejamento
- Analise o prompt e identifique: escopo, entidades, endpoints, componentes UI
- Verifique `docs/api-contracts.md` para conflitos
- Verifique `docs/architecture.md` para padrões existentes
- Apresente o plano ANTES de codar:
  ```
  ## Plano: [nome da feature]
  
  ### Escopo
  [O que será feito]
  
  ### Backend
  - Models: [lista]
  - Endpoints: [lista com métodos HTTP]
  - Services: [lógica de negócio]
  
  ### Frontend
  - Páginas: [lista]
  - Componentes: [lista]
  - Estado: [como será gerenciado]
  
  ### Riscos / Breaking Changes
  [Se houver]
  ```

### Fase 2: Backend (na ordem)
1. **Model** — SQLAlchemy model com tipos, constraints, relationships
2. **Migration** — `alembic revision --autogenerate -m "feat: add [entidade]"`
3. **Schema** — Pydantic v2 schemas (Create, Update, Response, List)
4. **Service** — Lógica de negócio com error handling
5. **Route** — FastAPI router com tags, status codes, response models
6. **Tests** — Testes para cada endpoint (success + error cases)

### Fase 3: Frontend (na ordem)
1. **Types** — Interfaces TypeScript espelhando os schemas do backend
2. **Validators** — Zod schemas em `src/validators/[feature].ts`
3. **API Client** — Funções de chamada retornando `.then(r => r.data)` usando Axios
4. **Hooks** — `queryOptions()` + `useQuery`/`useMutation` (TanStack Query v5)
5. **FormFields** — Se necessário, criar campos `useController` em `src/components/form/`
6. **Components** — shadcn/ui + FormFields com useController, composáveis, props tipadas
7. **Route** — File-based route com TanStack Router, `loader` com `ensureQueryData`, `validateSearch` com Zod
8. **Tests** — Testes de componentes críticos

### Fase 4: Documentação
1. Atualize `docs/api-contracts.md` com novos endpoints
2. Atualize `docs/changelog.md` com a feature
3. Commit: `feat: [descrição concisa]`

## Checklist de Qualidade
- [ ] Todos os endpoints têm validação de input
- [ ] Todos os endpoints retornam status codes corretos
- [ ] Loading states no frontend
- [ ] Error handling no frontend (toast/alert)
- [ ] Empty states quando aplicável
- [ ] Responsivo (mobile-first)
- [ ] Tipos consistentes entre front e back
- [ ] Formulários usam useController (nunca register direto)
- [ ] Rotas usam TanStack Router com loader e ensureQueryData
- [ ] Search params validados com Zod (validateSearch)
- [ ] queryOptions() exportados para reutilizar em loaders
