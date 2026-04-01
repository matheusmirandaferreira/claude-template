Auditoria de segurança: $ARGUMENTS

Se vazio, audite o projeto inteiro.

## Checklist

### 1. Injeção
```bash
grep -rn "raw\|execute(\|text(" --include="*.py" --include="*.php" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules | grep -v vendor
grep -rn "dangerouslySetInnerHTML\|innerHTML\|v-html\|{!!" --include="*.tsx" --include="*.jsx" --include="*.vue" --include="*.blade.php" . 2>/dev/null
```

### 2. Secrets
```bash
grep -rn "password\|secret\|api_key\|private_key" --include="*.py" --include="*.php" --include="*.ts" --include="*.env" . 2>/dev/null | grep -v node_modules | grep -v vendor | grep -v ".example" | grep -v test
```

### 3. Auth — rotas protegidas exigem autenticação, rate limiting presente

### 4. Config — CORS, debug mode, HTTPS

### 5. Dependências
```bash
npm audit --production 2>/dev/null; composer audit 2>/dev/null; pip audit 2>/dev/null
```

## Relatório
```
## Auditoria — [data]
- 🔴 Críticos: X | 🟡 Moderados: Y | 🔵 Baixos: Z | ✅ OK: W

### [SEVERIDADE] Título
- Local: arquivo:linha
- Impacto: ...
- Correção: ...
```
