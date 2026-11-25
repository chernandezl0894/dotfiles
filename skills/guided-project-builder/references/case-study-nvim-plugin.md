# Caso de estudio: `wordcount.nvim`

Este es el recorrido real que originó la skill. Sirve como ejemplo de cómo se ve un proyecto guiado de principio a fin.

## Contexto

- Entorno: Neovim 0.10.4, `lazy.nvim`, dotfiles con plugins en `nvim/lua/plugins/`.
- Idea: primer plugin de Neovim, sencillo pero completo.
- Decisiones tomadas con el usuario:
  - Proyecto: `wordcount.nvim` (palabras, caracteres, líneas y tiempo de lectura).
  - UI: función para statusline + comando `:WordCount` con ventana flotante.
  - Ubicación: repo aparte en `~/projects/wordcount.nvim`, integrado con `dev = true`.

## Mapa de pasos

| Paso | Construimos | Aprendes |
|---|---|---|
| 1 | Esqueleto + módulo mínimo | `runtimepath`, `require()`, `lua/<plugin>/init.lua` |
| 2 | `count.lua` (lógica pura) | módulos Lua, UTF-8, tests sin UI |
| 3 | `config.lua` + `setup()` + `statusline()` | opciones de usuario, validación, cache por `changedtick` |
| 4 | `ui.lua` + `plugin/wordcount.lua` | comandos, buffers scratch, ventanas flotantes, keymaps locales |
| 5 | Integración en dotfiles | `dev = true`, `opts`, componente de lualine |
| 6 | Tests + `stylua.toml` | runner headless, código de salida, formato |

## Estructura final

```text
wordcount.nvim/
├── lua/wordcount/
│   ├── init.lua      -- API: setup, enabled, count, statusline
│   ├── config.lua    -- defaults + merge + validación
│   ├── count.lua     -- lógica pura, sin API de Neovim
│   └── ui.lua        -- float y keymaps locales
├── plugin/wordcount.lua
├── tests/run.lua
├── doc/wordcount.txt
├── stylua.toml
├── .gitignore
└── README.md
```

## Decisiones didácticas que funcionaron

1. **Núcleo puro primero.** `count.lua` no toca Neovim, así que se prueba con `assert` antes de existir UI.
2. **Un paso, una API nueva.** Paso 1: `runtimepath`. Paso 4: `nvim_open_win`. Nunca dos conceptos grandes juntos.
3. **Salidas exactas.** Cada prueba se ejecutó antes de enviarla, incluida la salida esperada.
4. **Checklist "Listo cuando…"** al final de cada paso, con criterios observables.
5. **Verificación en disco** tras cada "listo": leer archivos + ejecutar la suite. Las diferencias de tabs/espacios se aceptaron como equivalentes.
6. **Prototipo en `/tmp/opencode`** antes de dar código no trivial (cache, float, tests).
7. **Integración al final**, cuando el plugin ya funcionaba solo.

## Trampas concretas que aparecieron

- `vim.tbl_deep_extend` fusiona listas por índice: `filetypes` había que reemplazarlo a mano.
- `#texto` cuenta bytes, no caracteres: para "canción" hay que contar puntos de código UTF-8.
- Cachear por `b:changedtick` evita recorrer el buffer en cada redraw de lualine.
- `modifiable = false` debe ir **después** de `nvim_buf_set_lines`.
- En un float, `bufhidden = "wipe"` y un `WinLeave` evitan ventanas huérfanas.
- Los keymaps del float usan `buffer = buf` para no secuestrar `q` globalmente.
- Un test que nunca puede fallar no sirve: se provocó un `FAIL` y se comprobó `exit=1`.
- El editor del usuario guardó tabs; no era un error, solo formato. `stylua` lo normalizó después.

## Lecciones para la skill

- El usuario avanza mejor con pasos de 20-30 minutos y una prueba visible por paso.
- Detenerse tras cada paso y verificar evita construir sobre una base rota.
- Las salidas exactas generan confianza; las aproximadas generan dudas.
- Al integrar en la configuración del usuario, mostrar el diff antes de commitear.
- Los tests sin dependencias (script + `exit code`) son suficientes para un primer proyecto.
