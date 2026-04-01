# API Contracts

> Fonte de verdade para contratos entre frontend e backend.
> Atualize sempre que adicionar/alterar endpoints.

## Base URL

- **Dev**: `http://localhost:8000`
- **Staging**: TBD
- **Prod**: TBD

## Autenticação

```
Authorization: Bearer <token>
```

Endpoints com 🔒 requerem autenticação.

---

## Health

### `GET /health`

**Response** `200`:
```json
{ "status": "healthy" }
```
