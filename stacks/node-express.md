# id: node-express
# name: Node.js + Express + TypeORM
# type: backend
# detect: package.json:express+typeorm|package.json:express+TypeORM

## Stack
- Node.js 20+ / TypeScript 5+ (strict mode)
- Express
- TypeORM + PostgreSQL
- Zod para validação
- Jest + Supertest para testes

## Estrutura

```
src/
├── server.ts                     # Entry point
├── app.ts                        # Express app, middleware, routes
├── config/
│   ├── database.ts               # DataSource config
│   └── env.ts                    # Zod-validated env vars
├── entities/                     # TypeORM entities
│   └── [Entity].ts
├── migrations/                   # TypeORM migrations
├── dto/                          # Zod schemas (request/response)
│   └── [entity].dto.ts
├── services/                     # Business logic
│   └── [entity].service.ts
├── controllers/                  # Route handlers (finos!)
│   └── [entity].controller.ts
├── routes/                       # Express routers
│   └── [entity].routes.ts
├── middleware/
│   ├── auth.ts
│   ├── validate.ts               # Zod validation middleware
│   └── error-handler.ts          # Global error handler
├── utils/
│   └── errors.ts                 # Custom error classes
└── __tests__/
    └── [entity].test.ts
```

## Ordem de Implementação
Entity → Migration → DTO (Zod) → Service → Controller → Route → Test

## Padrões

### Entity (TypeORM)
```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;

  @Column({ type: 'boolean', default: true })
  active: boolean;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;
}
```

### DTO (Zod)
```typescript
import { z } from 'zod';

export const createProductSchema = z.object({
  name: z.string().min(2).max(255),
  price: z.number().positive(),
  active: z.boolean().optional().default(true),
});

export const updateProductSchema = createProductSchema.partial();

export const listQuerySchema = z.object({
  skip: z.coerce.number().int().min(0).default(0),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
});

export type CreateProductDTO = z.infer<typeof createProductSchema>;
export type UpdateProductDTO = z.infer<typeof updateProductSchema>;
```

### Validation Middleware
```typescript
import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';

export const validate = (schema: ZodSchema, source: 'body' | 'query' | 'params' = 'body') =>
  (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req[source]);
    if (!result.success) {
      return res.status(422).json({ errors: result.error.flatten().fieldErrors });
    }
    req[source] = result.data;
    next();
  };
```

### Service
```typescript
import { AppDataSource } from '../config/database';
import { Product } from '../entities/Product';
import { CreateProductDTO, UpdateProductDTO } from '../dto/product.dto';
import { NotFoundException } from '../utils/errors';

const repo = AppDataSource.getRepository(Product);

export class ProductService {
  static async create(data: CreateProductDTO): Promise<Product> {
    const product = repo.create(data);
    return repo.save(product);
  }

  static async findById(id: string): Promise<Product> {
    const product = await repo.findOneBy({ id });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  static async list(skip = 0, limit = 20): Promise<{ items: Product[]; total: number }> {
    const [items, total] = await repo.findAndCount({
      skip,
      take: limit,
      order: { createdAt: 'DESC' },
    });
    return { items, total };
  }

  static async update(id: string, data: UpdateProductDTO): Promise<Product> {
    const product = await this.findById(id);
    Object.assign(product, data);
    return repo.save(product);
  }

  static async delete(id: string): Promise<void> {
    const product = await this.findById(id);
    await repo.remove(product);
  }
}
```

### Controller (fino!)
```typescript
import { Request, Response } from 'express';
import { ProductService } from '../services/product.service';

export class ProductController {
  static async create(req: Request, res: Response) {
    const product = await ProductService.create(req.body);
    res.status(201).json(product);
  }

  static async findById(req: Request, res: Response) {
    const product = await ProductService.findById(req.params.id);
    res.json(product);
  }

  static async list(req: Request, res: Response) {
    const { skip, limit } = req.query as any;
    const result = await ProductService.list(skip, limit);
    res.json(result);
  }

  static async update(req: Request, res: Response) {
    const product = await ProductService.update(req.params.id, req.body);
    res.json(product);
  }

  static async delete(req: Request, res: Response) {
    await ProductService.delete(req.params.id);
    res.status(204).send();
  }
}
```

### Routes
```typescript
import { Router } from 'express';
import { ProductController } from '../controllers/product.controller';
import { validate } from '../middleware/validate';
import { createProductSchema, updateProductSchema, listQuerySchema } from '../dto/product.dto';

const router = Router();

router.post('/', validate(createProductSchema), ProductController.create);
router.get('/', validate(listQuerySchema, 'query'), ProductController.list);
router.get('/:id', ProductController.findById);
router.patch('/:id', validate(updateProductSchema), ProductController.update);
router.delete('/:id', ProductController.delete);

export default router;
```

### Error Handler
```typescript
import { Request, Response, NextFunction } from 'express';
import { NotFoundException } from '../utils/errors';

export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  if (err instanceof NotFoundException) {
    return res.status(404).json({ error: err.message });
  }
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
}
```

### Testes
```typescript
import request from 'supertest';
import { app } from '../app';
import { AppDataSource } from '../config/database';

beforeAll(async () => { await AppDataSource.initialize(); });
afterAll(async () => { await AppDataSource.destroy(); });

describe('POST /products', () => {
  it('should create product with valid data', async () => {
    const res = await request(app)
      .post('/products')
      .send({ name: 'Test Product', price: 29.99 });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.name).toBe('Test Product');
  });

  it('should return 422 with invalid data', async () => {
    const res = await request(app)
      .post('/products')
      .send({ name: '' });
    expect(res.status).toBe(422);
  });
});
```

## Regras
- Nunca lógica de negócio nos controllers
- Nunca `any` — sempre tipos explícitos
- Nunca query raw sem parametrização — use TypeORM repository
- Services throw custom errors, error handler mapeia para HTTP status
- DTOs com Zod: um schema por operação (create, update, list query)
- Testes com Supertest + banco real (test database)

## Comandos
```bash
npm run dev                                        # Dev server
npm run test                                       # Testes
npm run test -- --coverage                         # Coverage
npx typeorm migration:generate -d src/config/database.ts src/migrations/NomeMigration  # Nova migration
npx typeorm migration:run -d src/config/database.ts    # Aplicar
npx typeorm migration:revert -d src/config/database.ts # Reverter
npm run lint                                       # Lint
npx tsc --noEmit                                   # Type check
```
