# Guía de Neovim

Todo lo que ofrece esta configuración y cómo aprovecharlo. Cada atajo de esta guía está comprobado contra `nvim/init.lua`.

- **`Espacio`** es la tecla líder. Si la pulsas y esperas un instante, aparece la lista de lo que puedes hacer a continuación.
- **`Espacio f a`** busca entre todos los atajos por nombre.
- **Clic derecho** en cualquier parte muestra las acciones disponibles en ese lugar.

Con esas tres cosas no hace falta memorizar nada; el resto de la guía es para ir más rápido.

## Contenido

1. [Arrancar y salir](#1-arrancar-y-salir)
2. [Mouse](#2-mouse)
3. [Árbol de archivos](#3-árbol-de-archivos)
4. [Buscar](#4-buscar)
5. [Pestañas y divisiones](#5-pestañas-y-divisiones)
6. [Editar](#6-editar)
7. [Código: definiciones, errores y autocompletado](#7-código-definiciones-errores-y-autocompletado)
8. [Formato](#8-formato)
9. [Ejecutar y terminal](#9-ejecutar-y-terminal)
10. [Python con uv](#10-python-con-uv)
11. [TypeScript y JavaScript](#11-typescript-y-javascript)
12. [Git](#12-git)
13. [Markdown](#13-markdown)
14. [Ajustes rápidos](#14-ajustes-rápidos)
15. [Mantenimiento](#15-mantenimiento)
16. [Si algo falla](#16-si-algo-falla)

## 1. Arrancar y salir

| Comando | Qué abre |
|---|---|
| `nvim` | El árbol a la izquierda y un archivo vacío |
| `nvim .` o `nvim carpeta` | Esa carpeta en el árbol, con el foco en él |
| `nvim archivo.py` | El archivo, con el árbol al lado |

Abre Neovim desde la raíz del proyecto: así los buscadores, `uv` y los servidores de lenguaje encuentran todo.

| Acción | Cómo |
|---|---|
| Guardar | `Ctrl+S` o `Espacio w` |
| Cerrar el archivo actual | `Espacio x`, o la × de su pestaña |
| Salir | `:q` (una ventana) o `:qa` (todo) |

Si hay cambios sin guardar, Neovim pregunta en vez de fallar. Al reabrir un archivo vuelves a la línea donde estabas y puedes seguir deshaciendo cambios de sesiones anteriores.

Si otro programa modifica un archivo abierto (por ejemplo Claude Code), se recarga solo al volver a la ventana.

## 2. Mouse

| Gesto | Resultado |
|---|---|
| Clic | Mueve el cursor o cambia de ventana |
| Arrastrar | Selecciona |
| Doble clic / triple clic | Selecciona la palabra / la línea |
| Clic derecho | Menú de acciones según el lugar (ver abajo) |
| Clic central | Pega |
| Rueda | Desplaza |
| `Ctrl`+clic | Va a la definición del símbolo |
| Dejar el puntero quieto sobre un símbolo | Muestra su documentación y, si lo hay, el error de esa posición |
| Arrastrar la barra de la derecha | Se mueve por el archivo; las marcas de color indican errores y resultados de búsqueda |
| Clic en la columna de pliegues (junto a los números) | Pliega o despliega el bloque |
| Arrastrar el borde entre dos divisiones | Cambia su tamaño |
| `Shift`+arrastrar | Selección propia de Windows Terminal, por si necesitas copiar algo tal como se ve |

**Botones arriba a la derecha de cada ventana:** dividir en vertical, dividir en horizontal y cerrar.

**Pestañas:** clic para cambiar, × o clic central para cerrar, clic derecho para más opciones.

**Barra de estado (abajo):**

| Clic en | Abre |
|---|---|
| El nombre de la rama | Lista de ramas de git |
| Los contadores de cambios (+ ~ −) | Archivos modificados |
| Los contadores de errores | Lista de problemas del archivo |
| `auto` / `manual` | Cambia cuándo se formatea al guardar |

### Menús de clic derecho

| Dónde | Acciones |
|---|---|
| Código | Ir a definición · Ver referencias · Renombrar símbolo · Acciones de código · Ver documentación · Ver problema de esta línea · Formatear documento · Cortar / Copiar / Copiar línea / Pegar / Seleccionar todo · Dividir a la derecha / abajo · Cerrar división · Buscar archivo / texto · Comentar · Ejecutar archivo |
| Árbol de archivos | Abrir · Abrir en división vertical / horizontal · Nuevo archivo o carpeta · Renombrar · Eliminar · Copiar / Cortar / Pegar · Copiar ruta · Buscar en el árbol · Filtrar lo visible · Buscar texto en esta carpeta · Usar esta carpeta como raíz · Subir la raíz un nivel · Contraer todo · Actualizar |
| Una pestaña | Cerrar · Cerrar las demás · Abrir en división vertical / horizontal · Copiar ruta |
| Terminal | Pegar · Cerrar terminal |

Las acciones de código solo aparecen cuando el lenguaje del archivo las ofrece.

## 3. Árbol de archivos

`Espacio e` lo muestra u oculta. Sigue al archivo que tienes abierto.

| Acción | Tecla | Mouse |
|---|---|---|
| Abrir archivo, o abrir/cerrar carpeta | `Enter` | Doble clic |
| Abrir en división vertical / horizontal | `v` / `h` | Clic derecho |
| Vista previa sin salir del árbol | `Tab` | |
| **Buscar en todas las subcarpetas** | `/` | Clic derecho |
| Filtrar lo que ya se ve / quitar el filtro | `f` / `F` | Clic derecho |
| Crear archivo (termina en `/` para crear carpeta) | `a` | Clic derecho |
| Renombrar | `r` | Clic derecho |
| Eliminar | `d` | Clic derecho |
| Copiar / cortar / pegar | `c` / `x` / `p` | Clic derecho |
| Copiar nombre / ruta relativa / ruta completa | `y` / `Y` / `gy` | Clic derecho (ruta completa) |
| Información del archivo (tamaño, fechas) | `i` | |
| Mostrar u ocultar archivos que empiezan con punto | `H` | |
| Mostrar u ocultar lo que ignora git | `I` | |
| Expandir todo / contraer todo | `E` / `W` | Clic derecho (contraer) |
| Subir la raíz una carpeta | `-` | Clic derecho |
| Usar una carpeta como raíz | | Clic derecho |
| Actualizar | `R` | Clic derecho |
| Todos los atajos del árbol | `g?` | |

Para trabajar con varios archivos a la vez: márcalos con `m` y luego `bmv` los mueve o `bd` los elimina.

Los nombres cambian de color según su estado en git, y los iconos al lado indican: `✗` modificado, `✓` preparado, `★` nuevo, `➜` renombrado.

## 4. Buscar

| Qué | Atajo |
|---|---|
| Un archivo por nombre | `Ctrl+P` o `Espacio f f` |
| Un texto en todo el proyecto | `Espacio f g` |
| Entre los archivos abiertos | `Espacio f b` |
| Archivos recientes | `Espacio f r` |
| Un atajo | `Espacio f a` |
| Un texto dentro de una carpeta concreta | Clic derecho sobre la carpeta en el árbol |
| Dentro del archivo actual | `Ctrl+F`, escribes y `Enter`; `n` siguiente, `N` anterior, `Esc` quita el resaltado |
| La palabra bajo el cursor en el archivo | `*` |

Los buscadores muestran archivos ocultos (`.env`, `.gitignore`) pero dejan fuera `.git`, `.venv`, `node_modules` y cachés.

**Dentro de un buscador:**

| Tecla | Acción |
|---|---|
| Escribir | Filtra; no hace falta escribir el nombre exacto ni completo |
| `↑` `↓` | Moverse por los resultados |
| `Enter` | Abrir |
| `Alt+V` / `Ctrl+S` | Abrir en división vertical / horizontal |
| `Tab` | Marcar varios resultados |
| `Ctrl+Q` | Enviar los resultados a una lista para recorrerlos después |
| `Ctrl+F` / `Ctrl+B` | Desplazar la vista previa |
| `Alt+P` | Mostrar u ocultar la vista previa |
| `Alt+H` / `Alt+I` | Incluir ocultos / incluir lo que ignora git |
| `Esc` (dos veces) o `Ctrl+C` | Cerrar |
| `Esc` y luego `?` | Ver todas las teclas del buscador |

Con el mouse: doble clic en un resultado lo abre.

Hay más buscadores que no tienen atajo: `:lua Snacks.picker()` los lista todos (ayuda de Neovim, historial de comandos, historial de deshacer, registro de git, entre otros).

**Reemplazar:** `:%s/viejo/nuevo/g` reemplaza en todo el archivo y muestra el resultado mientras escribes. Agrega `c` al final (`/gc`) para confirmar uno por uno.

## 5. Pestañas y divisiones

Cada archivo abierto es una pestaña en la barra superior.

| Acción | Atajo |
|---|---|
| Pestaña siguiente / anterior | `Tab` / `Shift+Tab` |
| Cerrar la pestaña | `Espacio x` |
| Elegir entre los abiertos | `Espacio f b` |
| Dividir en vertical (a la derecha) | `Espacio v` |
| Dividir en horizontal (abajo) | `Espacio h` |
| Cerrar la división | `Espacio q` |
| Moverse entre divisiones | `Ctrl+h` `Ctrl+j` `Ctrl+k` `Ctrl+l` (izquierda, abajo, arriba, derecha) |
| Igualar tamaños | `Ctrl+w` y luego `=` |
| Dejar solo la división actual | `Ctrl+w` y luego `o` |

Cerrar una pestaña no desarma las divisiones: la ventana pasa a mostrar otro archivo.

Dentro de tmux, `Ctrl+h/j/k/l` también pasa a los paneles vecinos. Ver la [guía de tmux](guia-tmux.md#5-tmux-y-neovim-juntos).

## 6. Editar

### Seleccionar

| Acción | Cómo |
|---|---|
| Con el mouse | Arrastrar, doble clic (palabra), triple clic (línea) |
| Con el teclado | `Shift+flechas`; una flecha sola termina la selección |
| Todo el archivo | `Ctrl+A` |
| Por líneas completas | `V` y luego `j` / `k` |
| En bloque (columna) | `Ctrl+Q` y luego `h` `j` `k` `l` |

### Copiar y pegar

Neovim comparte el portapapeles con Windows: lo que copias aquí se pega en cualquier programa, y al revés.

| Acción | Cómo |
|---|---|
| Copiar / cortar la selección | `Ctrl+C` / `Ctrl+X`, o `y` / `d` |
| Pegar | `Ctrl+V`, `p`, clic central o clic derecho |
| Copiar la línea actual | `yy`, o clic derecho → Copiar línea |
| Copiar el archivo entero | `Espacio y` |

En Windows Terminal, `Ctrl+V` lo hace el propio terminal. Por eso la selección en bloque es `Ctrl+Q` y no `Ctrl+V` como en otros Vim.

### Modificar

| Acción | Cómo |
|---|---|
| Deshacer / rehacer | `Ctrl+Z` / `Ctrl+Y` (o `u` / `Ctrl+R`) |
| Mover la línea o la selección | `Alt+k` / `Alt+j`, o `Alt+↑` / `Alt+↓` si el terminal las deja pasar |
| Indentar / quitar indentación de la selección | `Tab` / `Shift+Tab` |
| Comentar la línea / la selección | `gcc` / `gc`, o clic derecho |
| Plegar o desplegar un bloque | Clic en la columna de pliegues, o `za` |
| Desplegar todo / plegar todo | `zR` / `zM` |

Los paréntesis, corchetes y comillas se cierran solos.

## 7. Código: definiciones, errores y autocompletado

Funciona en Python, TypeScript y JavaScript. La barra de estado muestra qué servidores de lenguaje están activos en el archivo.

### Navegar

| Acción | Teclado | Mouse |
|---|---|---|
| Ir a la definición | `F12` o `gd` | `Ctrl`+clic, o clic derecho |
| Volver adonde estabas | `Ctrl+O` | |
| Ver dónde se usa (referencias) | `Espacio c u` | Clic derecho |
| Símbolos del archivo (funciones, clases) | `Espacio c s` | |
| Ver la documentación | `K` | Puntero quieto, o clic derecho |

### Cambiar

| Acción | Teclado | Mouse |
|---|---|---|
| Renombrar en todo el proyecto | `F2` | Clic derecho |
| Acciones de código (importar, corregir, organizar imports) | `Espacio c a` | Clic derecho |

### Errores y avisos

Aparecen subrayados, con un icono en el margen y el mensaje al final de la línea.

| Acción | Cómo |
|---|---|
| Ver el mensaje completo | `Espacio c d`, puntero quieto, o clic derecho |
| Lista de problemas del archivo | `Espacio c l`, o clic en los contadores de la barra de estado |
| Mostrar los tipos deducidos junto al código | `Espacio o h` |

### Autocompletado

Aparece solo mientras escribes.

| Tecla | Acción |
|---|---|
| `Tab` o `Enter` | Aceptar la sugerencia |
| `↑` `↓` | Elegir otra |
| `Ctrl+Espacio` | Abrir el menú a mano; si ya está abierto, mostrar u ocultar la documentación |
| `Ctrl+E` | Cerrar el menú |
| `Ctrl+F` / `Ctrl+B` | Desplazar la documentación |
| `Ctrl+K` | Mostrar u ocultar la ayuda de parámetros |

Al abrir el paréntesis de una función aparecen sus parámetros.

## 8. Formato

| Acción | Cómo |
|---|---|
| Formatear ahora | `Espacio c f`, o clic derecho → Formatear documento |
| Cambiar cuándo se formatea al guardar | `Espacio o f`, o clic en `auto` / `manual` en la barra de estado |

Python se formatea con `ruff`; TypeScript, JavaScript, JSON, CSS, HTML, YAML y Markdown con Prettier (o Biome si el proyecto lo usa).

Al guardar hay tres modos, que se alternan con `Espacio o f`:

| Modo | Comportamiento |
|---|---|
| Según el proyecto (por defecto) | Solo formatea si el proyecto lo configura: `[tool.ruff]` en `pyproject.toml`, `ruff.toml`, configuración de Prettier o Biome, o Prettier en `package.json` |
| Siempre | Formatea en cada guardado con los valores por defecto de la herramienta |
| Nunca | Solo cuando lo pides |

La barra de estado dice `auto` cuando el archivo actual se formateará al guardar y `manual` cuando no.

## 9. Ejecutar y terminal

| Acción | Atajo |
|---|---|
| Ejecutar el archivo actual | `Espacio r`, o clic derecho → Ejecutar archivo |
| Mostrar u ocultar el terminal | `Espacio t` |

`Espacio r` guarda el archivo y lo ejecuta en un panel inferior: Python con `uv run`, JavaScript y TypeScript con `node` (o `tsx` si el proyecto lo tiene instalado), y scripts de shell con `bash`. Cuando el programa termina, la salida queda a la vista y cualquier tecla cierra el panel. Volver a ejecutar reemplaza el panel anterior.

**Dentro del terminal:**

| Acción | Cómo |
|---|---|
| Volver al archivo | Clic en él |
| Pasar a modo normal (para moverse o copiar texto) | `Esc` dos veces |
| Ocultar el terminal desde modo normal | `Espacio t` |
| Pegar | `Ctrl+V` o clic derecho |

El terminal conserva lo que estaba haciendo aunque lo ocultes.

## 10. Python con uv

- **`ruff`** marca problemas de estilo y errores comunes, y formatea.
- **`basedpyright`** revisa tipos y da autocompletado, documentación y navegación.
- Ambos se instalan solos con `uv tool install` la primera vez.
- Si el proyecto tiene `.venv` (lo crea `uv sync`), se usa ese intérprete: los imports de tus dependencias se resuelven sin activar nada.

| Acción | Cómo |
|---|---|
| Ejecutar el archivo | `Espacio r` (`uv run archivo.py`) |
| Sincronizar dependencias | `Espacio p s` (`uv sync`) |
| Agregar un paquete | `Espacio p a` y escribes el nombre |
| Cualquier otro comando de uv | `:Uv …`, por ejemplo `:Uv run pytest`, `:Uv remove requests`, `:Uv tree` |

Los comandos `:Uv` se ejecutan en la raíz del proyecto, no importa en qué subcarpeta esté el archivo.

Después de agregar un paquete, si el editor aún marca el import como no resuelto: `:lsp restart`.

## 11. TypeScript y JavaScript

- El servidor de lenguaje se elige solo según el TypeScript del proyecto: **`vtsls`** para TypeScript 5 y 6, y el servidor nativo (**`tsc`**) para TypeScript 7.
- **ESLint** se activa únicamente en proyectos que tienen su configuración.
- **Prettier** formatea al guardar solo donde el proyecto lo configura (ver [Formato](#8-formato)).

Sobre un error, `Espacio c a` ofrece las correcciones disponibles: por ejemplo, agregar el import que falta o aplicar el arreglo que propone ESLint.

## 12. Git

Las líneas agregadas, cambiadas o borradas se marcan en el margen izquierdo, y la barra de estado muestra la rama y el resumen de cambios.

| Acción | Atajo |
|---|---|
| Ver el cambio de esta línea (antes y después) | `Espacio g p` |
| Deshacer ese cambio | `Espacio g r` |
| Quién cambió esta línea y cuándo | `Espacio g b` |
| Ir al cambio siguiente / anterior | `Espacio g n` / `Espacio g N` |
| Ramas | Clic en la rama, en la barra de estado |
| Archivos modificados | Clic en los contadores de cambios |

Estos atajos solo existen dentro de un repositorio git.

## 13. Markdown

Los archivos `.md` se muestran con formato dentro del editor: títulos, listas, tablas y bloques de código. Al poner el cursor en una línea se ve su texto original para editarlo.

| Acción | Cómo |
|---|---|
| Vista previa en el navegador, que se actualiza al escribir | `Espacio m` |
| Activar o desactivar el formato dentro del editor | `:RenderMarkdown toggle` |

## 14. Ajustes rápidos

Al inicio de `nvim/init.lua` está la tabla `OPC`. Cambia el valor, guarda y reinicia Neovim.

| Opción | Para qué |
|---|---|
| `nerd_font` | Ponla en `false` si el terminal no tiene una Nerd Font: usa texto en lugar de iconos |
| `formato_al_guardar` | Modo inicial: `'proyecto'`, `'siempre'` o `'nunca'` |
| `hover_mouse` | Documentación al dejar el puntero quieto |
| `arbol_al_abrir` | Mostrar el árbol al arrancar |
| `portapapeles_automatico` | Con `false`, `y`, `d` y `p` dejan de usar el portapapeles del sistema; quedan `Ctrl+C/X/V` y el menú |
| `python_lsp` | `'basedpyright'` o `'ty'` |

Interruptores sin editar el archivo:

| Atajo | Cambia |
|---|---|
| `Espacio o f` | Formato al guardar |
| `Espacio o h` | Tipos deducidos junto al código |
| `Espacio o w` | Ajuste de líneas largas |

## 15. Mantenimiento

| Tarea | Cómo |
|---|---|
| Actualizar plugins | `:Lazy update`, y después guardar `nvim/lazy-lock.json` en git |
| Volver a las versiones guardadas | `:Lazy restore` |
| Ver o instalar servidores de lenguaje | `:Mason` |
| Actualizar las herramientas de Python | `uv tool upgrade --all` en la terminal |
| Agregar resaltado para otro lenguaje | `:TSInstall nombre` |
| Reiniciar el servidor de lenguaje | `:lsp restart` |
| Ver qué formateador se usará | `:ConformInfo` |
| Revisar la instalación completa | `nvim/bootstrap.sh revisar` en la terminal |

## 16. Si algo falla

| Síntoma | Qué revisar |
|---|---|
| Iconos como cuadros | La fuente del terminal no es una Nerd Font: `nvim/bootstrap.sh fuente` y reinicia el terminal |
| Sin colores de sintaxis en Python o TypeScript | Falta el compilador o `tree-sitter`: `nvim/bootstrap.sh revisar` |
| Sin autocompletado ni errores | `:checkhealth vim.lsp` y `:Mason`; en Python, confirma que `uv` está instalado |
| Imports de Python marcados como no resueltos | Falta `.venv`: `:Uv sync` y luego `:lsp restart` |
| No formatea al guardar | Mira si la barra dice `manual`; cambia el modo con `Espacio o f` o usa `Espacio c f` |
| Copiar o borrar se siente lento | Pon `portapapeles_automatico = false` en `OPC` |
| Un aviso desapareció antes de leerlo | `:lua Snacks.notifier.show_history()` |
| Diagnóstico general | `:checkhealth` |
