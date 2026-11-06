# Cómo maneja la app las Biblias (guía para replicarlo en otra app)

Este documento describe cómo se almacenan, cargan y muestran las Biblias de `assets/bible/`
en esta app (Flutter). Está pensado para copiar las mismas carpetas a otra app y reutilizar
el mismo esquema sin reinventar nada.

> Nota: este `README.md` está directamente en `assets/bible/`, y `pubspec.yaml` declara solo las
> subcarpetas (`assets/bible/RVR1960/`, etc.), así que **no se empaqueta dentro de la app**.

---

## 1. Qué hay en la carpeta

```
assets/bible/
  RVR1960/   NVI/   NTV/   DHH/   TLA/   PDT/   BDO/      <- una carpeta por versión (ID corto)
    meta.txt        copyright de la versión (una línea)
    1.txt … 66.txt  un archivo por libro (1 = Génesis … 66 = Apocalipsis)
```

- 7 versiones en español, ~4 MB cada una, ~29 MB en total sin comprimir.
- Un libro pesa entre ~1.6 KB (libros cortos) y ~190 KB (Génesis, el más grande que medí). No medí
  Salmos, pero es del mismo orden.
- La numeración de libros es la canónica protestante, 1 a 66 (la misma de los XML de origen).

### Formato de cada libro (`<n>.txt`)

Texto plano UTF-8, saltos de línea `\n`:

```
#1
1<TAB>En el principio era el Verbo, y el Verbo era con Dios, y el Verbo era Dios.
2<TAB>Este era en el principio con Dios.
...
#2
1<TAB>...
```

- `#<capítulo>` abre un capítulo.
- Cada versículo es `<número>` + tabulador + `<texto>`, una línea por versículo.
- El texto ya viene limpio: espacios colapsados, sin etiquetas XML, sin saltos internos.

`meta.txt` es una sola línea con el copyright. Ejemplo: `Texto bíblico Reina-Valera 1960® © Sociedades Bíblicas…`

---

## 2. Cómo se generaron (y por qué ese formato)

Los orígenes son XML (`tools/bible_xml/Spanish<ID>Bible.xml`, ~4-5 MB cada uno). El script
`tools/convert_bible.py` los convierte **una sola vez, en tiempo de desarrollo** al formato de arriba.

Antes la app parseaba el XML completo en el dispositivo; el cambio a un archivo por libro es la
optimización principal: **la app solo lee el libro que se está leyendo** (~100 KB) en lugar de
parsear ~5 MB de XML.

Reglas de limpieza que aplica el conversor (importantes si se agrega otra versión):

| Caso | Qué hace |
|---|---|
| BOM al inicio del XML | Se lee con `utf-8-sig` |
| Capítulos "de más" (la NVI trae capítulos extra en Isaías) | Se ignoran los capítulos fuera del rango del catálogo |
| Versículos con número real distinto del orden (TLA) | Usa el atributo `number` del XML; si falta, el orden |
| Espacios/saltos raros dentro del versículo | `' '.join(texto.split())` |
| Copyright | Sale del atributo `status` o `info` de la raíz del XML |

El script valida que cada versión genere exactamente 66 libros (`assert count == 66`).
El catálogo (cantidad de capítulos por libro) se lee de `lib/data/bible_books.dart` con una regex,
así que ese archivo es la fuente de verdad.

Para regenerar: `python tools/convert_bible.py`.

---

## 3. Cómo se cargan en la app (lo que da la velocidad)

Tres capas:

```
BibleService  ->  BibleManager  ->  BibleReaderProvider (UI)
(lee + parsea)    (caché + dedupe)   (estado de lectura)
```

### 3.1 `BibleService` — lectura y parseo de UN libro

- Usa `rootBundle.loadString('assets/bible/<ID>/<n>.txt')`.
- `parseBibleBook(book, content)` recorre las líneas una vez: `#N` cambia de capítulo, el resto se
  separa por el primer tabulador. No usa regex ni XML.
- Devuelve `List<List<BibleVerse>>` donde el índice es `capítulo - 1`.
- Los capítulos que faltan quedan como lista vacía; los que exceden el catálogo se ignoran.
- El copyright se lee aparte (`meta.txt`) y **una sola vez por versión**. Si falla devuelve `''`.

### 3.2 `BibleManager` — caché en memoria y carga sin duplicados

- **Carga perezosa por libro:** nunca se carga la Biblia entera. Se abre el libro que se lee.
- **Caché por versión:** `Map<String, BibleTextModel>` donde cada modelo guarda
  `books: Map<int, List<List<BibleVerse>>>`. Lo ya cargado se queda en memoria, así cambiar de
  versión, comparar y volver **no vuelve a leer** el archivo.
- **Sin cargas duplicadas:** `_loading` guarda el `Future` en curso por clave `"<versión>:<libro>"`.
  Si dos partes de la UI piden el mismo libro a la vez, comparten la misma carga.
  - Gotcha real: el callback de `whenComplete(() { _loading.remove(key); })` **no debe devolver el
    Future** (si lo devolviera, `whenComplete` lo esperaría). Está comentado en el código.
- **Precarga en segundo plano:** `preloadBooks(version, libros)` carga libros sueltos (los de los
  marcadores) sin bloquear la pantalla; ignora los que fallen.
- **Comparar versiones:** `loadVerses(version, libro, capítulo, desde, hasta)` carga solo ese libro
  de esa otra versión y filtra el rango.
- Los errores se reportan a Crashlytics y se devuelven como `ManagerResult` (nunca excepción hacia la UI).

### 3.3 `BibleReaderProvider` — estado del lector

- **Primera carga:** `init()` restaura versión, libro, capítulo y tamaño de letra desde
  `SharedPreferences` (`BIBLE_VERSION`, `BIBLE_BOOK`, `BIBLE_CHAPTER`, `BIBLE_FONT_SIZE`) y carga
  solo ese libro. Mientras tanto muestra un spinner (`isLoading`).
- **Cambio de capítulo dentro del mismo libro:** instantáneo, ya está en memoria.
- **Salto a otro libro (`goTo`):** si no está cargado se lee antes de mostrarlo (milisegundos). Primero
  se actualiza la pantalla y **después** se guarda la posición en `SharedPreferences` (sin `await`),
  para no demorar el render.
- **Cambio de versión (`setVersion`):** el texto actual **sigue visible** (`isSwitching` solo muestra
  una barra fina) hasta que llega el de la nueva versión. Mantiene capítulo, scroll y selección. Si la
  nueva versión falla, se queda en la anterior.
- **Marcadores:** se indexan en un `Map` por clave `"libro:capítulo:versículo"` para que el `build`
  consulte cada versículo en O(1) (antes recorría toda la lista por cada versículo). El índice se
  recalcula solo cuando cambia la lista.

---

## 4. Cómo se dibuja un capítulo

- Un capítulo (máx. 176 versículos, Salmos 119) se arma con **`SingleChildScrollView` + `Column`**, no con
  `ListView`.
  - Motivo: `ListView(children: …)` solo construye lo visible, y para saltar a un versículo
    (`Scrollable.ensureVisible` con una `GlobalKey` por versículo) el widget tiene que existir. Con la
    columna completa el scroll al versículo siempre funciona y se sigue viendo todo el capítulo.
  - Con ≤176 versículos de texto el costo es bajo.
- Las `GlobalKey` de versículos son por `"libro:capítulo:versículo"` y se podan al cambiar de capítulo,
  porque durante la animación de cambio conviven dos páginas.
- Cada capítulo es una página con `AnimatedSwitcher` (deslizamiento + fundido de ~280 ms). Entra desde el
  lado del gesto; en saltos entre libros solo se funde.
- Lo ya leído se resalta con un fondo (tipo marcador) y los marcadores llevan un ícono; ambos se
  consultan por versículo sin recorrer listas.

---

## 5. Checklist para replicarlo en otra app

1. Copiar las carpetas `assets/bible/<ID>/` completas (incluido `meta.txt`).
2. Declarar **cada** carpeta en `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/bible/RVR1960/
       - assets/bible/NVI/
       # …una línea por versión
   ```
   (Flutter no incluye subcarpetas automáticamente; hay que listar cada una.)
3. Copiar el catálogo de libros (`BibleCatalog`: número, nombre, cantidad de capítulos) y las versiones
   (`BibleVersion`: id, nombre corto, nombre, `folder`).
4. Copiar `parseBibleBook` + `BibleService`, el modelo (`BibleVerse`, `BibleTextModel`) y `BibleManager`.
5. Mantener estas tres reglas, que son las que dan la velocidad:
   - **Nunca** cargar la Biblia entera: un libro a la vez.
   - **Cachear en memoria** por `versión → libro` y deduplicar cargas concurrentes con un mapa de `Future`.
   - **Guardar la posición después de renderizar**, no antes.
6. Mostrar el capítulo con todos los versículos construidos si se necesita saltar a uno concreto.
7. Si se agrega otra versión: poner el XML en `tools/bible_xml/`, registrarla en `VERSIONS` de
   `convert_bible.py`, regenerar y declararla en `pubspec.yaml`.

---

## 6. Ideas de optimización pendientes (no implementadas, no medidas)

Todo lo anterior es lo que la app hace hoy. Estas son ideas, **no las probé ni las medí**:

- **Parseo fuera del hilo principal:** `loadString` + `parseBibleBook` corren en el isolate principal.
  Con ~100-190 KB por libro no se nota, pero se podría mover a `compute()` si se quisiera cero jank.
- **Precargar el libro siguiente/anterior** cuando el usuario está cerca del final/inicio de un libro,
  para que el cruce de libro sea siempre instantáneo.
- **Liberar versiones que no se usan** de la caché si la memoria preocupa (hoy nada se descarta durante la sesión).
- **Tamaño de la app:** ~29 MB de texto plano; Android lo comprime en el AAB/APK, pero no medí cuánto.
  Si pesa, evaluar incluir solo las versiones más usadas o descargar el resto bajo demanda.
- **Índice de búsqueda por texto:** la app hoy busca por libro y referencia (ej. "Jn 3:16"), no por
  palabras dentro del texto.
