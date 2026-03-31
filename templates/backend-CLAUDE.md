# CLAUDE.md — Backend

## Stack
- Python 3.12+
- FastAPI 0.110+
- SQLAlchemy 2.0+ (async)
- Alembic para migrations
- PostgreSQL 16+
- Pydantic v2 para validação
- Pytest + httpx para testes
- UV ou pip para dependências

## Estrutura

```
app/
├── main.py                    # FastAPI app, lifespan, router includes
├── core/
│   ├── config.py              # Settings via pydantic-settings (.env)
│   ├── database.py            # Engine, SessionLocal, get_db dependency
│   ├── security.py            # JWT encode/decode, password hashing
│   └── exceptions.py          # Custom exceptions → HTTPException mapping
├── models/                    # SQLAlchemy ORM models
│   ├── base.py                # Base model com id, created_at, updated_at
│   └── [entidade].py
├── schemas/                   # Pydantic v2 schemas
│   └── [entidade].py          # Create, Update, Response, ListResponse
├── services/                  # Business logic (NUNCA nas routes)
│   └── [entidade]_service.py
├── routes/                    # FastAPI routers (finos!)
│   ├── health.py
│   └── [entidade].py
├── middleware/
│   ├── cors.py
│   ├── auth.py                # Dependency para autenticação
│   └── rate_limit.py
└── utils/                     # Helpers genéricos
```

## Padrões

### Models (SQLAlchemy)
```python
from app.models.base import Base
from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
import uuid
from datetime import datetime, timezone

class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), onupdate=lambda: datetime.now(timezone.utc))
```

### Schemas (Pydantic v2)
```python
from pydantic import BaseModel, EmailStr, ConfigDict
from uuid import UUID
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    email: EmailStr | None = None

class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    created_at: datetime

class UserListResponse(BaseModel):
    items: list[UserResponse]
    total: int
```

### Services
```python
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User
from app.schemas.user import UserCreate
from app.core.exceptions import NotFoundException

class UserService:
    @staticmethod
    async def create(db: AsyncSession, data: UserCreate) -> User:
        user = User(**data.model_dump())
        db.add(user)
        await db.commit()
        await db.refresh(user)
        return user

    @staticmethod
    async def get_by_id(db: AsyncSession, user_id: UUID) -> User:
        user = await db.get(User, user_id)
        if not user:
            raise NotFoundException("User not found")
        return user
```

### Routes (finas!)
```python
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=UserResponse)
async def create_user(data: UserCreate, db: AsyncSession = Depends(get_db)):
    return await UserService.create(db, data)
```

## Regras Específicas
- Nunca use `db.execute(text("SELECT ..."))` — sempre ORM
- Nunca retorne o model direto — sempre passe por schema Response
- Nunca coloque lógica de negócio na route
- Sempre use `async` para operações de DB
- Sempre use Depends() para injeção de dependência
- Sempre valide UUIDs em path params
- HTTP status codes: 201 create, 200 read/update, 204 delete, 404 not found, 422 validation

## Comandos
```bash
# Dev server
uvicorn app.main:app --reload --port 8000

# Testes
python -m pytest tests/ -v

# Testes com coverage
python -m pytest tests/ -v --cov=app --cov-report=term-missing

# Nova migration
alembic revision --autogenerate -m "descrição"

# Aplicar migrations
alembic upgrade head

# Lint
ruff check app/ tests/

# Format
ruff format app/ tests/
```
