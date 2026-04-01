#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# setup-claude.sh
#
# Instala/atualiza os slash commands e settings do Claude Code.
# NÃO toca em CLAUDE.md — isso é responsabilidade de cada projeto.
#
# Uso:
#   ~/claude-config/setup-claude.sh           # Instala
#   ~/claude-config/setup-claude.sh --force   # Sobrescreve
#   ~/claude-config/setup-claude.sh --dry-run # Simula
# ============================================================

VERSION="3.0.0"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

FORCE=false
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    --force)   FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Uso: setup-claude.sh [--force] [--dry-run]"
      echo "  --force    Sobrescreve commands e settings existentes"
      echo "  --dry-run  Mostra o que faria sem alterar"
      exit 0 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔═══════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Config Setup v${VERSION}    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════╝${NC}"
echo ""

copy_file() {
  local src="$1" dest="$2"
  if [ "$DRY_RUN" = true ]; then
    [ -f "$dest" ] && echo -e "  ${YELLOW}[dry-run] existe: $dest${NC}" || echo -e "  ${GREEN}[dry-run] criaria: $dest${NC}"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && [ "$FORCE" = false ]; then
    echo -e "  ${YELLOW}⏭ já existe: $dest (use --force)${NC}"
    return
  fi
  [ -f "$dest" ] && echo -e "  ${GREEN}↻ atualizado: $dest${NC}" || echo -e "  ${GREEN}✓ criado: $dest${NC}"
  cp "$src" "$dest"
}

# Settings
echo -e "${BLUE}[1/2] Settings...${NC}"
copy_file "$SCRIPT_DIR/settings.json" ".claude/settings.json"
echo ""

# Commands
echo -e "${BLUE}[2/2] Slash commands...${NC}"
for cmd in "$SCRIPT_DIR"/commands/*.md; do
  [ -f "$cmd" ] || continue
  copy_file "$cmd" ".claude/commands/$(basename "$cmd")"
done
echo ""

# Verificar se existe CLAUDE.md
if [ ! -f "CLAUDE.md" ]; then
  echo -e "${YELLOW}────────────────────────────────────────────${NC}"
  echo -e "${YELLOW}Nenhum CLAUDE.md encontrado na raiz.${NC}"
  echo -e ""
  echo -e "Crie manualmente o CLAUDE.md do projeto com os padrões"
  echo -e "da sua stack. Templates disponíveis em:"
  echo -e "  ${CYAN}$SCRIPT_DIR/stacks/${NC}"
  echo -e ""
  echo -e "Stacks disponíveis:"
  for stack in "$SCRIPT_DIR"/stacks/*.md; do
    [ -f "$stack" ] || continue
    name=$(grep "^# name:" "$stack" | head -1 | sed 's/^# name: //')
    id=$(basename "$stack" .md)
    echo -e "  ${CYAN}${id}${NC} — ${name}"
  done
  echo -e ""
  echo -e "Copie e adapte: ${CYAN}cp $SCRIPT_DIR/stacks/fastapi.md ./CLAUDE.md${NC}"
  echo -e "${YELLOW}────────────────────────────────────────────${NC}"
fi

echo ""
echo -e "${GREEN}✅ Pronto!${NC}"
echo ""
echo -e "${BOLD}Commands disponíveis:${NC}"
for cmd in .claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  echo -e "  ${CYAN}/$(basename "$cmd" .md)${NC}"
done
echo ""
echo -e "Atualizar: ${CYAN}~/claude-config/setup-claude.sh --force${NC}"
