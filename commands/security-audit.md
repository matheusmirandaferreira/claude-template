Execute uma auditoria de segurança no projeto: $ARGUMENTS

Se $ARGUMENTS estiver vazio, audite o projeto inteiro.

## Checklist de Auditoria

### 1. Autenticação & Autorização
- Verificar implementação JWT (algoritmo, expiração, refresh)
- Verificar que rotas protegidas exigem auth
- Verificar RBAC/permissões se aplicável
- Verificar que tokens expirados são rejeitados
- Verificar proteção contra brute force (rate limiting)

### 2. Injeção
- Buscar queries SQL raw: `grep -rn "text(" app/ --include="*.py"`
- Buscar f-strings em queries: `grep -rn "f\".*SELECT\|f\".*INSERT\|f\".*UPDATE\|f\".*DELETE" app/`
- Verificar que todo input passa por Pydantic/Zod
- Verificar XSS: `grep -rn "dangerouslySetInnerHTML\|v-html\|innerHTML" src/`

### 3. Dados Sensíveis
- Buscar secrets hardcoded: `grep -rn "password\|secret\|api_key\|token" --include="*.py" --include="*.ts" --include="*.tsx"`
- Verificar .gitignore inclui `.env`, `*.pem`, `*.key`
- Verificar que responses não expõem password hashes ou tokens internos
- Verificar logging não inclui dados sensíveis

### 4. Configuração
- Verificar CORS não é `*` em código de produção
- Verificar headers de segurança (CSP, HSTS, X-Frame-Options)
- Verificar HTTPS enforced
- Verificar que debug mode está off em configs de produção

### 5. Dependências
- Backend: `pip audit` ou checar CVEs conhecidos
- Frontend: `npm audit`
- Listar dependências desatualizadas

### 6. API
- Verificar rate limiting em endpoints públicos
- Verificar paginação tem limite máximo
- Verificar upload de arquivos (tipo, tamanho, sanitização de nome)
- Verificar que IDs em URLs são validados como UUID

## Relatório

```
## Auditoria de Segurança — [data]

### Resumo
- 🔴 Críticos: X
- 🟡 Moderados: Y  
- 🔵 Baixos: Z
- ✅ OK: W

### Findings

#### [SEVERIDADE] [Título]
- **Local**: arquivo:linha
- **Descrição**: O que está vulnerável
- **Impacto**: O que um atacante poderia fazer
- **Correção**: Como resolver (com código)
- **Referência**: OWASP/CWE se aplicável

### Recomendações Gerais
[Lista priorizada de ações]
```
