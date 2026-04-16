#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Team Config — Setup Script
#
# Modos:
#   setup.sh --global [--link]              Instala recursos genéricos em ~/.claude/
#   setup.sh /path/to/project [--link]      Instala recursos específicos do projeto
#   setup.sh --clean-project /path/to/proj  Limpa duplicatas genéricas de um projeto
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

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

# ─── Helpers ─────────────────────────────────────────────────────────────────

backup_if_exists() {
    local path="$1"
    if [ -e "$path" ]; then
        local backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backup: $path → $backup"
        cp -r "$path" "$backup"
    fi
}

install_item() {
    local src="$1"
    local dest="$2"
    local mode="${3:---copy}"

    mkdir -p "$(dirname "$dest")"

    if [ "$mode" = "--link" ]; then
        ln -sfn "$src" "$dest"
        ok "Linked: $dest → $src"
    else
        cp -r "$src" "$dest"
        ok "Copied: $dest"
    fi
}

show_usage() {
    echo ""
    echo -e "${BLUE}Claude Team Config — Setup${NC}"
    echo ""
    echo "Uso:"
    echo "  setup.sh --global [--link]              Instala skills, commands e settings globalmente"
    echo "  setup.sh /path/to/project [--link]      Instala hooks, CLAUDE.local.md e commands de monorepo"
    echo "  setup.sh --clean-project /path/to/proj  Remove duplicatas genéricas de um projeto"
    echo ""
    echo "Opções:"
    echo "  --link    Usa symlinks em vez de cópias (skills e commands)"
    echo ""
    echo "Exemplo (máquina nova):"
    echo "  setup.sh --global && setup.sh /path/to/project"
    echo ""
    exit 0
}

# ─── JSON merge (auto-detecta runtime: jq > python3 > python > node) ────────

detect_json_runtime() {
    if command -v jq &>/dev/null; then
        echo "jq"
    elif command -v python3 &>/dev/null; then
        echo "python3"
    elif command -v python &>/dev/null; then
        echo "python"
    elif command -v node &>/dev/null; then
        echo "node"
    else
        echo "none"
    fi
}

# Merge user_settings + team_settings → stdout
# Estratégia: user wins on conflict. Arrays são unidos sem duplicatas.
# Hooks e teammateMode nunca são tocados.
merge_settings_json() {
    local user_file="$1"
    local team_file="$2"
    local runtime
    runtime="$(detect_json_runtime)"

    case "$runtime" in
        jq)
            _merge_with_jq "$user_file" "$team_file"
            ;;
        python3|python)
            _merge_with_python "$runtime" "$user_file" "$team_file"
            ;;
        node)
            _merge_with_node "$user_file" "$team_file"
            ;;
        *)
            error "Nenhum runtime JSON encontrado. Instale um: jq, python3, python ou node."
            ;;
    esac
}

_merge_with_jq() {
    local user_file="$1"
    local team_file="$2"
    local user_json team_json

    # Se user_file não existe, cria JSON vazio
    if [ ! -f "$user_file" ]; then
        user_json="{}"
    else
        user_json="$(cat "$user_file")"
    fi

    # Remove hooks e _comment do team (ficam per-project)
    team_json="$(jq 'del(.hooks, ._comment)' "$team_file")"

    # jq merge com regras customizadas
    echo "$user_json" | jq --argjson team "$team_json" '
        # Union de arrays sem duplicatas
        def union(a; b): a + [b[] | select(. as $x | a | index($x) | not)];

        # Merge env: team keys que nao existem no user
        .env = (($team.env // {}) + (.env // {})) |

        # Merge permissions
        .permissions = (
            (.permissions // {}) as $up |
            ($team.permissions // {}) as $tp |
            {
                deny: union(($up.deny // []); ($tp.deny // [])),
                allowedTools: union(($up.allowedTools // []); ($tp.allowedTools // [])),
                allow: union(($up.allow // []); ($tp.allow // []))
            }
            | if $up.defaultMode then .defaultMode = $up.defaultMode
              elif $tp.defaultMode then .defaultMode = $tp.defaultMode
              else . end
        ) |

        # Merge enabledPlugins: user false prevalece
        .enabledPlugins = (($team.enabledPlugins // {}) * (.enabledPlugins // {})) |

        # Merge extraKnownMarketplaces: nao sobrescreve
        .extraKnownMarketplaces = (($team.extraKnownMarketplaces // {}) + (.extraKnownMarketplaces // {})) |

        # effortLevel: user prevalece se ja setado
        if .effortLevel == null and ($team.effortLevel // null) != null
        then .effortLevel = $team.effortLevel
        else . end
    '
}

_merge_with_python() {
    local runtime="$1"
    local user_file="$2"
    local team_file="$3"

    "$runtime" - "$user_file" "$team_file" << 'PYEOF'
import json, sys, copy

def union_list(a, b):
    seen = set(a)
    merged = list(a)
    for item in b:
        if item not in seen:
            merged.append(item)
            seen.add(item)
    return merged

def merge(user, team):
    r = copy.deepcopy(user)

    # env
    team_env = team.get("env", {})
    r.setdefault("env", {})
    for k, v in team_env.items():
        r["env"].setdefault(k, v)

    # permissions
    r.setdefault("permissions", {})
    tp = team.get("permissions", {})
    for field in ("deny", "allowedTools", "allow"):
        tl = tp.get(field, [])
        ul = r["permissions"].get(field, [])
        merged = union_list(ul, tl)
        if merged:
            r["permissions"][field] = merged
    if "defaultMode" not in r["permissions"] and "defaultMode" in tp:
        r["permissions"]["defaultMode"] = tp["defaultMode"]

    # enabledPlugins
    r.setdefault("enabledPlugins", {})
    for plugin, enabled in team.get("enabledPlugins", {}).items():
        if plugin not in r["enabledPlugins"]:
            r["enabledPlugins"][plugin] = enabled

    # extraKnownMarketplaces
    r.setdefault("extraKnownMarketplaces", {})
    for k, v in team.get("extraKnownMarketplaces", {}).items():
        r["extraKnownMarketplaces"].setdefault(k, v)

    # effortLevel
    if "effortLevel" not in r and "effortLevel" in team:
        r["effortLevel"] = team["effortLevel"]

    return r

user_path, team_path = sys.argv[1], sys.argv[2]
try:
    with open(user_path) as f:
        user = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    user = {}

with open(team_path) as f:
    team = json.load(f)
team.pop("hooks", None)
team.pop("_comment", None)

print(json.dumps(merge(user, team), indent=2, ensure_ascii=False))
PYEOF
}

# Adiciona/atualiza hooks em um settings.json existente
_upsert_hooks_in_settings() {
    local settings_file="$1"
    local runtime
    runtime="$(detect_json_runtime)"

    local hooks_json='{
  "PostToolUse": [
    {
      "matcher": "Write(*.py)",
      "hooks": [{"type": "command", "command": "python -m black $FILEPATH 2>/dev/null || true"}]
    },
    {
      "matcher": "Write(*.{ts,tsx,js,jsx})",
      "hooks": [{"type": "command", "command": "npx prettier --write $FILEPATH 2>/dev/null || true"}]
    }
  ]
}'

    case "$runtime" in
        jq)
            local tmp
            tmp="$(mktemp)"
            jq --argjson hooks "$hooks_json" '.hooks = $hooks' "$settings_file" > "$tmp"
            mv "$tmp" "$settings_file"
            ;;
        python3|python)
            "$runtime" - "$settings_file" << 'PYEOF'
import json, sys
f = sys.argv[1]
with open(f) as fh:
    data = json.load(fh)
data["hooks"] = {
    "PostToolUse": [
        {"matcher": "Write(*.py)", "hooks": [{"type": "command", "command": "python -m black $FILEPATH 2>/dev/null || true"}]},
        {"matcher": "Write(*.{ts,tsx,js,jsx})", "hooks": [{"type": "command", "command": "npx prettier --write $FILEPATH 2>/dev/null || true"}]}
    ]
}
with open(f, "w") as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PYEOF
            ;;
        node)
            node - "$settings_file" << 'JSEOF'
const fs = require('fs');
const f = process.argv[2];
const data = JSON.parse(fs.readFileSync(f, 'utf8'));
data.hooks = {
    PostToolUse: [
        {matcher: "Write(*.py)", hooks: [{type: "command", command: "python -m black $FILEPATH 2>/dev/null || true"}]},
        {matcher: "Write(*.{ts,tsx,js,jsx})", hooks: [{type: "command", command: "npx prettier --write $FILEPATH 2>/dev/null || true"}]}
    ]
};
fs.writeFileSync(f, JSON.stringify(data, null, 2) + '\n');
JSEOF
            ;;
        *)
            error "Nenhum runtime JSON encontrado. Instale um: jq, python3, python ou node."
            ;;
    esac
}

# Remove keys globais de um settings.json de projeto (clean-project)
_strip_global_keys_from_settings() {
    local settings_file="$1"
    local runtime
    runtime="$(detect_json_runtime)"

    case "$runtime" in
        jq)
            local result
            result="$(jq 'del(.env, .enabledPlugins, .effortLevel, ._comment) |
                if .permissions then .permissions |= del(.deny, .allowedTools, .defaultMode, .allow) else . end |
                if .permissions == {} then del(.permissions) else . end' "$settings_file")"
            if [ "$result" = "{}" ]; then
                rm -f "$settings_file"
                info "Settings removido (vazio após limpeza)."
            else
                echo "$result" > "$settings_file"
                info "Settings limpo — mantidas apenas configs de projeto."
            fi
            ;;
        python3|python)
            "$runtime" - "$settings_file" << 'PYEOF'
import json, sys, os
f = sys.argv[1]
with open(f) as fh:
    data = json.load(fh)
for key in ("env", "enabledPlugins", "effortLevel", "_comment"):
    data.pop(key, None)
perms = data.get("permissions", {})
for field in ("deny", "allowedTools", "defaultMode", "allow"):
    perms.pop(field, None)
if not perms:
    data.pop("permissions", None)
if data:
    with open(f, "w") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print("Settings limpo — mantidas apenas configs de projeto.")
else:
    os.remove(f)
    print("Settings removido (vazio após limpeza).")
PYEOF
            ;;
        node)
            node - "$settings_file" << 'JSEOF'
const fs = require('fs');
const f = process.argv[2];
const data = JSON.parse(fs.readFileSync(f, 'utf8'));
for (const k of ['env', 'enabledPlugins', 'effortLevel', '_comment']) delete data[k];
if (data.permissions) {
    for (const k of ['deny', 'allowedTools', 'defaultMode', 'allow']) delete data.permissions[k];
    if (!Object.keys(data.permissions).length) delete data.permissions;
}
if (Object.keys(data).length) {
    fs.writeFileSync(f, JSON.stringify(data, null, 2) + '\n');
    console.log('Settings limpo — mantidas apenas configs de projeto.');
} else {
    fs.unlinkSync(f);
    console.log('Settings removido (vazio após limpeza).');
}
JSEOF
            ;;
        *)
            error "Nenhum runtime JSON encontrado. Instale um: jq, python3, python ou node."
            ;;
    esac
}

_merge_with_node() {
    local user_file="$1"
    local team_file="$2"

    node - "$user_file" "$team_file" << 'JSEOF'
const fs = require('fs');
const [,, userPath, teamPath] = process.argv;

let user = {};
try { user = JSON.parse(fs.readFileSync(userPath, 'utf8')); } catch {}
const team = JSON.parse(fs.readFileSync(teamPath, 'utf8'));
delete team.hooks;
delete team._comment;

const union = (a = [], b = []) => [...a, ...b.filter(x => !a.includes(x))];

// env
user.env = { ...(team.env || {}), ...(user.env || {}) };

// permissions
user.permissions = user.permissions || {};
const tp = team.permissions || {};
for (const f of ['deny', 'allowedTools', 'allow']) {
    const merged = union(user.permissions[f], tp[f]);
    if (merged.length) user.permissions[f] = merged;
}
if (!user.permissions.defaultMode && tp.defaultMode)
    user.permissions.defaultMode = tp.defaultMode;

// enabledPlugins
user.enabledPlugins = user.enabledPlugins || {};
for (const [k, v] of Object.entries(team.enabledPlugins || {})) {
    if (!(k in user.enabledPlugins)) user.enabledPlugins[k] = v;
}

// extraKnownMarketplaces
user.extraKnownMarketplaces = { ...(team.extraKnownMarketplaces || {}), ...(user.extraKnownMarketplaces || {}) };

// effortLevel
if (!('effortLevel' in user) && 'effortLevel' in team)
    user.effortLevel = team.effortLevel;

console.log(JSON.stringify(user, null, 2));
JSEOF
}

# Recursos genéricos que são instalados globalmente
GENERIC_SKILLS=(code-review commit debug doc-gen pr-description refactor security-scan test-gen)
GENERIC_COMMANDS=(feature.md fix.md improve.md pre-deploy.md status.md)

# ─── Detecção de tipo de projeto ─────────────────────────────────────────────

PROJECT_MARKERS=("package.json" "composer.json" "go.mod" "Cargo.toml" "pyproject.toml" "requirements.txt" "manage.py" "artisan" "Dockerfile" "docker-compose.yml" "docker-compose.yaml")
IGNORED_DIRS="^(node_modules|vendor|__pycache__|scripts|dist|build|coverage|target|venv|\.venv|env)$"

is_project_dir() {
    local dir="$1"
    # Verifica markers na raiz do diretório
    for marker in "${PROJECT_MARKERS[@]}"; do
        [ -f "$dir/$marker" ] && return 0
    done
    # Verifica markers 1 nível abaixo (ex: src/composer.json, app/manage.py)
    for subdir in "$dir"/*/; do
        [ -d "$subdir" ] || continue
        for marker in "${PROJECT_MARKERS[@]}"; do
            [ -f "$subdir/$marker" ] && return 0
        done
    done
    return 1
}

detect_project_type() {
    local target="$1"
    local project_dirs=0

    for dir in "$target"/*/; do
        [ -d "$dir" ] || continue
        local dirname
        dirname="$(basename "$dir")"
        [[ "$dirname" == .* ]] && continue
        [[ "$dirname" =~ $IGNORED_DIRS ]] && continue
        is_project_dir "$dir" && ((project_dirs++)) || true
    done

    if [ "$project_dirs" -ge 2 ]; then
        echo "monorepo"
    else
        echo "monolith"
    fi
}

infer_alias() {
    local dirname="$1"
    local project="$2"
    local suffix="${dirname#${project}_}"
    [ "$suffix" = "$dirname" ] && suffix="${dirname#${project}-}"
    [ "$suffix" = "$dirname" ] && suffix="$dirname"
    case "$suffix" in
        frontend|front) echo "front" ;;
        backend|back)   echo "back" ;;
        docs|documentation) echo "docs" ;;
        api)            echo "api" ;;
        mobile)         echo "mobile" ;;
        web)            echo "web" ;;
        infra|infrastructure) echo "infra" ;;
        shared|common)  echo "shared" ;;
        socket|ws|websocket) echo "socket" ;;
        gateway)        echo "gateway" ;;
        worker|jobs)    echo "worker" ;;
        *)              echo "$suffix" ;;
    esac
}

infer_description() {
    local alias="$1"
    case "$alias" in
        front*) echo "Aplicação frontend" ;;
        back*)  echo "API backend" ;;
        docs*)  echo "Documentação" ;;
        api)    echo "Serviço API" ;;
        mobile) echo "Aplicação mobile" ;;
        web)    echo "Aplicação web" ;;
        infra)  echo "Infraestrutura" ;;
        shared|common) echo "Código compartilhado" ;;
        socket|ws) echo "Serviço WebSocket" ;;
        gateway) echo "API Gateway" ;;
        worker|jobs) echo "Worker/Jobs" ;;
        *)      echo "Repositório $alias" ;;
    esac
}

# ─── Helpers para plugins de sub-projetos ────────────────────────────────────

# Verifica se um settings.json tem enabledPlugins com pelo menos 1 plugin true
_has_plugins_in_settings() {
    local settings_file="$1"
    local runtime
    runtime="$(detect_json_runtime)"

    case "$runtime" in
        jq)
            jq -e '.enabledPlugins // {} | to_entries | map(select(.value == true)) | length > 0' "$settings_file" >/dev/null 2>&1
            ;;
        python3|python)
            "$runtime" -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
plugins = data.get('enabledPlugins', {})
sys.exit(0 if any(v is True for v in plugins.values()) else 1)
" "$settings_file" 2>/dev/null
            ;;
        node)
            node -e "
const d = JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));
const p = d.enabledPlugins || {};
process.exit(Object.values(p).some(v => v === true) ? 0 : 1);
" "$settings_file" 2>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Conta quantos plugins estão enabled (true) num settings.json
_count_plugins_in_settings() {
    local settings_file="$1"
    local runtime
    runtime="$(detect_json_runtime)"

    case "$runtime" in
        jq)
            jq '[.enabledPlugins // {} | to_entries[] | select(.value == true)] | length' "$settings_file" 2>/dev/null
            ;;
        python3|python)
            "$runtime" -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
print(sum(1 for v in data.get('enabledPlugins', {}).values() if v is True))
" "$settings_file" 2>/dev/null
            ;;
        node)
            node -e "
const d = JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));
console.log(Object.values(d.enabledPlugins||{}).filter(v=>v===true).length);
" "$settings_file" 2>/dev/null
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Merge enabledPlugins de um sub-projeto para o settings.json raiz
# Só adiciona plugins que não existem no raiz (não sobrescreve)
# Imprime em stdout os nomes dos plugins adicionados (1 por linha)
_merge_plugins_to_root() {
    local sub_settings="$1"
    local root_settings="$2"
    local alias="$3"
    local runtime
    runtime="$(detect_json_runtime)"

    local added_output
    case "$runtime" in
        jq)
            # Descobre quais são novos antes de mergear
            local new_plugins
            new_plugins="$(jq -r --slurpfile root "$root_settings" '
                (.enabledPlugins // {}) as $sub |
                ($root[0].enabledPlugins // {}) as $rp |
                $sub | to_entries[] | select(.value == true and ($rp[.key] == null)) | .key
            ' "$sub_settings")"

            # Faz o merge
            local merged
            local sub_plugins
            sub_plugins="$(jq '.enabledPlugins // {} | to_entries | map(select(.value == true)) | from_entries' "$sub_settings")"
            merged="$(jq --argjson sub "$sub_plugins" '
                .enabledPlugins = ((.enabledPlugins // {}) as $root |
                    $root + ($sub | to_entries | map(select(.key as $k | $root[$k] == null)) | from_entries))
            ' "$root_settings")"
            echo "$merged" > "$root_settings"
            added_output="$new_plugins"
            ;;
        python3|python)
            added_output="$("$runtime" - "$sub_settings" "$root_settings" << 'PYEOF'
import json, sys
sub_path, root_path = sys.argv[1], sys.argv[2]
with open(sub_path) as f:
    sub = json.load(f)
with open(root_path) as f:
    root = json.load(f)
sub_plugins = {k: v for k, v in sub.get("enabledPlugins", {}).items() if v is True}
root.setdefault("enabledPlugins", {})
added = []
for k, v in sub_plugins.items():
    if k not in root["enabledPlugins"]:
        root["enabledPlugins"][k] = v
        added.append(k)
with open(root_path, "w") as f:
    json.dump(root, f, indent=2, ensure_ascii=False)
    f.write("\n")
for p in added:
    print(p)
PYEOF
)"
            ;;
        node)
            added_output="$(node - "$sub_settings" "$root_settings" << 'JSEOF'
const fs = require('fs');
const [,, subPath, rootPath] = process.argv;
const sub = JSON.parse(fs.readFileSync(subPath, 'utf8'));
const root = JSON.parse(fs.readFileSync(rootPath, 'utf8'));
const subPlugins = Object.entries(sub.enabledPlugins || {}).filter(([,v]) => v === true);
root.enabledPlugins = root.enabledPlugins || {};
const added = [];
for (const [k, v] of subPlugins) {
    if (!(k in root.enabledPlugins)) {
        root.enabledPlugins[k] = v;
        added.push(k);
    }
}
fs.writeFileSync(rootPath, JSON.stringify(root, null, 2) + '\n');
added.forEach(p => console.log(p));
JSEOF
)"
            ;;
    esac

    if [ -n "$added_output" ]; then
        while IFS= read -r plugin; do
            [ -z "$plugin" ] && continue
            ok "  Plugin agregado (/$alias): $plugin"
        done <<< "$added_output"
    fi
}

# ─── Agrega skills/commands/agents/plugins dos sub-projetos para o .claude/ raiz

_aggregate_subproject_resources() {
    local target_dir="$1"
    local mode="$2"
    local root_claude="$target_dir/.claude"

    # Monta mapa alias→path a partir do COMMANDS array (variável do escopo pai)
    # COMMANDS tem formato "alias|path|desc"

    # Detecta sub-projetos que têm .claude/ com conteúdo
    local subs_with_claude=()
    for cmd_entry in "${COMMANDS[@]}"; do
        IFS='|' read -r alias path desc <<< "$cmd_entry"
        local sub_claude="$target_dir/$path/.claude"
        if [ -d "$sub_claude" ]; then
            local has_content=false
            [ -d "$sub_claude/skills" ] && [ "$(ls -A "$sub_claude/skills" 2>/dev/null)" ] && has_content=true
            [ -d "$sub_claude/commands" ] && [ "$(ls -A "$sub_claude/commands" 2>/dev/null)" ] && has_content=true
            [ -d "$sub_claude/agents" ] && [ "$(ls -A "$sub_claude/agents" 2>/dev/null)" ] && has_content=true
            # Verifica se tem enabledPlugins no settings.json
            if [ -f "$sub_claude/settings.json" ]; then
                _has_plugins_in_settings "$sub_claude/settings.json" && has_content=true
            fi
            if $has_content; then
                subs_with_claude+=("$alias|$path")
            fi
        fi
    done

    if [ ${#subs_with_claude[@]} -eq 0 ]; then
        return 0
    fi

    echo ""
    info "Sub-projetos com recursos Claude detectados:"
    for entry in "${subs_with_claude[@]}"; do
        IFS='|' read -r alias path <<< "$entry"
        local sub_claude="$target_dir/$path/.claude"
        local resources=""
        if [ -d "$sub_claude/skills" ] && [ "$(ls -A "$sub_claude/skills" 2>/dev/null)" ]; then
            local count
            count="$(ls -d "$sub_claude/skills"/*/ 2>/dev/null | wc -l)"
            resources="${resources}${count} skills"
        fi
        if [ -d "$sub_claude/commands" ] && [ "$(ls -A "$sub_claude/commands" 2>/dev/null)" ]; then
            local count
            count="$(ls "$sub_claude/commands"/*.md 2>/dev/null | wc -l)"
            [ -n "$resources" ] && resources="${resources}, "
            resources="${resources}${count} commands"
        fi
        if [ -d "$sub_claude/agents" ] && [ "$(ls -A "$sub_claude/agents" 2>/dev/null)" ]; then
            local count
            count="$(ls "$sub_claude/agents"/*.md 2>/dev/null | wc -l)"
            [ -n "$resources" ] && resources="${resources}, "
            resources="${resources}${count} agents"
        fi
        if [ -f "$sub_claude/settings.json" ] && _has_plugins_in_settings "$sub_claude/settings.json"; then
            local plugin_count
            plugin_count="$(_count_plugins_in_settings "$sub_claude/settings.json")"
            if [ "$plugin_count" -gt 0 ]; then
                [ -n "$resources" ] && resources="${resources}, "
                resources="${resources}${plugin_count} plugins"
            fi
        fi
        info "  /$alias ($path/) — $resources"
    done

    echo ""
    read -p "  Agregar recursos dos sub-projetos ao .claude/ raiz? (Y/n) " -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Nn]$ ]]; then
        info "Pulando agregação de sub-projetos."
        return 0
    fi

    echo ""
    local aggregated=0

    for entry in "${subs_with_claude[@]}"; do
        IFS='|' read -r alias path <<< "$entry"
        local sub_claude="$target_dir/$path/.claude"

        # ─── Skills: copia com prefixo "alias-" ─────────────────────────
        if [ -d "$sub_claude/skills" ]; then
            mkdir -p "$root_claude/skills"
            for skill_dir in "$sub_claude/skills"/*/; do
                [ -d "$skill_dir" ] || continue
                local skill_name
                skill_name="$(basename "$skill_dir")"
                local prefixed="${alias}-${skill_name}"
                local dest="$root_claude/skills/$prefixed"

                if [ -d "$dest" ]; then
                    # Compara ignorando a linha name: (que foi renomeada)
                    local src_content dest_content
                    src_content="$(find "$skill_dir" -type f -exec grep -v '^name: ' {} + 2>/dev/null | sort)"
                    dest_content="$(find "$dest" -type f -exec grep -v '^name: ' {} + 2>/dev/null | sort)"
                    if [ "$src_content" = "$dest_content" ]; then
                        info "  Skill $prefixed já está atualizada."
                        continue
                    fi
                    backup_if_exists "$dest"
                fi

                install_item "$skill_dir" "$dest" "$mode"
                # Atualiza o name no SKILL.md copiado para refletir o prefixo
                local skill_md="$dest/SKILL.md"
                if [ -f "$skill_md" ]; then
                    sed -i "s/^name: .*/name: ${prefixed}/" "$skill_md"
                fi
                ((aggregated++)) || true
            done
        fi

        # ─── Commands: copia com prefixo "alias-" ───────────────────────
        if [ -d "$sub_claude/commands" ]; then
            mkdir -p "$root_claude/commands"
            for cmd_file in "$sub_claude/commands"/*.md; do
                [ -f "$cmd_file" ] || continue
                local cmd_name
                cmd_name="$(basename "$cmd_file")"
                local prefixed="${alias}-${cmd_name}"
                local dest="$root_claude/commands/$prefixed"

                if [ -f "$dest" ]; then
                    if diff -q "$cmd_file" "$dest" >/dev/null 2>&1; then
                        info "  Command $prefixed já está atualizado."
                        continue
                    fi
                    backup_if_exists "$dest"
                fi

                install_item "$cmd_file" "$dest" "$mode"
                ((aggregated++)) || true
            done
        fi

        # ─── Agents: copia com prefixo "alias-" ─────────────────────────
        if [ -d "$sub_claude/agents" ]; then
            mkdir -p "$root_claude/agents"
            for agent_file in "$sub_claude/agents"/*.md; do
                [ -f "$agent_file" ] || continue
                local agent_name
                agent_name="$(basename "$agent_file")"
                local prefixed="${alias}-${agent_name}"
                local dest="$root_claude/agents/$prefixed"

                if [ -f "$dest" ]; then
                    if diff -q "$agent_file" "$dest" >/dev/null 2>&1; then
                        info "  Agent $prefixed já está atualizado."
                        continue
                    fi
                    backup_if_exists "$dest"
                fi

                install_item "$agent_file" "$dest" "$mode"
                ((aggregated++)) || true
            done
        fi

        # ─── Plugins: merge enabledPlugins para o settings.json raiz ────
        local sub_settings="$sub_claude/settings.json"
        if [ -f "$sub_settings" ] && _has_plugins_in_settings "$sub_settings"; then
            _merge_plugins_to_root "$sub_settings" "$root_claude/settings.json" "$alias"
        fi
    done

    if [ "$aggregated" -gt 0 ]; then
        echo ""
        ok "Agregados $aggregated recurso(s) dos sub-projetos ao .claude/ raiz."
    else
        info "Nenhum recurso novo para agregar."
    fi
}

# =============================================================================
# MODO: --global
# =============================================================================

run_global_install() {
    local mode="$1"

    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Claude Team Config — Global Setup      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    info "Config source: $CONFIG_DIR"
    info "Destino: ~/.claude/"
    info "Mode: $mode"
    echo ""

    local claude_dir="$HOME/.claude"

    # ─── Instala skills ──────────────────────────────────────────────────
    info "Instalando skills globais..."
    mkdir -p "$claude_dir/skills"

    for skill_dir in "$CONFIG_DIR/.claude/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local dest="$claude_dir/skills/$skill_name"

        if [ -d "$dest" ] && [ "$mode" != "--link" ]; then
            # Verifica se conteúdo é idêntico
            if diff -rq "$skill_dir" "$dest" >/dev/null 2>&1; then
                info "Skill $skill_name já está atualizada, pulando."
                continue
            fi
            backup_if_exists "$dest"
        fi

        install_item "$skill_dir" "$dest" "$mode"
    done

    # ─── Instala commands ────────────────────────────────────────────────
    info "Instalando commands globais..."
    mkdir -p "$claude_dir/commands"

    for cmd_file in "$CONFIG_DIR/.claude/commands"/*.md; do
        [ -f "$cmd_file" ] || continue
        local cmd_name
        cmd_name="$(basename "$cmd_file")"
        local dest="$claude_dir/commands/$cmd_name"

        if [ -f "$dest" ] && [ "$mode" != "--link" ]; then
            if diff -q "$cmd_file" "$dest" >/dev/null 2>&1; then
                info "Command $cmd_name já está atualizado, pulando."
                continue
            fi
            backup_if_exists "$dest"
        fi

        install_item "$cmd_file" "$dest" "$mode"
    done

    # ─── Merge settings.json ────────────────────────────────────────────
    info "Merging settings.json..."
    local user_settings="$claude_dir/settings.json"
    local team_settings="$CONFIG_DIR/.claude/settings.json"

    if [ -f "$user_settings" ]; then
        backup_if_exists "$user_settings"
    fi

    local temp_result
    temp_result="$(mktemp)"
    merge_settings_json "$user_settings" "$team_settings" > "$temp_result"
    mv "$temp_result" "$user_settings"
    ok "Settings merged: $user_settings"

    # ─── Resumo ─────────────────────────────────────────────────────────
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Global setup completo!             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""

    echo "Skills globais instaladas:"
    for skill_dir in "$claude_dir/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        echo "  /$(basename "$skill_dir")"
    done
    echo ""

    echo "Commands globais instalados:"
    for cmd_file in "$claude_dir/commands"/*.md; do
        [ -f "$cmd_file" ] || continue
        echo "  /$(basename "$cmd_file" .md)"
    done
    echo ""

    echo "Próximo passo:"
    echo "  Para cada projeto: setup.sh /path/to/project"
    echo ""
}

# =============================================================================
# MODO: project
# =============================================================================

run_project_install() {
    local target_dir="$1"
    local mode="$2"

    target_dir="$(cd "$target_dir" && pwd)"

    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Claude Team Config — Project Setup     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    info "Config source: $CONFIG_DIR"
    info "Target project: $target_dir"
    info "Mode: $mode"
    echo ""

    # Verifica se é um projeto git
    if [ ! -d "$target_dir/.git" ]; then
        warn "Diretório alvo não é um repositório git."
        read -p "Continuar mesmo assim? (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 0
    fi

    # Verifica se global setup foi feito
    if [ ! -d "$HOME/.claude/skills" ] || [ ! -d "$HOME/.claude/commands" ]; then
        warn "Skills/commands globais não encontrados."
        info "Execute primeiro: setup.sh --global"
        echo ""
    fi

    # ─── Instala hooks (per-project) ─────────────────────────────────────
    info "Configurando hooks do projeto..."
    mkdir -p "$target_dir/.claude"

    local project_settings="$target_dir/.claude/settings.json"

    if [ -f "$project_settings" ]; then
        # Projeto já tem settings.json — adiciona/atualiza hooks
        _upsert_hooks_in_settings "$project_settings"
        ok "Hooks atualizados em $project_settings"
    else
        # Cria settings.json mínimo com hooks
        cat > "$project_settings" << 'SETTINGS_EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [
          {
            "type": "command",
            "command": "python -m black $FILEPATH 2>/dev/null || true"
          }
        ]
      },
      {
        "matcher": "Write(*.{ts,tsx,js,jsx})",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $FILEPATH 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
        ok "Criado $project_settings (hooks)"
    fi

    # ─── Instala CLAUDE.local.md ─────────────────────────────────────────
    if [ -f "$CONFIG_DIR/CLAUDE.md" ]; then
        info "Instalando CLAUDE.md como CLAUDE.local.md..."
        if [ -f "$target_dir/CLAUDE.local.md" ]; then
            warn "CLAUDE.local.md já existe no projeto."
            read -p "Sobrescrever? Merge manual recomendado. (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                backup_if_exists "$target_dir/CLAUDE.local.md"
                install_item "$CONFIG_DIR/CLAUDE.md" "$target_dir/CLAUDE.local.md" "$mode"
            else
                info "Mantendo CLAUDE.local.md existente."
            fi
        else
            install_item "$CONFIG_DIR/CLAUDE.md" "$target_dir/CLAUDE.local.md" "$mode"
        fi
    fi

    # ─── Detecção de tipo de projeto ─────────────────────────────────────
    local PROJECT_NAME
    PROJECT_NAME="$(basename "$target_dir")"
    local PROJECT_TYPE
    PROJECT_TYPE="$(detect_project_type "$target_dir")"

    echo ""
    if [ "$PROJECT_TYPE" = "monorepo" ]; then
        info "Tipo de projeto detectado: ${GREEN}MONOREPO${NC}"
    else
        info "Tipo de projeto detectado: ${GREEN}MONOLITO${NC}"
    fi

    # Permite override da detecção
    read -p "  Confirma? (Enter = sim, n = Não): " override
    if [[ "$override" =~ ^[Nn] ]]; then
        if [ "$PROJECT_TYPE" = "monorepo" ]; then
            PROJECT_TYPE="monolith"
            info "Tipo alterado para: ${GREEN}MONOLITO${NC}"
        else
            PROJECT_TYPE="monorepo"
            info "Tipo alterado para: ${GREEN}MONOREPO${NC}"
        fi
    fi

    local COMMANDS=()

    if [ "$PROJECT_TYPE" = "monorepo" ]; then
        echo ""
        info "Configuração de commands (atalhos para navegação entre repos)"
        echo ""

        local DETECTED_REPOS=()
        for dir in "$target_dir"/*/; do
            [ -d "$dir" ] || continue
            local local_dirname
            local_dirname="$(basename "$dir")"
            [[ "$local_dirname" == .* ]] && continue
            [[ "$local_dirname" =~ $IGNORED_DIRS ]] && continue
            DETECTED_REPOS+=("$local_dirname")
        done

        if [ ${#DETECTED_REPOS[@]} -gt 0 ]; then
            echo "  Para cada pasta, digite o alias do command:"
            echo "    Enter     = aceitar sugestão entre [ ]"
            echo "    novo nome = usar como alias customizado"
            echo "    -         = pular (não criar command)"
            echo ""

            for repo in "${DETECTED_REPOS[@]}"; do
                local suggested
                suggested="$(infer_alias "$repo" "$PROJECT_NAME")"
                read -p "    $repo [$suggested]: " user_input

                local trimmed
                trimmed="$(echo "$user_input" | xargs 2>/dev/null || true)"

                if [ -z "$trimmed" ] && [ -z "$user_input" ]; then
                    local alias="$suggested"
                    local desc
                    desc="$(infer_description "$alias")"
                    COMMANDS+=("$alias|$repo|$desc")
                    ok "  /$alias → $repo/"
                elif [ -z "$trimmed" ] || [ "$trimmed" = "-" ]; then
                    warn "  $repo — pulado"
                else
                    local alias="$trimmed"
                    local desc
                    desc="$(infer_description "$alias")"
                    COMMANDS+=("$alias|$repo|$desc")
                    ok "  /$alias → $repo/"
                fi
            done
        fi

        echo ""
        echo "  Adicionar mais repos manualmente? (um por linha, vazio para encerrar)"
        echo "  Formato: <alias> <path_relativo> <descricao>"
        echo ""

        while true; do
            read -p "  > " cmd_alias cmd_path cmd_desc_rest
            [ -z "$cmd_alias" ] && break

            if [ -z "$cmd_path" ]; then
                cmd_path="$cmd_alias"
                cmd_desc_rest="Navega para $cmd_alias"
            fi
            if [ -z "$cmd_desc_rest" ]; then
                cmd_desc_rest="Navega para $cmd_path"
            fi

            COMMANDS+=("$cmd_alias|$cmd_path|$cmd_desc_rest")
        done
    else
        echo ""
        info "Projeto monolito — commands de navegação entre repos não são necessários."
        info "Commands de workflow (/feature, /fix, /improve, etc.) estão disponíveis globalmente."
    fi

    if [ ${#COMMANDS[@]} -gt 0 ]; then
        info "Gerando commands de monorepo..."
        mkdir -p "$target_dir/.claude/commands"

        for cmd_entry in "${COMMANDS[@]}"; do
            IFS='|' read -r alias path desc <<< "$cmd_entry"

            cat > "$target_dir/.claude/commands/${alias}.md" << CMDEOF
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

        # Gera /status geral para monorepo
        if [ ! -f "$target_dir/.claude/commands/status.md" ]; then
            local STATUS_PATHS=""
            for cmd_entry in "${COMMANDS[@]}"; do
                IFS='|' read -r alias path desc <<< "$cmd_entry"
                STATUS_PATHS="${STATUS_PATHS}\n- \`${path}/\`"
            done

            cat > "$target_dir/.claude/commands/status.md" << CMDEOF
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

        # Gera /logs para monorepo
        if [ ! -f "$target_dir/.claude/commands/logs.md" ]; then
            cat > "$target_dir/.claude/commands/logs.md" << 'CMDEOF'
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
    elif [ "$PROJECT_TYPE" = "monorepo" ]; then
        info "Nenhum command de navegação configurado. Você pode criar depois em .claude/commands/"
    fi

    # ─── Agrega recursos dos sub-projetos (monorepo) ───────────────────
    if [ "$PROJECT_TYPE" = "monorepo" ] && [ ${#COMMANDS[@]} -gt 0 ]; then
        _aggregate_subproject_resources "$target_dir" "$mode"
    fi

    # ─── Atualiza .gitignore ─────────────────────────────────────────────
    echo ""
    info "Verificando .gitignore..."
    local GITIGNORE="$target_dir/.gitignore"
    local ENTRIES=("CLAUDE.local.md" ".claude/settings.local.json")

    for entry in "${ENTRIES[@]}"; do
        if [ -f "$GITIGNORE" ] && grep -qF "$entry" "$GITIGNORE"; then
            info "$entry já está no .gitignore"
        else
            echo "$entry" >> "$GITIGNORE"
            ok "Adicionado $entry ao .gitignore"
        fi
    done

    # ─── Cria CLAUDE.local.md de exemplo se não existe ───────────────────
    if [ ! -f "$target_dir/CLAUDE.local.md" ]; then
        cat > "$target_dir/CLAUDE.local.md" << 'EOF'
# Local Overrides

<!-- Este arquivo não é commitado. Use para configs pessoais. -->
<!-- Exemplos: modelo preferido, estilo de output, etc. -->
EOF
        ok "Criado CLAUDE.local.md (template)"
    fi

    # ─── Resumo ──────────────────────────────────────────────────────────
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Project setup completo!            ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""

    if [ -d "$target_dir/.claude/skills" ] && [ "$(ls -A "$target_dir/.claude/skills" 2>/dev/null)" ]; then
        echo "Skills do projeto (agregadas dos sub-projetos):"
        for skill_dir in "$target_dir/.claude/skills"/*/; do
            [ -d "$skill_dir" ] || continue
            echo "  /$(basename "$skill_dir")"
        done
        echo ""
    fi

    if [ -d "$target_dir/.claude/agents" ] && [ "$(ls -A "$target_dir/.claude/agents" 2>/dev/null)" ]; then
        echo "Agents do projeto (agregados dos sub-projetos):"
        for agent_file in "$target_dir/.claude/agents"/*.md; do
            [ -f "$agent_file" ] || continue
            echo "  $(basename "$agent_file" .md)"
        done
        echo ""
    fi

    if [ -d "$target_dir/.claude/commands" ] && [ "$(ls -A "$target_dir/.claude/commands" 2>/dev/null)" ]; then
        echo "Commands do projeto:"
        for cmd_file in "$target_dir/.claude/commands"/*.md; do
            [ -f "$cmd_file" ] || continue
            echo "  /$(basename "$cmd_file" .md)"
        done
        echo ""
    fi

    echo "Recursos globais (disponíveis em todos os projetos):"
    echo "  Skills: /commit, /code-review, /debug, /doc-gen, /pr-description, /refactor, /security-scan, /test-gen"
    echo "  Commands: /feature, /fix, /improve, /pre-deploy, /status"
    echo ""
    echo "Próximos passos:"
    echo "  1. Revise e customize o CLAUDE.local.md"
    echo "  2. Abra o Claude Code no projeto e teste: /commit, /code-review, etc."
    echo ""
}

# =============================================================================
# MODO: --clean-project
# =============================================================================

run_clean_project() {
    local target_dir="$1"
    target_dir="$(cd "$target_dir" && pwd)"

    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Claude Team Config — Clean Project     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    info "Projeto: $target_dir"
    echo ""

    # Verifica se global setup existe
    if [ ! -d "$HOME/.claude/skills" ]; then
        error "Skills globais não encontradas. Execute setup.sh --global primeiro."
    fi

    local removed=0

    # ─── Remove skills genéricas duplicadas ──────────────────────────────
    info "Verificando skills duplicadas..."
    for skill in "${GENERIC_SKILLS[@]}"; do
        local project_skill="$target_dir/.claude/skills/$skill"
        local global_skill="$HOME/.claude/skills/$skill"
        if [ -d "$project_skill" ] && [ -d "$global_skill" ]; then
            rm -rf "$project_skill"
            ok "Removida skill duplicada: $skill"
            ((removed++)) || true
        fi
    done

    # Remove diretório skills se ficou vazio
    if [ -d "$target_dir/.claude/skills" ] && [ -z "$(ls -A "$target_dir/.claude/skills" 2>/dev/null)" ]; then
        rmdir "$target_dir/.claude/skills"
        ok "Removido diretório .claude/skills/ (vazio)"
    fi

    # ─── Remove commands genéricos duplicados ────────────────────────────
    info "Verificando commands duplicados..."
    for cmd in "${GENERIC_COMMANDS[@]}"; do
        local project_cmd="$target_dir/.claude/commands/$cmd"
        local global_cmd="$HOME/.claude/commands/$cmd"
        if [ -f "$project_cmd" ] && [ -f "$global_cmd" ]; then
            # Caso especial: status.md pode ser de monorepo (contém paths de repos)
            if [ "$cmd" = "status.md" ]; then
                if grep -q "Para cada diretório abaixo:" "$project_cmd" 2>/dev/null; then
                    info "Command status.md é de monorepo, mantendo."
                    continue
                fi
            fi
            rm -f "$project_cmd"
            ok "Removido command duplicado: $cmd"
            ((removed++)) || true
        fi
    done

    # ─── Limpa settings.json do projeto ──────────────────────────────────
    local project_settings="$target_dir/.claude/settings.json"
    if [ -f "$project_settings" ]; then
        info "Limpando settings.json do projeto..."
        backup_if_exists "$project_settings"
        _strip_global_keys_from_settings "$project_settings"
        ((removed++)) || true
    fi

    # ─── Resumo ──────────────────────────────────────────────────────────
    echo ""
    if [ "$removed" -gt 0 ]; then
        echo -e "${GREEN}Limpeza concluída: $removed item(ns) removido(s).${NC}"
    else
        info "Nenhuma duplicata encontrada."
    fi
    echo ""
}

# =============================================================================
# MAIN — Dispatch por modo
# =============================================================================

# Parse args
MODE="--copy"
ACTION=""
TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --global)
            ACTION="global"
            shift
            ;;
        --clean-project)
            ACTION="clean"
            if [[ -n "${2:-}" && "${2}" != --* ]]; then
                TARGET="$2"
                shift 2
            else
                error "Uso: setup.sh --clean-project /path/to/project"
            fi
            ;;
        --link)
            MODE="--link"
            shift
            ;;
        --help|-h)
            show_usage
            ;;
        -*)
            error "Flag desconhecida: $1. Use --help para ver uso."
            ;;
        *)
            if [ -z "$ACTION" ]; then
                ACTION="project"
                TARGET="$1"
            fi
            shift
            ;;
    esac
done

case "${ACTION:-}" in
    global)
        run_global_install "$MODE"
        ;;
    project)
        if [ -z "$TARGET" ]; then
            TARGET="."
        fi
        run_project_install "$TARGET" "$MODE"
        ;;
    clean)
        run_clean_project "$TARGET"
        ;;
    *)
        show_usage
        ;;
esac
