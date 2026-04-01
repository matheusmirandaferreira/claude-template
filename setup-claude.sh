#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# setup-claude.sh v2
#
# Detecta a stack de cada subprojeto e gera CLAUDE.md com
# patterns concretos para o Claude Code.
#
# Uso:
#   ~/claude-config/setup-claude.sh              # Detecta e instala
#   ~/claude-config/setup-claude.sh --force       # Sobrescreve tudo
#   ~/claude-config/setup-claude.sh --commands    # Só commands
#   ~/claude-config/setup-claude.sh --rebuild     # Reconstrói CLAUDE.md
#   ~/claude-config/setup-claude.sh --dry-run     # Simula
# ============================================================

VERSION="2.0.0"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

FORCE=false
DRY_RUN=false
ONLY_COMMANDS=false
REBUILD=false

for arg in "$@"; do
  case $arg in
    --force)    FORCE=true ;;
    --dry-run)  DRY_RUN=true ;;
    --commands) ONLY_COMMANDS=true ;;
    --rebuild)  REBUILD=true ;;
    --help|-h)
      echo "Uso: setup-claude.sh [--force] [--dry-run] [--commands] [--rebuild]"
      echo "  --force      Sobrescreve commands e settings"
      echo "  --commands   Atualiza apenas slash commands"
      echo "  --rebuild    Reconstrói todos os CLAUDE.md"
      echo "  --dry-run    Mostra sem alterar"
      exit 0 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Code Config Setup v${VERSION}         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
echo ""

# ─── HELPERS ──────────────────────────────────────────────

write_file() {
  local dest="$1" content="$2" protect="${3:-false}"
  if [ "$DRY_RUN" = true ]; then
    [ -f "$dest" ] && echo -e "  ${YELLOW}[dry-run] existe: $dest${NC}" || echo -e "  ${GREEN}[dry-run] criaria: $dest${NC}"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && [ "$protect" = "true" ] && [ "$FORCE" = false ] && [ "$REBUILD" = false ]; then
    echo -e "  ${YELLOW}⏭ preservado: $dest${NC}"
    return
  fi
  [ -f "$dest" ] && echo -e "  ${GREEN}↻ atualizado: $dest${NC}" || echo -e "  ${GREEN}✓ criado: $dest${NC}"
  printf '%s\n' "$content" > "$dest"
}

copy_file() {
  local src="$1" dest="$2" protect="${3:-false}"
  if [ "$DRY_RUN" = true ]; then
    [ -f "$dest" ] && echo -e "  ${YELLOW}[dry-run] existe: $dest${NC}" || echo -e "  ${GREEN}[dry-run] criaria: $dest${NC}"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && [ "$protect" = "true" ] && [ "$FORCE" = false ] && [ "$REBUILD" = false ]; then
    echo -e "  ${YELLOW}⏭ preservado: $dest${NC}"
    return
  fi
  [ -f "$dest" ] && echo -e "  ${GREEN}↻ atualizado: $dest${NC}" || echo -e "  ${GREEN}✓ criado: $dest${NC}"
  cp "$src" "$dest"
}

# Extrai conteúdo do stack file sem as linhas de metadata
stack_content() {
  sed '/^# id:/d; /^# name:/d; /^# type:/d; /^# detect:/d' "$1"
}

stack_meta() {
  grep "^# $1:" "$2" 2>/dev/null | head -1 | sed "s/^# $1: //"
}

# ─── DETECÇÃO ─────────────────────────────────────────────

DIRS=()
STACKS=()
LABELS=()
TYPES=()

detect_in() {
  local dir="$1" label="$2"
  local pkg="$dir/package.json"
  local comp="$dir/composer.json"
  local reqs="$dir/requirements.txt"
  local pyproj="$dir/pyproject.toml"

  # NestJS (antes de express, pois pode ter ambos)
  if [ -f "$pkg" ] && grep -q '"@nestjs/core"' "$pkg" 2>/dev/null; then
    DIRS+=("$dir"); STACKS+=("nestjs"); LABELS+=("$label NestJS + TypeORM"); TYPES+=("backend"); return
  fi

  # Express (checa TypeORM, Prisma, Drizzle, ou genérico)
  if [ -f "$pkg" ] && grep -q '"express"' "$pkg" 2>/dev/null; then
    DIRS+=("$dir"); STACKS+=("node-express"); LABELS+=("$label Express"); TYPES+=("backend"); return
  fi

  # Fastify
  if [ -f "$pkg" ] && grep -q '"fastify"' "$pkg" 2>/dev/null; then
    DIRS+=("$dir"); STACKS+=("node-express"); LABELS+=("$label Fastify"); TYPES+=("backend"); return
  fi

  # React frontend
  if [ -f "$pkg" ] && grep -q '"react"' "$pkg" 2>/dev/null; then
    DIRS+=("$dir"); STACKS+=("react"); LABELS+=("$label React + TypeScript"); TYPES+=("frontend"); return
  fi

  # Node genérico (tem package.json com src/ mas não é react nem framework conhecido)
  if [ -f "$pkg" ] && [ -d "$dir/src" ] && ! grep -qE '"react"|"vue"|"@angular"' "$pkg" 2>/dev/null; then
    # Só se não for frontend framework
    if grep -qE '"typescript"' "$pkg" 2>/dev/null; then
      DIRS+=("$dir"); STACKS+=("node-express"); LABELS+=("$label Node.js Backend"); TYPES+=("backend"); return
    fi
  fi

  # FastAPI
  if [ -f "$reqs" ] && grep -qi "fastapi" "$reqs" 2>/dev/null; then
    DIRS+=("$dir"); STACKS+=("fastapi"); LABELS+=("$label FastAPI"); TYPES+=("backend"); return
  fi
  if [ -f "$pyproj" ] && grep -qi "fastapi" "$pyproj" 2>/dev/null; then
    DIRS+=("$dir"); STACKS+=("fastapi"); LABELS+=("$label FastAPI"); TYPES+=("backend"); return
  fi

  # Laravel
  if [ -f "$dir/artisan" ] && [ -f "$comp" ] && grep -q "laravel" "$comp" 2>/dev/null; then
    DIRS+=("$dir"); STACKS+=("laravel"); LABELS+=("$label Laravel"); TYPES+=("backend"); return
  fi

  # PHP genérico
  if [ -f "$comp" ]; then
    DIRS+=("$dir"); STACKS+=("php"); LABELS+=("$label PHP"); TYPES+=("backend"); return
  fi
}

echo -e "${CYAN}Detectando stacks...${NC}"

# Raiz
detect_in "." ""

# Subdiretórios (1 nível)
for sub in */; do
  [ -d "$sub" ] || continue
  case "$sub" in
    .claude/|.git/|node_modules/|vendor/|docs/|dist/|build/|__pycache__/) continue ;;
  esac
  detect_in "${sub%/}" "${sub%/}/"
done

if [ ${#STACKS[@]} -eq 0 ]; then
  echo -e "${YELLOW}⚠ Nenhuma stack detectada. Instalando apenas commands e settings.${NC}"
else
  echo ""
  for i in "${!STACKS[@]}"; do
    echo -e "  ${GREEN}✓${NC} ${LABELS[$i]} ${CYAN}(${STACKS[$i]})${NC} → ${DIRS[$i]}/"
  done
fi
echo ""

# ─── 1. SETTINGS ─────────────────────────────────────────

if [ "$ONLY_COMMANDS" = false ]; then
  echo -e "${BLUE}[1/4] Settings...${NC}"
  copy_file "$SCRIPT_DIR/settings.json" ".claude/settings.json" false
  echo ""
fi

# ─── 2. COMMANDS ─────────────────────────────────────────

echo -e "${BLUE}[2/4] Slash commands...${NC}"
for cmd in "$SCRIPT_DIR"/commands/*.md; do
  [ -f "$cmd" ] || continue
  copy_file "$cmd" ".claude/commands/$(basename "$cmd")" false
done
echo ""

[ "$ONLY_COMMANDS" = true ] && { echo -e "${GREEN}✅ Commands atualizados!${NC}"; exit 0; }

# ─── 3. CLAUDE.md RAIZ ──────────────────────────────────

echo -e "${BLUE}[3/4] CLAUDE.md raiz...${NC}"

# Montar identidade
IDENTITY=""
for i in "${!STACKS[@]}"; do
  type="${TYPES[$i]}"
  label="${LABELS[$i]}"
  dir="${DIRS[$i]}"
  [ "$dir" = "." ] && loc="(raiz)" || loc="(\`${dir}/\`)"
  IDENTITY+="- **${type^}**: ${label} ${loc}"$'\n'
done

# Montar CLAUDE.md
ROOT_CLAUDE="# CLAUDE.md — Projeto

## Identidade

Você é um desenvolvedor senior. Trabalha com:
${IDENTITY}
Cada subprojeto tem seu próprio CLAUDE.md com patterns e comandos específicos da stack. Leia-o antes de codar naquele diretório.

## Regras Universais

### Antes de Codar
1. Leia o CLAUDE.md do diretório onde vai trabalhar
2. Entenda o contexto da feature/bug/melhoria
3. Verifique testes existentes relacionados
4. Planeje antes de executar

### Padrões de Código
- Tipagem forte sempre (TypeScript strict, type hints Python, strict_types PHP)
- Nunca suprima warnings de tipo sem justificativa
- Commits semânticos: feat:, fix:, refactor:, docs:, test:, chore:
- Variáveis e funções em inglês, comentários podem ser em português
- DRY: repetiu 3x, extraia
- Arquivos > 300 linhas devem ser divididos
- Toda função pública precisa de docstring/JSDoc/PHPDoc

### Segurança
- Nunca hardcode secrets — use .env (nunca commitado)
- Sanitize toda entrada do usuário
- Sempre ORM/prepared statements (nunca SQL concatenado)
- CORS explícito (nunca \`*\` em produção)
- Rate limiting em endpoints públicos
- Validação server-side obrigatória

### Git
- Branch: feat/nome ou fix/nome
- Nunca commit direto na main
- Mensagem clara em inglês

## Workflow para Features

1. Plano com escopo, arquivos afetados, riscos — apresente ANTES de codar
2. Backend primeiro (model → validação → service → route → test)
3. Frontend depois (types → api → hooks → components → pages)
4. Atualize docs/api-contracts.md e docs/changelog.md

## Workflow para Bugs

1. Diagnosticar causa raiz
2. Correção mínima
3. Teste de regressão
4. Documentar no changelog

## Workflow para Melhorias

1. Avaliar impacto e breaking changes
2. Propor antes de implementar
3. Refatorar incrementalmente
4. Manter backward compatibility"

write_file "CLAUDE.md" "$ROOT_CLAUDE" "true"
echo ""

# ─── 4. CLAUDE.md POR SUBPROJETO ─────────────────────────

echo -e "${BLUE}[4/4] CLAUDE.md por subprojeto...${NC}"

for i in "${!STACKS[@]}"; do
  stack="${STACKS[$i]}"
  dir="${DIRS[$i]}"
  label="${LABELS[$i]}"
  stack_file="$SCRIPT_DIR/stacks/${stack}.md"

  if [ ! -f "$stack_file" ]; then
    echo -e "  ${YELLOW}⚠ Stack file não encontrado: stacks/${stack}.md${NC}"
    continue
  fi

  content="# CLAUDE.md — ${label}
$(stack_content "$stack_file")"

  if [ "$dir" = "." ]; then
    # Projeto single-dir: anexar ao CLAUDE.md raiz
    if [ "$DRY_RUN" = false ]; then
      printf '\n%s\n' "$content" >> "CLAUDE.md"
      echo -e "  ${GREEN}✓ Stack ${stack} anexada ao CLAUDE.md raiz${NC}"
    else
      echo -e "  ${GREEN}[dry-run] anexaria ${stack} ao CLAUDE.md raiz${NC}"
    fi
  else
    write_file "${dir}/CLAUDE.md" "$content" "true"
  fi
done

echo ""

# ─── DOCS ─────────────────────────────────────────────────

if [ -d "$SCRIPT_DIR/docs" ]; then
  echo -e "${BLUE}Docs templates...${NC}"
  for doc in "$SCRIPT_DIR"/docs/*.md; do
    [ -f "$doc" ] || continue
    copy_file "$doc" "docs/$(basename "$doc")" "true"
  done
  echo ""
fi

# ─── RESUMO ──────────────────────────────────────────────

echo -e "${GREEN}═════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup completo!${NC}"
echo ""

if [ ${#STACKS[@]} -gt 0 ]; then
  echo -e "${BOLD}Stacks:${NC}"
  for i in "${!STACKS[@]}"; do
    dir="${DIRS[$i]}"
    [ "$dir" = "." ] && target="CLAUDE.md (raiz)" || target="${dir}/CLAUDE.md"
    echo -e "  ${CYAN}${LABELS[$i]}${NC} → ${target}"
  done
  echo ""
fi

echo -e "${BOLD}Commands:${NC}"
for cmd in .claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  echo -e "  ${CYAN}/$(basename "$cmd" .md)${NC}"
done
echo ""
echo -e "${BOLD}Próximos passos:${NC}"
echo -e "  1. Revise os CLAUDE.md gerados e adapte ao projeto"
echo -e "  2. ${CYAN}git add .claude/ CLAUDE.md docs/ && git commit -m 'chore: add claude config'${NC}"
echo ""
echo -e "  Atualizar commands:  ${CYAN}setup-claude.sh --commands --force${NC}"
echo -e "  Reconstruir tudo:    ${CYAN}setup-claude.sh --rebuild${NC}"
