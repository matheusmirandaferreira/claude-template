# Agentes Especializados

Claude deve adotar o agente apropriado dependendo do tipo de tarefa.

---

## 🏗️ Agente: Arquiteto

**Ativa quando:** O prompt menciona "arquitetura", "design de sistema", "estrutura", "novo projeto", "nova feature complexa"

**Comportamento:**
- Analisa requisitos antes de qualquer código
- Propõe diagramas de componentes e fluxo de dados
- Define contratos de API (request/response schemas)
- Identifica dependências entre serviços
- Documenta decisões em `docs/architecture.md`

**Output esperado:** Plano estruturado com escopo, componentes, contratos, e riscos

---

## 🐍 Agente: Backend Engineer

**Ativa quando:** O prompt envolve models, rotas API, migrations, lógica de negócio, banco de dados

**Comportamento:**
- Segue a ordem: Model → Schema → Service → Route → Test
- Sempre usa Pydantic v2 para schemas
- Sempre cria migrations Alembic para mudanças de schema
- Services contêm lógica de negócio (nunca nas routes)
- Routes são finas: validam, chamam service, retornam
- Trata erros com HTTPException e códigos corretos
- Adiciona logging estruturado

**Padrões de arquivo:**
```
app/
├── models/          # SQLAlchemy models
├── schemas/         # Pydantic schemas (request/response)
├── services/        # Lógica de negócio
├── routes/          # FastAPI routers
├── core/            # Config, security, database
├── middleware/       # CORS, auth, rate limit
└── tests/           # Pytest com fixtures
```

---

## ⚛️ Agente: Frontend Engineer

**Ativa quando:** O prompt envolve UI, componentes, páginas, formulários, estado, estilo

**Comportamento:**
- Usa shadcn/ui como base — customiza, não reinventa
- Componentes pequenos e composáveis
- Formulários: React Hook Form + Zod + `useController` (NUNCA `register` direto em shadcn)
- Campos reutilizáveis em `src/components/form/` (FormInput, FormSelect, etc.)
- TanStack Query v5 para server state com `queryOptions()` helper
- TanStack Router para navegação (file-based routing, NUNCA React Router)
- Route loaders com `ensureQueryData` para pre-fetch
- Search params tipados com `validateSearch` + Zod
- Axios como HTTP client com interceptors
- Zustand ou Context para client state simples
- Nunca CSS inline — sempre Tailwind classes

**Padrões de arquivo:**
```
src/
├── routes/
│   ├── __root.tsx           # Root layout com providers
│   ├── _authenticated.tsx   # Auth guard layout
│   └── _authenticated/
│       └── [feature]/       # File-based routes
├── components/
│   ├── ui/                  # shadcn/ui (NÃO EDITAR)
│   ├── form/                # FormInput, FormSelect, etc. (useController)
│   └── [feature]/           # Feature components
├── hooks/                   # queryOptions + useQuery/useMutation
├── lib/
│   ├── api.ts               # Axios instance
│   ├── api/                 # API functions por entidade
│   └── query-client.ts      # QueryClient config
├── validators/              # Zod schemas
├── types/                   # TypeScript interfaces
└── __tests__/
```

---

## 🧪 Agente: QA Engineer

**Ativa quando:** O prompt menciona "teste", "test", "cobertura", "coverage", "bug", "regressão"

**Comportamento:**
- Backend: pytest + httpx AsyncClient para testes de API
- Frontend: Vitest + Testing Library para componentes
- Testa happy path E edge cases
- Usa factories/fixtures, nunca dados hardcoded
- Mocks apenas no boundary (API calls, DB)
- Todo bug fix acompanha teste de regressão

**Estrutura de teste:**
```python
# Backend pattern
class TestNomeFeature:
    async def test_should_do_x_when_y(self, client, db_session):
        # Arrange
        # Act
        # Assert

    async def test_should_fail_when_z(self, client):
        # Arrange
        # Act
        # Assert
```

```typescript
// Frontend pattern
describe('ComponentName', () => {
  it('should render X when Y', () => {
    // arrange → render → assert
  });

  it('should handle Z error', () => {
    // arrange → render → act → assert
  });
});
```

---

## 🔒 Agente: Security Reviewer

**Ativa quando:** O prompt menciona "segurança", "security", "auth", "vulnerabilidade", "review de segurança"

**Comportamento:**
- Audita inputs não sanitizados
- Verifica SQL injection (mesmo com ORM)
- Checa XSS em renderização de dados do usuário
- Valida autenticação e autorização em todas as rotas
- Verifica exposição de dados sensíveis em responses
- Checa headers de segurança (CORS, CSP, HSTS)
- Verifica rate limiting em endpoints públicos
- Revisa .env e secrets management

---

## 📦 Agente: DevOps

**Ativa quando:** O prompt menciona "deploy", "docker", "CI/CD", "infra", "ambiente"

**Comportamento:**
- Docker multi-stage builds (build vs runtime)
- docker-compose para desenvolvimento local
- Health checks em todos os serviços
- Environment-specific configs (dev, staging, prod)
- Migrations rodam automaticamente no deploy
- Logs estruturados para observabilidade

---

## Seleção Automática

Se o prompt não se encaixa claramente em um agente, Claude deve:
1. Identificar a natureza primária da tarefa
2. Combinar agentes se necessário (ex: feature nova = Arquiteto + Backend + Frontend)
3. Executar na ordem lógica de dependências
