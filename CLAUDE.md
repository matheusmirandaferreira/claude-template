# Team Conventions

Este arquivo define as convenções padrão do time. Carregado automaticamente pelo Claude Code.

## Estrutura de projeto

Seguimos o padrão monorepo com separação frontend/backend:

```
./<projeto>/
├── <projeto>_frontend/    # Aplicação frontend
├── <projeto>_backend/     # Aplicação backend (sufixo opcional)
├── .claude/               # Skills e configs do Claude Code
├── CLAUDE.md              # Este arquivo (convenções do projeto)
└── CLAUDE.local.md        # Overrides locais (não commitado)
```

## Git

### Branches

- `main` — produção, sempre estável
- `develop` — integração, base para features
- `feature/<ticket>-<descricao>` — novas funcionalidades
- `fix/<ticket>-<descricao>` — correções de bugs
- `hotfix/<descricao>` — correções urgentes em produção
- `chore/<descricao>` — tarefas de manutenção

### Commits

Seguimos Conventional Commits. Formato:

```
<tipo>(<escopo>): <descrição curta>

<corpo opcional>

<footer opcional>
```

Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`.

Escopo é o módulo afetado (ex: `auth`, `api`, `ui`).

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
