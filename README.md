# nvim-config

Mis archivos de configuración, para llevarlos a cualquier máquina.

| Carpeta | Contenido |
|---|---|
| `nvim/` | Neovim 0.12: `init.lua`, `lazy-lock.json` y `bootstrap.sh`. Ver `nvim/README.md` |
| `tmux/` | `tmux.conf` (copiar o enlazar a `~/.tmux.conf`) |
| `windows-terminal/` | `settings.json` de Windows Terminal, con la fuente JetBrainsMono Nerd Font |
| `docs/` | Plan con el que se armó la configuración de Neovim y las decisiones tomadas |

## Instalar

```bash
gh auth login                                  # el repo es privado
gh repo clone joelmatiassilva/nvim-config ~/projects/nvim-config
~/projects/nvim-config/nvim/bootstrap.sh
```

Para tmux: `ln -s ~/projects/nvim-config/tmux/tmux.conf ~/.tmux.conf`

## Qué no se guarda aquí

Credenciales, claves SSH, tokens ni archivos como `.claude.json`. Esos no deben entrar en un repo.
