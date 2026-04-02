---
name: security-scan
description: Análise de vulnerabilidades e problemas de segurança no código. Use quando o usuário pedir scan de segurança, audit, verificação de vulnerabilidades, ou antes de deploy/release. Ativa com "verifica segurança", "tem vulnerabilidade?", "security audit", "tá seguro?".
allowed-tools: Read, Grep, Glob, Bash
---

# Security Scan

Análise de segurança focada em vulnerabilidades comuns.

## Escopo

`$ARGUMENTS` pode especificar arquivos ou diretórios. Se não fornecido, analise os arquivos alterados:
```bash
git diff --name-only develop
# ou todos os arquivos do projeto
```

## Checklist de verificação

### Secrets e credenciais
```bash
# Busca padrões suspeitos
grep -rn "password\s*=" --include="*.{ts,tsx,js,jsx,py,env,yml,yaml,json}" .
grep -rn "api[_-]key\s*=" --include="*.{ts,tsx,js,jsx,py,env,yml,yaml,json}" .
grep -rn "secret\s*=" --include="*.{ts,tsx,js,jsx,py,env,yml,yaml,json}" .
grep -rn "token\s*=" --include="*.{ts,tsx,js,jsx,py,env,yml,yaml,json}" .
# Chaves hardcoded (padrão base64 longo ou hex)
grep -rn "['\"][A-Za-z0-9+/=]\{40,\}['\"]" --include="*.{ts,tsx,js,jsx,py}" .
```

### Injeção
- SQL injection: queries construídas com concatenação.
- XSS: output não sanitizado em templates.
- Command injection: exec/spawn com input do usuário.
- Path traversal: input do usuário em caminhos de arquivo.

### Autenticação e autorização
- Endpoints sem verificação de auth.
- Tokens sem expiração.
- Senhas sem hash adequado.
- CORS permissivo demais.

### Dependências
```bash
# JS
npm audit 2>/dev/null
# Python
pip audit 2>/dev/null || safety check 2>/dev/null
```

### Dados sensíveis
- Logs contendo PII ou dados sensíveis.
- Informação sensível em respostas de API.
- Dados não criptografados em trânsito ou repouso.

## Saída

Para cada achado:
- **Severidade**: 🔴 Crítica | 🟠 Alta | 🟡 Média | 🔵 Baixa
- **Categoria**: OWASP Top 10 quando aplicável.
- **Local**: arquivo e linha.
- **Descrição**: o que foi encontrado.
- **Remediação**: como corrigir.

Resumo final com contagem por severidade e as 3 ações mais urgentes.
