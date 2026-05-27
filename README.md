# Himnario ICE - Iglesia Cristiana Evangelica

App movil para Android (y iOS) con los 517 himnos del Himnario de la Iglesia Cristiana Evangelica. Desarrollada en Flutter como puerto moderno de la app original en Kotlin/Android.

---

## Funcionalidades

### Busqueda de himnos
- Busca por **numero** (1 al 517) o por cualquier parte del **titulo**.
- Los resultados aparecen en tiempo real mientras escribes.
- Cada resultado muestra el numero, titulo y el versiculo biblico asociado al himno.
- Los himnos marcados como favorito muestran una estrella dorada en la lista.

### Lectura del himno
- Letras con formato completo: estrofas, coro intercalado y repeticiones segun el original.
- Fragmentos en **negrita e italica** donde el himnario los indica.
- Navegacion con botones **Anterior / Siguiente** para recorrer el himnario sin volver a buscar.
- Contador de posicion visible (`42 / 517`).

### Versiculos biblicos integrados
- Cada himno puede tener uno o varios versiculos de referencia.
- Toca el versiculo para ver el texto completo directamente dentro de la app.
- La Biblia completa **Reina-Valera 1960** esta incluida como recurso, sin necesidad de conexion a internet.
- Soporta referencias simples (`Juan 3:16`), rangos (`Salmos 23:1-4`) y multiples citas en un mismo himno.

### Favoritos
- Marca cualquier himno con la estrella desde la pantalla de lectura.
- Accede a todos tus favoritos desde el boton de estrella en la pantalla principal.
- El estado de favorito se actualiza de inmediato en la lista y se persiste entre sesiones.

### Compartir
- Desde cualquier himno, comparte la letra completa (con formato de texto limpio) a cualquier app instalada: WhatsApp, Telegram, correo, notas, etc.
- Desde Configuracion puedes compartir la app con otros miembros de tu congregacion.

### Configuracion de lectura
- **Tamano de letra**: deslizador de 12 pt a 26 pt con indicador en tiempo real.
- **Color del texto**: seis opciones — Negro, Grafito, Indigo, Caoba, Bosque, Vino.
- **Color de fondo**: seis opciones — Blanco, Perla, Crema, Menta, Celeste, Rosa.
- **Vista previa en vivo**: ve el resultado exacto con un himno real antes de confirmar.
- Boton para restablecer todos los valores al estado predeterminado.
- Las preferencias se guardan y persisten entre sesiones.

### Diseno
- Interfaz Material 3 con tema indigo.
- Adaptada a distintos tamanos de pantalla.
- Respeta los paddings del sistema (notch, barra de navegacion).

---

## Beneficios

- **Sin internet**: los 517 himnos y la Biblia completa estan incluidos en la app. Funciona en reuniones, retiros o zonas sin cobertura.
- **Rapida**: base de datos SQLite local, busqueda instantanea sin latencia de red.
- **Biblica**: cada himno esta vinculado a su versiculo de referencia y puedes leer el texto completo con un toque.
- **Personalizable**: ajusta el tamano y los colores para leer con comodidad en cualquier condicion de luz.
- **Congregacional**: comparte letras directamente con otros miembros desde la app.
- **Sin anuncios ni pagos**: app limpia y directa.

---

## Requisitos

- Flutter 3.x / Dart 3.10+
- Android 5.0 (API 21) o superior
- iOS 12 o superior

---

## Instalacion y desarrollo

```bash
# Instalar dependencias
flutter pub get

# Correr en dispositivo/emulador
flutter run

# Compilar APK de debug
flutter build apk

# Compilar APK de release
flutter build apk --release

# Analisis estatico
flutter analyze

# Tests
flutter test
```

---

## Arquitectura

| Capa | Archivos |
|------|----------|
| Pantallas | `lib/screens/` — `main_screen.dart`, `busqueda_screen.dart`, `favoritos_screen.dart`, `settings_screen.dart` |
| Estado (BLoC) | `lib/blocs/` — search, hymno, favoritos, settings |
| Servicios | `lib/services/` — `database_service.dart`, `bible_service.dart`, `settings_service.dart` |
| Modelo | `lib/models/himno.dart` |
| Recursos | `assets/dbHimnosEstructuraCompleta.db`, `assets/SpanishRVR1960Bible.xml` |

Estado manejado con `flutter_bloc`. No hay llamadas de red; toda la data viene de assets locales. La base de datos SQLite se copia al almacenamiento interno del dispositivo en el primer arranque.

---

## Dependencias principales

| Paquete | Uso |
|---------|-----|
| `sqflite` | Base de datos de himnos |
| `flutter_bloc` | Gestion de estado |
| `shared_preferences` | Persistencia de configuracion |
| `share_plus` | Compartir letras y la app |
| `xml` | Parseo de la Biblia RVR1960 |
| `firebase_crashlytics` | Reporte de errores en produccion |
