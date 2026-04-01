# id: react
# name: React + TypeScript + Vite + TanStack
# type: frontend
# detect: package.json:react+vite|package.json:@tanstack/react-router

## Stack
- React 18+, TypeScript 5+ (strict), Vite 5+, Tailwind CSS 3+, shadcn/ui
- TanStack Query v5 + Axios, TanStack Router, React Hook Form + Zod (useController)
- Vitest + Testing Library

## Estrutura

```
src/
├── main.tsx                     # RouterProvider + QueryClientProvider
├── routeTree.gen.ts             # Auto-gerado
├── routes/
│   ├── __root.tsx               # Root layout
│   ├── _authenticated.tsx       # Auth guard (beforeLoad + redirect)
│   └── _authenticated/[feature]/
├── components/
│   ├── ui/                      # shadcn/ui (NÃO EDITAR)
│   ├── form/                    # FormInput, FormSelect, etc. (useController)
│   ├── layout/
│   └── [feature]/
├── hooks/                       # queryOptions + useQuery/useMutation
├── lib/
│   ├── api.ts                   # Axios instance + interceptors
│   ├── api/[feature].ts         # API functions
│   ├── query-client.ts
│   └── utils.ts                 # cn()
├── validators/                  # Zod schemas
├── types/
└── __tests__/
```

## Ordem de Implementação
Types → Validator (Zod) → API functions → Hooks (queryOptions) → FormFields → Components → Route → Test

## Padrões

### API Client + Functions
```typescript
// lib/api.ts
export const api = axios.create({ baseURL: import.meta.env.VITE_API_URL });
api.interceptors.request.use((c) => {
  const token = localStorage.getItem('token');
  if (token) c.headers.Authorization = `Bearer ${token}`;
  return c;
});

// lib/api/products.ts — retorna .data direto
export const productsApi = {
  list: (params: { skip?: number; limit?: number }) =>
    api.get<PaginatedResponse<Product>>('/products', { params }).then(r => r.data),
  getById: (id: string) => api.get<Product>(`/products/${id}`).then(r => r.data),
  create: (data: ProductCreate) => api.post<Product>('/products', data).then(r => r.data),
  update: (id: string, data: ProductUpdate) => api.patch<Product>(`/products/${id}`, data).then(r => r.data),
  delete: (id: string) => api.delete(`/products/${id}`),
};
```

### Hooks (queryOptions reutilizáveis em loaders)
```typescript
export const productsQueryOptions = (params?: { skip?: number; limit?: number }) =>
  queryOptions({ queryKey: ['products', params ?? {}], queryFn: () => productsApi.list(params ?? {}) });

export const useProducts = (params?) => useQuery(productsQueryOptions(params));

export function useCreateProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: productsApi.create,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['products'] }),
  });
}
```

### Route com Loader
```typescript
export const Route = createFileRoute('/_authenticated/products/')({
  validateSearch: z.object({ page: z.number().default(1), limit: z.number().default(20) }),
  loader: ({ context: { queryClient } }) => queryClient.ensureQueryData(productsQueryOptions()),
  component: ProductsPage,
});
```

### FormField com useController
```typescript
export function FormInput<T extends FieldValues>({ control, name, label, ...props }: FormInputProps<T>) {
  const { field, fieldState: { error } } = useController({ name, control });
  return (
    <div className="space-y-2">
      <Label htmlFor={name} className={cn(error && 'text-destructive')}>{label}</Label>
      <Input {...field} id={name} className={cn(error && 'border-destructive')} value={field.value ?? ''} {...props} />
      {error && <p className="text-sm text-destructive">{error.message}</p>}
    </div>
  );
}
```

### Form completo
```typescript
export function ProductForm({ product, onSuccess }: { product?: Product; onSuccess?: () => void }) {
  const create = useCreateProduct();
  const update = useUpdateProduct();
  const { control, handleSubmit, formState: { isSubmitting } } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues: { name: product?.name ?? '', price: product?.price ?? 0 },
  });
  const onSubmit = async (data: ProductFormData) => {
    product ? await update.mutateAsync({ id: product.id, data }) : await create.mutateAsync(data);
    onSuccess?.();
  };
  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <FormInput control={control} name="name" label="Nome" />
      <FormInput control={control} name="price" label="Preço" type="number" />
      <Button type="submit" disabled={isSubmitting}>{isSubmitting ? 'Salvando...' : 'Salvar'}</Button>
    </form>
  );
}
```

## Regras
- NUNCA React Router — sempre TanStack Router
- NUNCA `register` direto em shadcn — sempre `useController`
- NUNCA `useEffect` para fetch — sempre TanStack Query
- NUNCA server state em useState — sempre queryOptions
- Use `gcTime` (v5), nunca `cacheTime`
- Sempre 3 estados: loading, error, success
- Mobile-first, `cn()` para classes, `@/` para imports

## Comandos
```bash
npm run dev
npm run build
npm run test
npm run test -- --coverage
npm run lint
npx shadcn@latest add [component]
npx tsc --noEmit
npx tsr generate
```
