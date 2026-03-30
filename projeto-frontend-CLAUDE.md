# CLAUDE.md — Frontend

## Stack
- React 18+
- TypeScript 5+ (strict mode)
- Vite 5+
- Tailwind CSS 3+
- shadcn/ui (componentes base)
- TanStack Query v5 para server state (com Axios)
- TanStack Router para navegação (file-based routing)
- React Hook Form + Zod para formulários
- useController para integração RHF ↔ shadcn/ui
- Axios para HTTP client
- Vitest + Testing Library para testes

## Estrutura

```
src/
├── main.tsx                     # Entry point com RouterProvider
├── index.css                    # Tailwind directives + globals
├── routeTree.gen.ts             # Auto-gerado pelo TanStack Router
├── routes/
│   ├── __root.tsx               # Root layout (providers, shell)
│   ├── index.tsx                # Home "/"
│   ├── _authenticated.tsx       # Layout guard para rotas autenticadas
│   ├── _authenticated/
│   │   └── [feature]/
│   │       ├── index.tsx        # Lista "/[feature]"
│   │       ├── $id.tsx          # Detalhe "/[feature]/$id"
│   │       └── new.tsx          # Criação "/[feature]/new"
│   ├── login.tsx
│   └── register.tsx
├── components/
│   ├── ui/                      # shadcn/ui (NÃO EDITAR MANUALMENTE)
│   ├── form/                    # Form fields com useController
│   │   ├── FormInput.tsx
│   │   ├── FormSelect.tsx
│   │   ├── FormTextarea.tsx
│   │   ├── FormCheckbox.tsx
│   │   ├── FormDatePicker.tsx
│   │   └── FormCombobox.tsx
│   ├── layout/                  # Header, Sidebar, Footer, PageLayout
│   └── [feature]/               # Componentes por feature
│       ├── [Feature]List.tsx
│       ├── [Feature]Form.tsx
│       ├── [Feature]Card.tsx
│       └── [Feature]Detail.tsx
├── hooks/
│   └── use-[feature].ts         # TanStack Query hooks por feature
├── lib/
│   ├── api.ts                   # Axios instance configurada
│   ├── api/                     # Funções de API por entidade
│   │   └── [feature].ts
│   ├── query-client.ts          # QueryClient config centralizada
│   ├── utils.ts                 # cn() e helpers
│   └── constants.ts
├── validators/                  # Zod schemas (separados dos types)
│   └── [feature].ts
├── types/
│   ├── index.ts                 # Re-exports
│   └── [feature].ts             # Types por feature
└── __tests__/
    └── [feature]/
```

## TanStack Router

### Setup (`main.tsx`)
```typescript
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { RouterProvider, createRouter } from '@tanstack/react-router';
import { QueryClientProvider } from '@tanstack/react-query';
import { routeTree } from './routeTree.gen';
import { queryClient } from './lib/query-client';

const router = createRouter({
  routeTree,
  context: { queryClient },
  defaultPreload: 'intent',
  defaultPreloadStaleTime: 0,
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  </StrictMode>,
);
```

### Root Layout (`routes/__root.tsx`)
```typescript
import { createRootRouteWithContext, Outlet } from '@tanstack/react-router';
import type { QueryClient } from '@tanstack/react-query';

interface RouterContext {
  queryClient: QueryClient;
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: () => (
    <div className="min-h-screen bg-background">
      <Outlet />
    </div>
  ),
});
```

### Route com Loader (data pre-fetching)
```typescript
// routes/_authenticated/users/index.tsx
import { createFileRoute } from '@tanstack/react-router';
import { usersQueryOptions } from '@/hooks/use-users';
import { UserList } from '@/components/users/UserList';

export const Route = createFileRoute('/_authenticated/users/')({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(usersQueryOptions()),
  component: UsersPage,
});

function UsersPage() {
  return <UserList />;
}
```

### Route com Params
```typescript
// routes/_authenticated/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router';
import { userQueryOptions } from '@/hooks/use-users';

export const Route = createFileRoute('/_authenticated/users/$id')({
  loader: ({ context: { queryClient }, params: { id } }) =>
    queryClient.ensureQueryData(userQueryOptions(id)),
  component: UserDetailPage,
});

function UserDetailPage() {
  const { id } = Route.useParams();
  // ...
}
```

### Authenticated Layout Guard
```typescript
// routes/_authenticated.tsx
import { createFileRoute, Outlet, redirect } from '@tanstack/react-router';

export const Route = createFileRoute('/_authenticated')({
  beforeLoad: () => {
    if (!isAuthenticated()) {
      throw redirect({ to: '/login' });
    }
  },
  component: () => (
    <AppShell>
      <Outlet />
    </AppShell>
  ),
});
```

### Navegação Tipada
```typescript
import { Link, useNavigate } from '@tanstack/react-router';

// Link tipado — autocomplete de rotas
<Link to="/users/$id" params={{ id: user.id }}>
  {user.name}
</Link>

// Navigate programático tipado
const navigate = useNavigate();
navigate({ to: '/users/$id', params: { id: newUser.id } });
```

### Search Params Tipados (filtros, paginação)
```typescript
import { createFileRoute } from '@tanstack/react-router';
import { z } from 'zod';

const usersSearchSchema = z.object({
  page: z.number().default(1),
  limit: z.number().default(20),
  search: z.string().optional(),
  status: z.enum(['active', 'inactive']).optional(),
});

export const Route = createFileRoute('/_authenticated/users/')({
  validateSearch: usersSearchSchema,
  component: UsersPage,
});

function UsersPage() {
  const { page, limit, search, status } = Route.useSearch();
  const navigate = useNavigate();

  const setFilters = (newFilters: Partial<z.infer<typeof usersSearchSchema>>) => {
    navigate({ search: (prev) => ({ ...prev, ...newFilters }) });
  };
}
```

## TanStack Query v5 + Axios

### QueryClient (`lib/query-client.ts`)
```typescript
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,
      gcTime: 1000 * 60 * 5,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});
```

### API Client (`lib/api.ts`)
```typescript
import axios, { AxiosError } from 'axios';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000',
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  },
);
```

### API Functions (`lib/api/users.ts`)
```typescript
import { api } from '../api';
import type { User, UserCreate, UserUpdate, PaginatedResponse } from '@/types';

export const usersApi = {
  list: (params: { skip?: number; limit?: number; search?: string }) =>
    api.get<PaginatedResponse<User>>('/users', { params }).then((r) => r.data),

  getById: (id: string) =>
    api.get<User>(`/users/${id}`).then((r) => r.data),

  create: (data: UserCreate) =>
    api.post<User>('/users', data).then((r) => r.data),

  update: (id: string, data: UserUpdate) =>
    api.patch<User>(`/users/${id}`, data).then((r) => r.data),

  delete: (id: string) =>
    api.delete(`/users/${id}`),
};
```

### Query Hooks com queryOptions (`hooks/use-users.ts`)
```typescript
import { queryOptions, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { usersApi } from '@/lib/api/users';
import type { UserCreate, UserUpdate } from '@/types';

// queryOptions — reutilizável em hooks E em route loaders
export const usersQueryOptions = (params?: { skip?: number; limit?: number; search?: string }) =>
  queryOptions({
    queryKey: ['users', params ?? {}],
    queryFn: () => usersApi.list(params ?? {}),
  });

export const userQueryOptions = (id: string) =>
  queryOptions({
    queryKey: ['users', id],
    queryFn: () => usersApi.getById(id),
    enabled: !!id,
  });

export const useUsers = (params?: { skip?: number; limit?: number; search?: string }) =>
  useQuery(usersQueryOptions(params));

export const useUser = (id: string) =>
  useQuery(userQueryOptions(id));

export function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: UserCreate) => usersApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UserUpdate }) =>
      usersApi.update(id, data),
    onSuccess: (_data, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['users', id] });
    },
  });
}

export function useDeleteUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => usersApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

## React Hook Form + useController + shadcn/ui

### Padrão: FormField com useController

Todos os campos integram RHF com shadcn/ui via `useController`.
Ficam em `src/components/form/` e são reutilizáveis em qualquer form.

```typescript
// components/form/FormInput.tsx
import { useController, type Control, type FieldValues, type Path } from 'react-hook-form';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

interface FormInputProps<T extends FieldValues> {
  control: Control<T>;
  name: Path<T>;
  label: string;
  placeholder?: string;
  type?: string;
  description?: string;
  disabled?: boolean;
  className?: string;
}

export function FormInput<T extends FieldValues>({
  control, name, label, placeholder, type = 'text',
  description, disabled, className,
}: FormInputProps<T>) {
  const { field, fieldState: { error } } = useController({ name, control });

  return (
    <div className={cn('space-y-2', className)}>
      <Label htmlFor={name} className={cn(error && 'text-destructive')}>
        {label}
      </Label>
      <Input
        {...field}
        id={name}
        type={type}
        placeholder={placeholder}
        disabled={disabled}
        className={cn(error && 'border-destructive')}
        value={field.value ?? ''}
      />
      {description && !error && (
        <p className="text-sm text-muted-foreground">{description}</p>
      )}
      {error && <p className="text-sm text-destructive">{error.message}</p>}
    </div>
  );
}
```

```typescript
// components/form/FormSelect.tsx
import { useController, type Control, type FieldValues, type Path } from 'react-hook-form';
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

interface SelectOption { label: string; value: string }

interface FormSelectProps<T extends FieldValues> {
  control: Control<T>;
  name: Path<T>;
  label: string;
  options: SelectOption[];
  placeholder?: string;
  disabled?: boolean;
  className?: string;
}

export function FormSelect<T extends FieldValues>({
  control, name, label, options,
  placeholder = 'Selecione...', disabled, className,
}: FormSelectProps<T>) {
  const { field, fieldState: { error } } = useController({ name, control });

  return (
    <div className={cn('space-y-2', className)}>
      <Label htmlFor={name} className={cn(error && 'text-destructive')}>
        {label}
      </Label>
      <Select value={field.value ?? ''} onValueChange={field.onChange} disabled={disabled}>
        <SelectTrigger className={cn(error && 'border-destructive')}>
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent>
          {options.map((opt) => (
            <SelectItem key={opt.value} value={opt.value}>{opt.label}</SelectItem>
          ))}
        </SelectContent>
      </Select>
      {error && <p className="text-sm text-destructive">{error.message}</p>}
    </div>
  );
}
```

```typescript
// components/form/FormTextarea.tsx
import { useController, type Control, type FieldValues, type Path } from 'react-hook-form';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

interface FormTextareaProps<T extends FieldValues> {
  control: Control<T>;
  name: Path<T>;
  label: string;
  placeholder?: string;
  rows?: number;
  disabled?: boolean;
  className?: string;
}

export function FormTextarea<T extends FieldValues>({
  control, name, label, placeholder, rows = 3, disabled, className,
}: FormTextareaProps<T>) {
  const { field, fieldState: { error } } = useController({ name, control });

  return (
    <div className={cn('space-y-2', className)}>
      <Label htmlFor={name} className={cn(error && 'text-destructive')}>{label}</Label>
      <Textarea
        {...field}
        id={name}
        placeholder={placeholder}
        rows={rows}
        disabled={disabled}
        className={cn(error && 'border-destructive')}
        value={field.value ?? ''}
      />
      {error && <p className="text-sm text-destructive">{error.message}</p>}
    </div>
  );
}
```

```typescript
// components/form/FormCheckbox.tsx
import { useController, type Control, type FieldValues, type Path } from 'react-hook-form';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

interface FormCheckboxProps<T extends FieldValues> {
  control: Control<T>;
  name: Path<T>;
  label: string;
  description?: string;
  disabled?: boolean;
  className?: string;
}

export function FormCheckbox<T extends FieldValues>({
  control, name, label, description, disabled, className,
}: FormCheckboxProps<T>) {
  const { field, fieldState: { error } } = useController({ name, control });

  return (
    <div className={cn('flex items-start space-x-3', className)}>
      <Checkbox
        id={name}
        checked={field.value ?? false}
        onCheckedChange={field.onChange}
        disabled={disabled}
      />
      <div className="space-y-1 leading-none">
        <Label htmlFor={name} className={cn(error && 'text-destructive')}>{label}</Label>
        {description && <p className="text-sm text-muted-foreground">{description}</p>}
        {error && <p className="text-sm text-destructive">{error.message}</p>}
      </div>
    </div>
  );
}
```

### Usando FormFields em um Form completo
```typescript
// components/users/UserForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { FormInput } from '@/components/form/FormInput';
import { FormSelect } from '@/components/form/FormSelect';
import { useCreateUser, useUpdateUser } from '@/hooks/use-users';
import { useNavigate } from '@tanstack/react-router';
import type { User } from '@/types';

const userSchema = z.object({
  name: z.string().min(2, 'Mínimo 2 caracteres'),
  email: z.string().email('Email inválido'),
  role: z.enum(['admin', 'user', 'viewer'], { required_error: 'Selecione um papel' }),
});

type UserFormData = z.infer<typeof userSchema>;

interface UserFormProps {
  user?: User;
  onSuccess?: () => void;
}

export function UserForm({ user, onSuccess }: UserFormProps) {
  const navigate = useNavigate();
  const createUser = useCreateUser();
  const updateUser = useUpdateUser();
  const isEditing = !!user;

  const { control, handleSubmit, formState: { isSubmitting } } = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
    defaultValues: {
      name: user?.name ?? '',
      email: user?.email ?? '',
      role: user?.role ?? undefined,
    },
  });

  const onSubmit = async (data: UserFormData) => {
    if (isEditing) {
      await updateUser.mutateAsync({ id: user.id, data });
    } else {
      await createUser.mutateAsync(data);
    }
    onSuccess?.();
    navigate({ to: '/users' });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6 max-w-md">
      <FormInput control={control} name="name" label="Nome" placeholder="Digite o nome" />
      <FormInput control={control} name="email" label="Email" type="email" placeholder="usuario@email.com" />
      <FormSelect
        control={control}
        name="role"
        label="Papel"
        options={[
          { label: 'Admin', value: 'admin' },
          { label: 'Usuário', value: 'user' },
          { label: 'Visualizador', value: 'viewer' },
        ]}
      />
      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Salvando...' : isEditing ? 'Atualizar' : 'Criar'}
      </Button>
    </form>
  );
}
```

## Regras Específicas

### Formulários
- SEMPRE use `useController` para integrar RHF com componentes shadcn/ui
- NUNCA use `register` diretamente em componentes shadcn/ui (não funciona com Radix)
- NUNCA use `<Form>` do shadcn/ui — use `<form>` nativo + `handleSubmit` do RHF
- Campos reutilizáveis ficam em `src/components/form/`
- Validators Zod ficam em `src/validators/[feature].ts`
- `defaultValues` sempre preenchido (evita uncontrolled → controlled warnings)
- `control` é passado para cada FormField, nunca o form inteiro

### Roteamento
- SEMPRE use TanStack Router (file-based routing)
- NUNCA use React Router
- Rotas autenticadas sob `_authenticated/`
- Use `loader` para pre-fetch com `queryClient.ensureQueryData`
- Use `validateSearch` com Zod para search params tipados
- Navegação sempre tipada via `<Link>` e `useNavigate`
- Exportar `queryOptions()` dos hooks para reutilizar em loaders

### Queries
- SEMPRE use TanStack Query v5 com `queryOptions()` helper
- NUNCA use `useEffect` para fetch
- NUNCA guarde server state em useState
- API functions retornam `data` direto (`.then(r => r.data)` no api layer)
- Mutations invalidam queries relacionadas no `onSuccess`
- Use `gcTime` (v5), nunca `cacheTime` (v4 deprecated)

### Geral
- Nunca use `any` — sempre tipos explícitos
- Sempre trate os 3 estados: loading, error, success
- Sempre use `cn()` de lib/utils para concatenar classes Tailwind
- Sempre importe de `@/` (path alias configurado)
- Componentes shadcn/ui ficam em `components/ui/` e NÃO devem ser editados
- Mobile-first: comece com layout mobile, adicione breakpoints

## Comandos
```bash
# Dev server
npm run dev

# Build
npm run build

# Testes
npm run test

# Testes com coverage  
npm run test -- --coverage

# Lint
npm run lint

# Adicionar componente shadcn/ui
npx shadcn@latest add [component]

# Type check
npx tsc --noEmit

# Gerar route tree (TanStack Router)
npx tsr generate
```