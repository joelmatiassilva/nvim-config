# Neovim

- `init.lua`: toda la configuración, en secciones y comentada. Requiere Neovim 0.12.
- `lazy-lock.json`: versión exacta de cada plugin, para que quede igual en todas las máquinas.
- `bootstrap.sh`: prepara una máquina nueva (Neovim, herramientas, fuente, tmux y plugins). Ver el [README principal](../README.md).

Cómo usarlo todo: **[Guía de Neovim](../docs/guia-neovim.md)** y **[Guía de tmux](../docs/guia-tmux.md)**.

## Lo esencial

| Para | Haz |
|---|---|
| Ver qué puedes hacer | Clic derecho, o `Espacio` y esperar |
| Abrir un archivo | `Ctrl+P`, o doble clic en el árbol (`Espacio e`) |
| Buscar un texto en el proyecto | `Espacio f g` |
| Dividir la pantalla | `Espacio v` / `Espacio h`, o los botones arriba a la derecha |
| Moverse entre divisiones y paneles de tmux | `Ctrl+h` `Ctrl+j` `Ctrl+k` `Ctrl+l` |
| Guardar · copiar · pegar · deshacer | `Ctrl+S` · `Ctrl+C` · `Ctrl+V` · `Ctrl+Z` |
| Ir a la definición · renombrar | `F12` · `F2` |
| Ejecutar el archivo | `Espacio r` |

## Ajustes rápidos

La tabla `OPC`, al inicio de `init.lua`:

| Opción | Valores |
|---|---|
| `nerd_font` | `false` si el terminal no tiene una Nerd Font |
| `formato_al_guardar` | `'proyecto'` (solo si el proyecto configura ruff, Prettier o Biome), `'siempre'`, `'nunca'` |
| `hover_mouse` | Documentación al dejar el puntero quieto |
| `arbol_al_abrir` | Mostrar el árbol al arrancar |
| `portapapeles_automatico` | Con `false`, `y`/`d`/`p` dejan de usar el portapapeles del sistema |
| `python_lsp` | `'basedpyright'` o `'ty'` |

## Mantenimiento

- Plugins: `:Lazy update` y luego guardar `lazy-lock.json` en git.
- Servidores de lenguaje: `:Mason`.
- Herramientas de Python: `uv tool upgrade --all`.
- Revisar la instalación: `./bootstrap.sh revisar`.
