# Neovim: configuración portable

Tres archivos:

- `init.lua`: toda la configuración, en secciones y comentada.
- `lazy-lock.json`: versión exacta de cada plugin, para que quede igual en todas las máquinas.
- `bootstrap.sh`: prepara una máquina nueva.

## Instalar en una máquina nueva

```bash
git clone https://github.com/joelmatiassilva/nvim-config.git ~/.config/nvim
~/.config/nvim/bootstrap.sh
```

El script instala Neovim 0.12.6 en `~/.local` (sin sudo), `tree-sitter`, `uv`, `ruff`, `basedpyright`, la fuente JetBrainsMono Nerd Font y todos los plugins. Solo pide contraseña para los paquetes del sistema (compilador, `ripgrep`, `fd`). Se puede ejecutar las veces que haga falta.

- `./bootstrap.sh revisar` muestra qué hay y qué falta, sin cambiar nada.
- Necesita Node.js ya instalado (para los servidores de TypeScript).
- Probado en Ubuntu y WSL. En WSL instala la fuente en Windows y la configura en Windows Terminal; en otros sistemas hay que elegirla a mano en el terminal.

## Mouse

| Gesto | Resultado |
|---|---|
| Clic derecho | Menú según el lugar: editor, árbol de archivos o pestaña |
| Botones arriba a la derecha de cada ventana | Dividir vertical, dividir horizontal, cerrar |
| Doble clic en el árbol | Abrir archivo o carpeta |
| Arrastrar el borde entre divisiones | Cambiar el tamaño |
| Arrastrar la barra de desplazamiento | Moverse por el archivo |
| Clic en la columna de pliegues | Plegar o desplegar |
| Dejar el puntero quieto sobre un símbolo | Documentación y problemas |
| `Ctrl`+clic | Ir a la definición |
| Clic central | Pegar |
| Clic en la barra de estado | Problemas, rama de git, formato al guardar |
| `Shift`+arrastrar | Selección propia del terminal |

## Atajos

`Espacio` es la tecla líder: al pulsarla aparece la lista completa.

| Grupo | Atajos |
|---|---|
| Archivos | `Espacio e` árbol · `Ctrl+P` buscar archivo · `Espacio fg` buscar texto · `Espacio fr` recientes |
| En el árbol | `/` buscar en todas las subcarpetas · `f` filtrar lo visible · `v` / `h` abrir en división |
| Pestañas | `Tab` / `Shift+Tab` cambiar · `Espacio x` cerrar |
| Divisiones | `Espacio v` vertical · `Espacio h` horizontal · `Espacio q` cerrar · `Ctrl+h/j/k/l` moverse |
| Editar | `Ctrl+S` guardar · `Ctrl+C` / `Ctrl+X` / `Ctrl+V` · `Ctrl+Z` / `Ctrl+Y` · `Ctrl+A` todo · `Ctrl+F` buscar |
| Selección | `Shift+flechas` · `Ctrl+Q` en bloque · `Alt+↑/↓` o `Alt+j/k` mover líneas |
| Código | `F12` o `gd` definición · `F2` renombrar · `K` documentación · `Espacio ca` acciones · `Espacio cf` formatear |
| Ejecutar | `Espacio r` archivo actual (`uv run`, `node`) · `Espacio t` terminal · `:Uv sync`, `:Uv add paquete` |
| Opciones | `Espacio of` formato al guardar · `Espacio oh` pistas de tipos · `Espacio ow` ajuste de línea |

En el terminal integrado, `Esc Esc` vuelve al modo normal.

## Ajustes rápidos

Al inicio de `init.lua` está la tabla `OPC`:

| Opción | Valores |
|---|---|
| `nerd_font` | `false` si el terminal no tiene una Nerd Font |
| `formato_al_guardar` | `'proyecto'` (solo si el proyecto configura ruff, Prettier o Biome), `'siempre'`, `'nunca'` |
| `hover_mouse` | Documentación al dejar el puntero quieto |
| `arbol_al_abrir` | Mostrar el árbol al arrancar |
| `python_lsp` | `'basedpyright'` o `'ty'` |

## Mantenimiento

- Plugins: `:Lazy update` y luego guardar el `lazy-lock.json` en git.
- Servidores de lenguaje: `:Mason`.
- Herramientas de Python: `uv tool upgrade --all`.
