#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# setup-claude.sh — Instala/atualiza configuração Claude Code
# 
# Uso:
#   curl -s https://raw.githubusercontent.com/EMPRESA/claude-config/main/setup-claude.sh | bash
#   ou
#   ./setup-claude.sh [--force] [--backend] [--frontend] [--full]
#
# Flags:
#   --force      Sobrescreve arquivos existentes (exceto CLAUDE.md raiz)
#   --backend    Instala template CLAUDE.md de backend
#   --frontend   Instala template CLAUDE.md de frontend
#   --full       Instala tudo (commands + backend + frontend + docs)
#   --commands   Atualiza apenas os slash commands
#   --dry-run    Mostra o que seria feito sem alterar nada
# ============================================================

REPO_URL="https://raw.githubusercontent.com/EMPRESA/claude-config/main"
VERSION="1.0.0"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FORCE=false
INSTALL_BACKEND=false
INSTALL_FRONTEND=false
INSTALL_COMMANDS=true
INSTALL_DOCS=false
DRY_RUN=false

# Parse args
for arg in "$@"; do
  case $arg in
    --force) FORCE=true ;;
    --backend) INSTALL_BACKEND=true ;;
    --frontend) INSTALL_FRONTEND=true ;;
    --full) INSTALL_BACKEND=true; INSTALL_FRONTEND=true; INSTALL_DOCS=true ;;
    --commands) INSTALL_COMMANDS=true; INSTALL_BACKEND=false; INSTALL_FRONTEND=false ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Uso: ./setup-claude.sh [--force] [--backend] [--frontend] [--full] [--commands] [--dry-run]"
      exit 0
      ;;
  esac
done

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Code Config Setup v${VERSION}    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Detectar se estamos na raiz de um projeto git
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}⚠ Não estamos na raiz de um repositório git.${NC}"
  read -p "Continuar mesmo assim? (y/N) " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Função para copiar arquivo com check
install_file() {
  local src="$1"
  local dest="$2"
  local protect="${3:-false}"  # se true, nunca sobrescreve

  if [ "$DRY_RUN" = true ]; then
    if [ -f "$dest" ]; then
      echo -e "  ${YELLOW}[dry-run] Existe: $dest ($([ "$FORCE" = true ] && [ "$protect" != true ] && echo "seria sobrescrito" || echo "seria preservado"))${NC}"
    else
      echo -e "  ${GREEN}[dry-run] Criaria: $dest${NC}"
    fi
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -f "$dest" ]; then
    if [ "$protect" = true ]; then
      echo -e "  ${YELLOW}⏭ Preservado (editável): $dest${NC}"
      return
    fi
    if [ "$FORCE" = false ]; then
      echo -e "  ${YELLOW}⏭ Já existe: $dest (use --force para sobrescrever)${NC}"
      return
    fi
    echo -e "  ${GREEN}↻ Atualizado: $dest${NC}"
  else
    echo -e "  ${GREEN}✓ Criado: $dest${NC}"
  fi

  cp "$src" "$dest"
}

# Detectar se estamos rodando do repo local ou via curl
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/commands" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
  echo -e "${GREEN}Usando arquivos locais de: $SOURCE_DIR${NC}"
else
  echo -e "${YELLOW}Modo remoto não implementado nesta versão.${NC}"
  echo -e "${YELLOW}Clone o repo e rode localmente: ./setup-claude.sh${NC}"
  exit 1
fi

echo ""

# ── 1. Settings ──
echo -e "${BLUE}[1/5] Settings...${NC}"
install_file "$SOURCE_DIR/settings.json" ".claude/settings.json" false

# ── 2. Commands (sempre instala, sempre sobrescreve) ──
if [ "$INSTALL_COMMANDS" = true ]; then
  echo -e "${BLUE}[2/5] Slash commands...${NC}"
  for cmd_file in "$SOURCE_DIR"/commands/*.md; do
    filename=$(basename "$cmd_file")
    install_file "$cmd_file" ".claude/commands/$filename" false
  done
else
  echo -e "${YELLOW}[2/5] Slash commands... pulado${NC}"
fi

# ── 3. CLAUDE.md raiz ──
echo -e "${BLUE}[3/5] CLAUDE.md raiz...${NC}"
if [ -f "$SOURCE_DIR/CLAUDE.md" ]; then
  install_file "$SOURCE_DIR/CLAUDE.md" "CLAUDE.md" true  # NUNCA sobrescreve
fi

# ── 4. Templates de subprojeto ──
echo -e "${BLUE}[4/5] Templates de subprojeto...${NC}"
if [ "$INSTALL_BACKEND" = true ] && [ -f "$SOURCE_DIR/templates/backend-CLAUDE.md" ]; then
  # Detectar pasta de backend
  BACKEND_DIR=$(find . -maxdepth 1 -type d -name "*backend*" | head -1)
  if [ -n "$BACKEND_DIR" ]; then
    install_file "$SOURCE_DIR/templates/backend-CLAUDE.md" "$BACKEND_DIR/CLAUDE.md" true
    echo -e "  ${GREEN}  → Instalado em $BACKEND_DIR/${NC}"
  else
    echo -e "  ${YELLOW}  Nenhuma pasta *backend* encontrada. Criando template em ./backend-CLAUDE.md.template${NC}"
    install_file "$SOURCE_DIR/templates/backend-CLAUDE.md" "backend-CLAUDE.md.template" false
  fi
elif [ "$INSTALL_BACKEND" = true ]; then
  echo -e "  ${YELLOW}  Template backend não encontrado no source${NC}"
fi

if [ "$INSTALL_FRONTEND" = true ] && [ -f "$SOURCE_DIR/templates/frontend-CLAUDE.md" ]; then
  FRONTEND_DIR=$(find . -maxdepth 1 -type d -name "*frontend*" | head -1)
  if [ -n "$FRONTEND_DIR" ]; then
    install_file "$SOURCE_DIR/templates/frontend-CLAUDE.md" "$FRONTEND_DIR/CLAUDE.md" true
    echo -e "  ${GREEN}  → Instalado em $FRONTEND_DIR/${NC}"
  else
    echo -e "  ${YELLOW}  Nenhuma pasta *frontend* encontrada. Criando template em ./frontend-CLAUDE.md.template${NC}"
    install_file "$SOURCE_DIR/templates/frontend-CLAUDE.md" "frontend-CLAUDE.md.template" false
  fi
elif [ "$INSTALL_FRONTEND" = true ]; then
  echo -e "  ${YELLOW}  Template frontend não encontrado no source${NC}"
fi

# ── 5. Docs ──
if [ "$INSTALL_DOCS" = true ]; then
  echo -e "${BLUE}[5/5] Templates de documentação...${NC}"
  for doc_file in "$SOURCE_DIR"/docs/*.md; do
    filename=$(basename "$doc_file")
    install_file "$doc_file" "docs/$filename" true
  done
else
  echo -e "${YELLOW}[5/5] Docs... pulado (use --full)${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup completo!${NC}"
echo ""
echo -e "Próximos passos:"
echo -e "  1. Revise e adapte o ${BLUE}CLAUDE.md${NC} raiz para o seu projeto"
if [ "$INSTALL_BACKEND" = true ]; then
  echo -e "  2. Revise o ${BLUE}CLAUDE.md${NC} do backend"
fi
if [ "$INSTALL_FRONTEND" = true ]; then
  echo -e "  3. Revise o ${BLUE}CLAUDE.md${NC} do frontend"
fi
echo -e "  4. Teste com: ${BLUE}claude${NC} e use ${BLUE}/feature${NC}, ${BLUE}/fix${NC}, ${BLUE}/crud${NC}, etc."
echo ""
echo -e "${YELLOW}Dica: rode ./setup-claude.sh --commands periodicamente para atualizar os comandos.${NC}"
