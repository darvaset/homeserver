# 🗺️ Roadmap del HomeServer de Darva

Este documento describe un plan estratégico para mejorar y expandir las capacidades de este HomeServer. El objetivo es evolucionar hacia un sistema más robusto, seguro, automatizado y funcional, siguiendo las mejores prácticas de la comunidad de auto-alojamiento.

---

## Fase 1: Mejoras Fundamentales y Seguridad (Corto Plazo)

*Objetivo: Fortalecer la base actual, optimizar la seguridad y evaluar alternativas directas a los servicios existentes.*

### 1. Estrategia de Backups Automatizados
- **Problema:** Actualmente no existe una estrategia de respaldo para los datos persistentes de los contenedores (los volúmenes que guardan la configuración y datos).
- **Solución:** Implementar un servicio de backup automatizado.
  - **Opción A (Simple):** Crear un script `bash` que use `rsync` para copiar los volúmenes importantes a una ubicación segura (otro disco, un NAS, o un proveedor de nube) y ejecutarlo diariamente con un `cronjob`.
  - **Opción B (Avanzado):** Desplegar un contenedor de backup como **[Restic](https://restic.net/)** o **[Duplicati](https://www.duplicati.com/)**, que ofrecen encriptación, compresión, deduplicación y múltiples destinos de almacenamiento.
- **Resultado:** Proteger los datos críticos y la configuración ante fallos de disco o errores humanos.

### 2. Evaluación de Alternativas de Servicios
- **Objetivo:** Asegurar que estamos usando las herramientas más eficientes y con más funcionalidades.
- **Análisis a realizar:**
  - **`Pi-hole` vs. `AdGuard Home`**:
    - **Pi-hole** es el estándar y funciona perfectamente.
    - **AdGuard Home** ofrece de forma nativa DNS sobre HTTPS (DoH) y DNS sobre TLS (DoT), una interfaz más moderna y controles parentales más granulares. **Propuesta:** Evaluar la migración a AdGuard Home para mejorar la privacidad y la usabilidad.
  - **`Nginx Proxy Manager` vs. `Traefik`**:
    - **NPM** es excelente por su simplicidad y su interfaz gráfica.
    - **Traefik** es más potente para entornos dinámicos, ya que se configura directamente a través de las etiquetas de los contenedores Docker, automatizando la creación de rutas. **Propuesta:** Mantener NPM por ahora, ya que cumple su función, pero considerar Traefik si el número de servicios crece exponencialmente.
  - **`WireGuard` vs. `Headscale` (Tailscale auto-alojado)**:
    - La configuración actual de **WireGuard** es eficiente y segura.
    - **Headscale** crea una red virtual tipo "mesh" que simplifica enormemente la conexión entre dispositivos (no más apertura de puertos ni IPs públicas), gestiona las claves automáticamente y ofrece funcionalidades como MagicDNS. **Propuesta:** Planificar la migración a Headscale para una gestión de VPN mucho más simple y potente.

---

## Fase 2: Expansión de Capacidades (Medio Plazo)

*Objetivo: Añadir nuevas funcionalidades clave que son pilares en la mayoría de los HomeServers modernos.*

### 1. Suite de Medios Automatizada (Los `*arrs`)
- **Objetivo:** Automatizar la descarga y gestión de contenido multimedia.
- **Nuevos Servicios a Implementar:**
  - **[Prowlarr](https://prowlarr.com/):** Gestor de indexers para los otros `*arrs`.
  - **[Sonarr](https://sonarr.tv/):** Gestión y descarga automática de series de TV.
  - **[Radarr](https://radarr.video/):** Gestión y descarga automática de películas.
  - **[Jellyfin](https://jellyfin.org/):** Servidor de streaming de medios, 100% open source. Una alternativa a Plex.
  - **Cliente de descargas:** Como `qBittorrent` o `SABnzbd`.

### 2. Monitorización y Observabilidad
- **Objetivo:** Tener una visión completa del estado y rendimiento del servidor y los servicios.
- **Nuevos Servicios a Implementar:**
  - **[Prometheus](https://prometheus.io/):** Para la recolección de métricas.
  - **[Grafana](https://grafana.com/):** Para la visualización de las métricas en dashboards impresionantes.
  - **[Loki](https://grafana.com/oss/loki/):** Para la recolección de logs de todos los contenedores.
- **Resultado:** Pasar de una gestión reactiva a una proactiva, detectando problemas antes de que ocurran.

---

## Fase 3: Servicios Avanzados y Automatización Total (Largo Plazo)

*Objetivo: Convertir el HomeServer en el centro neurálgico del hogar digital.*

### 1. Hub de Domótica
- **Objetivo:** Centralizar el control de todos los dispositivos inteligentes del hogar.
- **Nuevo Servicio a Implementar:**
  - **[Home Assistant](https://www.home-assistant.io/):** La plataforma open source líder para la domótica. Permite crear automatizaciones complejas (ej. "si llego a casa y es de noche, enciende las luces del salón").

### 2. Oficina sin Papeles
- **Objetivo:** Digitalizar y organizar todos los documentos físicos.
- **Nuevo Servicio a Implementar:**
  - **[Paperless-ngx](https://paperless-ngx.com/):** Escanea, etiqueta y archiva documentos. Utiliza OCR para hacer que el contenido de los PDFs sea buscable.

### 3. Nube Personal Completa
- **Objetivo:** Reemplazar servicios como Google Drive/Photos por una solución auto-alojada.
- **Análisis a realizar:**
  - **`FileBrowser` vs. `Nextcloud`**:
    - **FileBrowser** es excelente como explorador de archivos simple.
    - **Nextcloud** es una suite completa que incluye gestión de archivos, calendario, contactos, galería de fotos (con reconocimiento facial y de objetos), y edición de documentos en línea. **Propuesta:** Evaluar la migración de FileBrowser a Nextcloud para una experiencia de nube privada total.
