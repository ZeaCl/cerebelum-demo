# 🧠 Cerebelum Demo

> **5 minutos para tu primer workflow con Cerebelum.**

## Requisitos

- Elixir 1.18+
- PostgreSQL corriendo en localhost

## Setup

```bash
git clone https://github.com/ZeaCl/cerebelum-demo.git
cd cerebelum-demo
mix setup
mix ecto.create && mix ecto.migrate
```

## Tu primer workflow

Abre `lib/cerebelum_demo/workflows/order_workflow.ex`. Un workflow se define en **3 partes**:

```elixir
defmodule MiWorkflow do
  use Cerebelum.Workflow

  # 1. ESTRUCTURA — qué steps y en qué orden
  workflow do
    timeline do
      validar() |> procesar() |> notificar()
    end
  end

  # 2. STEPS — funciones puras de Elixir
  def validar(context), do: {:ok, context.inputs}
  def procesar(_ctx, datos), do: {:ok, datos}
  def notificar(_ctx, _prev, datos), do: {:ok, datos}
end
```

### Reglas de dependencia entre steps

Cerebelum **inyecta automáticamente** los resultados de steps anteriores según el nombre del parámetro:

```elixir
def step3(context, step1, step2) do
  # step1 = resultado de la función `step1`
  # step2 = resultado de la función `step2`
end
```

## Ejecutar workflows

```bash
# E-commerce
mix run scripts/run_demo.exs order

# CI/CD Pipeline
mix run scripts/run_demo.exs pipeline

# Onboarding (long-running)
mix run scripts/run_demo.exs onboarding
```

## Modo interactivo (IEx)

```bash
iex -S mix
```

```elixir
# Ejecutar workflow
alias CerebelumDemo.Workflows.OrderWorkflow
{:ok, exec} = Cerebelum.execute_workflow(OrderWorkflow, %{
  order: %{id: "ORD-001", items: [%{name: "Widget", price: 100}]}
})

# Ver estado
{:ok, status} = Cerebelum.get_execution_status(exec.id)
status.state        # :completed | :failed | :executing_step
status.results      # %{step1: result, step2: result, ...}
status.timeline_progress  # "3/5"
```

## REST API

Con `http_enabled: true` en config, Cerebelum expone una API REST en `localhost:4001`:

```bash
# Listar workflows registrados
curl http://localhost:4001/api/v1/workflows

# Ver un workflow
curl http://localhost:4001/api/v1/workflows/OrderWorkflow

# Ejecutar workflow
curl -X POST http://localhost:4001/api/v1/executions \
  -H "Content-Type: application/json" \
  -d '{"workflow":"OrderWorkflow","input":{"order":{"id":"ORD-123","items":[]}}}'

# Estado de ejecución
curl http://localhost:4001/api/v1/executions/EXEC_ID

# Health
curl http://localhost:4001/health
```

## Funcionalidades del DSL

### Timeline (secuencial)

```elixir
timeline do
  step1() |> step2() |> step3()
end
```

### Diverge (manejo de errores)

```elixir
diverge from: validate_order() do
  {:error, :timeout} -> back_to(:validate_order)  # reintentar
  {:error, _} -> :failed                            # fallar
end
```

Acciones disponibles: `:failed`, `:continue`, `back_to(:step)`, `skip_to(:step)`

### Branch (condicional)

```elixir
branch after: process_payment(), on: result do
  result.amount > 1000 -> :high_value_path
  true -> :standard_path
end
```

### Ciclos

```elixir
branch after: check_completion() do
  done? -> :continue
  true -> back_to(:send_reminder)  # vuelve atrás
end
```

## Proyecto de ejemplo

```
cerebelum-demo/
├── config/
│   └── config.exs            ← http_enabled: true
├── lib/cerebelum_demo/
│   ├── application.ex        ← arranca el engine
│   └── workflows/            ← tus workflows
│       ├── order_workflow.ex
│       ├── pipeline_workflow.ex
│       └── long_running_workflow.ex
├── scripts/
│   └── run_demo.exs          ← ejecuta desde CLI
└── mix.exs                   ← {:cerebelum, github: "ZeaCl/cerebelum"}
```

## Recursos

| Recurso | Link |
|---|---|
| Engine | [ZeaCl/cerebelum](https://github.com/ZeaCl/cerebelum) |
| Python SDK | [ZeaCl/cerebelum-python](https://github.com/ZeaCl/cerebelum-python) |
| TypeScript SDK | [ZeaCl/cerebelum-js](https://github.com/ZeaCl/cerebelum-js) |
