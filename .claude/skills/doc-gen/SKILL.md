---
name: doc-gen
description: Gera documentação técnica para código, APIs e módulos. Use quando o usuário pedir documentação, docstrings, JSDoc, README, API docs, ou "documenta isso". Ativa automaticamente quando o contexto indica necessidade de documentação.
allowed-tools: Read, Write, Grep, Glob
---

# Doc Gen

Gera documentação técnica seguindo as convenções do projeto.

## Detecção de contexto

1. Identifique a linguagem e padrão de docs:
   - **TypeScript/JavaScript**: JSDoc ou TSDoc
   - **Python**: docstrings (Google style, NumPy, ou Sphinx — siga o que já existe)
   - **Outra**: siga o padrão idiomático

2. Verifique se já existe documentação parcial e estenda.

## O que documentar

`$ARGUMENTS` pode ser: path de arquivo, módulo, ou "api" / "readme".

### Para funções/métodos
- Descrição concisa do propósito.
- Parâmetros com tipo e descrição.
- Retorno com tipo e descrição.
- Exceções/erros possíveis.
- Exemplo de uso quando a interface não for óbvia.

### Para classes/módulos
- Propósito e responsabilidade.
- Dependências relevantes.
- Exemplo de uso.

### Para APIs (quando solicitado "api")
- Endpoint, método HTTP.
- Headers obrigatórios.
- Request body com tipos.
- Response com tipos e status codes.
- Exemplo de request/response.

### Para README (quando solicitado "readme")
- Descrição do projeto.
- Pré-requisitos.
- Instalação.
- Uso.
- Estrutura do projeto.
- Como contribuir.

## Regras

- Documente o "por quê", não o "o quê" (o código já diz o quê).
- Seja conciso — documentação verbosa é ignorada.
- Mantenha exemplos simples e executáveis.
- Atualize docs existentes ao invés de duplicar.
