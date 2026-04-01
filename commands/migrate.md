Gerencie migrations: $ARGUMENTS

## Comportamento

Use a ferramenta de migration da stack (documentada no CLAUDE.md do subprojeto).

- **generate** / **auto**: gere nova migration, revise o arquivo gerado
- **up** / **upgrade**: aplique migrations pendentes
- **down** / **downgrade**: reverta última migration
- **status** / **history**: mostre estado atual
- **[descrição livre]**: gere migration com essa descrição

## Regras
- Mensagens em inglês: `create users table`, `add email index`
- Nunca edite migrations já aplicadas em produção
- Sempre inclua operação reversa
- Para mudanças destrutivas (drop), avise antes
