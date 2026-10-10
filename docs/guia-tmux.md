# Guía de tmux

tmux divide el terminal en paneles y mantiene todo abierto aunque cierres la ventana: los programas siguen corriendo y vuelves a encontrarlos como los dejaste. Cada atajo de esta guía está comprobado con `tmux/tmux.conf`.

**El prefijo.** Casi todos los atajos de tmux empiezan con `Ctrl+b`. "`prefijo c`" significa: pulsa `Ctrl+b`, suelta, y pulsa `c`.

- **`prefijo ?`** lista todos los atajos (`q` para salir).
- **El mouse funciona**: clic para elegir panel o ventana, arrastrar bordes, rueda para subir en el historial y clic derecho para un menú.

## Contenido

1. [Sesiones](#1-sesiones)
2. [Ventanas](#2-ventanas)
3. [Paneles](#3-paneles)
4. [Copiar y pegar](#4-copiar-y-pegar)
5. [tmux y Neovim juntos](#5-tmux-y-neovim-juntos)
6. [Formas de trabajar](#6-formas-de-trabajar)
7. [Línea de comandos de tmux](#7-línea-de-comandos-de-tmux)
8. [Por SSH](#8-por-ssh)
9. [Windows Terminal](#9-windows-terminal)
10. [Qué hace `tmux.conf`](#10-qué-hace-tmuxconf)
11. [Si algo falla](#11-si-algo-falla)

## 1. Sesiones

Una sesión es un espacio de trabajo completo, con sus ventanas y paneles. Lo habitual es una por proyecto.

| Acción | Cómo |
|---|---|
| Crear una sesión con nombre | `tmux new -s proyecto` |
| Crear una sin nombre | `tmux` |
| Ver las que existen | `tmux ls` |
| Volver a una | `tmux attach -t proyecto` (o `tmux a` para la última) |
| Salir sin cerrar nada | `prefijo d` |
| Cambiar de sesión | `prefijo s` y eliges |
| Renombrar la sesión | `prefijo $` |
| Cerrar una sesión y todo lo que tiene | `tmux kill-session -t proyecto` |

Las sesiones sobreviven a cerrar la pestaña o la ventana de Windows Terminal. No sobreviven a reiniciar Windows ni a `wsl --shutdown`.

## 2. Ventanas

Las ventanas son como pestañas dentro de la sesión. Aparecen en la barra inferior.

| Acción | Teclado | Mouse |
|---|---|---|
| Nueva ventana | `prefijo c` | |
| Siguiente / anterior | `prefijo n` / `prefijo p` | Clic en su nombre |
| Ir a la número N | `prefijo 0` … `prefijo 9` | |
| Volver a la anterior en la que estabas | `prefijo l` | |
| Lista de ventanas, con vista previa | `prefijo w` | |
| Renombrar | `prefijo ,` | Clic derecho en su nombre |
| Cerrar | `prefijo &` | Clic derecho en su nombre |

El nombre que le pongas a una ventana se conserva.

## 3. Paneles

| Acción | Teclado | Mouse |
|---|---|---|
| Dividir lado a lado | `prefijo %` | Clic derecho en un panel de shell |
| Dividir arriba y abajo | `prefijo "` | Clic derecho en un panel de shell |
| Moverse entre paneles | `Ctrl+h` `Ctrl+j` `Ctrl+k` `Ctrl+l`, sin prefijo | Clic |
| Ampliar el panel a toda la ventana, y volver | `prefijo z` | Clic derecho |
| Cambiar el tamaño | `prefijo Ctrl+flechas` (de a 1) o `prefijo Alt+flechas` (de a 5) | Arrastrar el borde |
| Cambiar la distribución | `prefijo Espacio` | |
| Intercambiar con el panel anterior / siguiente | `prefijo {` / `prefijo }` | Clic derecho |
| Convertir el panel en una ventana propia | `prefijo !` | |
| Mostrar el número de cada panel | `prefijo q` | |
| Cerrar el panel | `prefijo x`, o `exit` en el shell | Clic derecho |

En teclado español, `%` es `Shift+5` y `"` es `Shift+2`.

`Ctrl+h/j/k/l` no da la vuelta al llegar a un borde, y no sale de un panel ampliado.

**Cuando la ventana tiene más de un panel**, en los paneles de shell `Ctrl+l` y `Ctrl+k` se usan para moverse. Para enviar la tecla original:

| Quieres | Pulsa |
|---|---|
| Limpiar la pantalla (`Ctrl+l`) | `prefijo Ctrl+l` |
| Borrar hasta el final de la línea (`Ctrl+k`) | `prefijo Ctrl+k` |

Con un solo panel, todas las teclas funcionan como siempre.

## 4. Copiar y pegar

Todo lo que copias en tmux va al portapapeles del sistema: puedes pegarlo en Windows, en Neovim o en otro panel.

### Con el mouse

| Gesto | Resultado |
|---|---|
| Arrastrar | Copia la selección y deja la vista donde está (`q` o `Esc` para volver al final) |
| Doble clic | Copia la palabra |
| Triple clic | Copia la línea |
| Rueda hacia arriba | Recorre el historial; al volver al final se sale solo |
| `Shift`+arrastrar | Selección de Windows Terminal, sin pasar por tmux |

### Con el teclado

El modo copia usa teclas de Vim.

| Paso | Teclas |
|---|---|
| Entrar | `prefijo RePág` (sube una página) o `prefijo [` |
| Moverse | Flechas o `h` `j` `k` `l` · `w` / `b` por palabra · `0` / `$` inicio y fin de línea · `g` / `G` inicio y fin del historial · `Ctrl+u` / `Ctrl+d` media página |
| Buscar | `/texto` hacia abajo, `?texto` hacia arriba; `n` siguiente, `N` anterior |
| Seleccionar | `v` empieza la selección; `V` selecciona la línea |
| Copiar y salir | `y` o `Enter` |
| Salir sin copiar | `q` o `Esc` |

El historial guarda 50.000 líneas por panel.

### Pegar

| Qué | Cómo |
|---|---|
| El portapapeles del sistema | `Ctrl+V` |
| Lo último copiado en tmux | `prefijo ]` |
| Elegir entre copias anteriores | `prefijo =` |

## 5. tmux y Neovim juntos

Las dos configuraciones de este repo están hechas para usarse juntas.

| Qué | Cómo se comporta |
|---|---|
| Moverse | `Ctrl+h/j/k/l` pasa entre divisiones de Neovim y paneles de tmux como si fueran lo mismo. Al llegar al borde de Neovim, sigue hacia el panel vecino. |
| Mouse | Dentro de Neovim, el mouse es de Neovim: menús, documentación al dejar el puntero quieto, arrastrar para seleccionar. En los paneles de shell, es de tmux. |
| Portapapeles | Lo que copias en uno se pega en el otro, y en Windows. |
| Archivos | Al volver al panel de Neovim se recargan los archivos que cambió otro programa. |
| Colores | Color real y subrayado ondulado en los errores, igual que fuera de tmux. |
| Panel ampliado | Con `prefijo z` sobre Neovim, `Ctrl+h/j/k/l` se queda dentro de Neovim. |

Para comprobar que tmux está bien configurado para Neovim: dentro de tmux abre Neovim y ejecuta `:checkhealth vim.health`; la sección `tmux` debe estar en verde.

## 6. Formas de trabajar

**Editor y terminal lado a lado**

```bash
cd ~/projects/mi-proyecto
tmux new -s mi-proyecto
nvim .
```

Luego `prefijo %` abre un shell a la derecha para pruebas y git. `Ctrl+l` y `Ctrl+h` van y vienen. `prefijo z` amplía el editor cuando necesitas espacio.

**Un proceso largo en su propia ventana**

`prefijo c` crea una ventana; ahí lanzas el servidor o el entrenamiento. Con `prefijo n` / `prefijo p` vuelves al editor. Si cierras el terminal, sigue corriendo: `tmux a` lo recupera.

**Varios proyectos**

Una sesión por proyecto (`tmux new -s otro`), y `prefijo s` para saltar entre ellas sin cerrar nada.

**Dentro de Neovim también hay terminal**

Para algo rápido no hace falta un panel de tmux: `Espacio t` abre un terminal dentro de Neovim y `Espacio r` ejecuta el archivo actual. Ver la [guía de Neovim](guia-neovim.md#9-ejecutar-y-terminal).

## 7. Línea de comandos de tmux

`prefijo :` abre una línea para escribir comandos.

| Comando | Para qué |
|---|---|
| `source-file ~/.tmux.conf` | Aplicar cambios de configuración sin reiniciar |
| `setw synchronize-panes on` | Escribir lo mismo en todos los paneles de la ventana (`off` para terminar) |
| `swap-window -t 0` | Mover la ventana actual a la posición 0 |
| `join-pane -s 2` | Traer la ventana 2 como panel de la actual |
| `kill-session` | Cerrar la sesión |

Desde el shell, `tmux kill-server` cierra todas las sesiones.

## 8. Por SSH

- **Copiar funciona**: tmux envía la copia al terminal, así que llega al portapapeles de tu máquina aunque tmux esté en el servidor.
- **Colores en servidores remotos**: dentro de tmux el tipo de terminal es `tmux-256color`, y algunos servidores no lo conocen. Si al conectarte ves avisos o colores rotos:

  ```bash
  TERM=xterm-256color ssh servidor
  ```

  O, una sola vez por servidor, cópiale la definición:

  ```bash
  infocmp -x tmux-256color | ssh servidor tic -x -
  ```

## 9. Windows Terminal

Estos atajos son del terminal, no de tmux, y actúan antes que él:

| Atajo | Acción |
|---|---|
| `Ctrl+V` | Pega el portapapeles de Windows |
| `Ctrl+C` | Copia, solo si hay una selección hecha con `Shift`+arrastrar; si no, interrumpe el programa como siempre |
| `Ctrl+Shift+F` | Busca en el texto del terminal |
| `Alt+Shift+D` | Divide el propio Windows Terminal |

La fuente (JetBrainsMono Nerd Font) se configura en Windows Terminal; `nvim/bootstrap.sh fuente` la instala y la deja por defecto.

## 10. Qué hace `tmux.conf`

| Ajuste | Efecto |
|---|---|
| `mouse on` | Mouse en paneles, bordes y barra |
| `history-limit 50000` | Historial largo por panel |
| `allow-rename off` | Las ventanas conservan su nombre |
| `escape-time 0` | `Esc` responde al instante (importante para Neovim) |
| `focus-events on` | Neovim sabe cuándo vuelves a su panel |
| `default-terminal tmux-256color` | Tipo de terminal correcto; usa `screen-256color` si la máquina no lo conoce |
| `terminal-features …RGB:usstyle` | Color real y subrayados con estilo |
| `set-clipboard on` y `copy-command` | Copia al portapapeles del sistema; el programa se elige solo según la plataforma (`win32yank`, `pbcopy`, `wl-copy`, `xclip`) |
| `mode-keys vi` | Teclas de Vim en el modo copia |
| `Ctrl+h/j/k/l` | Navegación compartida con Neovim |

Requiere tmux 3.2 o superior.

## 11. Si algo falla

| Síntoma | Qué hacer |
|---|---|
| Cambié `tmux.conf` y no pasa nada | `tmux source-file ~/.tmux.conf` |
| Colores raros dentro de tmux | Cierra todo con `tmux kill-server` y vuelve a entrar: el tipo de terminal se fija al crear cada panel |
| Lo copiado no llega a Windows | `tmux show -s copy-command` debe mostrar un programa; si está vacío, `nvim/bootstrap.sh herramientas` |
| `Ctrl+l` no limpia la pantalla | Hay más de un panel: usa `prefijo Ctrl+l` |
| `Ctrl+h/j/k/l` no cruza hacia o desde Neovim | Comprueba que `~/.tmux.conf` apunta al repo: `nvim/bootstrap.sh revisar` |
| Avisos al cargar la configuración | tmux anterior a 3.2: `tmux -V` |
