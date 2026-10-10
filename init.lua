-- ════════════════════════════════════════════════════════════════════════════
--  Neovim — toda la configuración en este archivo
-- ════════════════════════════════════════════════════════════════════════════
--
--  MÁQUINA NUEVA
--    git clone <este-repo> ~/.config/nvim && ~/.config/nvim/bootstrap.sh
--    (instala Neovim 0.12, compilador, tree-sitter, uv, la fuente y los plugins)
--
--  LO ESENCIAL   (Espacio = tecla líder; al pulsarla aparece la ayuda de atajos)
--    Mouse     clic derecho = menú · doble clic en el árbol = abrir · arrastra bordes y barras
--    Archivos  Espacio e árbol · Ctrl+P buscar archivo · Espacio fg buscar texto
--    Dividir   Espacio v vertical · Espacio h horizontal · Espacio q cerrar · Ctrl+h/j/k/l moverse
--    Editar    Ctrl+S guardar · Ctrl+C/X/V copiar/cortar/pegar · Ctrl+Z/Y deshacer/rehacer
--    Código    F12 definición · F2 renombrar · K documentación · Espacio cf formatear
--    Ejecutar  Espacio r archivo actual (uv run / node) · Espacio t terminal
--    Bloque    Ctrl+Q selección en bloque (Ctrl+V pega)

-- ════════════════════════════════════════════════════════════════════════════
--  1. OPCIONES RÁPIDAS — lo que más se suele querer cambiar
-- ════════════════════════════════════════════════════════════════════════════
local OPC = {
  nerd_font = true,                -- false si el terminal no tiene una Nerd Font (texto en vez de iconos)
  formato_al_guardar = 'proyecto', -- 'proyecto' (solo si el proyecto lo configura) | 'siempre' | 'nunca'
  hover_mouse = true,              -- documentación flotante al dejar el puntero quieto
  arbol_al_abrir = true,           -- muestra el árbol de archivos al arrancar
  python_lsp = 'basedpyright',     -- 'basedpyright' | 'ty'
}

-- ════════════════════════════════════════════════════════════════════════════
--  2. BÁSICO — sin plugins; funciona también en versiones viejas de Neovim
-- ════════════════════════════════════════════════════════════════════════════
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local o = vim.o
o.mouse = 'a'                -- mouse en todos los modos (mousemodel queda en su valor por defecto)
o.mousemoveevent = true      -- avisa cuando el puntero se mueve (hover y resaltados)
o.number = true
o.signcolumn = 'yes'
o.cursorline = true
o.termguicolors = true
o.splitright = true          -- las divisiones verticales se abren a la derecha…
o.splitbelow = true          -- …y las horizontales, abajo
o.ignorecase = true
o.smartcase = true
o.undofile = true            -- deshacer sobrevive al cerrar el archivo
o.confirm = true             -- pregunta en vez de fallar si hay cambios sin guardar
o.autoread = true            -- recarga archivos que cambió otro programa
o.scrolloff = 5
o.sidescrolloff = 8
o.wrap = false
o.linebreak = true
o.breakindent = true
o.expandtab = true
o.shiftwidth = 2
o.softtabstop = 2
o.updatetime = 300
o.timeoutlen = 500
o.keymodel = 'startsel'      -- Shift+flechas inicia una selección
o.whichwrap = 'b,s,<,>,[,]'  -- las flechas pasan de una línea a otra
o.title = true
o.list = true
o.listchars = 'tab:» ,trail:·,nbsp:␣'
o.foldlevel = 99
o.foldlevelstart = 99

-- Portapapeles del sistema ----------------------------------------------------
-- En WSL se usa win32yank (rápido y respeta acentos). Si no está, se copia con
-- OSC 52 (lo entiende el terminal) y se pega con PowerShell forzando UTF-8.
local es_wsl = vim.fn.has('wsl') == 1
if es_wsl and vim.fn.executable('win32yank.exe') == 1 then
  local copiar = { 'win32yank.exe', '-i', '--crlf' }
  local pegar = { 'win32yank.exe', '-o', '--lf' }
  vim.g.clipboard = {
    name = 'win32yank',
    copy = { ['+'] = copiar, ['*'] = copiar },
    paste = { ['+'] = pegar, ['*'] = pegar },
    cache_enabled = 0,
  }
elseif es_wsl or vim.env.SSH_TTY then
  local ok, osc52 = pcall(require, 'vim.ui.clipboard.osc52')
  if ok then
    local pegar
    if es_wsl then
      pegar = {
        'powershell.exe', '-NoLogo', '-NoProfile', '-Command',
        '[Console]::OutputEncoding=[System.Text.Encoding]::UTF8; '
          .. '[Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace("`r", ""))',
      }
    else
      -- Por SSH el terminal no deja leer su portapapeles: p pega lo último copiado
      -- aquí; para traer algo de fuera se usa el pegado del propio terminal.
      pegar = function()
        return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
      end
    end
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
      paste = { ['+'] = pegar, ['*'] = pegar },
    }
  end
end
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus' -- y/p usan el portapapeles del sistema
end)

-- Atajos ------------------------------------------------------------------------
local map = vim.keymap.set

local function guardar()
  if vim.bo.buftype ~= '' then return end
  if vim.api.nvim_buf_get_name(0) == '' then
    local nombre = vim.fn.input('Guardar como: ', '', 'file')
    if nombre == '' then return end
    vim.cmd.saveas(vim.fn.fnameescape(nombre))
    return
  end
  local ok, err = pcall(vim.cmd.update)
  if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
end

-- Los de siempre
map('n', '<leader>w', guardar, { desc = 'Guardar' })
map('n', '<leader>y', '<Cmd>%yank +<CR>', { desc = 'Copiar todo el archivo' })
map('n', '<leader>x', '<Cmd>bdelete<CR>', { desc = 'Cerrar pestaña' })
map('n', '<Tab>', '<Cmd>bnext<CR>', { desc = 'Pestaña siguiente' })
map('n', '<S-Tab>', '<Cmd>bprevious<CR>', { desc = 'Pestaña anterior' })

-- Divisiones
map('n', '<leader>v', '<Cmd>vsplit<CR>', { desc = 'Dividir vertical (a la derecha)' })
map('n', '<leader>h', '<Cmd>split<CR>', { desc = 'Dividir horizontal (abajo)' })
map('n', '<leader>q', '<Cmd>silent! close<CR>', { desc = 'Cerrar división' })
map('n', '<C-h>', '<C-w>h', { desc = 'Ir a la división izquierda' })
map('n', '<C-j>', '<C-w>j', { desc = 'Ir a la división de abajo' })
map('n', '<C-k>', '<C-w>k', { desc = 'Ir a la división de arriba' })
map('n', '<C-l>', '<C-w>l', { desc = 'Ir a la división derecha' })

-- Estilo VS Code
map({ 'n', 'i', 'x' }, '<C-s>', guardar, { desc = 'Guardar' })
map('x', '<C-c>', '"+y', { desc = 'Copiar' })
map('x', '<C-x>', '"+d', { desc = 'Cortar' })
-- Windows Terminal ya pega con Ctrl+V por su cuenta; esto cubre los demás terminales.
map('n', '<C-v>', '"+gP', { desc = 'Pegar' })
map('x', '<C-v>', '"+P', { desc = 'Pegar' })
map('i', '<C-v>', '<C-r><C-o>+', { desc = 'Pegar' })
map('c', '<C-v>', '<C-r>+', { desc = 'Pegar' })
map('n', '<C-z>', 'u', { desc = 'Deshacer' })
map('i', '<C-z>', '<C-o>u', { desc = 'Deshacer' })
map('n', '<C-y>', '<C-r>', { desc = 'Rehacer' })
map('n', '<C-a>', 'ggVG', { desc = 'Seleccionar todo' })
map('n', '<C-f>', '/', { desc = 'Buscar en el archivo' })

-- Mover líneas (con flechas o con j/k, por si el terminal se queda con Alt+flechas)
for _, t in ipairs({ { '<A-Down>', '<A-Up>' }, { '<A-j>', '<A-k>' } }) do
  map('n', t[1], '<Cmd>move .+1<CR>==', { desc = 'Mover línea abajo' })
  map('n', t[2], '<Cmd>move .-2<CR>==', { desc = 'Mover línea arriba' })
  map('i', t[1], '<Esc><Cmd>move .+1<CR>==gi', { desc = 'Mover línea abajo' })
  map('i', t[2], '<Esc><Cmd>move .-2<CR>==gi', { desc = 'Mover línea arriba' })
  map('x', t[1], ":move '>+1<CR>gv=gv", { desc = 'Mover selección abajo', silent = true })
  map('x', t[2], ":move '<-2<CR>gv=gv", { desc = 'Mover selección arriba', silent = true })
end

map('x', '<Tab>', '>gv', { desc = 'Indentar selección' })
map('x', '<S-Tab>', '<gv', { desc = 'Quitar indentación' })
map('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Quitar resaltado de búsqueda' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Salir del modo terminal' })

-- ════════════════════════════════════════════════════════════════════════════
--  3. A PARTIR DE AQUÍ HACE FALTA NEOVIM 0.12
-- ════════════════════════════════════════════════════════════════════════════
if vim.fn.has('nvim-0.12') == 0 then
  local v = vim.version()
  vim.schedule(function()
    vim.notify(
      ('Esta configuración necesita Neovim 0.12 o superior (tienes %d.%d.%d).\n'):format(v.major, v.minor, v.patch)
        .. 'Solo se cargó lo básico. Para actualizar: '
        .. vim.fn.stdpath('config')
        .. '/bootstrap.sh nvim',
      vim.log.levels.WARN
    )
  end)
  return
end

o.showmode = false           -- el modo ya lo muestra la barra de estado
o.smoothscroll = true
o.pumborder = 'rounded'      -- borde del menú de clic derecho
o.foldcolumn = '1'           -- columna de pliegues: clic para plegar o desplegar
o.foldtext = ''              -- la línea plegada conserva sus colores

local ic = vim.fn.nr2char
local ICO = OPC.nerd_font
    and {
      error = ic(0xF057) .. ' ',
      aviso = ic(0xF071) .. ' ',
      info = ic(0xF05A) .. ' ',
      pista = ic(0xF0335) .. ' ',
      dividir_v = ic(0xEB56),
      dividir_h = ic(0xEB57),
      cerrar = ic(0xEA76),
      formato = ic(0xF0D0) .. ' ',
      plegado = ic(0xF460),
      desplegado = ic(0xF47C),
    }
  or {
    error = 'E ',
    aviso = 'A ',
    info = 'I ',
    pista = 'P ',
    dividir_v = '[|]',
    dividir_h = '[-]',
    cerrar = '[x]',
    formato = '',
    plegado = '+',
    desplegado = '-',
  }
o.fillchars = ('foldopen:%s,foldclose:%s,fold: ,foldsep: ,foldinner: ,eob: '):format(ICO.desplegado, ICO.plegado)

local grupo = vim.api.nvim_create_augroup('config', { clear = true })
local function autocmd(evento, opts)
  opts.group = grupo
  return vim.api.nvim_create_autocmd(evento, opts)
end

autocmd('TextYankPost', {
  desc = 'Destello sobre lo copiado',
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'TermLeave' }, {
  desc = 'Recarga archivos modificados por otro programa',
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == '' then vim.cmd.checktime() end
  end,
})

autocmd('BufReadPost', {
  desc = 'Vuelve a la última posición del cursor',
  callback = function(ev)
    local marca = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if marca[1] > 0 and marca[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, marca)
    end
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  -- Solo la primera línea del mensaje: ruff añade ayuda en líneas siguientes.
  virtual_text = { spacing = 2, prefix = '●', format = function(d) return (d.message:match('^[^\n]*')) end },
  float = { border = 'rounded', source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ICO.error,
      [vim.diagnostic.severity.WARN] = ICO.aviso,
      [vim.diagnostic.severity.INFO] = ICO.info,
      [vim.diagnostic.severity.HINT] = ICO.pista,
    },
  },
})

-- ── Utilidades compartidas ────────────────────────────────────────────────────
local function existe(ruta) return ruta ~= nil and vim.uv.fs_stat(ruta) ~= nil end

local function leer(ruta)
  local ok, lineas = pcall(vim.fn.readfile, ruta)
  return ok and table.concat(lineas, '\n') or ''
end

local function avisar(texto, nivel)
  vim.notify(texto, nivel or vim.log.levels.INFO, { title = 'Neovim' })
end

-- Deja el foco en una ventana de edición (no en el árbol ni en un terminal).
local function ir_a_ventana_de_edicion()
  if vim.bo.buftype == '' then return end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_win_get_config(win).relative == '' and vim.bo[buf].buftype == '' then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

local function cerrar_buffer(buf) Snacks.bufdelete(buf) end

-- ── Formato ───────────────────────────────────────────────────────────────────
-- 'proyecto': al guardar solo se formatea si el proyecto declara su formateador.
vim.g.formato_al_guardar = OPC.formato_al_guardar

local WEB = {
  javascript = true, javascriptreact = true, typescript = true, typescriptreact = true,
  json = true, jsonc = true, css = true, scss = true, html = true, yaml = true, markdown = true,
}
local CONFIG_PRETTIER = {
  '.prettierrc', '.prettierrc.json', '.prettierrc.json5', '.prettierrc.yml', '.prettierrc.yaml',
  '.prettierrc.toml', '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.mjs', '.prettierrc.ts',
  'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs', 'prettier.config.ts',
}
local CONFIG_BIOME = { 'biome.json', 'biome.jsonc' }

local function buscar_arriba(nombres, buf)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  return vim.fs.find(nombres, { path = dir, upward = true })[1]
end

local function usa_biome(buf) return buscar_arriba(CONFIG_BIOME, buf) ~= nil end

local function proyecto_formatea(buf)
  if vim.b[buf].proyecto_formatea ~= nil then return vim.b[buf].proyecto_formatea end
  local ft, si = vim.bo[buf].filetype, false
  if ft == 'python' then
    local pyproject = buscar_arriba('pyproject.toml', buf)
    si = buscar_arriba({ 'ruff.toml', '.ruff.toml' }, buf) ~= nil
      or (pyproject ~= nil and leer(pyproject):find('[tool.ruff', 1, true) ~= nil)
  elseif WEB[ft] then
    local paquete = buscar_arriba('package.json', buf)
    si = buscar_arriba(CONFIG_PRETTIER, buf) ~= nil
      or usa_biome(buf)
      or (paquete ~= nil and leer(paquete):find('"prettier"', 1, true) ~= nil)
  end
  vim.b[buf].proyecto_formatea = si
  return si
end

autocmd('BufWritePost', {
  desc = 'Si cambia la configuración del proyecto, se vuelve a evaluar si formatea',
  pattern = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', 'package.json', '.prettierrc*', 'prettier.config.*', 'biome.json*' },
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.b[buf].proyecto_formatea = nil
    end
  end,
})

local function formato_activo(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if vim.bo[buf].buftype ~= '' then return false end
  local modo = vim.g.formato_al_guardar
  if modo == 'siempre' then return true end
  if modo == 'nunca' then return false end
  return proyecto_formatea(buf)
end

local function formatear()
  require('conform').format({ async = true, lsp_format = 'fallback' }, function(err)
    if err then avisar('No se pudo formatear: ' .. tostring(err), vim.log.levels.WARN) end
  end)
end

local function alternar_formato()
  local siguiente = { proyecto = 'siempre', siempre = 'nunca', nunca = 'proyecto' }
  local texto = {
    proyecto = 'solo si el proyecto lo configura',
    siempre = 'siempre',
    nunca = 'nunca (solo manual)',
  }
  vim.g.formato_al_guardar = siguiente[vim.g.formato_al_guardar] or 'proyecto'
  avisar('Formato al guardar: ' .. texto[vim.g.formato_al_guardar])
end

-- ── Ejecutar y uv ─────────────────────────────────────────────────────────────
local function raiz(marcadores) return vim.fs.root(0, marcadores) or vim.fn.getcwd() end

-- Panel inferior para ejecutar comandos. Cada ejecución reemplaza a la anterior
-- y la salida queda a la vista al terminar.
local panel_de_ejecucion
local function en_terminal(cmd, cwd)
  if panel_de_ejecucion and panel_de_ejecucion:valid() then panel_de_ejecucion:close() end
  ir_a_ventana_de_edicion()
  panel_de_ejecucion = Snacks.terminal.open(cmd, { cwd = cwd, auto_close = false, win = { position = 'bottom', height = 0.3 } })
end

local function ejecutar_archivo()
  ir_a_ventana_de_edicion()
  local archivo, ft = vim.api.nvim_buf_get_name(0), vim.bo.filetype
  if archivo == '' or vim.bo.buftype ~= '' then return avisar('Aquí no hay un archivo que ejecutar', vim.log.levels.WARN) end
  if vim.bo.modified then vim.cmd.update() end
  if ft == 'python' then
    local cmd = vim.fn.executable('uv') == 1 and { 'uv', 'run', archivo } or { 'python3', archivo }
    en_terminal(cmd, raiz({ 'pyproject.toml', 'uv.lock', '.git' }))
  elseif ft == 'typescript' or ft == 'typescriptreact' then
    local dir = raiz({ 'package.json', '.git' })
    local tsx = dir .. '/node_modules/.bin/tsx'
    en_terminal(existe(tsx) and { tsx, archivo } or { 'node', archivo }, dir)
  elseif ft == 'javascript' or ft == 'javascriptreact' then
    en_terminal({ 'node', archivo }, raiz({ 'package.json', '.git' }))
  elseif ft == 'sh' or ft == 'bash' then
    en_terminal({ 'bash', archivo }, vim.fs.dirname(archivo))
  else
    avisar(('No sé cómo ejecutar archivos de tipo "%s"'):format(ft), vim.log.levels.WARN)
  end
end

-- ── Árbol ─────────────────────────────────────────────────────────────────────
local function buscar_en_arbol()
  local api = require('nvim-tree.api')
  Snacks.picker.files({ cwd = api.tree.get_nodes().absolute_path, title = 'Buscar en el árbol' })
end

local function carpeta_bajo_cursor()
  local nodo = require('nvim-tree.api').tree.get_node_under_cursor()
  if not nodo or not nodo.absolute_path then return vim.fn.getcwd() end
  return nodo.type == 'directory' and nodo.absolute_path or vim.fs.dirname(nodo.absolute_path)
end

-- ── Menús de clic derecho ─────────────────────────────────────────────────────
-- Se usa el menú nativo de Neovim ("PopUp"). Se reconstruye en cada clic según
-- dónde se hizo: el clic derecho primero mueve el cursor a ese punto.
local acciones_menu, separadores = {}, 0

function _G.MenuAccion(n)
  local accion = acciones_menu[n]
  if accion then accion() end
end

local function limpiar_menu(menu)
  pcall(vim.cmd, 'aunmenu ' .. menu)
  acciones_menu, separadores = {}, 0
end

-- modos: letras de n, v, i, a (todos). accion: función Lua o teclas.
-- remap = true cuando las teclas son a su vez un atajo (p. ej. gcc).
local function entrada(menu, modos, etiqueta, accion, remap)
  local teclas = accion
  if type(accion) == 'function' then
    acciones_menu[#acciones_menu + 1] = accion
    teclas = ('<Cmd>lua MenuAccion(%d)<CR>'):format(#acciones_menu)
  end
  local nombre = etiqueta:gsub('([ .\\|])', '\\%1')
  for modo in modos:gmatch('.') do
    vim.cmd(('%s%smenu %s.%s %s'):format(modo, remap and '' or 'nore', menu, nombre, teclas))
  end
end

local function separador(menu)
  separadores = separadores + 1
  vim.cmd(('anoremenu %s.-%d- <Nop>'):format(menu, separadores))
end

local function entradas_portapapeles(menu)
  entrada(menu, 'v', 'Cortar', '"+x')
  entrada(menu, 'v', 'Copiar', '"+y')
  entrada(menu, 'n', 'Copiar línea', '"+yy')
  entrada(menu, 'n', 'Pegar', '"+gP')
  entrada(menu, 'v', 'Pegar', '"+P')
  entrada(menu, 'i', 'Pegar', '<C-r><C-o>+')
  entrada(menu, 'n', 'Seleccionar todo', 'ggVG')
end

local function entradas_ventana(menu)
  entrada(menu, 'n', 'Dividir a la derecha', '<Cmd>vsplit<CR>')
  entrada(menu, 'n', 'Dividir abajo', '<Cmd>split<CR>')
  entrada(menu, 'n', 'Cerrar división', '<Cmd>silent! close<CR>')
end

local function menu_editor(menu)
  local buf = vim.api.nvim_get_current_buf()
  local function lsp(metodo) return #vim.lsp.get_clients({ bufnr = buf, method = metodo }) > 0 end
  if lsp('textDocument/definition') then entrada(menu, 'n', 'Ir a definición', function() Snacks.picker.lsp_definitions() end) end
  if lsp('textDocument/references') then entrada(menu, 'n', 'Ver referencias', function() Snacks.picker.lsp_references() end) end
  if lsp('textDocument/rename') then entrada(menu, 'n', 'Renombrar símbolo', vim.lsp.buf.rename) end
  if lsp('textDocument/codeAction') then entrada(menu, 'nv', 'Acciones de código', vim.lsp.buf.code_action) end
  if lsp('textDocument/hover') then entrada(menu, 'n', 'Ver documentación', function() vim.lsp.buf.hover({ border = 'rounded' }) end) end
  if #vim.diagnostic.get(buf, { lnum = vim.fn.line('.') - 1 }) > 0 then
    entrada(menu, 'n', 'Ver problema de esta línea', vim.diagnostic.open_float)
  end
  entrada(menu, 'n', 'Formatear documento', formatear)
  separador(menu)
  entradas_portapapeles(menu)
  separador(menu)
  entradas_ventana(menu)
  separador(menu)
  entrada(menu, 'n', 'Buscar archivo…', function() Snacks.picker.files() end)
  entrada(menu, 'n', 'Buscar texto…', function() Snacks.picker.grep() end)
  separador(menu)
  entrada(menu, 'n', 'Comentar línea', 'gcc', true)
  entrada(menu, 'v', 'Comentar selección', 'gc', true)
  entrada(menu, 'n', 'Ejecutar archivo', ejecutar_archivo)
end

local function menu_arbol(menu)
  local api = require('nvim-tree.api')
  entrada(menu, 'n', 'Abrir', api.node.open.edit)
  entrada(menu, 'n', 'Abrir en división vertical', api.node.open.vertical)
  entrada(menu, 'n', 'Abrir en división horizontal', api.node.open.horizontal)
  separador(menu)
  entrada(menu, 'n', 'Nuevo archivo o carpeta…', api.fs.create)
  entrada(menu, 'n', 'Renombrar…', api.fs.rename)
  entrada(menu, 'n', 'Eliminar', api.fs.remove)
  entrada(menu, 'n', 'Copiar', api.fs.copy.node)
  entrada(menu, 'n', 'Cortar', api.fs.cut)
  entrada(menu, 'n', 'Pegar', api.fs.paste)
  entrada(menu, 'n', 'Copiar ruta', api.fs.copy.absolute_path)
  separador(menu)
  entrada(menu, 'n', 'Buscar en el árbol…', buscar_en_arbol)
  entrada(menu, 'n', 'Filtrar lo visible…', api.live_filter.start)
  entrada(menu, 'n', 'Buscar texto en esta carpeta…', function() Snacks.picker.grep({ dirs = { carpeta_bajo_cursor() } }) end)
  separador(menu)
  entrada(menu, 'n', 'Contraer todo', api.tree.collapse_all)
  entrada(menu, 'n', 'Actualizar', api.tree.reload)
end

local function menu_terminal(menu)
  entrada(menu, 'a', 'Pegar', function() vim.api.nvim_paste(vim.fn.getreg('+'), true, -1) end)
  entrada(menu, 'a', 'Cerrar terminal', function() cerrar_buffer(0) end)
end

local function menu_otros(menu)
  entrada(menu, 'v', 'Copiar', '"+y')
  entrada(menu, 'n', 'Cerrar ventana', '<Cmd>silent! close<CR>')
end

local function menu_pestana(buf)
  local menu = 'Pestana'
  limpiar_menu(menu)
  entrada(menu, 'a', 'Cerrar', function() cerrar_buffer(buf) end)
  entrada(menu, 'a', 'Cerrar las demás', function()
    for _, otro in ipairs(vim.api.nvim_list_bufs()) do
      if otro ~= buf and vim.bo[otro].buflisted then cerrar_buffer(otro) end
    end
  end)
  separador(menu)
  entrada(menu, 'a', 'Abrir en división vertical', function()
    ir_a_ventana_de_edicion()
    vim.cmd('vertical sbuffer ' .. buf)
  end)
  entrada(menu, 'a', 'Abrir en división horizontal', function()
    ir_a_ventana_de_edicion()
    vim.cmd('sbuffer ' .. buf)
  end)
  entrada(menu, 'a', 'Copiar ruta', function()
    vim.fn.setreg('+', vim.api.nvim_buf_get_name(buf))
    avisar('Ruta copiada')
  end)
  vim.schedule(function() vim.cmd('popup! ' .. menu) end)
end

pcall(vim.api.nvim_clear_autocmds, { group = 'nvim.popupmenu' }) -- quita el menú por defecto (en inglés)
autocmd('MenuPopup', {
  desc = 'Menú de clic derecho según el tipo de ventana',
  callback = function()
    limpiar_menu('PopUp')
    if vim.bo.filetype == 'NvimTree' then
      menu_arbol('PopUp')
    elseif vim.bo.buftype == 'terminal' then
      menu_terminal('PopUp')
    elseif vim.bo.buftype == '' then
      menu_editor('PopUp')
    else
      menu_otros('PopUp')
    end
  end,
})

-- ── Barra de cada ventana: ruta del archivo y botones clicables ───────────────
local function ventana_clicada()
  local win = vim.fn.getmousepos().winid
  if win ~= 0 and vim.api.nvim_win_is_valid(win) then vim.api.nvim_set_current_win(win) end
end
function _G.ClicDividirV()
  ventana_clicada()
  vim.cmd.vsplit()
end
function _G.ClicDividirH()
  ventana_clicada()
  vim.cmd.split()
end
function _G.ClicCerrar()
  ventana_clicada()
  pcall(vim.cmd.close)
end

local BARRA = table.concat({
  ' %<%f %m%=',
  '%@v:lua.ClicDividirV@ ' .. ICO.dividir_v .. ' %X',
  '%@v:lua.ClicDividirH@ ' .. ICO.dividir_h .. ' %X',
  '%@v:lua.ClicCerrar@ ' .. ICO.cerrar .. ' %X',
})

autocmd({ 'BufWinEnter', 'WinEnter', 'FileType', 'TermOpen' }, {
  desc = 'Barra con botones solo en ventanas de archivos',
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(win).relative ~= '' then return end
    if vim.bo.buftype == '' then
      if vim.wo[win].winbar == '' then vim.wo[win].winbar = BARRA end
    elseif vim.wo[win].winbar == BARRA then
      vim.wo[win].winbar = ''
    end
  end,
})

-- ── Documentación al dejar el puntero quieto (como en VS Code) ────────────────
-- Muestra el problema y la documentación de lo que hay bajo el puntero. Solo
-- aparece si hay algo que mostrar y se cierra al alejar el puntero.
local puntero = { reloj = nil, ventana = nil, clave = nil }

local function cerrar_flotante_del_puntero()
  if puntero.ventana and vim.api.nvim_win_is_valid(puntero.ventana) then
    pcall(vim.api.nvim_win_close, puntero.ventana, true)
  end
  puntero.ventana, puntero.clave = nil, nil
end

-- Qué hay bajo el puntero, si está sobre texto de un archivo.
local function bajo_el_puntero()
  local m = vim.fn.getmousepos()
  if m.winid == 0 or m.line == 0 or not vim.api.nvim_win_is_valid(m.winid) then return end
  local buf = vim.api.nvim_win_get_buf(m.winid)
  if vim.bo[buf].buftype ~= '' then return end
  if m.wincol <= vim.fn.getwininfo(m.winid)[1].textoff then return end -- números y signos
  local linea = vim.api.nvim_buf_get_lines(buf, m.line - 1, m.line, false)[1] or ''
  if m.column > #linea or linea:sub(m.column, m.column):match('%s') then return end
  local inicio = m.column -- inicio de la palabra: moverse dentro de ella no reabre nada
  while inicio > 1 and linea:sub(inicio - 1, inicio - 1):match('[%w_]') do
    inicio = inicio - 1
  end
  return { buf = buf, fila = m.line - 1, col = m.column - 1, linea = linea, clave = ('%d:%d:%d'):format(buf, m.line, inicio) }
end

local function mostrar_bajo_el_puntero()
  if vim.fn.mode() ~= 'n' or vim.fn.pumvisible() == 1 then return end
  local p = bajo_el_puntero()
  if not p then return end

  local lineas = {}
  for _, d in ipairs(vim.diagnostic.get(p.buf, { lnum = p.fila })) do
    local fin = (d.end_lnum or d.lnum) > d.lnum and math.huge or math.max(d.end_col or 0, d.col + 1)
    if p.col >= d.col and p.col < fin then
      local icono = ({ ICO.error, ICO.aviso, ICO.info, ICO.pista })[d.severity] or ''
      if #lineas == 0 then lineas[1] = '```' end -- bloque literal: sin interpretar Markdown
      for i, texto in ipairs(vim.split(d.message, '\n')) do
        lineas[#lineas + 1] = (i == 1 and icono or '  ') .. texto
      end
    end
  end
  if #lineas > 0 then lineas[#lineas + 1] = '```' end

  local function abrir()
    local ahora = bajo_el_puntero()
    if #lineas == 0 or not ahora or ahora.clave ~= p.clave then return end -- nada que mostrar o el puntero se fue
    cerrar_flotante_del_puntero()
    local _, ventana = vim.lsp.util.open_floating_preview(lineas, 'markdown', {
      relative = 'mouse',
      border = 'rounded',
      focus = false,
      max_width = 90,
      max_height = 20,
      close_events = { 'CursorMoved', 'CursorMovedI', 'InsertEnter', 'WinScrolled' },
    })
    puntero.ventana, puntero.clave = ventana, p.clave
  end

  if #vim.lsp.get_clients({ bufnr = p.buf, method = 'textDocument/hover' }) == 0 then return abrir() end
  vim.lsp.buf_request_all(p.buf, 'textDocument/hover', function(cliente)
    return {
      textDocument = { uri = vim.uri_from_bufnr(p.buf) },
      position = { line = p.fila, character = vim.str_utfindex(p.linea, cliente.offset_encoding, p.col, false) },
    }
  end, function(respuestas)
    for _, r in pairs(respuestas) do
      local doc = r.result and r.result.contents and vim.lsp.util.convert_input_to_markdown_lines(r.result.contents) or {}
      if #doc > 0 and table.concat(doc):match('%S') then
        if #lineas > 0 then lineas[#lineas + 1] = '---' end
        vim.list_extend(lineas, doc)
      end
    end
    abrir()
  end)
end

local function al_mover_el_puntero()
  if puntero.ventana then
    if vim.fn.getmousepos().winid == puntero.ventana then return end -- el puntero está sobre el flotante
    local p = bajo_el_puntero()
    if p and p.clave == puntero.clave then return end -- sigue sobre la misma palabra
    cerrar_flotante_del_puntero()
  end
  puntero.reloj = puntero.reloj or vim.uv.new_timer()
  puntero.reloj:stop()
  puntero.reloj:start(600, 0, vim.schedule_wrap(mostrar_bajo_el_puntero))
end

if OPC.hover_mouse then
  map('n', '<MouseMove>', al_mover_el_puntero, { desc = 'Documentación al dejar el puntero quieto' })
end

-- ════════════════════════════════════════════════════════════════════════════
--  4. PLUGINS (lazy.nvim se instala solo)
-- ════════════════════════════════════════════════════════════════════════════
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local salida = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then error('No se pudo descargar lazy.nvim:\n' .. salida) end
  -- Misma versión de lazy.nvim que fija lazy-lock.json, para que todas las máquinas queden iguales
  local ok, fijadas = pcall(vim.json.decode, leer(vim.fn.stdpath('config') .. '/lazy-lock.json'))
  local commit = ok and type(fijadas) == 'table' and fijadas['lazy.nvim'] and fijadas['lazy.nvim'].commit
  if commit then vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--quiet', commit }) end
end
vim.opt.rtp:prepend(lazypath)

-- Desactiva netrw (el árbol lo reemplaza) y los proveedores de scripting que no se usan
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
for _, proveedor in ipairs({ 'node', 'perl', 'python3', 'ruby' }) do
  vim.g['loaded_' .. proveedor .. '_provider'] = 0
end

local PARSERS = {
  'python', 'typescript', 'tsx', 'javascript', 'json', 'yaml', 'toml', 'html', 'css',
  'bash', 'dockerfile', 'sql', 'diff', 'gitcommit', 'regex',
}

local EXCLUIR = { '.git', '.venv', 'node_modules', '__pycache__', '.pytest_cache', '.ruff_cache', '.mypy_cache', '.next' }

local function puede_compilar()
  return vim.fn.executable('tree-sitter') == 1
    and (vim.fn.executable('cc') == 1 or vim.fn.executable('gcc') == 1 or vim.fn.executable('clang') == 1)
end
local instalacion_de_parsers -- tarea en curso; :InstalarTodo espera a que termine

require('lazy').setup({
  -- Tema de colores
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup({ flavour = 'mocha', auto_integrations = true })
      vim.cmd.colorscheme('catppuccin')
    end,
  },

  -- Iconos
  { 'nvim-tree/nvim-web-devicons', lazy = true, opts = { default = true } },

  -- Buscador, terminal, notificaciones, guías de indentación
  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      notifier = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } },
      input = { enabled = true },
      picker = {
        enabled = true,
        -- Muestra archivos ocultos (.env, .gitignore) pero no carpetas de dependencias,
        -- que inundan la búsqueda cuando el proyecto no es un repo git.
        sources = {
          files = { hidden = true, exclude = EXCLUIR },
          grep = { hidden = true, exclude = EXCLUIR },
        },
      },
    },
  },

  -- Árbol de archivos
  {
    'nvim-tree/nvim-tree.lua',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local api = require('nvim-tree.api')
      require('nvim-tree').setup({
        hijack_cursor = true,
        sync_root_with_cwd = true,
        update_focused_file = { enable = true }, -- el árbol sigue al archivo abierto
        view = { width = 35 },
        renderer = {
          group_empty = true,
          highlight_git = 'name',
          indent_markers = { enable = true },
          icons = {
            show = { file = OPC.nerd_font, folder = OPC.nerd_font, folder_arrow = true, git = true },
            glyphs = OPC.nerd_font and {
              default = ic(0xF021A),
              symlink = ic(0xF481),
              folder = {
                arrow_closed = ic(0xF460),
                arrow_open = ic(0xF47C),
                default = ic(0xE5FF),
                open = ic(0xE5FE),
                empty = ic(0xF114),
                empty_open = ic(0xF115),
                symlink = ic(0xF482),
                symlink_open = ic(0xF482),
              },
              git = {
                unstaged = '✗',
                staged = '✓',
                unmerged = ic(0xE727),
                renamed = '➜',
                untracked = '★',
                deleted = ic(0xF458),
                ignored = '◌',
              },
            } or { folder = { arrow_closed = '+', arrow_open = '-' } },
          },
        },
        filters = { dotfiles = false, custom = { '^\\.git$', '^__pycache__$' } },
        -- Con varias divisiones abre en la última usada, sin preguntar por teclado en cuál.
        actions = { open_file = { window_picker = { enable = false } } },
        on_attach = function(buf)
          api.config.mappings.default_on_attach(buf)
          local function m(lhs, accion, desc)
            vim.keymap.set('n', lhs, accion, { buffer = buf, desc = desc, nowait = true, silent = true })
          end
          m('/', buscar_en_arbol, 'Buscar en el árbol (todas las subcarpetas)')
          m('v', api.node.open.vertical, 'Abrir en división vertical')
          m('h', api.node.open.horizontal, 'Abrir en división horizontal')
        end,
      })
    end,
  },

  -- Pestañas
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      return {
        highlights = require('catppuccin.special.bufferline').get_theme(),
        options = {
          mode = 'buffers',
          separator_style = 'slant',
          diagnostics = 'nvim_lsp',
          show_buffer_icons = OPC.nerd_font,
          close_command = cerrar_buffer,
          middle_mouse_command = cerrar_buffer,
          right_mouse_command = menu_pestana,
          -- Sin `hover` de bufferline: se adueña de <MouseMove> y anula la documentación flotante.
          offsets = {
            { filetype = 'NvimTree', text = 'Explorador', text_align = 'left', separator = true },
          },
        },
      }
    end,
  },

  -- Barra de estado
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'auto',
        globalstatus = true,
        icons_enabled = OPC.nerd_font,
        component_separators = '',
        section_separators = OPC.nerd_font and { left = ic(0xE0B4), right = ic(0xE0B6) } or '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          { 'branch', on_click = function() Snacks.picker.git_branches() end },
          { 'diff', on_click = function() Snacks.picker.git_status() end },
        },
        lualine_c = {
          { 'diagnostics', on_click = function() Snacks.picker.diagnostics_buffer() end },
          { 'filename', path = 1 },
        },
        lualine_x = {
          {
            function() return ICO.formato .. (formato_activo(0) and 'auto' or 'manual') end,
            cond = function() return vim.bo.buftype == '' end,
            on_click = alternar_formato,
          },
          'lsp_status',
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      extensions = { 'nvim-tree', 'lazy', 'mason' },
    },
  },

  -- Ayuda de atajos al pulsar Espacio
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      icons = { mappings = OPC.nerd_font },
      spec = {
        { '<leader>f', group = 'Buscar' },
        { '<leader>c', group = 'Código' },
        { '<leader>p', group = 'Python / uv' },
        { '<leader>o', group = 'Opciones' },
        { '<leader>g', group = 'Git' },
      },
    },
  },

  -- Marcas de cambios de git en el margen
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(buf)
        local gs = require('gitsigns')
        local function m(lhs, accion, desc) vim.keymap.set('n', lhs, accion, { buffer = buf, desc = desc }) end
        m('<leader>gp', gs.preview_hunk, 'Ver cambio')
        m('<leader>gr', gs.reset_hunk, 'Deshacer cambio')
        m('<leader>gb', gs.blame_line, 'Quién cambió esta línea')
        m('<leader>gn', function() gs.nav_hunk('next') end, 'Cambio siguiente')
        m('<leader>gN', function() gs.nav_hunk('prev') end, 'Cambio anterior')
      end,
    },
  },

  -- Barra de desplazamiento que se puede arrastrar
  {
    'dstein64/nvim-scrollview',
    event = 'VeryLazy',
    opts = {
      excluded_filetypes = { 'NvimTree' },
      signs_on_startup = { 'diagnostics', 'search' },
    },
  },

  -- Resaltado de sintaxis (treesitter). La rama main no activa nada sola:
  -- se enciende por buffer en el autocmd FileType de más abajo.
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = function()
      if puede_compilar() then require('nvim-treesitter').update() end
    end,
    config = function()
      if puede_compilar() then instalacion_de_parsers = require('nvim-treesitter').install(PARSERS) end
    end,
  },

  -- Servidores de lenguaje
  { 'neovim/nvim-lspconfig', lazy = false },
  { 'mason-org/mason.nvim', lazy = false, opts = { ui = { border = 'rounded' } } },
  {
    'mason-org/mason-lspconfig.nvim',
    lazy = false,
    dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
    opts = { ensure_installed = {}, automatic_enable = true },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    lazy = false,
    dependencies = { 'mason-org/mason.nvim' },
    opts = { ensure_installed = { 'vtsls', 'eslint-lsp', 'prettier' } },
  },

  -- Autocompletado. La versión etiquetada trae el binario precompilado. Se carga
  -- al inicio porque al cargarse anuncia sus capacidades a los servidores de lenguaje.
  {
    'saghen/blink.cmp',
    version = '1.*',
    lazy = false,
    opts = {
      keymap = { preset = 'super-tab', ['<CR>'] = { 'accept', 'fallback' } },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
      },
      signature = { enabled = true },
    },
  },

  -- Formateadores
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    opts = function()
      local web = function(buf) return usa_biome(buf) and { 'biome' } or { 'prettier' } end
      local por_tipo = { python = { 'ruff_format' } }
      for ft in pairs(WEB) do
        por_tipo[ft] = web
      end
      return {
        formatters_by_ft = por_tipo,
        format_on_save = function(buf)
          if formato_activo(buf) then return { timeout_ms = 3000, lsp_format = 'fallback' } end
        end,
      }
    end,
  },

  -- Cierra paréntesis y comillas
  { 'nvim-mini/mini.pairs', event = 'InsertEnter', opts = {} },

  -- Markdown dentro de Neovim
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },

  -- Markdown en el navegador
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = 'markdown',
    -- --no-package-lock evita que npm reescriba el yarn.lock del plugin
    build = function(plugin)
      if vim.fn.executable('npm') == 1 then
        vim.system({ 'npm', 'install', '--no-package-lock' }, { cwd = plugin.dir .. '/app' }):wait()
      else
        vim.fn['mkdp#util#install']()
      end
    end,
    init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
  },
}, {
  install = { colorscheme = { 'catppuccin' } },
  change_detection = { notify = false },
  rocks = { enabled = false },
  ui = { border = 'rounded' },
})

-- ════════════════════════════════════════════════════════════════════════════
--  5. LENGUAJES
-- ════════════════════════════════════════════════════════════════════════════
-- Treesitter: resaltado, indentación y pliegues por buffer
local function pliegues_treesitter(buf)
  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  if not (lang and vim.treesitter.highlighter.active[buf] and vim.treesitter.query.get(lang, 'folds')) then return end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].foldmethod = 'expr'
    vim.wo[win][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end
end

autocmd('FileType', {
  desc = 'Activa treesitter si hay parser para el tipo de archivo',
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= '' or not pcall(vim.treesitter.start, ev.buf) then return end
    local lang = vim.treesitter.language.get_lang(ev.match)
    if lang and vim.treesitter.query.get(lang, 'indents') then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    pliegues_treesitter(ev.buf)
  end,
})

autocmd('BufWinEnter', {
  desc = 'Pliegues por treesitter al mostrar el buffer en otra ventana',
  callback = function(ev) pliegues_treesitter(ev.buf) end,
})

-- Python: ruff (lint y formato) + basedpyright (tipos), instalados con uv.
-- Se le indica el intérprete del .venv del proyecto para que resuelva los imports.
local function python_del_venv(dir)
  if not dir then return end
  local py = dir .. (vim.fn.has('win32') == 1 and '/.venv/Scripts/python.exe' or '/.venv/bin/python')
  if existe(py) then return py end
end

vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = { typeCheckingMode = 'standard', diagnosticMode = 'openFilesOnly', autoImportCompletions = true },
    },
  },
  before_init = function(_, config)
    local py = python_del_venv(config.root_dir)
    if py then config.settings = vim.tbl_deep_extend('force', config.settings or {}, { python = { pythonPath = py } }) end
  end,
})

vim.lsp.config('ruff', {
  capabilities = { general = { positionEncodings = { 'utf-16' } } }, -- igual que basedpyright
  on_attach = function(cliente)
    cliente.server_capabilities.hoverProvider = false -- la documentación la da el servidor de tipos
  end,
})

local HERRAMIENTAS_PYTHON = {
  { paquete = 'ruff', ejecutable = 'ruff', servidor = 'ruff' },
  OPC.python_lsp == 'ty' and { paquete = 'ty', ejecutable = 'ty', servidor = 'ty' }
    or { paquete = 'basedpyright', ejecutable = 'basedpyright-langserver', servidor = 'basedpyright' },
}
for _, h in ipairs(HERRAMIENTAS_PYTHON) do
  if vim.fn.executable(h.ejecutable) == 1 then
    vim.lsp.enable(h.servidor)
  elseif vim.fn.executable('uv') == 1 then
    vim.system({ 'uv', 'tool', 'install', h.paquete }, { text = true }, vim.schedule_wrap(function(r)
      if r.code == 0 and vim.fn.executable(h.ejecutable) == 1 then
        vim.lsp.enable(h.servidor)
        avisar(h.paquete .. ' instalado con uv')
      else
        avisar('No se pudo instalar ' .. h.paquete .. ' con uv:\n' .. (r.stderr or ''), vim.log.levels.WARN)
      end
    end))
  end
end

-- TypeScript: vtsls para proyectos con TypeScript 5/6 y el servidor nativo
-- (tsc --lsp) para los que ya usan TypeScript 7. Nunca los dos a la vez.
local function typescript_del_proyecto(buf)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  for _, modulos in ipairs(vim.fs.find('node_modules', { path = dir, upward = true, type = 'directory', limit = math.huge })) do
    local paquete = modulos .. '/typescript/package.json'
    if existe(paquete) then
      local ok, datos = pcall(vim.json.decode, leer(paquete))
      return ok and tonumber((datos.version or ''):match('^(%d+)')) or nil
    end
  end
end

-- Envuelve la definición de nvim-lspconfig. Se carga una sola vez con dofile porque
-- en `tsc` las funciones cmd y root_dir comparten estado (el binario encontrado).
local function solo_si(servidor, condicion)
  local archivo = vim.api.nvim_get_runtime_file('lsp/' .. servidor .. '.lua', false)[1]
  if not archivo then return end
  local base = dofile(archivo)
  vim.lsp.config(servidor, {
    cmd = base.cmd,
    root_dir = function(buf, on_dir)
      if not condicion(typescript_del_proyecto(buf)) then return end
      if type(base.root_dir) == 'function' then return base.root_dir(buf, on_dir) end
      on_dir(vim.fs.root(buf, base.root_markers or { 'package.json', '.git' }))
    end,
  })
end
solo_si('vtsls', function(version) return version == nil or version < 7 end)
solo_si('tsc', function(version) return version ~= nil and version >= 7 end)
vim.lsp.config('vtsls', { settings = { vtsls = { autoUseWorkspaceTsdk = true } } })
vim.lsp.enable('tsc') -- vtsls y eslint los activa mason-lspconfig al instalarlos

autocmd('LspAttach', {
  desc = 'Atajos disponibles cuando hay servidor de lenguaje',
  callback = function(ev)
    local function m(modos, lhs, accion, desc) vim.keymap.set(modos, lhs, accion, { buffer = ev.buf, desc = desc }) end
    local definicion = function() Snacks.picker.lsp_definitions() end
    m('n', 'gd', definicion, 'Ir a definición')
    m('n', '<F12>', definicion, 'Ir a definición')
    m('n', 'K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Ver documentación')
    m({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, 'Renombrar símbolo')
    m('n', '<leader>cr', vim.lsp.buf.rename, 'Renombrar símbolo')
    m({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'Acciones de código')
    m('n', '<leader>cu', function() Snacks.picker.lsp_references() end, 'Ver referencias (usos)')
    m('n', '<leader>cs', function() Snacks.picker.lsp_symbols() end, 'Símbolos del archivo')
  end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  6. ATAJOS QUE USAN PLUGINS
-- ════════════════════════════════════════════════════════════════════════════
map('n', '<leader>e', '<Cmd>NvimTreeToggle<CR>', { desc = 'Árbol de archivos' })
map('n', '<leader>m', '<Cmd>MarkdownPreviewToggle<CR>', { desc = 'Vista previa de Markdown' })
map('n', '<leader>x', function() cerrar_buffer(0) end, { desc = 'Cerrar pestaña' })
map('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Pestaña siguiente' })
map('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Pestaña anterior' })

map('n', '<C-p>', function() Snacks.picker.files() end, { desc = 'Buscar archivo' })
map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Archivos' })
map('n', '<leader>fg', function() Snacks.picker.grep() end, { desc = 'Texto en el proyecto' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Archivos abiertos' })
map('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Recientes' })
map('n', '<leader>fa', function() Snacks.picker.keymaps() end, { desc = 'Atajos' })

map('n', '<leader>cf', formatear, { desc = 'Formatear' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Ver problema de esta línea' })
map('n', '<leader>cl', function() Snacks.picker.diagnostics_buffer() end, { desc = 'Lista de problemas' })

map('n', '<leader>r', ejecutar_archivo, { desc = 'Ejecutar archivo' })
map('n', '<leader>t', function() Snacks.terminal() end, { desc = 'Terminal' })

map('n', '<leader>of', alternar_formato, { desc = 'Formato al guardar' })
map('n', '<leader>oh', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  avisar('Pistas de tipos: ' .. (vim.lsp.inlay_hint.is_enabled() and 'sí' or 'no'))
end, { desc = 'Pistas de tipos' })
map('n', '<leader>ow', function()
  vim.wo.wrap = not vim.wo.wrap
  avisar('Ajuste de línea: ' .. (vim.wo.wrap and 'sí' or 'no'))
end, { desc = 'Ajuste de línea' })

-- ════════════════════════════════════════════════════════════════════════════
--  7. EXTRAS
-- ════════════════════════════════════════════════════════════════════════════
-- :Uv sync, :Uv add requests, :Uv run pytest… en la raíz del proyecto
vim.api.nvim_create_user_command('Uv', function(args)
  en_terminal(vim.list_extend({ 'uv' }, args.fargs), raiz({ 'pyproject.toml', 'uv.lock', '.git' }))
end, {
  nargs = '+',
  desc = 'Ejecuta uv en la raíz del proyecto',
  complete = function() return { 'sync', 'add', 'remove', 'run', 'lock', 'tree', 'init', 'venv', 'python', 'pip' } end,
})
map('n', '<leader>ps', '<Cmd>Uv sync<CR>', { desc = 'uv sync' })
map('n', '<leader>pa', function()
  vim.ui.input({ prompt = 'uv add: ' }, function(paquete)
    if paquete and paquete ~= '' then vim.cmd('Uv add ' .. paquete) end
  end)
end, { desc = 'uv add…' })

-- Lo usa bootstrap.sh para dejar todo instalado sin abrir la interfaz
vim.api.nvim_create_user_command('InstalarTodo', function()
  pcall(vim.cmd, 'MasonToolsInstallSync')
  if instalacion_de_parsers then instalacion_de_parsers:wait(600000) end
end, { desc = 'Instala servidores de lenguaje y parsers (bloquea hasta terminar)' })

local con_interfaz = #vim.api.nvim_list_uis() > 0

autocmd('VimEnter', {
  desc = 'Muestra el árbol al arrancar',
  callback = function()
    local tipo = vim.bo.filetype
    if not OPC.arbol_al_abrir or not con_interfaz or vim.o.columns < 100 or vim.o.diff then return end
    if tipo == 'gitcommit' or tipo == 'gitrebase' or tipo == 'NvimTree' then return end
    require('nvim-tree.api').tree.toggle({ focus = false })
  end,
})

if con_interfaz then
  vim.defer_fn(function()
    local faltan = {}
    local function requiere(ok, nombre)
      if not ok then faltan[#faltan + 1] = nombre end
    end
    requiere(puede_compilar(), 'compilador de C y tree-sitter (resaltado de Python y TypeScript)')
    requiere(vim.fn.executable('uv') == 1, 'uv (Python)')
    requiere(vim.fn.executable('node') == 1, 'Node.js (TypeScript)')
    requiere(vim.fn.executable('rg') == 1, 'ripgrep (buscar texto)')
    if #faltan > 0 then
      avisar(
        'Faltan herramientas:\n  • ' .. table.concat(faltan, '\n  • ')
          .. '\nRevisa con: ' .. vim.fn.stdpath('config') .. '/bootstrap.sh revisar',
        vim.log.levels.WARN
      )
    end
  end, 1500)
end
