# id: fastapi
# name: FastAPI + SQLAlchemy + PostgreSQL
# type: backend
# detect: requirements.txt:fastapi|pyproject.toml:fastapi

## Stack
- Python 3.12+, FastAPI 0.110+, SQLAlchemy 2.0+ (async), Alembic, PostgreSQL 16+
- Pydantic v2 para validação, Pytest + httpx para testes

## Estrutura

```
app/
├── main.py                    # FastAPI app, lifespan, router includes
├── core/
│   ├── config.py              # Settings via pydantic-settings (.env)
│   ├── database.py            # async engine + session + get_db
│   ├── security.py            # JWT, hashing
│   └── exceptions.py          # Custom exceptions → HTTPException
├── models/
│   ├── base.py                # Base com id, created_at, updated_at
│   └── [entidade].py
├── schemas/
│   └── [entidade].py          # Create, Update, Response, ListResponse
├── services/
│   └── [entidade]_service.py
├── routes/
│   └── [entidade].py
├── middleware/
└── utils/
```

## Ordem de Implementação
Model → Migration (Alembic) → Schema (Pydantic) → Service → Route → Test

## Padrões

### Model
```python
class Product(Base):
    __tablename__ = "products"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    price = Column(Numeric(10, 2), nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), onupdate=lambda: datetime.now(timezone.utc))
```

### Schema (Pydantic v2)
```python
class ProductCreate(BaseModel):
    name: str = Field(min_length=2, max_length=255)
    price: Decimal = Field(gt=0)

class ProductUpdate(BaseModel):
    name: str | None = None
    price: Decimal | None = None

class ProductResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    name: str
    price: Decimal
    created_at: datetime

class ProductListResponse(BaseModel):
    items: list[ProductResponse]
    total: int
```

### Service
```python
class ProductService:
    @staticmethod
    async def create(db: AsyncSession, data: ProductCreate) -> Product:
        product = Product(**data.model_dump())
        db.add(product)
        await db.commit()
        await db.refresh(product)
        return product

    @staticmethod
    async def get_by_id(db: AsyncSession, id: UUID) -> Product:
        product = await db.get(Product, id)
        if not product:
            raise NotFoundException("Product not found")
        return product
```

### Route (fina!)
```python
router = APIRouter(prefix="/products", tags=["products"])

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=ProductResponse)
async def create(data: ProductCreate, db: AsyncSession = Depends(get_db)):
    return await ProductService.create(db, data)
```

### Testes
```python
class TestProducts:
    async def test_should_create_product(self, client, db_session):
        res = await client.post("/products", json={"name": "Test", "price": "29.99"})
        assert res.status_code == 201
        assert res.json()["name"] == "Test"
```

## Regras
- Nunca `db.execute(text(...))` — sempre ORM
- Nunca retorne model direto — passe por Response schema
- Nunca lógica de negócio na route
- Services throw custom errors, nunca HTTPException
- Sempre `async` para DB operations

## Comandos
```bash
uvicorn app.main:app --reload --port 8000
python -m pytest tests/ -v
python -m pytest tests/ -v --cov=app
alembic revision --autogenerate -m "desc"
alembic upgrade head
ruff check app/ tests/ && ruff format app/ tests/
```
