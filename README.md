# nvim-config

Mi configuración de Neovim y tmux, para llevarla a cualquier máquina.

## Guías

- **[Guía de Neovim](docs/guia-neovim.md)**: mouse, árbol, buscadores, código, formato, ejecución, Python con uv, TypeScript, git y Markdown.
- **[Guía de tmux](docs/guia-tmux.md)**: sesiones, ventanas, paneles, copiar y pegar, y cómo se combina con Neovim.

Lo mínimo para empezar: en Neovim, **clic derecho** en cualquier parte o **`Espacio`** y esperar; en tmux, **`Ctrl+b` y luego `?`**.

## Instalar en una máquina nueva

```bash
gh auth login                                  # el repo es privado
gh repo clone joelmatiassilva/nvim-config ~/projects/nvim-config
~/projects/nvim-config/nvim/bootstrap.sh
```

El script deja todo listo y se puede ejecutar las veces que haga falta:

- Neovim 0.12.6 en `~/.local`, sin sudo.
- Herramientas: `tree-sitter`, `uv`, `ruff`, `basedpyright` y, en WSL, `win32yank` para el portapapeles.
- La fuente JetBrainsMono Nerd Font. En WSL la instala en Windows y la configura en Windows Terminal.
- Los enlaces `~/.config/nvim` → `nvim/` y `~/.tmux.conf` → `tmux/tmux.conf`, de modo que siempre se edita en el repo.
- Plugins, servidores de lenguaje y parsers, en las versiones de `nvim/lazy-lock.json`.

Solo pide contraseña para los paquetes del sistema (compilador, `ripgrep`, `fd`, `tmux`). Necesita Node.js ya instalado para los servidores de TypeScript.

`nvim/bootstrap.sh revisar` muestra qué hay y qué falta, sin cambiar nada.

Probado en Ubuntu sobre WSL. El diseño contempla Linux nativo y macOS, pero ahí no está probado.

## Contenido

| Carpeta | Qué hay |
|---|---|
| `nvim/` | `init.lua` (toda la configuración en un archivo), `lazy-lock.json` y `bootstrap.sh` |
| `tmux/` | `tmux.conf` |
| `windows-terminal/` | `settings.json` de referencia, con la fuente |
| `docs/` | Las guías y los planes con los que se diseñó todo |

## Qué no se guarda aquí

Credenciales, claves SSH, tokens ni archivos como `.claude.json`.
