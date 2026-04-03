# Claude Team Config

Template de configuracao padronizada do Claude Code para projetos vibe coding.

Clone, rode o setup no seu projeto e tenha skills, commands e convencoes prontos para uso.

## Fluxo de trabalho

```
          ┌─────────────────────────────────────────────────┐
          │              CICLO VIBE CODING                   │
          └─────────────────────────────────────────────────┘

   1. SETUP                    2. DESENVOLVER               3. ENTREGAR
   ──────────                  ──────────────               ──────────
   setup.sh no projeto         /feature, /fix, /improve     /commit
   Skills + commands           Claude planeja e executa      /code-review
   instalados automatico       Testes rodam a cada passo     /pr-description
                                                             /pre-deploy
```

### 1. Setup do projeto

```bash
git clone https://github.com/matheusmirandaferreira/claude-template.git /tmp/ctc
/tmp/ctc/scripts/setup.sh /caminho/do/seu/projeto
```

O setup detecta as subpastas do projeto e sugere commands automaticamente:

```
i  Repos detectados — aceite ou recuse cada sugestao:

    meuapp_frontend              → /front  "Aplicacao frontend"  (Y/n)
    meuapp_backend               → /back   "API backend"         (Y/n)
```

Resultado: skills, commands, settings e convencoes instalados no projeto.

### 2. Desenvolvimento com commands

Abra o Claude Code no projeto e use os commands para guiar o trabalho:

| Command | O que faz |
|---|---|
| `/feature <descricao>` | Planeja, implementa (backend-first), testa e documenta uma feature |
| `/fix <descricao>` | Diagnostica, aplica correcao minima, escreve teste de regressao |
| `/improve <descricao>` | Analisa impacto, refatora incrementalmente, valida com testes |
| `/review` | Revisao com checklist de seguranca, corretude, qualidade e performance |

Cada command segue um processo estruturado — o Claude planeja antes de codar, testa a cada passo, e documenta ao final.

### 3. Navegacao entre repos

Commands gerados pelo setup para monorepos:

| Command | O que faz |
|---|---|
| `/front` | Inspeciona o repo frontend (estrutura, deps, git status) |
| `/back` | Inspeciona o repo backend |
| `/status` | Visao geral de todos os repos (branch, diff, ultimo commit) |
| `/logs` | Logs git recentes de todos os repos |

Cada command de repo aceita sub-comandos: `/front status`, `/front deps`, `/front run dev`.

### 4. Qualidade e entrega

| Skill | Quando usar |
|---|---|
| `/commit` | Gera mensagem de commit no padrao Conventional Commits |
| `/code-review` | Revisao automatizada antes de abrir PR |
| `/pr-description` | Gera descricao de PR com contexto, mudancas e checklist |
| `/test-gen` | Gera testes unitarios e de integracao para codigo existente |
| `/pre-deploy` | Checklist completo: testes, lint, build, seguranca, migrations, docs |

### 5. Ferramentas de suporte

| Skill | Quando usar |
|---|---|
| `/debug` | Investigacao guiada de bugs com analise de causa raiz |
| `/refactor` | Refatoracao com analise de impacto e validacao incremental |
| `/doc-gen` | Gera documentacao tecnica (JSDoc, docstrings, README, API docs) |
| `/security-scan` | Analise de vulnerabilidades (OWASP Top 10, secrets, deps) |

## Estrutura

```
claude-team-config/
├── .claude/
│   ├── skills/                  # Workflows inteligentes (invocados via /nome)
│   │   ├── code-review/         # Revisao de codigo
│   │   ├── commit/              # Commits padronizados
│   │   ├── pr-description/      # Descricao de PR
│   │   ├── test-gen/            # Geracao de testes
│   │   ├── refactor/            # Refatoracao guiada
│   │   ├── doc-gen/             # Documentacao
│   │   ├── debug/               # Investigacao de bugs
│   │   └── security-scan/       # Analise de seguranca
│   ├── commands/                # Atalhos de projeto (gerados pelo setup)
│   │   ├── feature.md           # /feature — implementa feature
│   │   ├── fix.md               # /fix — corrige bug
│   │   ├── improve.md           # /improve — aplica melhoria
│   │   ├── review.md            # /review — revisao de codigo
│   │   └── pre-deploy.md        # /pre-deploy — checklist de deploy
│   └── settings.json            # Permissoes, hooks e plugins
├── CLAUDE.md                    # Convencoes do time
├── scripts/
│   └── setup.sh                 # Integra configs em projeto existente
└── README.md
```

## Instalacao

### Setup automatico (recomendado)

```bash
# Clone o template
git clone https://github.com/matheusmirandaferreira/claude-template.git /tmp/ctc

# Rode no seu projeto
/tmp/ctc/scripts/setup.sh /caminho/do/projeto
```

O setup:
1. Instala skills e commands no `.claude/` do projeto
2. Copia `settings.json` com permissoes e hooks padrao
3. Detecta subpastas e sugere commands de navegacao
4. Cria `CLAUDE.local.md` para overrides pessoais
5. Atualiza `.gitignore`

### Git submodule

```bash
git submodule add https://github.com/matheusmirandaferreira/claude-template.git .claude-team-config
.claude-team-config/scripts/setup.sh --link
```

### Manual

Copie `.claude/` e `CLAUDE.md` para a raiz do seu projeto.

## Configuracao

### Settings padrao

O `settings.json` inclui:

- **Plan mode** por default — Claude apresenta o plano antes de executar
- **Protecao de secrets** — bloqueia leitura/escrita de `.env` e configs de producao
- **Auto-formatacao** — roda Black (Python) e Prettier (JS/TS) apos cada escrita
- **Plugins** — frontend-design, superpowers, code-review, ui-ux-pro-max, feature-dev

### Customizacao por projeto

Preencha a secao `## Project-specific` no `CLAUDE.md` com detalhes do seu stack.

Crie `CLAUDE.local.md` (gitignored) para preferencias pessoais.

## Atualizando

```bash
# Se usou submodule
git submodule update --remote .claude-team-config
.claude-team-config/scripts/setup.sh --link

# Se copiou manualmente
git pull no template e re-rode setup.sh
```

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
