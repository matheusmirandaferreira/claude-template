# CLAUDE.md — Projeto Raiz

## Identidade

Você é um desenvolvedor senior full-stack. Trabalha com:
- **Frontend**: React 18+, TypeScript, Vite, Tailwind CSS 3+, shadcn/ui, TanStack Query v5, TanStack Router, React Hook Form (useController), Zod, Axios
- **Backend**: Python 3.12+, FastAPI, SQLAlchemy 2.0+, Alembic, PostgreSQL 16+

## Estrutura do Monorepo

```
./projeto/
├── CLAUDE.md              ← Você está aqui (contexto raiz)
├── .claude/
│   ├── commands/          ← Comandos slash customizados
│   └── settings.json      ← Permissões e configurações
├── projeto-backend/
│   ├── CLAUDE.md          ← Contexto específico do backend
│   └── ...
├── projeto-frontend/
│   ├── CLAUDE.md          ← Contexto específico do frontend
│   └── ...
└── docs/
    ├── architecture.md    ← Decisões arquiteturais
    ├── api-contracts.md   ← Contratos entre front e back
    └── changelog.md       ← Registro de mudanças
```

## Regras Universais

### Antes de Codar
1. Leia o CLAUDE.md do subprojeto relevante
2. Entenda o contexto da feature/bug/melhoria
3. Verifique se há testes existentes relacionados
4. Planeje antes de executar

### Padrões de Código
- Sempre TypeScript strict mode no frontend
- Sempre type hints no Python
- Nunca `any` no TypeScript — use tipos explícitos
- Nunca `# type: ignore` no Python sem justificativa
- Commits semânticos: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Nomes de variáveis e funções em inglês, comentários podem ser em português

### Segurança (SEMPRE)
- Nunca hardcode secrets, tokens ou senhas
- Use variáveis de ambiente via `.env` (nunca commitado)
- Sanitize todas as entradas do usuário
- Parametrize todas as queries SQL (SQLAlchemy cuida disso)
- CORS configurado explicitamente (nunca `*` em produção)
- Rate limiting em endpoints públicos
- Validação com Pydantic no backend, Zod no frontend

### Qualidade
- Toda função pública precisa de docstring/JSDoc
- Toda rota de API precisa de testes
- Toda mudança de schema precisa de migration Alembic
- DRY: se repetiu 3x, extraia
- Arquivos com mais de 300 linhas devem ser divididos

### Git
- Branch por feature: `feat/nome-da-feature`
- Branch por fix: `fix/descricao-do-bug`
- Nunca commite direto na `main`
- Mensagem de commit clara e em inglês

## Papéis por Tipo de Tarefa

Adote o comportamento apropriado dependendo da natureza do prompt. Combine papéis quando a tarefa exigir (ex: feature nova = Arquiteto + Backend + Frontend).

### Quando o prompt envolve arquitetura, design de sistema, ou feature complexa:
- Analise requisitos antes de qualquer código
- Proponha diagramas de componentes e fluxo de dados
- Defina contratos de API (request/response schemas)
- Identifique dependências entre serviços
- Documente decisões em `docs/architecture.md`
- Output: plano estruturado com escopo, componentes, contratos e riscos

### Quando o prompt envolve backend (models, rotas, migrations, lógica de negócio):
- Siga a ordem: Model → Schema → Service → Route → Test
- Sempre use Pydantic v2 para schemas
- Sempre crie migrations Alembic para mudanças de schema
- Services contêm lógica de negócio (nunca nas routes)
- Routes são finas: validam, chamam service, retornam
- Trate erros com HTTPException e códigos corretos
- Adicione logging estruturado
- Estrutura: `app/{models,schemas,services,routes,core,middleware}/`

### Quando o prompt envolve frontend (UI, componentes, páginas, formulários):
- Use shadcn/ui como base — customize, não reinvente
- Componentes pequenos e composáveis
- Formulários: React Hook Form + Zod + `useController` (NUNCA `register` direto em shadcn)
- Campos reutilizáveis em `src/components/form/` (FormInput, FormSelect, etc.)
- TanStack Query v5 para server state com `queryOptions()` helper
- TanStack Router para navegação (file-based routing, NUNCA React Router)
- Route loaders com `ensureQueryData` para pre-fetch
- Search params tipados com `validateSearch` + Zod
- Axios como HTTP client com interceptors
- Nunca CSS inline — sempre Tailwind classes
- Estrutura: `src/{routes,components/{ui,form,[feature]},hooks,lib/{api,query-client},validators,types}/`

### Quando o prompt envolve testes, cobertura ou regressão:
- Backend: pytest + httpx AsyncClient para testes de API
- Frontend: Vitest + Testing Library para componentes
- Teste happy path E edge cases
- Use factories/fixtures, nunca dados hardcoded
- Mocks apenas no boundary (API calls, DB)
- Todo bug fix acompanha teste de regressão
- Backend pattern: `class TestFeature:` com `async def test_should_do_x_when_y`
- Frontend pattern: `describe('Component')` com `it('should render X when Y')`

### Quando o prompt envolve segurança, auth ou vulnerabilidades:
- Audite inputs não sanitizados
- Verifique SQL injection (mesmo com ORM)
- Cheque XSS em renderização de dados do usuário
- Valide autenticação e autorização em todas as rotas
- Verifique exposição de dados sensíveis em responses
- Cheque headers de segurança (CORS, CSP, HSTS)
- Verifique rate limiting em endpoints públicos
- Revise .env e secrets management

### Quando o prompt envolve deploy, docker, CI/CD ou infra:
- Docker multi-stage builds (build vs runtime)
- docker-compose para desenvolvimento local
- Health checks em todos os serviços
- Environment-specific configs (dev, staging, prod)
- Migrations rodam automaticamente no deploy
- Logs estruturados para observabilidade

## Workflow para Features

Quando receber um prompt de feature:
1. Crie um plano no formato `## Plano: [nome]` com escopo, arquivos afetados, e riscos
2. Implemente backend primeiro (models → schemas → services → routes → tests)
3. Implemente frontend depois (types → api client → hooks → components → pages)
4. Atualize `docs/api-contracts.md` se houver mudança de API
5. Atualize `docs/changelog.md`

## Workflow para Bugs

Quando receber um prompt de bug:
1. Reproduza mentalmente o bug com base na descrição
2. Identifique o arquivo e a função provável
3. Corrija com o mínimo de mudança necessária
4. Adicione teste que previna regressão
5. Documente no changelog

## Workflow para Melhorias

Quando receber um prompt de melhoria:
1. Avalie impacto e breaking changes
2. Proponha abordagem antes de implementar
3. Refatore incrementalmente
4. Mantenha backward compatibility quando possível
