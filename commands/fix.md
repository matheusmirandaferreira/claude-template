Corrija o seguinte bug: $ARGUMENTS

## Processo Obrigatório

### Fase 1: Diagnóstico
1. Leia a descrição do bug com atenção
2. Identifique o módulo afetado (backend/frontend/ambos)
3. Localize os arquivos prováveis com `grep` e `find`
4. Analise o código ao redor do problema
5. Formule a hipótese da causa raiz

### Fase 2: Correção
1. Aplique a correção MÍNIMA necessária
2. Não refatore código adjacente (a menos que seja a causa)
3. Não mude assinaturas de função/API sem necessidade
4. Preserve backward compatibility

### Fase 3: Teste de Regressão
1. Escreva um teste que FALHA antes da correção e PASSA depois
2. Rode os testes existentes para garantir que nada quebrou:
   - Backend: `python -m pytest tests/ -v`
   - Frontend: `npm run test`

### Fase 4: Documentação
1. Atualize `docs/changelog.md`:
   ```
   ### Fix
   - **[módulo]**: [descrição do bug e da correção]
   ```
2. Commit: `fix: [descrição concisa do que foi corrigido]`

## Regras
- NUNCA faça mudanças cosméticas junto com bug fixes
- NUNCA mude mais arquivos do que o necessário
- Se o bug revela um problema arquitetural, reporte como melhoria separada
- Se não conseguir reproduzir, peça mais contexto antes de tentar corrigir
