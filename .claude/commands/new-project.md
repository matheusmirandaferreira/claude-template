Crie um novo projeto completo com a seguinte estrutura:

## Instruções

1. Pergunte o nome do projeto: $ARGUMENTS (se vazio, pergunte)
2. Crie a estrutura de diretórios:

```
./[nome]/
├── CLAUDE.md (copie e adapte o template raiz)
├── .claude/
│   ├── commands/ (copie os comandos)
│   ├── settings.json
│   └── agents.md
├── [nome]-backend/
│   ├── CLAUDE.md
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py              # FastAPI app com lifespan
│   │   ├── core/
│   │   │   ├── __init__.py
│   │   │   ├── config.py        # Pydantic Settings
│   │   │   ├── database.py      # SQLAlchemy async engine + session
│   │   │   └── security.py      # JWT, hashing, auth utils
│   │   ├── models/
│   │   │   └── __init__.py
│   │   ├── schemas/
│   │   │   └── __init__.py
│   │   ├── services/
│   │   │   └── __init__.py
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   └── health.py        # GET /health
│   │   └── middleware/
│   │       └── __init__.py
│   ├── tests/
│   │   ├── __init__.py
│   │   ├── conftest.py          # Fixtures: db, client, factories
│   │   └── test_health.py
│   ├── alembic/
│   │   ├── env.py
│   │   └── versions/
│   ├── alembic.ini
│   ├── pyproject.toml
│   ├── requirements.txt
│   ├── .env.example
│   ├── .gitignore
│   └── Dockerfile
├── [nome]-frontend/
│   ├── CLAUDE.md
│   ├── src/
│   │   ├── main.tsx             # Entry point com RouterProvider + QueryClientProvider
│   │   ├── vite-env.d.ts
│   │   ├── index.css            # Tailwind directives
│   │   ├── routeTree.gen.ts     # Auto-gerado pelo TanStack Router
│   │   ├── routes/
│   │   │   ├── __root.tsx       # Root layout (providers, shell)
│   │   │   ├── index.tsx        # Home "/"
│   │   │   ├── _authenticated.tsx # Auth guard layout
│   │   │   ├── login.tsx
│   │   │   └── register.tsx
│   │   ├── components/
│   │   │   ├── ui/              # shadcn/ui (instalar componentes)
│   │   │   ├── form/            # FormInput, FormSelect, etc. (useController)
│   │   │   │   ├── FormInput.tsx
│   │   │   │   ├── FormSelect.tsx
│   │   │   │   ├── FormTextarea.tsx
│   │   │   │   └── FormCheckbox.tsx
│   │   │   └── layout/          # Header, Sidebar, PageLayout
│   │   ├── hooks/               # queryOptions + useQuery/useMutation
│   │   ├── lib/
│   │   │   ├── api.ts           # Axios instance com interceptors
│   │   │   ├── query-client.ts  # QueryClient config centralizada
│   │   │   ├── utils.ts         # cn() e helpers
│   │   │   └── constants.ts
│   │   ├── validators/          # Zod schemas por feature
│   │   ├── types/
│   │   │   └── index.ts
│   │   └── __tests__/
│   ├── package.json
│   ├── tsconfig.json
│   ├── tsconfig.node.json
│   ├── vite.config.ts
│   ├── tsr.config.json          # TanStack Router config
│   ├── tailwind.config.ts
│   ├── postcss.config.js
│   ├── components.json          # shadcn/ui config
│   ├── .env.example
│   ├── .gitignore
│   └── Dockerfile
├── docker-compose.yml           # postgres + backend + frontend
└── docs/
    ├── architecture.md
    ├── api-contracts.md
    └── changelog.md
```

3. Todos os arquivos devem ter conteúdo funcional, não apenas placeholders
4. O backend deve startar com `uvicorn app.main:app --reload`
5. O frontend deve startar com `npm run dev`
6. O docker-compose deve subir tudo com `docker compose up`
7. Inicialize git e faça o commit inicial: `feat: initial project scaffold`
