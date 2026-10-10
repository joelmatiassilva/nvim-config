#!/usr/bin/env bash
# bootstrap.sh — deja una máquina lista para esta configuración de Neovim y tmux.
#
#   ./bootstrap.sh               todo: herramientas, Neovim, fuente, tmux, plugins y revisión
#   ./bootstrap.sh revisar       solo muestra qué hay y qué falta (no cambia nada)
#   ./bootstrap.sh herramientas  compilador, tree-sitter, uv, ruff, basedpyright, tmux…
#   ./bootstrap.sh nvim          Neovim en ~/.local (sin sudo)
#   ./bootstrap.sh fuente        JetBrainsMono Nerd Font (en WSL: Windows + Windows Terminal)
#   ./bootstrap.sh tmux          enlaza ~/.tmux.conf a ../tmux/tmux.conf
#   ./bootstrap.sh plugins       plugins, servidores de lenguaje y parsers
#
# Es idempotente: se puede ejecutar las veces que haga falta.
# Variables opcionales: NVIM_VERSION, NVIM_APPNAME, SIN_ENLACE=1 (no enlaza ~/.local/bin/nvim).
set -euo pipefail

NVIM_VERSION="${NVIM_VERSION:-v0.12.6}"
NVIM_MINIMO="0.12.0"
TREE_SITTER_VERSION="${TREE_SITTER_VERSION:-v0.27.1}"
TREE_SITTER_MINIMO="0.26.1"
NERD_FONTS_VERSION="${NERD_FONTS_VERSION:-v3.5.1}"
FUENTE="JetBrainsMono Nerd Font"
ESTILOS=(Regular Bold Italic BoldItalic)
TMUX_MINIMO="3.2"
WIN32YANK_VERSION="${WIN32YANK_VERSION:-v0.1.1}"

APP="${NVIM_APPNAME:-nvim}"
# Ruta real de esta carpeta, aunque el script se invoque a través de ~/.config/nvim.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/$APP"
TMUX_CONF="$(dirname "$REPO")/tmux/tmux.conf"
TMUX_DESTINO="$HOME/.tmux.conf"
BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
NVIM_DIR="$OPT/nvim-$NVIM_VERSION"
DIR_FUENTES="$HOME/.local/share/fonts"
SO="$(uname -s)"
ARQ="$(uname -m)"
PATH_ORIGINAL="$PATH"
export PATH="$BIN:$PATH"

# ── Utilidades ──────────────────────────────────────────────────────────────
titulo() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }
info()   { printf '   %s\n' "$*"; }
ok()     { printf ' \033[32m✓\033[0m %s\n' "$*"; }
aviso()  { printf ' \033[33m!\033[0m %s\n' "$*"; }
falta()  { printf ' \033[31m✗\033[0m %s\n' "$*"; }
error()  { printf '\n\033[31mError:\033[0m %s\n' "$*" >&2; exit 1; }

tiene()    { command -v "$1" >/dev/null 2>&1; }
tiene_cc() { tiene cc || tiene gcc || tiene clang; }
es_wsl()   { grep -qi microsoft /proc/version 2>/dev/null; }
# version_ok MINIMO ACTUAL → verdadero si ACTUAL >= MINIMO
version_ok() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n 1)" = "$1" ]; }

version_nvim() { "$1" --version 2>/dev/null | sed -n -E '1s/^NVIM v([0-9.]+).*/\1/p'; }
version_tree_sitter() { tree-sitter --version 2>/dev/null | sed -E 's/^tree-sitter ([0-9.]+).*/\1/'; }
version_tmux() { tmux -V 2>/dev/null | sed -E 's/^tmux ([0-9.]+).*/\1/'; }

# Imprime la ruta de un Neovim que sirva (el de ~/.local/opt tiene prioridad).
buscar_nvim() {
  local c
  for c in "$NVIM_DIR/bin/nvim" "$(command -v nvim 2>/dev/null || true)"; do
    if [ -n "$c" ] && [ -x "$c" ] && version_ok "$NVIM_MINIMO" "$(version_nvim "$c")"; then
      printf '%s\n' "$c"
      return 0
    fi
  done
  return 1
}

# ── Herramientas ────────────────────────────────────────────────────────────
instalar_tree_sitter() {
  if tiene tree-sitter && version_ok "$TREE_SITTER_MINIMO" "$(version_tree_sitter)"; then
    ok "tree-sitter $(version_tree_sitter)"
    return
  fi
  local plataforma
  case "$SO-$ARQ" in
    Linux-x86_64)             plataforma=linux-x64 ;;
    Linux-aarch64|Linux-arm64) plataforma=linux-arm64 ;;
    Darwin-arm64)             plataforma=macos-arm64 ;;
    Darwin-x86_64)            plataforma=macos-x64 ;;
    *) aviso "No hay binario de tree-sitter para $SO-$ARQ; instálalo con tu gestor de paquetes."; return ;;
  esac
  mkdir -p "$BIN"
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/$TREE_SITTER_VERSION/tree-sitter-$plataforma.gz" \
    | gunzip > "$BIN/tree-sitter.tmp"
  chmod +x "$BIN/tree-sitter.tmp"
  mv -f "$BIN/tree-sitter.tmp" "$BIN/tree-sitter"
  ok "tree-sitter $(version_tree_sitter) instalado en $BIN"
}

# En WSL, win32yank es la forma rápida y fiel (acentos incluidos) de llegar al
# portapapeles de Windows. Lo usan Neovim y tmux.
instalar_win32yank() {
  es_wsl || return 0
  if tiene win32yank.exe; then
    ok "win32yank.exe (portapapeles de Windows)"
    return
  fi
  if [ "$ARQ" != x86_64 ]; then
    aviso "No hay win32yank para $ARQ; el portapapeles usará OSC 52."
    return
  fi
  local tmp
  tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/win32yank.zip" "https://github.com/equalsraf/win32yank/releases/download/$WIN32YANK_VERSION/win32yank-x64.zip" \
    && unzip -q -o "$tmp/win32yank.zip" win32yank.exe -d "$tmp"; then
    mkdir -p "$BIN"
    mv -f "$tmp/win32yank.exe" "$BIN/win32yank.exe"
    chmod +x "$BIN/win32yank.exe"
    ok "win32yank.exe instalado en $BIN"
  else
    aviso "No se pudo descargar win32yank.exe; el portapapeles usará OSC 52."
  fi
  rm -rf "$tmp"
}

instalar_uv_tool() { # paquete ejecutable
  if tiene "$2"; then
    ok "$1"
  else
    uv tool install "$1" >/dev/null 2>&1 && ok "$1 instalado con uv" || aviso "No se pudo instalar $1 con uv"
  fi
}

paso_herramientas() {
  titulo "Herramientas"
  local faltan=() c
  for c in git curl unzip tar gzip; do tiene "$c" || faltan+=("$c"); done
  tiene_cc || faltan+=(build-essential)
  tiene rg || faltan+=(ripgrep)
  tiene fd || tiene fdfind || faltan+=(fd-find)
  tiene tmux || faltan+=(tmux)

  if ((${#faltan[@]})); then
    if tiene apt-get; then
      if sudo -n true 2>/dev/null || [ -t 0 ]; then
        info "Instalando con apt: ${faltan[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y "${faltan[@]}"
      else
        aviso "Faltan paquetes del sistema. Ejecuta:"
        info  "  sudo apt-get install -y ${faltan[*]}"
      fi
    else
      aviso "Instala con el gestor de paquetes de tu sistema: ${faltan[*]}"
    fi
  else
    ok "Paquetes del sistema"
  fi

  # En Debian/Ubuntu el ejecutable de fd se llama fdfind.
  if ! tiene fd && tiene fdfind; then
    mkdir -p "$BIN"
    ln -sfn "$(command -v fdfind)" "$BIN/fd"
    ok "Enlace fd → fdfind"
  fi

  instalar_tree_sitter
  instalar_win32yank

  if ! tiene uv; then
    info "Instalando uv…"
    curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || aviso "No se pudo instalar uv"
  fi
  if tiene uv; then
    ok "$(uv --version)"
    instalar_uv_tool ruff ruff
    instalar_uv_tool basedpyright basedpyright-langserver
  fi

  tiene node || aviso "Falta Node.js (lo usan los servidores de TypeScript). Sugerencia: https://github.com/nvm-sh/nvm"
}

# ── Neovim ──────────────────────────────────────────────────────────────────
paso_nvim() {
  titulo "Neovim $NVIM_VERSION"
  if [ "$SO" = Darwin ]; then
    if tiene brew; then brew install neovim; else aviso "Instala Neovim >= $NVIM_MINIMO (https://neovim.io)."; fi
    return
  fi
  local paquete
  case "$ARQ" in
    x86_64)        paquete=nvim-linux-x86_64 ;;
    aarch64|arm64) paquete=nvim-linux-arm64 ;;
    *) error "No hay Neovim precompilado para $ARQ." ;;
  esac
  if [ ! -x "$NVIM_DIR/bin/nvim" ]; then
    info "Descargando $paquete.tar.gz…"
    rm -rf "$NVIM_DIR.tmp"
    mkdir -p "$NVIM_DIR.tmp"
    curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$paquete.tar.gz" \
      | tar -xz -C "$NVIM_DIR.tmp" --strip-components=1
    rm -rf "$NVIM_DIR"
    mv "$NVIM_DIR.tmp" "$NVIM_DIR"
  fi
  ok "Neovim $(version_nvim "$NVIM_DIR/bin/nvim") en $NVIM_DIR"

  if [ "${SIN_ENLACE:-0}" = 1 ]; then
    info "Sin enlace en $BIN (SIN_ENLACE=1)."
    return
  fi
  mkdir -p "$BIN"
  ln -sfn "$NVIM_DIR/bin/nvim" "$BIN/nvim"
  ok "Enlace $BIN/nvim"
  case ":$PATH_ORIGINAL:" in
    *":$BIN:"*) ;;
    *) aviso "Agrega $BIN a tu PATH (por ejemplo en ~/.bashrc): export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
  esac
}

# ── Fuente ──────────────────────────────────────────────────────────────────
fuente_registrada_windows() {
  # Sin tubería: con pipefail, grep -q corta la lectura y reg.exe "falla" aunque haya coincidencia.
  local registro
  registro="$(reg.exe query 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts' 2>/dev/null || true)"
  grep -q "$FUENTE Regular" <<<"$registro"
}

fuente_windows() {
  tiene powershell.exe && tiene reg.exe || { aviso "No encuentro powershell.exe/reg.exe: instala \"$FUENTE\" a mano en Windows."; return; }
  local local_win local_wsl destino estilo etiqueta ajustes resultado
  local_win="$(powershell.exe -NoLogo -NoProfile -Command '[Environment]::GetFolderPath("LocalApplicationData")' | tr -d '\r')"
  local_wsl="$(wslpath -u "$local_win")"
  destino="$local_wsl/Microsoft/Windows/Fonts"
  mkdir -p "$destino"
  for estilo in "${ESTILOS[@]}"; do
    case "$estilo" in BoldItalic) etiqueta="Bold Italic" ;; *) etiqueta="$estilo" ;; esac
    cp -f "$DIR_FUENTES/JetBrainsMonoNerdFont-$estilo.ttf" "$destino/"
    reg.exe add 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts' \
      /v "$FUENTE $etiqueta (TrueType)" /t REG_SZ \
      /d "$local_win\\Microsoft\\Windows\\Fonts\\JetBrainsMonoNerdFont-$estilo.ttf" /f >/dev/null
  done
  ok "Fuente instalada para tu usuario de Windows (sin permisos de administrador)"

  for ajustes in \
    "$local_wsl/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" \
    "$local_wsl/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json" \
    "$local_wsl/Microsoft/Windows Terminal/settings.json"; do
    [ -f "$ajustes" ] || continue
    resultado="$(python3 -I - "$ajustes" "$FUENTE" <<'PY' || true
import json, shutil, sys, time

ruta, fuente = sys.argv[1], sys.argv[2]
try:
    with open(ruta, encoding="utf-8-sig") as fh:
        datos = json.load(fh)
except ValueError:
    print("NO_JSON")
    sys.exit(0)
perfiles = datos.get("profiles")
if not isinstance(perfiles, dict):
    print("NO_JSON")
    sys.exit(0)
letra = perfiles.setdefault("defaults", {}).setdefault("font", {})
if letra.get("face") == fuente:
    print("YA")
    sys.exit(0)
shutil.copy2(ruta, ruta + time.strftime(".bak-%Y%m%d-%H%M%S"))
letra["face"] = fuente
with open(ruta, "w", encoding="utf-8", newline="") as fh:
    json.dump(datos, fh, indent=4)
    fh.write("\n")
print("OK")
PY
)"
    case "$resultado" in
      OK) ok "Windows Terminal: fuente por defecto = $FUENTE (respaldo junto a settings.json)" ;;
      YA) ok "Windows Terminal ya usa $FUENTE" ;;
      *)  aviso "No pude editar $ajustes. En Windows Terminal: Configuración → Valores predeterminados → Apariencia → Tipo de fuente → $FUENTE" ;;
    esac
  done
  info "Cierra y vuelve a abrir Windows Terminal para que tome la fuente."
}

paso_fuente() {
  titulo "Fuente $FUENTE"
  if [ "$SO" = Darwin ]; then
    if tiene brew; then brew install --cask font-jetbrains-mono-nerd-font; else aviso "Instala \"$FUENTE\" desde https://www.nerdfonts.com"; fi
    info "Selecciónala como fuente en las preferencias de tu terminal."
    return
  fi
  local estilo faltan=0 archivos=()
  for estilo in "${ESTILOS[@]}"; do
    archivos+=("JetBrainsMonoNerdFont-$estilo.ttf")
    [ -f "$DIR_FUENTES/JetBrainsMonoNerdFont-$estilo.ttf" ] || faltan=1
  done
  if ((faltan)); then
    info "Descargando JetBrainsMono de Nerd Fonts $NERD_FONTS_VERSION…"
    mkdir -p "$DIR_FUENTES"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/JetBrainsMono.tar.xz" \
      | tar -xJ -C "$DIR_FUENTES" "${archivos[@]}"
    if tiene fc-cache; then fc-cache -f "$DIR_FUENTES" >/dev/null 2>&1 || true; fi
  fi
  ok "Archivos de la fuente en $DIR_FUENTES"
  if es_wsl; then
    fuente_windows
  else
    info "Selecciona \"$FUENTE\" como fuente en las preferencias de tu terminal."
  fi
}

# ── tmux ────────────────────────────────────────────────────────────────────
tmux_enlazado() { [ -L "$TMUX_DESTINO" ] && [ "$(readlink -f "$TMUX_DESTINO")" = "$TMUX_CONF" ]; }

paso_tmux() {
  titulo "tmux"
  if [ ! -f "$TMUX_CONF" ]; then
    info "No hay $TMUX_CONF; se omite."
    return 0
  fi
  if tiene tmux; then
    if version_ok "$TMUX_MINIMO" "$(version_tmux)"; then
      ok "tmux $(version_tmux)"
    else
      aviso "tmux $(version_tmux) es anterior a $TMUX_MINIMO: el portapapeles y los colores pueden fallar."
    fi
  else
    aviso "tmux no está instalado → $0 herramientas"
  fi
  if tmux_enlazado; then
    ok "$TMUX_DESTINO ya apunta al repo"
  else
    if [ -e "$TMUX_DESTINO" ] || [ -L "$TMUX_DESTINO" ]; then
      local respaldo
      respaldo="$TMUX_DESTINO.bak-$(date +%Y%m%d-%H%M%S)"
      mv "$TMUX_DESTINO" "$respaldo"
      info "Respaldo de la configuración anterior: $respaldo"
    fi
    ln -s "$TMUX_CONF" "$TMUX_DESTINO"
    ok "Enlace $TMUX_DESTINO → $TMUX_CONF"
  fi
  # Si hay un tmux abierto, toma la configuración nueva sin reiniciarlo.
  if tiene tmux && tmux list-sessions >/dev/null 2>&1; then
    if tmux source-file "$TMUX_DESTINO"; then info "Configuración recargada en el tmux abierto."; fi
  fi
}

# ── Plugins ─────────────────────────────────────────────────────────────────
enlazar_config() {
  [ "$(readlink -f "$CONFIG" 2>/dev/null || true)" = "$REPO" ] && return 0
  [ -e "$CONFIG" ] && error "$CONFIG ya existe. Muévelo (por ejemplo a $CONFIG.bak) y vuelve a ejecutar."
  mkdir -p "$(dirname "$CONFIG")"
  ln -s "$REPO" "$CONFIG"
  ok "Enlace $CONFIG → $REPO"
}

paso_plugins() {
  titulo "Plugins, servidores de lenguaje y parsers"
  local nvim
  nvim="$(buscar_nvim)" || error "No hay Neovim >= $NVIM_MINIMO. Ejecuta: $0 nvim"
  tiene_cc || error "Falta un compilador de C (lo necesitan los parsers de treesitter).
       Ejecuta:  sudo apt-get install -y build-essential
       y luego:  $0 plugins"
  tiene tree-sitter || error "Falta tree-sitter. Ejecuta: $0 herramientas"
  tiene git || error "Falta git."
  enlazar_config
  info "Instalando plugins (versiones de lazy-lock.json), servidores de lenguaje y parsers…"
  info "Puede tardar unos minutos."
  # Una sola sesión: así :InstalarTodo espera a la misma instalación que arranca init.lua.
  NVIM_APPNAME="$APP" "$nvim" --headless "+Lazy! restore" "+InstalarTodo" +qa
  printf '\n'
  ok "Plugins listos"
}

# ── Revisión ────────────────────────────────────────────────────────────────
paso_revisar() {
  titulo "Revisión"
  local esencial=0 nvim v c
  if nvim="$(buscar_nvim)"; then ok "Neovim $(version_nvim "$nvim") ($nvim)"; else falta "Neovim >= $NVIM_MINIMO → $0 nvim"; esencial=1; fi
  if tiene nvim; then
    v="$(version_nvim "$(command -v nvim)")"
    version_ok "$NVIM_MINIMO" "$v" || aviso "El comando nvim de tu PATH es $v ($(command -v nvim)) → $0 nvim"
  fi
  for c in git curl unzip; do
    if tiene "$c"; then ok "$c"; else falta "$c"; esencial=1; fi
  done
  if tiene_cc; then ok "Compilador de C"; else falta "Compilador de C → sudo apt-get install -y build-essential"; esencial=1; fi
  if tiene tree-sitter && version_ok "$TREE_SITTER_MINIMO" "$(version_tree_sitter)"; then ok "tree-sitter $(version_tree_sitter)"; else falta "tree-sitter >= $TREE_SITTER_MINIMO → $0 herramientas"; esencial=1; fi
  if tiene rg; then ok "ripgrep (buscar texto)"; else falta "ripgrep → sudo apt-get install -y ripgrep"; esencial=1; fi
  if tiene fd; then ok "fd (buscar archivos más rápido)"; else aviso "fd (opcional) → sudo apt-get install -y fd-find && $0 herramientas"; fi
  if tiene node && tiene npm; then ok "Node.js $(node --version)"; else falta "Node.js y npm (TypeScript)"; esencial=1; fi
  if tiene uv; then ok "$(uv --version)"; else falta "uv → $0 herramientas"; esencial=1; fi
  if tiene ruff; then ok "ruff"; else aviso "ruff → uv tool install ruff"; fi
  if tiene basedpyright-langserver; then ok "basedpyright"; else aviso "basedpyright → uv tool install basedpyright"; fi
  if es_wsl; then
    if tiene win32yank.exe; then ok "win32yank.exe (portapapeles de Windows)"; else aviso "win32yank.exe no está: el portapapeles usará OSC 52 → $0 herramientas"; fi
    if tiene reg.exe && fuente_registrada_windows; then ok "Fuente $FUENTE instalada en Windows"; else aviso "Fuente $FUENTE sin instalar en Windows → $0 fuente"; fi
  fi
  if [ -f "$TMUX_CONF" ]; then
    if ! tiene tmux; then
      aviso "tmux no está instalado (opcional) → $0 herramientas"
    elif version_ok "$TMUX_MINIMO" "$(version_tmux)"; then
      ok "tmux $(version_tmux)"
    else
      aviso "tmux $(version_tmux): hace falta $TMUX_MINIMO o superior para el portapapeles y los colores"
    fi
    if tmux_enlazado; then ok "$TMUX_DESTINO enlazado al repo"; else aviso "$TMUX_DESTINO no apunta al repo → $0 tmux"; fi
    if infocmp tmux-256color >/dev/null 2>&1; then
      ok "terminfo tmux-256color"
    else
      aviso "Falta el terminfo tmux-256color (tmux usará screen-256color) → sudo apt-get install -y ncurses-term"
    fi
  fi
  if ((esencial)); then
    printf '\n'
    aviso "Falta algo esencial (marcado con ✗)."
    return 1
  fi
  printf '\n'
  ok "Todo listo. Abre Neovim con: nvim"
}

# ── Entrada ─────────────────────────────────────────────────────────────────
case "${1:-todo}" in
  todo)
    paso_herramientas
    paso_nvim
    paso_fuente
    paso_tmux
    paso_plugins
    paso_revisar
    ;;
  herramientas|nvim|fuente|tmux|plugins|revisar) "paso_$1" ;;
  *) sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
