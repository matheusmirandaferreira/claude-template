---
name: test-gen
description: Gera testes unitários e de integração para código existente. Use quando o usuário pedir para criar testes, aumentar cobertura, "testa isso", "adiciona testes", ou ao implementar lógica de negócio que precisa de verificação.
allowed-tools: Read, Write, Grep, Glob, Bash
---

# Test Gen

Gera testes para código existente, respeitando o framework e convenções do projeto.

## Detecção do ambiente

1. Identifique o framework de testes do projeto:
```bash
# JS/TS
cat package.json | grep -E "jest|vitest|mocha|playwright|cypress"

# Python
cat pyproject.toml requirements*.txt | grep -E "pytest|unittest|nose"

# Outros: procure configs de teste
ls -la *test* *spec* pytest.ini jest.config.* vitest.config.* 2>/dev/null
```

2. Identifique padrões existentes:
```bash
# Onde ficam os testes?
find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) | head -20

# Padrão de um teste existente
```

3. Siga o padrão encontrado (localização, naming, imports, assertions).

## O que receber como input

`$ARGUMENTS` pode ser: path de arquivo, nome de função/classe, ou descrição do que testar.

Se não fornecido, pergunte o que testar.

## Geração de testes

Para cada função/método público:

### Testes unitários
- **Happy path**: input válido → output esperado.
- **Edge cases**: null, undefined, vazio, limites, tipos inesperados.
- **Erros**: inputs inválidos devem resultar em erro adequado.

### Testes de integração (quando aplicável)
- Fluxo completo entre módulos.
- Interação com banco, API, ou serviços externos (mocked).

## Regras

- Cada teste deve ter um nome descritivo que explique o cenário.
- Use o padrão Arrange-Act-Assert (AAA) ou Given-When-Then.
- Mocks apenas para dependências externas, nunca para o SUT (System Under Test).
- Testes devem ser independentes — sem dependência de ordem de execução.
- Rode os testes ao final para verificar que passam:
```bash
# Adapte ao framework detectado
npm test -- --passWithNoTests
pytest -x
```

## Formato

Crie o arquivo de teste no local correto seguindo a convenção do projeto. Se não há convenção clara, coloque ao lado do arquivo fonte com sufixo `.test` ou `.spec`.
