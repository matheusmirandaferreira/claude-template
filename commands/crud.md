Crie um CRUD completo para a entidade: $ARGUMENTS

## O que será gerado

Para a entidade `$ARGUMENTS`, crie todos os arquivos seguindo os padrões do projeto:

### Backend

1. **Model** (`app/models/[entidade].py`):
   - SQLAlchemy model com `id` (UUID), `created_at`, `updated_at`
   - Todos os campos com tipos e constraints
   - Relationships se aplicável
   - `__tablename__` em snake_case plural

2. **Schemas** (`app/schemas/[entidade].py`):
   - `[Entidade]Base` — campos compartilhados
   - `[Entidade]Create` — campos para criação
   - `[Entidade]Update` — campos opcionais para update parcial
   - `[Entidade]Response` — response com id e timestamps
   - `[Entidade]ListResponse` — lista paginada com total

3. **Service** (`app/services/[entidade]_service.py`):
   - `create(db, data)` → cria registro
   - `get_by_id(db, id)` → busca por ID ou 404
   - `list(db, skip, limit, filters)` → lista paginada
   - `update(db, id, data)` → update parcial
   - `delete(db, id)` → soft ou hard delete
   - Error handling com exceções tipadas

4. **Route** (`app/routes/[entidade].py`):
   - `POST /[entidades]` → 201 Created
   - `GET /[entidades]/{id}` → 200 OK
   - `GET /[entidades]` → 200 OK (paginado)
   - `PATCH /[entidades]/{id}` → 200 OK
   - `DELETE /[entidades]/{id}` → 204 No Content
   - Tags para OpenAPI docs
   - Dependency injection para auth se necessário

5. **Migration**: `alembic revision --autogenerate -m "feat: add [entidade] table"`

6. **Tests** (`tests/test_[entidade].py`):
   - Test create (success + validation error)
   - Test get by id (found + not found)
   - Test list (empty + with data + pagination)
   - Test update (success + not found + validation)
   - Test delete (success + not found)

### Frontend

7. **Types** (`src/types/[entidade].ts`):
   - Interface espelhando os schemas do backend

8. **Validator** (`src/validators/[entidade].ts`):
   - Zod schema para criação e edição
   - Exportar `type [Entidade]FormData = z.infer<typeof schema>`

9. **API** (`src/lib/api/[entidade].ts`):
   - Funções para cada endpoint, retornando `.then(r => r.data)`

10. **Hooks** (`src/hooks/use-[entidade].ts`):
    - `[entidade]sQueryOptions(params?)` — queryOptions reutilizável em loaders
    - `[entidade]QueryOptions(id)` — queryOptions para item individual
    - `use[Entidade]s(params?)` — useQuery para lista
    - `use[Entidade](id)` — useQuery para item
    - `useCreate[Entidade]()` — useMutation com invalidação
    - `useUpdate[Entidade]()` — useMutation com invalidação
    - `useDelete[Entidade]()` — useMutation com invalidação

11. **FormFields** (se necessário, em `src/components/form/`):
    - Criar campos genéricos que não existam ainda usando `useController`
    - Reutilizar FormInput, FormSelect, FormTextarea, FormCheckbox existentes

12. **Components**:
    - `[Entidade]List` — tabela/cards com paginação
    - `[Entidade]Form` — form com `useForm` + `zodResolver` + `useController` via FormFields
    - `[Entidade]Detail` — visualização detalhada

13. **Routes** (TanStack Router file-based):
    - `src/routes/_authenticated/[entidade]s/index.tsx` — lista com loader + validateSearch
    - `src/routes/_authenticated/[entidade]s/$id.tsx` — detalhe com loader por id
    - `src/routes/_authenticated/[entidade]s/new.tsx` — formulário de criação

### Documentação

11. Atualize `docs/api-contracts.md`
12. Atualize `docs/changelog.md`
13. Registre o router no `app/main.py`

## Regras
- Use UUID v4 como primary key
- Timestamps com timezone (UTC)
- Paginação com `skip` e `limit` (default 0, 20)
- Response de lista inclui `total` count
- Soft delete quando fizer sentido (campo `deleted_at`)
