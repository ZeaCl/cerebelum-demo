# 🧠 Cerebelum Demo

> **Workflow orchestration — Elixir engine + Python SDK. Sin recompilar.**

## Elige tu modo

## Elige tu modo

### Requisitos

- Elixir 1.18+
- PostgreSQL corriendo
- Python 3.10+ (para Python SDK)

### 🐍 Python SDK (recomendado)

Workflows en Python, sin recompilar, sin reiniciar.

```bash
cd examples/python
python3 -m venv venv && source venv/bin/activate
pip install cerebelum-sdk

# Modo local (sin engine)
python 01_local_workflow.py

# Modo distribuido (con engine corriendo en otra terminal)
python 01_local_workflow.py --distributed
```

➡️ [Guía completa](examples/python/README.md)

### 💧 Elixir nativo

Workflows compilados con máxima performance.

```bash
iex -S mix
# En IEx:
alias CerebelumDemo.Workflows.OrderWorkflow
{:ok, exec} = Cerebelum.execute_workflow(OrderWorkflow, %{order: %{id: "ORD-123", items: [%{name: "Widget", price: 25}]}})
```

- Elixir 1.18+
- PostgreSQL corriendo

## Setup

```bash
git clone https://github.com/ZeaCl/cerebelum-demo.git
cd cerebelum-demo
mix setup
mix ecto.create && mix ecto.migrate
```

## Arrancar el servicio

```bash
iex -S mix
```

Esto levanta el engine de workflows + la API REST en `localhost:4001`.

## Usarlo desde IEx

En la consola de Elixir:

```elixir
# Ejecutar workflow
alias CerebelumDemo.Workflows.OrderWorkflow

{:ok, exec} = Cerebelum.execute_workflow(OrderWorkflow, %{
  order: %{id: "ORD-001", items: [%{name: "Widget", price: 100}]}
})

# Ver estado
{:ok, s} = Cerebelum.get_execution_status(exec.id)
s.state               # :completed | :failed
s.timeline_progress   # "5/5"
s.results             # %{validate_order: {:ok, ...}, ...}

# Ver historial de eventos (audit trail completo)
{:ok, events} = Cerebelum.EventStore.get_events(exec.id)
```

## Usarlo desde REST API

En otra terminal:

```bash
# Health check
curl http://localhost:4001/health

# Ejecutar workflow
curl -X POST http://localhost:4001/api/v1/executions \
  -H "Content-Type: application/json" \
  -d '{
    "workflow": "OrderWorkflow",
    "input": {
      "order": {"id": "ORD-123", "items": [{"name": "Widget", "price": 25}]}
    }
  }'

# Ver eventos de la ejecución (usá el execution_id de la respuesta)
curl http://localhost:4001/api/v1/executions/EL_ID/events
```

## Cómo definir un workflow

Abrí `lib/cerebelum_demo/workflows/order_workflow.ex`. Son 3 partes:

```elixir
defmodule MiWorkflow do
  use Cerebelum.Workflow

  # 1. ESTRUCTURA — qué steps y en qué orden
  workflow do
    timeline do
      validar() |> procesar() |> notificar()
    end
  end

  # 2. STEPS — funciones Elixir
  # Cada step recibe [context | TODOS los resultados anteriores]
  def validar(context) do
    if context.inputs[:ok], do: {:ok, context.inputs}, else: {:error, :invalido}
  end

  def procesar(_context, {:ok, datos}) do
    {:ok, Map.put(datos, :procesado, true)}
  end

  def notificar(_context, {:ok, _prev}, {:ok, datos}) do
    IO.puts("✅ Listo: #{inspect(datos)}")
    {:ok, :notificado}
  end
end
```

**Regla clave:** El step N recibe `[context, result_0, result_1, ..., result_N-1]`. Todos los resultados anteriores, en orden.

## DSL — Funcionalidades

### Timeline

```elixir
timeline do
  step1() |> step2() |> step3()
end
```

### Diverge — manejo de errores

```elixir
diverge from: step1() do
  {:error, :timeout} -> back_to(:step1)   # reintentar
  {:error, _} -> :failed                   # fallar
end
```

### Branch — rutas condicionales

```elixir
branch after: step1(), on: result do
  result[:amount] > 1000 -> skip_to(:otro_step)
  true -> :continue
end
```

### Ciclos (loops)

```elixir
branch after: check(), on: result do
  result[:done] -> :continue
  true -> back_to(:paso_anterior)
end
```

## Los 3 workflows de ejemplo

| Workflow | Descripción | Features |
|---|---|---|
| `OrderWorkflow` | E-commerce completo | timeline, diverge, branch |
| `PipelineWorkflow` | CI/CD pipeline | diverge, branch, multi-step |
| `LongRunningWorkflow` | Onboarding multi-día | sleep, cycles, resurrection |

## Monitoreo y auditoría

Cada ejecución registra eventos inmutables en PostgreSQL:

```elixir
{:ok, events} = Cerebelum.EventStore.get_events(exec_id)

# 🚀 ExecutionStartedEvent  → inputs, versión del workflow
# ✅ StepExecutedEvent       → step, resultado, duración
# 🔀 DivergeTakenEvent       → error matcheado, acción tomada
# 🔁 BranchTakenEvent        → condición evaluada, ruta tomada
# 🏁 ExecutionCompletedEvent → resultados finales, tiempo total
```

## Proyecto de ejemplo

```
cerebelum-demo/
├── config/config.exs           ← http_enabled: true
├── lib/cerebelum_demo/
│   ├── application.ex          ← arranca engine + API
│   └── workflows/              ← tus workflows
│       ├── order_workflow.ex
│       ├── pipeline_workflow.ex
│       └── long_running_workflow.ex
├── scripts/
│   ├── run_demo.exs            ← ejecución rápida CLI
│   └── test_history.exs        ← demo de event sourcing
└── mix.exs
```

## Recursos

| Recurso | Link |
|---|---|
| Engine | [ZeaCl/cerebelum](https://github.com/ZeaCl/cerebelum) |
| Python SDK | [ZeaCl/cerebelum-python](https://github.com/ZeaCl/cerebelum-python) |
| TypeScript SDK | [ZeaCl/cerebelum-js](https://github.com/ZeaCl/cerebelum-js) |
