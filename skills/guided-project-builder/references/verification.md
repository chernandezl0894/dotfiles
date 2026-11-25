# Verificación

## Principio

Verificar = **leer** + **ejecutar** + **comparar**. Nunca avanzar porque el usuario dijo "creo que funciona".

## Checklist universal

1. El archivo existe en la ruta indicada.
2. El contenido es el esperado (o equivalente: formato distinto no es error).
3. El comando de prueba se ejecuta sin errores.
4. La salida coincide con la prometida.
5. No hay errores nuevos en el resto del proyecto (build/tests generales).

## Comandos por ecosistema

### Node / TypeScript

```bash
node --version
npm test
npx tsc --noEmit
npm run lint
```

### Python

```bash
python --version
python -m pytest -q
python -m pytest -q tests/test_x.py::test_caso
ruff check .
python -c "import paquete"
```

### Go

```bash
go version
go build ./...
go test ./...
go vet ./...
```

### Rust

```bash
cargo test
cargo clippy -- -D warnings
cargo fmt --check
```

### Lua / Neovim

```bash
nvim --headless -u NONE -l tests/run.lua
echo "exit=$?"
```

Cargar un plugin local sin instalarlo:

```bash
nvim --headless -u NONE \
  --cmd "set runtimepath+=$HOME/projects/mi-plugin" \
  -c 'lua print(require("mi-plugin").version())' \
  -c "qa!"
```

### Shell

```bash
bash -n script.sh
shellcheck script.sh
```

## Verificar código escrito a mano

- Compara **semántica**, no espacios: tabs vs spaces, comillas simples vs dobles y saltos de línea no son errores.
- Si el usuario reformateó, dilo explícitamente y sigue.
- Si el usuario escribió de menos, señala la línea o bloque que falta.

## Cómo reportar

Usa una tabla y un veredicto claro:

| Comprobación | Resultado |
|---|---|
| `count.lua` existe | ✅ |
| `nvim ... -l tests/run.lua` | ✅ 15 tests OK |
| Salida de `statusline()` | ❌ esperado `3 words`, obtenido `1 word` |

- **Todo ✅**: confirma en 1-2 líneas y pasa al siguiente paso.
- **Algo ❌**: no avances. Di qué falla, dónde, por qué y el parche mínimo. Espera de nuevo.

## Diagnóstico de fallos

1. Lee el error literal completo; no lo parafrasees.
2. Reproduce en el caso más pequeño posible.
3. Aísla: ¿entrada, lógica o salida?
4. Corrige una cosa a la vez.
5. Vuelve a ejecutar el mismo comando de la prueba.

## Errores comunes de verificación

- Probar en el entorno del agente y no en el del usuario.
- Comandos interactivos en CI: usa variantes headless.
- Tests que dependen de hora, red o estado global.
- Salidas con colores o ANSI que rompen la comparación.
- Asumir que un `require`/`import` funciona sin comprobar la ruta.
