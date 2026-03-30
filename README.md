# Claude Code Dev Framework

Framework de configuração para desenvolvimento full-stack com Claude Code.
Transforma prompts de features, bugs e melhorias em código de produção.

## Como Usar

### 1. Instalar o Framework em um Novo Projeto

Copie estes arquivos para a raiz do seu projeto:

```bash
# Estrutura que você precisa
seu-projeto/
├── CLAUDE.md                    # ← Copie e adapte
├── .claude/
│   ├── settings.json            # ← Copie
│   ├── agents.md                # ← Copie
│   └── commands/                # ← Copie toda a pasta
│       ├── feature.md
│       ├── fix.md
│       ├── improve.md
│       ├── review.md
│       ├── test.md
│       ├── crud.md
│       ├── security-audit.md
│       ├── migrate.md
│       ├── status.md
│       ├── add-auth.md
│       ├── dockerize.md
│       └── pre-deploy.md
├── seu-projeto-backend/
│   └── CLAUDE.md                # ← Use o template backend
├── seu-projeto-frontend/
│   └── CLAUDE.md                # ← Use o template frontend
└── docs/
    ├── architecture.md          # ← Copie o template
    ├── api-contracts.md         # ← Copie o template
    └── changelog.md             # ← Copie o template
```

### 2. Comandos Disponíveis (Slash Commands)

No Claude Code, use `/` para acessar os comandos:

| Comando         | O que faz                                          | Exemplo                                              |
|-----------------|-----------------------------------------------------|------------------------------------------------------|
| `/feature`      | Implementa feature end-to-end com plano             | `/feature cadastro de produtos com foto e preço`     |
| `/fix`          | Corrige bug com teste de regressão                  | `/fix login retorna 500 quando email tem acentos`    |
| `/improve`      | Refatora com análise de impacto                     | `/improve extrair lógica de email para um service`   |
| `/crud`         | Gera CRUD completo (back + front + tests + docs)    | `/crud Product`                                      |
| `/review`       | Code review com checklist de segurança              | `/review` ou `/review app/routes/users.py`           |
| `/test`         | Roda testes e gera relatório                        | `/test` ou `/test coverage`                          |
| `/migrate`      | Gerencia migrations Alembic                         | `/migrate generate` ou `/migrate up`                 |
| `/add-auth`     | Adiciona autenticação JWT completa                  | `/add-auth`                                          |
| `/dockerize`    | Configura Docker + docker-compose                   | `/dockerize`                                         |
| `/security-audit` | Auditoria de segurança completa                  | `/security-audit`                                    |
| `/status`       | Relatório de saúde do projeto                       | `/status`                                            |
| `/pre-deploy`   | Checklist pré-deploy automatizado                   | `/pre-deploy`                                        |

### 3. Workflow do Dia a Dia

#### Nova Feature (prompt natural)
```
Preciso de um sistema de notificações. O usuário recebe notificações quando
alguém comenta no post dele. Deve ter um ícone de sino no header com badge
do número de não lidas, e uma página listando todas as notificações.
```
→ Claude vai seguir o workflow de `/feature` automaticamente pelo CLAUDE.md

#### Bug Fix (prompt natural)
```
Bug: quando o usuário tenta editar o perfil sem mudar a foto, 
o backend retorna 422 dizendo que o campo image é obrigatório,
mas deveria ser opcional no update.
```
→ Claude vai seguir o workflow de `/fix`

#### Melhoria (prompt natural)  
```
A listagem de produtos está lenta quando tem mais de 1000 items.
Precisa de paginação no backend e infinite scroll no frontend.
```
→ Claude vai seguir o workflow de `/improve`

### 4. Agentes Automáticos

O Claude seleciona automaticamente o agente certo:

- **Arquiteto** → Para decisões de design e features complexas
- **Backend Engineer** → Para models, APIs, lógica de negócio
- **Frontend Engineer** → Para UI, componentes, estado
- **QA Engineer** → Para testes e cobertura
- **Security Reviewer** → Para auditorias e auth
- **DevOps** → Para Docker, CI/CD, infra

### 5. Padrões Enforçados Automaticamente

O CLAUDE.md garante que o Claude sempre:

- ✅ Planeja antes de codar
- ✅ Implementa backend antes do frontend
- ✅ Cria testes para toda mudança
- ✅ Valida inputs (Pydantic + Zod)
- ✅ Trata loading/error states no frontend
- ✅ Documenta endpoints em api-contracts.md
- ✅ Registra mudanças no changelog
- ✅ Usa commits semânticos
- ✅ Nunca usa `any` no TypeScript
- ✅ Nunca hardcoda secrets
- ✅ Segue a estrutura de pastas definida
- ✅ Formulários com `useController` + shadcn/ui (nunca `register` direto)
- ✅ Rotas com TanStack Router (file-based, nunca React Router)
- ✅ Server state com TanStack Query v5 + `queryOptions()`
- ✅ Route loaders com `ensureQueryData` para pre-fetch
- ✅ Search params tipados com `validateSearch` + Zod
- ✅ API functions com Axios retornando `.then(r => r.data)`

## Customização

### Adicionar Novo Comando

Crie um arquivo `.claude/commands/meu-comando.md`:

```markdown
Descrição do que fazer: $ARGUMENTS

## Processo
1. Passo 1
2. Passo 2

## Regras
- Regra 1
- Regra 2
```

Ficará disponível como `/meu-comando` no Claude Code.

### Adicionar Novo Agente

Edite `.claude/agents.md` e adicione uma nova seção seguindo o padrão.

### Mudar Padrões de Código

Edite o `CLAUDE.md` do subprojeto relevante (backend ou frontend).