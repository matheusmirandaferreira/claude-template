# Decisões Arquiteturais

> Registro de decisões técnicas importantes do projeto.
> Formato: ADR (Architecture Decision Record)

---

## ADR-001: Monorepo com repositórios separados por camada

**Data**: [data de criação do projeto]
**Status**: Aceito

**Contexto**: Precisamos organizar backend e frontend de forma que possam evoluir independentemente mas compartilhem contexto.

**Decisão**: Usar uma pasta raiz com subdiretórios para cada serviço:
```
./projeto/
├── projeto-backend/
├── projeto-frontend/
└── CLAUDE.md
```

**Consequências**:
- ✅ Cada serviço tem suas dependências isoladas
- ✅ Deploy independente possível
- ✅ CLAUDE.md raiz mantém contexto compartilhado
- ⚠️ Contratos de API precisam ser mantidos manualmente

---

## ADR-002: SQLAlchemy 2.0 async + Alembic

**Data**: [data de criação do projeto]
**Status**: Aceito

**Contexto**: Precisamos de um ORM robusto com suporte a async e migrations confiáveis.

**Decisão**: SQLAlchemy 2.0 com asyncpg driver e Alembic para migrations.

**Consequências**:
- ✅ Performance com async I/O
- ✅ Migrations versionadas e reversíveis
- ✅ Type safety com mapped_column
- ⚠️ Curva de aprendizado maior que ORMs mais simples

---

## ADR-003: TanStack Query v5 + TanStack Router

**Data**: [data de criação do projeto]
**Status**: Aceito

**Contexto**: Precisamos de server state management robusto e roteamento type-safe com data pre-fetching.

**Decisão**: 
- TanStack Query v5 com Axios para server state
- TanStack Router para file-based routing com type safety total
- `queryOptions()` compartilhados entre hooks e route loaders
- Route loaders com `ensureQueryData` para pre-fetch

**Consequências**:
- ✅ Cache automático e invalidação inteligente
- ✅ Rotas 100% tipadas (params, search params, loaders)
- ✅ Pre-fetch automático no hover (`defaultPreload: 'intent'`)
- ✅ Search params validados com Zod (`validateSearch`)
- ✅ Sem waterfall de requests (dados carregam no loader)
- ⚠️ Não usar React Router — migração completa para TanStack Router
- ⚠️ Não usar para client-only state (usar Zustand ou Context)

---

## ADR-003b: React Hook Form + useController + shadcn/ui

**Data**: [data de criação do projeto]
**Status**: Aceito

**Contexto**: shadcn/ui usa Radix primitives que não suportam `register` do React Hook Form. Precisamos de uma integração que funcione com componentes controlados.

**Decisão**: 
- `useController` para integrar RHF com shadcn/ui
- Componentes genéricos em `src/components/form/` (FormInput, FormSelect, etc.)
- Cada FormField recebe `control` e `name` tipados
- Zod schemas em `src/validators/` separados dos types

**Consequências**:
- ✅ Type-safe end-to-end (Zod → RHF → componente)
- ✅ Componentes reutilizáveis em qualquer formulário
- ✅ Validação visual integrada com shadcn/ui (erro em vermelho)
- ✅ Sem warnings de uncontrolled → controlled
- ⚠️ Nunca usar `register` direto em componentes Radix
- ⚠️ Nunca usar `<Form>` do shadcn — usar `<form>` nativo

---

## ADR-004: shadcn/ui como design system base

**Data**: [data de criação do projeto]
**Status**: Aceito

**Contexto**: Precisamos de componentes acessíveis e customizáveis sem o overhead de um design system completo.

**Decisão**: shadcn/ui como fundação — componentes são copiados para o projeto e customizados.

**Consequências**:
- ✅ Componentes acessíveis (Radix primitives)
- ✅ Totalmente customizável via Tailwind
- ✅ Sem dependência de versão de lib
- ⚠️ Updates manuais quando necessário

---

<!-- 
TEMPLATE para novas ADRs:

## ADR-XXX: [Título da decisão]

**Data**: YYYY-MM-DD
**Status**: Proposto | Aceito | Depreciado | Substituído por ADR-XXX

**Contexto**: [Por que essa decisão é necessária]

**Decisão**: [O que foi decidido]

**Alternativas consideradas**:
1. [Alternativa A] — [por que não]
2. [Alternativa B] — [por que não]

**Consequências**:
- ✅ [benefício]
- ⚠️ [trade-off]
- ❌ [desvantagem aceita]
-->
