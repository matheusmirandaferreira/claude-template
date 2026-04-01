# id: laravel
# name: Laravel
# type: backend
# detect: artisan|composer.json:laravel

## Stack
- PHP 8.2+, Laravel 11+, Eloquent ORM, PostgreSQL/MySQL
- Pest / PHPUnit para testes

## Estrutura

```
app/
├── Http/
│   ├── Controllers/[Entity]Controller.php
│   ├── Requests/[Entity]/Store[Entity]Request.php
│   ├── Requests/[Entity]/Update[Entity]Request.php
│   └── Resources/[Entity]Resource.php
├── Models/[Entity].php
├── Services/[Entity]Service.php
├── Policies/[Entity]Policy.php
database/
├── migrations/
├── seeders/
└── factories/
routes/api.php
tests/Feature/[Entity]Test.php
```

## Ordem de Implementação
Migration → Model → FormRequests → Service → Resource → Controller → Route → Test

## Padrões

### Model
```php
class Product extends Model {
    use HasUuids; // ou sem, para auto-increment

    protected $fillable = ['name', 'price', 'active'];
    protected $casts = ['price' => 'decimal:2', 'active' => 'boolean'];
}
```

### FormRequest
```php
class StoreProductRequest extends FormRequest {
    public function authorize(): bool { return true; }
    public function rules(): array {
        return [
            'name' => ['required', 'string', 'min:2', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
        ];
    }
}
```

### Service
```php
class ProductService {
    public function create(array $data): Product {
        return Product::create($data);
    }
    public function findOrFail(string $id): Product {
        return Product::findOrFail($id);
    }
    public function list(int $perPage = 20) {
        return Product::latest()->paginate($perPage);
    }
    public function update(Product $product, array $data): Product {
        $product->update($data);
        return $product->fresh();
    }
    public function delete(Product $product): void {
        $product->delete();
    }
}
```

### Resource
```php
class ProductResource extends JsonResource {
    public function toArray(Request $request): array {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'price' => $this->price,
            'created_at' => $this->created_at,
        ];
    }
}
```

### Controller (fino!)
```php
class ProductController extends Controller {
    public function __construct(private ProductService $service) {}

    public function store(StoreProductRequest $request) {
        $product = $this->service->create($request->validated());
        return ProductResource::make($product)->response()->setStatusCode(201);
    }
    public function show(string $id) {
        return ProductResource::make($this->service->findOrFail($id));
    }
    public function index() {
        return ProductResource::collection($this->service->list());
    }
    public function update(UpdateProductRequest $request, string $id) {
        $product = $this->service->findOrFail($id);
        return ProductResource::make($this->service->update($product, $request->validated()));
    }
    public function destroy(string $id) {
        $this->service->delete($this->service->findOrFail($id));
        return response()->noContent();
    }
}
```

### Route
```php
Route::apiResource('products', ProductController::class);
```

### Teste
```php
it('creates a product', function () {
    $response = $this->postJson('/api/products', ['name' => 'Test', 'price' => 29.99]);
    $response->assertStatus(201)->assertJsonFragment(['name' => 'Test']);
});

it('returns 422 with invalid data', function () {
    $this->postJson('/api/products', ['name' => ''])->assertStatus(422);
});
```

## Regras
- Nunca `$guarded = []` — sempre `$fillable` explícito
- Nunca lógica nos controllers — use Services
- Nunca retorne Model direto — use Resources
- Nunca `DB::raw()` com input do usuário
- FormRequests para toda validação
- `declare(strict_types=1)` em todo arquivo

## Comandos
```bash
php artisan serve
php artisan test
php artisan test --coverage
php artisan make:migration create_x_table
php artisan migrate
php artisan migrate:rollback
./vendor/bin/pint
```
