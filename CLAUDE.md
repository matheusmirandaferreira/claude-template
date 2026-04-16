# Team Conventions

Este arquivo define as convenções padrão do time. Carregado automaticamente pelo Claude Code.

## Estrutura de projeto

Seguimos dois padrões, monorepo com mais de projeto ou monolito.

### Monorepo:

```
./<projeto>/
├── <repo_1>/              # Aplicação podendo ser frontend, backend ou algum outro repo ou micro-servico
├── <repo_2>/              #
├── .claude/               # Skills e configs do Claude Code
├── CLAUDE.md              # Este arquivo (convenções do projeto)
└── CLAUDE.local.md        # Overrides locais (não commitado)
```

### Monolito
```
./<projeto>/
├── src/                   # Pode variar de acordo com stack do projeto (src/ para React ou Node, app/ para Python, src/ para Laravel e etc)
├── .claude/               # Skills e configs do Claude Code
├── CLAUDE.md              # Este arquivo (convenções do projeto)
└── CLAUDE.local.md        # Overrides locais (não commitado)
```


## Git

### Branches

- `<ticket>` — novas funcionalidades
- `main` / `master` — branch de testes onde vão as tarefas aprovadas
- `HML` - reflete o ambiente de homologação depois de aprovadas as alterações na master
- `PROD` - reflete o ambiente de produção com a versão de HML aprovada

### Commits

Seguimos Conventional Commits. Formato:

```
<ticket> - <descrição curta>
```

### Pull Requests

Toda PR precisa de: descrição do que muda, por que muda, como testar, e checklist de revisão.

## Código

### Princípios gerais

- Prefira composição sobre herança.
- Funções devem fazer uma coisa e fazer bem.
- Nomes descritivos, sem abreviações obscuras.
- Comentários explicam "por quê", não "o quê".
- Sem código morto ou comentado no merge.
- Trate warnings como errors.

### Testes

- Todo código novo precisa de testes.
- Cobertura mínima: 80% em novos arquivos.
- Testes devem ser independentes e determinísticos.
- Use mocks/stubs com parcimônia — prefira testes de integração quando viável.

### Segurança

- Nunca commite secrets, tokens ou credenciais.
- Use variáveis de ambiente para configuração sensível.
- Valide toda entrada do usuário.
- Sanitize toda saída.

## Documentação

- Toda API pública precisa de docstring/JSDoc.
- README atualizado é pré-requisito de merge.
- ADRs (Architecture Decision Records) para decisões significativas.

## Claude Code — Regras de uso

- Use `/commit` para gerar mensagens de commit.
- Use `/code-review` antes de abrir PRs.
- Use `/test-gen` ao adicionar lógica de negócio.
- Prefira edições cirúrgicas a reescritas completas.
- Sempre verifique se testes passam antes de commitar.

---

## Project-specific

<!-- Preencha esta seção com detalhes do seu projeto -->
<!-- Exemplos: stack utilizada, padrões de naming, endpoints, etc. -->
