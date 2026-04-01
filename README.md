# claude-config

Configuração compartilhada do Claude Code para todos os projetos da empresa.

## Como funciona

O script `setup-claude.sh` **detecta automaticamente** a stack de cada subprojeto e gera `CLAUDE.md` com patterns concretos (exemplos de código, estrutura de pastas, comandos) para que o Claude Code saiba exatamente como codar naquele projeto.

### Stacks suportadas

| Stack | Detecta por | Tipo |
|-------|-------------|------|
| **FastAPI + SQLAlchemy** | `requirements.txt` ou `pyproject.toml` com `fastapi` | backend |
| **Laravel** | `artisan` + `composer.json` com `laravel` | backend |
| **Express + TypeORM** | `package.json` com `express` | backend |
| **NestJS + TypeORM** | `package.json` com `@nestjs/core` | backend |
| **PHP genérico** | `composer.json` sem laravel | backend |
| **React + Vite + TanStack** | `package.json` com `react` | frontend |

## Instalação

```bash
# 1. Clone uma vez
git clone https://github.com/EMPRESA/claude-config.git ~/claude-config

# 2. No seu projeto
cd ~/projetos/meu-projeto
~/claude-config/setup-claude.sh
```

O setup vai:
- Detectar as stacks (ex: `backend/` é Express, `frontend/` é React)
- Gerar `CLAUDE.md` raiz com regras universais
- Gerar `CLAUDE.md` em cada subprojeto com patterns da stack
- Instalar slash commands em `.claude/commands/`
- Instalar `settings.json` com permissões
- Criar templates em `docs/`

## Atualização

```bash
# Atualizar commands (mais comum)
~/claude-config/setup-claude.sh --commands --force

# Reconstruir CLAUDE.md (quando mudar de stack ou atualizar patterns)
~/claude-config/setup-claude.sh --rebuild

# Ver o que faria sem alterar
~/claude-config/setup-claude.sh --dry-run
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

Os commands são **stack-agnostic** — definem o processo (planeje → implemente → teste → documente). Os patterns específicos vêm do `CLAUDE.md` do subprojeto.

## O que commitar

```bash
git add .claude/ CLAUDE.md docs/
# E os CLAUDE.md dos subprojetos
git add backend/CLAUDE.md frontend/CLAUDE.md
git commit -m "chore: add claude config"
```

## Arquitetura

```
claude-config/              ← Este repo (central)
├── setup-claude.sh         ← Script de instalação
├── settings.json           ← Permissões
├── commands/               ← Slash commands (processo)
├── stacks/                 ← Patterns por stack (código)
│   ├── fastapi.md
│   ├── laravel.md
│   ├── node-express.md
│   ├── nestjs.md
│   ├── php.md
│   └── react.md
└── docs/                   ← Templates de documentação

seu-projeto/                ← Após rodar setup
├── CLAUDE.md               ← Gerado (regras universais)
├── .claude/
│   ├── settings.json       ← Copiado
│   └── commands/           ← Copiado
├── backend/
│   └── CLAUDE.md           ← Gerado pela stack detectada
├── frontend/
│   └── CLAUDE.md           ← Gerado pela stack detectada
└── docs/                   ← Templates
```

**Separação de responsabilidades:**
- `CLAUDE.md` raiz → regras universais + workflows
- `subprojeto/CLAUDE.md` → patterns da stack com código real
- `.claude/commands/` → processo (o quê fazer, em que ordem)

## Adicionar nova stack

1. Crie `stacks/minha-stack.md` seguindo o formato (metadata + patterns)
2. Adicione detecção no `setup-claude.sh` na função `detect_in()`
3. Teste com `--dry-run`

## Contribuindo

- Alterar um command → PR neste repo → time roda `--commands --force`
- Alterar patterns de stack → PR neste repo → time roda `--rebuild`
- Alterar algo só no projeto → edite direto no repo do projeto
