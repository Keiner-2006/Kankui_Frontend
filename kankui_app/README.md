# Kankui App

**Aplicación etnoeducativa para la recuperación y enseñanza de la lengua Kankuamo (Kankui)**

---

## 📖 Descripción

Kankui App es una plataforma de aprendizaje móvil diseñada para la **recuperación de la lengua Kankuamo**, lengua ancestral del pueblo indígena Kankuamo, asentado en la Sierra Nevada de Santa Marta, Colombia. Desarrollada para la **I.E. Indígena de Atánquez**, esta aplicación permite a estudiantes y docentes interactuar con el vocabulario, la cultura y la cosmovisión Kankuamo a través de una experiencia gamificada, offline-first y enriquecida con elementos multimedia.

> *"Sewa"* — Gracias en lengua Kankui.

---

## ✨ Características Principales

### Para Estudiantes
- **Lecciones interactivas** con tarjetas de vocabulario (flashcards), pronunciación en audio y descripciones culturales
- **Sistema de gamificación** — Gana experiencia (XP), sube niveles en el *Círculo de Sabiduría*, desbloquea logros y mantén rachas de estudio
- **Quiz con temporizador** — Pon a prueba tu conocimiento con preguntas de opción múltiple Kankui ↔ Español
- **Escáner QR** — Escanea códigos QR físicos en objetos culturales (mochilas, poporos, plantas) para descubrir su nombre en Kankui
- **Palabra del día** — Aprendizaje diario con una palabra nueva cada día
- **Ranking comunitario** — Compara tu progreso con otros estudiantes en el *Círculo de Sabiduría*

### Para Docentes
- **Panel de control** con métricas en tiempo real (XP total, rachas, lecciones completadas, escaneos, palabras aprendidas)
- **Dashboard analítico** con gráficos interactivos (barras, líneas, torta, radial) y filtros por día/semana/mes/personalizado
- **Exportación de reportes** en PDF e imágenes
- **Gestión de estudiantes** — Registro, consulta y seguimiento individual
- **Generación de códigos QR** imprimibles para lecciones y objetos culturales
- **Autenticación segura** — Inicio de sesión por correo para docentes, PIN único para estudiantes

---

## 🏗️ Arquitectura

```
kankui_app/
├── lib/
│   ├── main.dart                  # Punto de entrada
│   ├── data/                      # Capa de datos
│   │   ├── local/                 # SQLite offline-first
│   │   ├── remote/                # Supabase API
│   │   ├── seed/                  # Vocabulario base
│   │   └── sync/                  # Sincronización híbrida
│   ├── models/                    # Modelos de dominio
│   ├── repositories/              # Repositorios (abstracción datos)
│   ├── screens/                   # Pantallas de la app
│   ├── services/                  # Servicios (audio, auth, notificaciones, etc.)
│   ├── theme/                     # Tema visual e iconografía personalizada
│   └── widgets/                   # Componentes reutilizables
├── assets/
│   └── fonts/                     # Tipografía personalizada
├── android/
├── ios/
├── web/
└── test/
```

**Patrón:** Repository + Service Locator (`get_it`)
**Estrategia:** Offline-first con sincronización híbrida (SQLite local ↔ Supabase remoto)

---

## 🛠️ Tecnologías

| Tecnología | Propósito |
|-----------|-----------|
| [Flutter](https://flutter.dev) | Framework de desarrollo multiplataforma |
| [Supabase](https://supabase.com) | Backend-as-a-Service (Auth, PostgreSQL, RLS) |
| [SQLite](https://sqlite.org) (sqflite) | Base de datos local offline-first |
| [get_it](https://pub.dev/packages/get_it) | Inyección de dependencias / Service Locator |
| [Google Fonts](https://fonts.google.com) — Nunito | Tipografía orgánica y cálida |
| [mobile_scanner](https://pub.dev/packages/mobile_scanner) | Escaneo de códigos QR |
| [qr_flutter](https://pub.dev/packages/qr_flutter) | Generación de códigos QR |
| [audioplayers](https://pub.dev/packages/audioplayers) | Reproducción de pronunciación en audio |
| [fl_chart](https://pub.dev/packages/fl_chart) | Gráficos interactivos para dashboard |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Notificaciones de progreso |

---

## 🚀 Cómo Empezar

### Prerrequisitos
- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK
- Android Studio / Xcode (para emulación)
- Dispositivo o emulador físico

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/tu-organizacion/kankui_app.git

# Entrar al directorio
cd kankui_app

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run
```

### Configuración de Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Configura las tablas según el esquema definido en `lib/data/local/database_service.dart`
3. Define las variables de entorno (o archivo de configuración):

```dart
const supabaseUrl = 'https://jghnbyuanxxhtpllazmq.supabase.co';
const supabaseAnonKey = 'tu-anon-key';
```

---

## 🎯 Sistema de Progresión — Círculo de Sabiduría

| Nivel | Nombre | XP Requerido |
|-------|--------|:-----------:|
| 1 | Semilla | 0 |
| 2 | Brote | 100 |
| 3 | Raíz | 300 |
| 4 | Tallo | 600 |
| 5 | Hoja | 1 000 |
| 6 | Flor | 1 500 |
| 7 | Fruto | 2 200 |
| 8 | Árbol | 3 000 |
| 9 | Guardián | 4 000 |
| 10 | Sabio | 5 500 |
| 11 | Mayor | 7 500 |

---

## 🎨 Tema Visual

La identidad visual de Kankui App está inspirada en la **Sierra Nevada de Santa Marta** y la **cosmovisión Kankuamo**:

- **Paleta de colores:** Terracota, verde selva, azul cielo, dorado sol y crema
- **Tipografía:** Nunito — orgánica, cálida y accesible
- **Iconografía personalizada:** Mochila, Sierra, Espiral, Poporo, Hoja, Ojo Ancestral, Círculo de Sabiduría, Tejido
- **Material 3** con bordes redondeados y sombras suaves

---

## 🤝 Contribuciones

Este es un proyecto educativo de la **I.E. Indígena de Atánquez**. Si deseas contribuir:

1. Haz fork del proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Realiza tus cambios y haz commit (`git commit -m 'feat: añadir nueva funcionalidad'`)
4. Sube los cambios (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

**© 2025 I.E. Indígena de Atánquez** — Todos los derechos reservados.

El conocimiento ancestral contenido en esta aplicación pertenece al **Pueblo Kankuamo** y su uso está destinado exclusivamente a fines educativos y de revitalización cultural.

---

<div align="center">
  <p><em>"El conocimiento ancestral es el tejido que conecta nuestro pasado con nuestro futuro"</em></p>
  <p><strong>Sewa</strong> 🙏</p>
</div>
