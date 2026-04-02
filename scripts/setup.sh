#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Team Config — Setup Script
# Integra as configs padrão do time em um projeto existente.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="${1:-.}"  # Diretório do projeto (default: diretório atual)
MODE="${2:---copy}"   # --copy (default) ou --link (symlinks)

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}ℹ${NC}  $1"; }
ok()    { echo -e "${GREEN}✓${NC}  $1"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $1"; }
error() { echo -e "${RED}✗${NC}  $1"; exit 1; }

# Resolve target
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Claude Team Config — Setup           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
info "Config source: $CONFIG_DIR"
info "Target project: $TARGET_DIR"
info "Mode: $MODE"
echo ""

# ─── Verifica se é um projeto git ───────────────────────────────────────────
if [ ! -d "$TARGET_DIR/.git" ]; then
    warn "Diretório alvo não é um repositório git."
    read -p "Continuar mesmo assim? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

# ─── Backup de configs existentes ──────────────────────────────────────────
backup_if_exists() {
    local path="$1"
    if [ -e "$path" ]; then
        local backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backup: $path → $backup"
        cp -r "$path" "$backup"
    fi
}

# ─── Copia ou linka ─────────────────────────────────────────────────────────
install_item() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ "$MODE" = "--link" ]; then
        ln -sfn "$src" "$dest"
        ok "Linked: $dest → $src"
    else
        cp -r "$src" "$dest"
        ok "Copied: $dest"
    fi
}

# ─── Instala .claude/skills ────────────────────────────────────────────────
info "Instalando skills..."
backup_if_exists "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/skills"

for skill_dir in "$CONFIG_DIR/.claude/skills"/*/; do
    skill_name="$(basename "$skill_dir")"
    install_item "$skill_dir" "$TARGET_DIR/.claude/skills/$skill_name"
done

# ─── Instala settings.json ─────────────────────────────────────────────────
if [ -f "$CONFIG_DIR/.claude/settings.json" ]; then
    info "Instalando settings.json..."
    if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
        warn "settings.json já existe no projeto."
        read -p "Sobrescrever? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            backup_if_exists "$TARGET_DIR/.claude/settings.json"
            install_item "$CONFIG_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
        else
            info "Mantendo settings.json existente."
        fi
    else
        install_item "$CONFIG_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
    fi
fi

# ─── Instala .claude/commands ─────────────────────────────────────────────
if [ -d "$CONFIG_DIR/.claude/commands" ]; then
    info "Instalando commands..."
    mkdir -p "$TARGET_DIR/.claude/commands"

    for cmd_file in "$CONFIG_DIR/.claude/commands"/*.md; do
        [ -f "$cmd_file" ] || continue
        cmd_name="$(basename "$cmd_file")"
        dest="$TARGET_DIR/.claude/commands/$cmd_name"
        if [ -f "$dest" ]; then
            warn "Command $cmd_name já existe no projeto, pulando."
        else
            install_item "$cmd_file" "$dest"
        fi
    done
fi

# ─── Instala CLAUDE.md como CLAUDE.local.md ───────────────────────────────
if [ -f "$CONFIG_DIR/CLAUDE.md" ]; then
    info "Instalando CLAUDE.md como CLAUDE.local.md..."
    if [ -f "$TARGET_DIR/CLAUDE.local.md" ]; then
        warn "CLAUDE.local.md já existe no projeto."
        read -p "Sobrescrever? Merge manual recomendado. (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            backup_if_exists "$TARGET_DIR/CLAUDE.local.md"
            install_item "$CONFIG_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.local.md"
        else
            info "Mantendo CLAUDE.local.md existente."
        fi
    else
        install_item "$CONFIG_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.local.md"
    fi
fi

# ─── Gera commands de projeto (atalhos para repos) ────────────────────────
echo ""
info "Configuração de commands (atalhos para navegação entre repos)"
echo ""
echo "  Seu projeto segue a estrutura:"
echo "    ./<projeto>/<projeto>_frontend"
echo "    ./<projeto>/<projeto>_backend"
echo ""

PROJECT_NAME="$(basename "$TARGET_DIR")"
read -p "  Nome do projeto [$PROJECT_NAME]: " input_project
PROJECT_NAME="${input_project:-$PROJECT_NAME}"

# Detecta subdiretórios existentes
DETECTED_REPOS=()
for dir in "$TARGET_DIR"/*/; do
    [ -d "$dir" ] || continue
    dirname="$(basename "$dir")"
    # Ignora diretórios de config
    [[ "$dirname" == .* ]] && continue
    [[ "$dirname" == "node_modules" ]] && continue
    [[ "$dirname" == "scripts" ]] && continue
    DETECTED_REPOS+=("$dirname")
done

if [ ${#DETECTED_REPOS[@]} -gt 0 ]; then
    echo ""
    info "Repos detectados no projeto:"
    for repo in "${DETECTED_REPOS[@]}"; do
        echo "    - $repo"
    done
fi

echo ""
echo "  Defina os repos do projeto (um por linha, vazio para encerrar)."
echo "  Formato: <alias> <path_relativo> <descricao>"
echo ""
echo "  Exemplos:"
echo "    front ${PROJECT_NAME}_frontend    Aplicação frontend React"
echo "    back  ${PROJECT_NAME}_backend     API backend Node.js"
echo "    docs  ${PROJECT_NAME}_docs        Documentação"
echo ""

COMMANDS=()
while true; do
    read -p "  > " cmd_alias cmd_path cmd_desc_rest
    [ -z "$cmd_alias" ] && break

    # Se só passou alias, tenta inferir path
    if [ -z "$cmd_path" ]; then
        cmd_path="$cmd_alias"
        cmd_desc_rest="Navega para $cmd_alias"
    fi
    if [ -z "$cmd_desc_rest" ]; then
        cmd_desc_rest="Navega para $cmd_path"
    fi

    COMMANDS+=("$cmd_alias|$cmd_path|$cmd_desc_rest")
done

if [ ${#COMMANDS[@]} -gt 0 ]; then
    info "Gerando commands..."
    mkdir -p "$TARGET_DIR/.claude/commands"

    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r alias path desc <<< "$cmd_entry"

        cat > "$TARGET_DIR/.claude/commands/${alias}.md" << CMDEOF
---
description: ${desc}
---

Mude o contexto de trabalho para o repositório **${path}** dentro deste projeto.

1. Liste a estrutura do diretório \`${path}/\` (2 níveis de profundidade).
2. Se existir \`${path}/README.md\`, leia e resuma brevemente.
3. Se existir \`${path}/package.json\` ou \`${path}/pyproject.toml\`, identifique os scripts/commands disponíveis.
4. Reporte o status git desse diretório: branch atual, arquivos modificados, commits recentes.

Se \$ARGUMENTS for fornecido, trate como um sub-comando:
- "status" → git status + branch + últimos 5 commits
- "deps" → lista dependências e versões
- "run <script>" → executa o script indicado
- qualquer outra coisa → interprete como instrução a executar no contexto de ${path}/
CMDEOF

        ok "Criado command: /${alias} → ${path}/"
    done

    # Gera um /status geral se não existe
    if [ ! -f "$TARGET_DIR/.claude/commands/status.md" ]; then
        # Monta lista de paths para o command status
        STATUS_PATHS=""
        for cmd_entry in "${COMMANDS[@]}"; do
            IFS='|' read -r alias path desc <<< "$cmd_entry"
            STATUS_PATHS="${STATUS_PATHS}\n- \`${path}/\`"
        done

        cat > "$TARGET_DIR/.claude/commands/status.md" << CMDEOF
---
description: Visão geral do status de todos os repos do projeto
---

Dê uma visão geral rápida de todos os repos deste projeto:

Para cada diretório abaixo:
$(echo -e "$STATUS_PATHS")

Reporte:
1. Branch atual
2. Arquivos modificados (staged e unstaged)
3. Último commit (hash curto + mensagem)
4. Se há divergência com origin (ahead/behind)

Formate como uma tabela compacta.
CMDEOF

        ok "Criado command: /status → visão geral de todos os repos"
    fi

    # Gera /logs se não existe
    if [ ! -f "$TARGET_DIR/.claude/commands/logs.md" ]; then
        cat > "$TARGET_DIR/.claude/commands/logs.md" << 'CMDEOF'
---
description: Mostra logs recentes de todos ou um repo específico
---

Mostre os logs git recentes do projeto.

Se $ARGUMENTS especificar um repo (ex: "front", "back"), mostre apenas desse repo.
Caso contrário, mostre de todos os repos do projeto.

Para cada repo:
1. Últimos 10 commits: hash curto, autor, data relativa, mensagem.
2. Destaque commits das últimas 24h.
3. Se há commits não pushados, avise.
CMDEOF

        ok "Criado command: /logs → logs git do projeto"
    fi
else
    info "Nenhum command configurado. Você pode criar depois em .claude/commands/"
fi

echo ""

# ─── Atualiza .gitignore ──────────────────────────────────────────────────
info "Verificando .gitignore..."
GITIGNORE="$TARGET_DIR/.gitignore"
ENTRIES=("CLAUDE.local.md" ".claude/settings.local.json")

for entry in "${ENTRIES[@]}"; do
    if [ -f "$GITIGNORE" ] && grep -qF "$entry" "$GITIGNORE"; then
        info "$entry já está no .gitignore"
    else
        echo "$entry" >> "$GITIGNORE"
        ok "Adicionado $entry ao .gitignore"
    fi
done

# ─── Cria CLAUDE.local.md de exemplo ──────────────────────────────────────
if [ ! -f "$TARGET_DIR/CLAUDE.local.md" ]; then
    cat > "$TARGET_DIR/CLAUDE.local.md" << 'EOF'
# Local Overrides

<!-- Este arquivo não é commitado. Use para configs pessoais. -->
<!-- Exemplos: modelo preferido, estilo de output, etc. -->
EOF
    ok "Criado CLAUDE.local.md (template)"
fi

# ─── Resumo ────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Setup completo!                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "Skills disponíveis (workflows inteligentes):"
for skill_dir in "$TARGET_DIR/.claude/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    echo "  /$skill_name"
done
echo ""

if [ -d "$TARGET_DIR/.claude/commands" ] && [ "$(ls -A "$TARGET_DIR/.claude/commands" 2>/dev/null)" ]; then
    echo "Commands disponíveis (atalhos de projeto):"
    for cmd_file in "$TARGET_DIR/.claude/commands"/*.md; do
        [ -f "$cmd_file" ] || continue
        cmd_name="$(basename "$cmd_file" .md)"
        echo "  /$cmd_name"
    done
    echo ""
fi

echo "Próximos passos:"
echo "  1. Revise e customize o CLAUDE.md (seção Project-specific)"
echo "  2. Ajuste .claude/settings.json para seu stack"
echo "  3. Abra o Claude Code no projeto e teste: /commit, /code-review, etc."
echo "  4. Crie mais commands em .claude/commands/ conforme necessidade"
echo ""
