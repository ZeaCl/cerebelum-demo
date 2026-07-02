# Cerebelum Python Demo

Workflows en Python — sin recompilar, sin reiniciar.

## Setup

```bash
cd examples/python

# Crear virtualenv
python3 -m venv venv
source venv/bin/activate

# Instalar SDK
pip install cerebelum-sdk
# O desde fuente:
# pip install -e ../../../cerebelum-python

pip install -r requirements.txt
```

## Ejecutar

### Modo local (sin engine)

```bash
python 01_local_workflow.py
```

No necesita nada más. El SDK ejecuta todo en Python puro.

### Modo distribuido (con engine)

```bash
# Terminal 1: Arrancar cerebelum
cd ../..  # volver a la raíz del demo
iex -S mix

# Terminal 2: Ejecutar workflow distribuido
cd examples/python
source venv/bin/activate
python 01_local_workflow.py --distributed
```

El workflow se envía por gRPC al engine en `localhost:50051`. El engine lo ejecuta, registra eventos y devuelve resultados.

## Diferencia clave vs Elixir nativo

| | Elixir nativo | Python SDK |
|---|---|---|
| Definir workflow | `.ex` → `mix compile` | `.py` → runtime |
| Agregar un step | Recompilar + reiniciar | Guardar archivo `.py` |
| Hot-reload | ❌ | ✅ |
| Event sourcing | ✅ | ✅ (vía engine) |
| REST API | ✅ | ✅ (mismo engine) |
