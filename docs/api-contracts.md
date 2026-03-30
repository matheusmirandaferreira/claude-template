# API Contracts

> Este documento é a fonte de verdade para os contratos entre frontend e backend.
> Atualize sempre que adicionar/alterar endpoints.

## Base URL

- **Dev**: `http://localhost:8000`
- **Staging**: `https://api.staging.projeto.com`
- **Prod**: `https://api.projeto.com`

## Autenticação

```
Authorization: Bearer <jwt_token>
```

Endpoints marcados com 🔒 requerem autenticação.

---

## Health

### `GET /health`
Verifica se o serviço está rodando.

**Response** `200`:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2025-01-01T00:00:00Z"
}
```

---

<!-- 
TEMPLATE para novos endpoints:

## [Entidade]

### `POST /[entidades]` 🔒
Cria um(a) novo(a) [entidade].

**Request Body**:
```json
{
  "campo": "tipo — descrição"
}
```

**Response** `201`:
```json
{
  "id": "uuid",
  "campo": "valor",
  "created_at": "datetime"
}
```

**Errors**:
- `422` — Validação falhou
- `401` — Não autenticado
- `409` — Conflito (duplicado)
-->
