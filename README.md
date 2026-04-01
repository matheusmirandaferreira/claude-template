# claude-config

Configuração compartilhada do Claude Code para os projetos da empresa.

## O que faz

O script `setup-claude.sh` instala **apenas** os slash commands e settings do Claude Code no projeto. Ele **não toca** em `CLAUDE.md` — isso é responsabilidade de cada projeto.

## Instalação

```bash
# 1. Clone uma vez
git clone https://github.com/EMPRESA/claude-config.git ~/claude-config

# 2. No seu projeto
cd ~/projetos/meu-projeto
~/claude-config/setup-claude.sh
```

Resultado:
```
meu-projeto/
├── .claude/
│   ├── settings.json       ← Permissões
│   └── commands/            ← 10 slash commands
│       ├── feature.md
│       ├── fix.md
│       ├── improve.md
│       ├── crud.md
│       ├── review.md
│       ├── test.md
│       ├── migrate.md
│       ├── security-audit.md
│       ├── status.md
│       └── pre-deploy.md
```

## CLAUDE.md — responsabilidade do projeto

O `CLAUDE.md` é o arquivo mais importante. Ele define os padrões, patterns e comandos da stack do projeto. Cada projeto cria e mantém o seu.

### Templates disponíveis

Use como ponto de partida, copie e **adapte** ao seu projeto:

```bash
# Ver templates disponíveis
ls ~/claude-config/stacks/

# Copiar o que precisa
cp ~/claude-config/stacks/node-express.md ./backend/CLAUDE.md
cp ~/claude-config/stacks/react.md ./frontend/CLAUDE.md

# Projeto single-dir (ex: Laravel)
cp ~/claude-config/stacks/laravel.md ./CLAUDE.md

# EDITE para refletir o projeto real
```

| Template | Stack |
|----------|-------|
| `fastapi.md` | FastAPI + SQLAlchemy + PostgreSQL |
| `laravel.md` | Laravel + Eloquent |
| `node-express.md` | Express + TypeORM |
| `nestjs.md` | NestJS + TypeORM |
| `php.md` | PHP genérico |
| `react.md` | React + Vite + TanStack + shadcn/ui |

Cada template inclui: estrutura de pastas, ordem de implementação, patterns com código, regras e comandos de terminal.

### O que colocar no CLAUDE.md

Um bom CLAUDE.md responde estas perguntas para o Claude Code:
- Qual a stack exata? (versões, libs, ORM)
- Qual a estrutura de pastas?
- Em que ordem implementar? (model → service → route → test)
- Como é o pattern de cada camada? (com código de exemplo)
- O que NUNCA fazer? (regras e proibições)
- Quais os comandos de terminal? (dev, test, lint, migrate)

## Atualização

```bash
# Atualizar commands (quando houver mudança no repo central)
~/claude-config/setup-claude.sh --force
```

## Slash Commands

| Comando | O que faz |
|---------|-----------|
| `/feature` | Implementa feature com plano obrigatório |
| `/fix` | Corrige bug com teste de regressão |
| `/improve` | Refatora com análise de impacto |
| `/crud` | Gera CRUD completo (back + front + tests) |
| `/review` | Code review com checklist de segurança |
| `/test` | Roda testes e gera relatório |
| `/migrate` | Gerencia migrations |
| `/security-audit` | Auditoria de segurança |
| `/status` | Relatório de saúde do projeto |
| `/pre-deploy` | Checklist pré-deploy |

Os commands definem **processo** (planeje → implemente → teste → documente). Os patterns específicos da stack vêm do `CLAUDE.md` do projeto.

## Commitar no projeto

```bash
git add .claude/ CLAUDE.md
git commit -m "chore: add claude config"
```

## Estrutura deste repo

```
claude-config/
├── setup-claude.sh        ← Script (só copia commands + settings)
├── settings.json          ← Permissões do Claude Code
├── commands/              ← Slash commands (processo)
└── stacks/                ← Templates de CLAUDE.md (referência)
    ├── fastapi.md
    ├── laravel.md
    ├── node-express.md
    ├── nestjs.md
    ├── php.md
    └── react.md
```

## Contribuindo

- **Alterar um command** → PR neste repo → time roda `setup-claude.sh --force`
- **Novo template de stack** → crie em `stacks/` e abra PR
- **Alterar CLAUDE.md de um projeto** → edite direto no repo do projeto
