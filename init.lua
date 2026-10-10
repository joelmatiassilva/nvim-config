-- 1. Instalar Lazy.nvim automáticamente (No tocar)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- RECOMENDADO: Desactivar netrw al principio (para nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 2. Configuración de Plugins (TODO en un solo bloque)
require("lazy").setup({
  -- Iconos (Esencial para una buena estética)
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
        strict = true,
      })
    end,
  },

  -- Explorador de archivos
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        hijack_cursor = true,
        sync_root_with_cwd = true,
        view = {
          width = 35,
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "󰈚",
              symlink = "",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
        },
      })
    end,
  },

  -- Markdown visual dentro de Neovim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    config = function()
      require("render-markdown").setup()
    end,
  },

  -- Markdown previsualización en el navegador
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
       vim.g.mkdp_filetypes = { "markdown" }
    end,
  },

  -- Barra de pestañas (estilo VS Code)
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          show_buffer_close_icons = true,
          show_close_icon = true,
          diagnostics = "nvim_lsp",
          offsets = {
            {
              filetype = "NvimTree",
              text = "Explorador",
              text_align = "left",
              separator = true,
            }
          },
        }
      })
    end,
  },

  -- Tema de colores
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
})

-- 3. Ajustes Generales y Atajos
vim.g.mapleader = " " -- Definir espacio como líder ANTES de los atajos
vim.cmd.colorscheme "catppuccin"

-- Atajo para el explorador de archivos (Espacio + e)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Atajo para guardar (Espacio + w)
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- Atajo para previsualizar Markdown en navegador (Espacio + m)
vim.keymap.set("n", "<leader>m", ":MarkdownPreviewToggle<CR>")

-- Atajos para navegar entre pestañas (estilo VS Code)
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<leader>x", ":bdelete<CR>") -- Cerrar pestaña actual (Espacio + x)

-- ATENCIÓN: Atajo para COPIAR TODO el archivo al portapapeles (Espacio + y)
-- Ideal para pasarle código a Claude rápido
vim.keymap.set("n", "<leader>y", ":%y+<CR>")
