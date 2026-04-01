# id: nestjs
# name: NestJS + TypeORM
# type: backend
# detect: package.json:@nestjs/core

## Stack
- Node.js 20+ / TypeScript 5+ (strict mode)
- NestJS 10+
- TypeORM + PostgreSQL
- class-validator + class-transformer para DTOs
- Jest + Supertest para testes

## Estrutura

```
src/
├── main.ts                          # Bootstrap
├── app.module.ts                    # Root module
├── config/
│   └── configuration.ts
├── common/
│   ├── filters/exception.filter.ts
│   ├── guards/auth.guard.ts
│   ├── interceptors/
│   └── pipes/
└── modules/
    └── [feature]/
        ├── [feature].module.ts
        ├── [feature].controller.ts
        ├── [feature].service.ts
        ├── [feature].entity.ts
        ├── dto/
        │   ├── create-[feature].dto.ts
        │   └── update-[feature].dto.ts
        └── [feature].controller.spec.ts
```

## Ordem de Implementação
Entity → Migration → DTOs → Service → Controller → Module → Register → Test

## Padrões

### Entity
```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  name: string;

  @Column('decimal', { precision: 10, scale: 2 })
  price: number;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;
}
```

### DTOs (class-validator)
```typescript
import { IsString, IsNumber, IsOptional, Min, MinLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateProductDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsNumber()
  @Min(0)
  price: number;
}

export class UpdateProductDto extends PartialType(CreateProductDto) {}
```

### Service
```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class ProductService {
  constructor(
    @InjectRepository(Product)
    private readonly repo: Repository<Product>,
  ) {}

  async create(dto: CreateProductDto): Promise<Product> {
    const product = this.repo.create(dto);
    return this.repo.save(product);
  }

  async findById(id: string): Promise<Product> {
    const product = await this.repo.findOneBy({ id });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async list(skip = 0, limit = 20) {
    const [items, total] = await this.repo.findAndCount({
      skip, take: limit, order: { createdAt: 'DESC' },
    });
    return { items, total };
  }

  async update(id: string, dto: UpdateProductDto): Promise<Product> {
    const product = await this.findById(id);
    Object.assign(product, dto);
    return this.repo.save(product);
  }

  async remove(id: string): Promise<void> {
    const product = await this.findById(id);
    await this.repo.remove(product);
  }
}
```

### Controller
```typescript
import { Controller, Get, Post, Patch, Delete, Param, Body, Query, HttpCode } from '@nestjs/common';

@Controller('products')
export class ProductController {
  constructor(private readonly service: ProductService) {}

  @Post()
  create(@Body() dto: CreateProductDto) {
    return this.service.create(dto);
  }

  @Get(':id')
  findById(@Param('id') id: string) {
    return this.service.findById(id);
  }

  @Get()
  list(@Query('skip') skip?: number, @Query('limit') limit?: number) {
    return this.service.list(skip, limit);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateProductDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(204)
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
```

## Regras
- Um module por feature, registrado no AppModule
- Services injetados via constructor
- DTOs com class-validator (nunca validação manual)
- `PartialType` para update DTOs
- Nunca lógica nos controllers
- Global ValidationPipe habilitado
- Nunca `any`

## Comandos
```bash
npm run start:dev                                  # Dev server
npm run test                                       # Unit tests
npm run test:e2e                                   # E2E tests
npm run test:cov                                   # Coverage
npx typeorm migration:generate -d src/config/database.ts src/migrations/Name
npx typeorm migration:run -d src/config/database.ts
npm run lint
```
