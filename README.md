# claude-config

Configuração compartilhada do Claude Code para os projetos da empresa.
Padroniza comandos, regras de código e workflows entre todos os repositórios.

## Estrutura deste repo

```
claude-config/
├── setup-claude.sh                # Script de instalação
├── CLAUDE.md                      # Template raiz (regras universais)
├── settings.json                  # Permissões do Claude Code
├── commands/                      # Slash commands compartilhados
│   ├── feature.md
│   ├── fix.md
│   ├── improve.md
│   ├── crud.md
│   ├── review.md
│   ├── test.md
│   ├── migrate.md
│   ├── security-audit.md
│   ├── status.md
│   └── pre-deploy.md
├── templates/
│   ├── backend-CLAUDE.md          # CLAUDE.md para projetos FastAPI
│   └── frontend-CLAUDE.md         # CLAUDE.md para projetos React
└── docs/
    ├── api-contracts.md           # Template de contratos de API
    ├── architecture.md            # Template de ADRs
    └── changelog.md               # Template de changelog
```

## Como usar

### Primeira vez no projeto

```bash
# 1. Clone este repo em algum lugar da sua máquina
git clone git@github.com:EMPRESA/claude-config.git ~/claude-config

# 2. Vá para o seu projeto
cd ~/projetos/meu-projeto

# 3. Rode o setup
~/claude-config/setup-claude.sh --full
```

O que acontece:
- Copia `.claude/settings.json` e `.claude/commands/` para o projeto
- Cria `CLAUDE.md` raiz se não existir (nunca sobrescreve o existente)
- Detecta pastas `*backend*` e `*frontend*` e instala os CLAUDE.md específicos
- Cria templates de documentação em `docs/`

### Atualizar apenas os comandos

Quando atualizarmos comandos no repo central:

```bash
cd ~/projetos/meu-projeto
~/claude-config/setup-claude.sh --commands --force
```

O `--force` sobrescreve os commands existentes. O `CLAUDE.md` raiz nunca é sobrescrito (é marcado como editável por projeto).

### Flags disponíveis

| Flag          | O que faz                                           |
|---------------|-----------------------------------------------------|
| `--full`      | Instala tudo (commands + backend + frontend + docs) |
| `--commands`  | Atualiza apenas os slash commands                   |
| `--backend`   | Instala template CLAUDE.md de backend               |
| `--frontend`  | Instala template CLAUDE.md de frontend              |
| `--force`     | Sobrescreve arquivos (exceto CLAUDE.md raiz)        |
| `--dry-run`   | Mostra o que seria feito sem alterar nada            |

## O que commitar no seu projeto

Após rodar o setup, commite tudo que foi gerado:

```bash
git add .claude/ CLAUDE.md docs/
git commit -m "chore: add claude code config"
```

Esses arquivos devem ficar no repositório do projeto para que todos os devs do time tenham acesso.

## Fluxo de atualização

```
┌──────────────────┐     setup-claude.sh     ┌──────────────────┐
│  claude-config   │ ──────────────────────>  │   projeto-api    │
│  (repo central)  │      --commands          │  .claude/commands│
│                  │      --force             │  CLAUDE.md       │
└──────────────────┘                          └──────────────────┘
                     ╲
                      ╲  setup-claude.sh      ┌──────────────────┐
                       ╲ ──────────────────>  │  projeto-admin   │
                          --commands           │  .claude/commands│
                          --force              │  CLAUDE.md       │
                                              └──────────────────┘
```

**Arquivos centralizados** (sobrescrevem com `--force`):
- `.claude/commands/*.md` — Comandos padronizados
- `.claude/settings.json` — Permissões

**Arquivos locais** (nunca sobrescritos):
- `CLAUDE.md` raiz — Cada projeto adapta para seu contexto
- `*/CLAUDE.md` nos subprojetos — Cada backend/frontend tem suas particularidades
- `docs/*` — Documentação viva do projeto

## Customização por projeto

O `CLAUDE.md` raiz instalado pelo setup é um template. Cada projeto deve adaptar:

1. **Nome do projeto** — Trocar `[projeto]` pelo nome real
2. **Stack específica** — Se algum projeto usa algo diferente, ajustar
3. **Regras adicionais** — Adicionar regras específicas do domínio
4. **Workflows** — Adaptar se o projeto tem particularidades

Os slash commands em `.claude/commands/` são genéricos e funcionam em qualquer projeto. Se precisar de um comando específico, crie direto no projeto — o setup não apaga commands que não existem no repo central.

## Contribuindo

Para alterar um comando ou regra que afeta todos os projetos:

1. Crie uma branch neste repo
2. Faça a alteração
3. Abra PR com descrição do impacto
4. Após merge, avise o time para rodar `setup-claude.sh --commands --force`

Para alterações que só afetam um projeto, edite direto no repositório do projeto.
