# Claude Team Config

Template de configuracao padronizada do Claude Code para projetos vibe coding.

Instale globalmente uma vez e tenha skills, commands e convencoes prontos em todos os projetos.

## Fluxo de trabalho

```
          ┌─────────────────────────────────────────────────┐
          │              CICLO VIBE CODING                   │
          └─────────────────────────────────────────────────┘

   1. SETUP                    2. DESENVOLVER               3. ENTREGAR
   ──────────                  ──────────────               ──────────
   --global (1x na máquina)    /feature, /fix, /improve     /commit
   project (1x por projeto)    Claude planeja e executa      /code-review
                               Testes rodam a cada passo     /pr-description
                                                             /pre-deploy
```

## Instalacao

### 1. Setup global (uma vez por maquina)

Instala skills, commands, plugins e settings em `~/.claude/` — disponivel em todos os projetos.

```bash
git clone https://github.com/matheusmirandaferreira/claude-template.git ~/claude-config
~/claude-config/scripts/setup.sh --global
```

### 2. Setup por projeto (uma vez por projeto)

Instala hooks de formatacao, CLAUDE.local.md e commands de navegacao (monorepo).

```bash
~/claude-config/scripts/setup.sh /caminho/do/projeto
```

### 3. Migracao de projetos antigos

Se o projeto ja tinha o setup antigo (per-project), limpe as duplicatas:

```bash
~/claude-config/scripts/setup.sh --clean-project /caminho/do/projeto
```

### Setup completo (maquina nova)

```bash
git clone https://github.com/matheusmirandaferreira/claude-template.git ~/claude-config
~/claude-config/scripts/setup.sh --global
~/claude-config/scripts/setup.sh /caminho/do/projeto
```

### Opcoes

| Flag | Descricao |
|------|-----------|
| `--global` | Instala recursos genericos em `~/.claude/` |
| `--link` | Usa symlinks em vez de copias (skills e commands) |
| `--clean-project /path` | Remove duplicatas genericas de um projeto |
| `--help` | Mostra ajuda |

### Git submodule (desenvolvimento com symlinks)

```bash
git submodule add https://github.com/matheusmirandaferreira/claude-template.git .claude-team-config
.claude-team-config/scripts/setup.sh --global --link
```

## O que e instalado onde

### Global (`~/.claude/`) — todos os projetos

| Recurso | Destino |
|---------|---------|
| 8 skills (commit, code-review, debug, etc.) | `~/.claude/skills/` |
| 5 commands (feature, fix, improve, etc.) | `~/.claude/commands/` |
| Plugins (superpowers, frontend-design, LSPs, etc.) | `~/.claude/settings.json` |
| Env vars, permissions baseline, effortLevel | `~/.claude/settings.json` |

### Por projeto (`.claude/` do projeto) — especifico

| Recurso | Destino |
|---------|---------|
| Hooks de formatacao (Black, Prettier) | `.claude/settings.json` |
| Commands de monorepo (/<alias>, /status, /logs) | `.claude/commands/` |
| Skills agregadas dos sub-projetos (monorepo) | `.claude/skills/<alias>-<skill>/` |
| Agents agregados dos sub-projetos (monorepo) | `.claude/agents/<alias>-<agent>.md` |
| Commands agregados dos sub-projetos (monorepo) | `.claude/commands/<alias>-<command>.md` |
| Convencoes do time | `CLAUDE.local.md` |

## Deteccao de tipo de projeto

O setup por projeto detecta automaticamente:

**Monorepo** (2+ pastas com projeto):
```
i  Tipo de projeto detectado: MONOREPO
  Confirma? (Enter = sim, m = forcar monolito):

  Para cada pasta, digite o alias do command:
    Enter     = aceitar sugestao entre [ ]
    novo nome = usar como alias customizado
    -         = pular (nao criar command)

    meuapp_frontend [front]: 
    meuapp_backend [back]: api
    meuapp_socket [socket]: -
```

**Monolito** (projeto unico):
```
i  Tipo de projeto detectado: MONOLITO
i  Projeto monolito — commands de navegacao nao sao necessarios.
```

### Agregacao de recursos (monorepo)

Em monorepos, se os sub-projetos tiverem `.claude/` com skills, commands ou agents, o setup oferece agregar tudo no `.claude/` raiz com prefixo do alias:

```
i  Sub-projetos com recursos Claude detectados:
i    /api (backend/) — 3 skills, 1 agents
i    /front (frontend/) — 2 skills, 1 commands

  Agregar recursos dos sub-projetos ao .claude/ raiz? (Y/n)

✓  Copied: .claude/skills/api-fastapi-crud
✓  Copied: .claude/skills/api-sqlalchemy-patterns
✓  Copied: .claude/agents/api-coder.md
✓  Copied: .claude/skills/front-tanstack-query
```

Isso garante que ao trabalhar no nivel raiz do monorepo, todas as skills especializadas dos sub-projetos ficam acessiveis (ex: `/api-fastapi-crud`, `/front-tanstack-query`).

## Commands e skills disponiveis

### Desenvolvimento

| Command | O que faz |
|---|---|
| `/feature <descricao>` | Planeja, implementa (backend-first), testa e documenta uma feature |
| `/fix <descricao>` | Diagnostica, aplica correcao minima, escreve teste de regressao |
| `/improve <descricao>` | Analisa impacto, refatora incrementalmente, valida com testes |

### Qualidade e entrega

| Skill | Quando usar |
|---|---|
| `/commit` | Gera mensagem de commit no padrao Conventional Commits |
| `/code-review` | Revisao automatizada antes de abrir PR |
| `/pr-description` | Gera descricao de PR com contexto, mudancas e checklist |
| `/test-gen` | Gera testes unitarios e de integracao para codigo existente |
| `/pre-deploy` | Checklist completo: testes, lint, build, seguranca, migrations, docs |

### Ferramentas de suporte

| Skill | Quando usar |
|---|---|
| `/debug` | Investigacao guiada de bugs com analise de causa raiz |
| `/refactor` | Refatoracao com analise de impacto e validacao incremental |
| `/doc-gen` | Gera documentacao tecnica (JSDoc, docstrings, README, API docs) |
| `/security-scan` | Analise de vulnerabilidades (OWASP Top 10, secrets, deps) |

### Navegacao entre repos (monorepo)

| Command | O que faz |
|---|---|
| `/<alias>` | Inspeciona o repo (estrutura, deps, git status) |
| `/status` | Visao geral de todos os repos (branch, diff, ultimo commit) |
| `/logs` | Logs git recentes de todos os repos |

Cada command de repo aceita sub-comandos: `/<alias> status`, `/<alias> deps`, `/<alias> run dev`.

## Estrutura do repo

```
claude-config/
├── .claude/
│   ├── skills/                  # Workflows inteligentes (instalados em ~/.claude/skills/)
│   │   ├── code-review/         # Revisao de codigo
│   │   ├── commit/              # Commits padronizados
│   │   ├── pr-description/      # Descricao de PR
│   │   ├── test-gen/            # Geracao de testes
│   │   ├── refactor/            # Refatoracao guiada
│   │   ├── doc-gen/             # Documentacao
│   │   ├── debug/               # Investigacao de bugs
│   │   └── security-scan/       # Analise de seguranca
│   ├── commands/                # Atalhos (instalados em ~/.claude/commands/)
│   │   ├── feature.md           # /feature
│   │   ├── fix.md               # /fix
│   │   ├── improve.md           # /improve
│   │   └── pre-deploy.md        # /pre-deploy
│   └── settings.json            # Template de settings (merged no global)
├── CLAUDE.md                    # Template de convencoes do time
├── scripts/
│   └── setup.sh                 # Script principal (merge embutido, sem deps externas)
└── README.md
```

## Configuracao

### Settings globais

O merge de settings respeita configs existentes do usuario:

- **Env vars**: adiciona apenas keys que nao existem
- **Plugins**: ativa novos, nao sobrescreve `false` explicito do usuario
- **Permissions**: une arrays sem duplicatas
- **effortLevel**: user prevalece se ja setado
- **Nunca toca**: `teammateMode`, hooks

### Customizacao por projeto

Preencha a secao `## Project-specific` no `CLAUDE.local.md` com detalhes do seu stack.

Crie `.claude/settings.local.json` (gitignored) para overrides pessoais de permissoes.

## Atualizando

```bash
# Atualize o repo
cd ~/claude-config && git pull

# Re-rode o global (idempotente)
~/claude-config/scripts/setup.sh --global
```

Com `--link`, as atualizacoes propagam automaticamente (sem re-rodar).

## Criando skills customizadas

```bash
mkdir -p .claude/skills/minha-skill
cat > .claude/skills/minha-skill/SKILL.md << 'EOF'
---
name: minha-skill
description: Descricao do que faz e quando usar.
---

# Minha Skill

Instrucoes aqui...
EOF
```

## Contribuindo

1. Crie uma branch: `feature/nome-da-skill`
2. Adicione ou edite skills em `.claude/skills/`
3. Teste localmente rodando o Claude Code no projeto
4. Abra um PR com descricao do que a skill faz e quando dispara
