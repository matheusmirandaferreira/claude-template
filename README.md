# Claude Team Config

Configurações padronizadas do Claude Code para equipes de desenvolvimento.

Clone este repositório e integre no seu projeto para ter skills, comandos e convenções prontos para uso.

## Estrutura

```
claude-team-config/
├── .claude/
│   ├── skills/                  # Skills invocáveis via /nome ou automaticamente
│   │   ├── code-review/         # /code-review — revisão de código
│   │   ├── commit/              # /commit — commits padronizados
│   │   ├── pr-description/      # /pr-description — gera descrição de PR
│   │   ├── test-gen/            # /test-gen — gera testes
│   │   ├── refactor/            # /refactor — refatoração guiada
│   │   ├── doc-gen/             # /doc-gen — gera documentação
│   │   ├── debug/               # /debug — investigação de bugs
│   │   └── security-scan/       # /security-scan — análise de segurança
│   ├── commands/                # ⚡ Gerado pelo setup.sh (atalhos do projeto)
│   │   ├── front.md             # /front — navega para o frontend
│   │   ├── back.md              # /back — navega para o backend
│   │   ├── status.md            # /status — visão geral dos repos
│   │   └── logs.md              # /logs — logs git recentes
│   └── settings.json            # Permissões e hooks padrão
├── CLAUDE.md                    # Convenções base do time
├── scripts/
│   └── setup.sh                 # Integra configs em um projeto existente
└── README.md
```

## Instalação

### Opção 1: Setup automático (recomendado)

```bash
# De dentro do diretório raiz do seu projeto
curl -fsSL https://raw.githubusercontent.com/<seu-org>/claude-team-config/main/scripts/setup.sh | bash
```

Ou, se já clonou o repo:

```bash
git clone https://github.com/<seu-org>/claude-team-config.git /tmp/claude-team-config
/tmp/claude-team-config/scripts/setup.sh
```

### Opção 2: Git submodule

```bash
# Adiciona como submodule na raiz do projeto
git submodule add https://github.com/<seu-org>/claude-team-config.git .claude-team-config

# Roda o setup para copiar/linkar os arquivos
.claude-team-config/scripts/setup.sh --link
```

### Opção 3: Manual

Copie `.claude/` e `CLAUDE.md` para a raiz do seu projeto.

## Como funciona

### Skills

Skills são instruções em markdown que o Claude Code usa automaticamente ou via `/nome`. Cada skill fica em `.claude/skills/<nome>/SKILL.md`.

| Skill | Comando | Descrição |
|---|---|---|
| code-review | `/code-review` | Revisão de código com checklist padronizado |
| commit | `/commit` | Gera mensagem de commit no padrão Conventional Commits |
| pr-description | `/pr-description` | Gera descrição de PR com contexto e checklist |
| test-gen | `/test-gen` | Gera testes unitários e de integração |
| refactor | `/refactor` | Refatoração com análise de impacto |
| doc-gen | `/doc-gen` | Gera documentação técnica |
| debug | `/debug` | Investigação guiada de bugs |
| security-scan | `/security-scan` | Análise de vulnerabilidades |

### Commands (gerados pelo setup)

Commands são atalhos manuais e diretos, gerados sob medida para cada projeto pelo `setup.sh`. Eles ficam em `.claude/commands/`.

O setup pergunta os repos do projeto e gera commands como:

| Command | Descrição |
|---|---|
| `/front` | Navega e inspeciona o repo frontend |
| `/back` | Navega e inspeciona o repo backend |
| `/status` | Visão geral de todos os repos (branch, diff, último commit) |
| `/logs` | Logs git recentes de todos os repos |

Cada command de repo aceita sub-comandos: `/front status`, `/front deps`, `/front run dev`.

Você pode criar mais commands a qualquer momento adicionando arquivos `.md` em `.claude/commands/`.

### Skills vs Commands — quando usar cada um

- **Skills** → workflows complexos que o Claude pode invocar sozinho (review, testes, debug).
- **Commands** → atalhos determinísticos que você invoca manualmente (navegar entre repos, ver status).

### CLAUDE.md

O `CLAUDE.md` na raiz define convenções globais do time: estilo de código, padrões de commit, estrutura de branches, e regras de arquitetura. Ele é carregado automaticamente pelo Claude Code.

### Customização

Cada projeto pode ter seu próprio `CLAUDE.local.md` (adicionado ao `.gitignore`) para overrides locais.

O `CLAUDE.md` base inclui uma seção `## Project-specific` que deve ser preenchida por cada projeto.

## Atualizando

Se usou submodule:
```bash
git submodule update --remote .claude-team-config
.claude-team-config/scripts/setup.sh --link
```

Se copiou manualmente, re-clone e re-execute o setup.

## Criando skills customizadas

```bash
mkdir -p .claude/skills/minha-skill
cat > .claude/skills/minha-skill/SKILL.md << 'EOF'
---
name: minha-skill
description: Descrição do que faz e quando usar.
---

# Minha Skill

Instruções aqui...
EOF
```

## Contribuindo

1. Crie uma branch: `feature/nome-da-skill`
2. Adicione ou edite skills em `.claude/skills/`
3. Teste localmente rodando o Claude Code no projeto
4. Abra um PR com descrição do que a skill faz e quando dispara
