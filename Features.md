<div align="center">
  <h1>🐧 Linux Desktop Support (Bilingual Guide)</h1>
  <p>
    <a href="#english-version">English</a> • 
    <a href="#versión-en-español">Español</a>
  </p>
</div>

---

<h1 id="english-version">🇬🇧 Advanced Linux Desktop Support</h1>

This document summarizes the improvements made to turn **DailyAL** into a first-class citizen on Linux. These features were specifically tested on **Pop!_OS 22.04 (LTS)** but are compatible with any modern distribution (GNOME, KDE, or with Ayatana support).

## 🚀 Key Added Features

### 1. Centralized Architecture (Linux Helper)
Introduced `lib/util/linux_desktop_helper.dart` to isolate all native logic. This avoids "polluting" the app's main code and allows for clean maintenance in this Fork.

### 2. Modern Taskbar (Tray Manager)
- **Official Branding:** DailyAL official icon in the taskbar.
- **Always-Alive Window:** Closing the app with the [X] minimizes it to the Tray instead of closing it, keeping background tasks active.
- **Quick Actions:** Context menu (right-click) with direct navigation to Search, My List, and Calendar.

### 3. Native Notifications (Libnotify)
- **Visual Identity:** Automatic logo extraction to the local disk so notifications show the app icon instead of a generic alert.
- **Auto-Focus:** Clicking a notification restores the app, takes system focus, and navigates to the relevant content.

### 4. Premium Image Viewer (Darkeudo Enhancements)
The image viewer has been redesigned for a real desktop experience:
- **Keyboard Navigation:** Full support for flipping images with **arrow keys** (left/right) and closing with the **Escape** key, something that did not exist in the original version.
- **Dynamic High Resolution:** The app loads lightweight thumbnails first and, after 3 seconds of viewing, automatically switches to **FilterQuality.high** and downloads the high-resolution version (`l.jpg`).
- **Smart Downloads:** Corrected saving system for desktop. Images download directly to your system **Downloads** folder with a readable name, avoiding hidden app folders.

### 5. Stability and Fixes
- **Dependency Detector:** Smart warning that detects if `libnotify` or `libayatana` is missing and tells you exactly what to install.

### 6. Desktop-Optimized Messaging (Custom Toasts)
Replaced the generic mobile-style toast system with a **Custom Overlay UI** for desktop. These toasts feature modern aesthetics, rounded corners, and adaptive opacity, ensuring a premium feel that doesn't conflict with system themes.

### 7. Zero-Friction Notification Setup
Avoids annoying "request permission" pop-ups on first launch. By bypassing mobile permission logic, notifications on Linux work instantly out-of-the-box, providing a seamless onboarding experience.

## 🛠️ System Dependencies
To build or run these features on Debian/Ubuntu systems (Pop!_OS), you need:

```bash
# For the Taskbar and Menus
sudo apt-get install libayatana-appindicator3-dev libdbusmenu-gtk3-dev

# For Native Notifications
sudo apt-get install libnotify-bin
```

## 🔱 Fork Maintenance
This project uses a **"Hook" Architecture**. Almost all Linux code lives in its own file, allowing updates from the original JICA98 repository to be extremely easy and without code conflicts.

*Created with care by Darkeudo to make DailyAL a key element on the Linux desktop.*
---

<h1 id="versión-en-español">🇪🇸 Soporte Avanzado para Linux Desktop</h1>

Este documento resume las mejoras realizadas para convertir a **DailyAL** en un ciudadano de primera clase en Linux. Estas funcionalidades fueron probadas específicamente en **Pop!_OS 22.04 (LTS)** pero son compatibles con cualquier distribución moderna (GNOME, KDE o con soporte de Ayatana).

## 🚀 Funcionalidades Clave Añadidas

### 1. Arquitectura Centralizada (Helper de Linux)
Se introdujo `lib/util/linux_desktop_helper.dart` para aislar toda la lógica nativa. Esto evita "ensuciar" el código principal de la app y permite un mantenimiento limpio en este Fork.

### 2. Barra de Tareas Moderna (Tray Manager)
- **Imagen de Marca:** Icono oficial de DailyAL en la barra de tareas.
- **Ventana Siempre Viva:** Al cerrar la app con la [X], se minimiza al Tray en lugar de cerrarse, manteniendo las tareas en segundo plano.
- **Acciones Rápidas:** Menú contextual (clic derecho) con navegación directa a Búsqueda, Mi Lista y Calendario.

### 3. Notificaciones Nativas (Libnotify)
- **Identidad Visual:** Extracción automática del logo al disco local para que las notificaciones muestren el icono de la app en lugar de un aviso genérico.
- **Auto-Foco:** Al hacer clic en una notificación, la app se restaura, toma el foco del sistema y navega al contenido relevante.

### 4. Visor de Imágenes Premium (Mejoras Darkeudo)
Se ha rediseñado el visor de imágenes para ofrecer una experiencia de escritorio real:
- **Navegación por Teclado:** Soporte total para pasar imágenes con las **flechas del teclado** (izquierda/derecha) y cerrar con la tecla **Escape**, algo que no existía en la versión original.
- **Alta Resolución Dinámica:** La app carga miniaturas ligeras primero y, tras 3 segundos de visualización, cambia automáticamente a **FilterQuality.high** y descarga la versión en alta resolución (`l.jpg`).
- **Descargas Inteligentes:** Sistema de guardado corregido para escritorio. Las imágenes se descargan directamente en tu carpeta de **Descargas** del sistema con un nombre legible, evitando carpetas ocultas de la app.

### 5. Estabilidad y Correcciones
- **Zonas Horarias:** Solucionado el error que hacía cerrar la app en Linux al no detectar automáticamente el huso horario local.
- **Detector de Dependencias:** Aviso inteligente que detecta si falta `libnotify` o `libayatana` y te dice exactamente qué instalar.

### 6. Mensajería Optimizada (Toasts Personalizados)
Se reemplazó el sistema de avisos genérico de móviles por un **Sistema de Overlays personalizado**. Estos avisos cuentan con una estética moderna, bordes redondeados y opacidad adaptativa, garantizando una experiencia premium que se integra perfectamente con el escritorio.

### 7. Configuración Sin Fricción
Elimina los molestos pop-ups de "solicitar permisos" al iniciar la app por primera vez. Al omitir la lógica de permisos móviles, las notificaciones en Linux funcionan al instante, ofreciendo una experiencia de uso fluida desde el primer segundo.

## 🛠️ Dependencias del Sistema
Para compilar o ejecutar estas funciones en sistemas basados en Debian/Ubuntu (Pop!_OS), necesitas:

```bash
# Para la Barra de Tareas y Menús
sudo apt-get install libayatana-appindicator3-dev libdbusmenu-gtk3-dev

# Para las Notificaciones Nativas
sudo apt-get install libnotify-bin
```

## 🔱 Mantenimiento del Fork
Este proyecto usa una **arquitectura de "Ganchos" (Hooks)**. Casi todo el código de Linux vive en su propio archivo, lo que permite que actualizar desde el repositorio original de JICA98 sea extremadamente fácil y sin conflictos de código.

---

*Creado con esmero por Darkeudo para que DailyAL sea un elemento clave en el escritorio Linux.*