Corrija o seguinte bug: $ARGUMENTS

## Processo

### 1. Diagnóstico
- Identifique o módulo afetado (backend/frontend/ambos)
- Localize os arquivos com `grep` e `find`
- Formule a causa raiz

### 2. Correção
- Aplique a correção MÍNIMA necessária
- Não refatore código adjacente
- Não mude assinaturas de API sem necessidade

### 3. Teste de regressão
- Escreva um teste que reproduza o bug
- Rode os testes existentes

### 4. Finalização
- Atualize `docs/changelog.md`
- Commit: `fix: [descrição]`

## Regras
- NUNCA mudanças cosméticas junto com bug fix
- Se o bug revela problema arquitetural, reporte separado
- Se não conseguir reproduzir, peça contexto antes de corrigir
