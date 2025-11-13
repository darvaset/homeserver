# Darva's HomeServer Configuration

Este repositorio contiene la configuración completa de mi HomeServer, gestionado enteramente a través de Docker y Docker Compose. El objetivo es mantener una infraestructura como código (IaC) para facilitar la gestión, el despliegue y la recuperación del sistema.

## 🚀 Servicios Activos

A continuación se detallan los servicios que están actualmente en ejecución:

| Servicio | Propósito | Acceso |
| :--- | :--- | :--- |
| **Nginx Proxy Manager** | Gestión de proxy inverso, certificados SSL y enrutamiento de dominios. | `http://<IP>:81` |
| **Homepage** | Dashboard centralizado para acceder a todos los servicios. | `http://<IP>:3000` |
| **Pi-hole** | Bloqueador de anuncios y rastreadores a nivel de red (DNS Sinkhole). | `http://<IP>:8088` |
| **Vaultwarden** | Gestor de contraseñas auto-alojado compatible con Bitwarden. | `https://vault.delaguilahuaroc.com` |
| **WireGuard** | Solución de VPN moderna, rápida y segura para acceso remoto. | `UDP 51820` |
| **FileBrowser** | Explorador de archivos basado en web. | `http://<IP>:8082` |
| **Portainer** | Interfaz de gestión para entornos Docker. | `https://portainer.delaguilahuaroc.com` |

---

## 🛠️ Gestión y Estructura

El proyecto está estructurado con un directorio por servicio, donde cada uno contiene su propio archivo `docker-compose.yml`. Esto permite gestionar los servicios de forma independiente.

- **Orquestación:** Docker Compose
- **Control de Versiones:** Git y GitHub
- **Seguridad:** El acceso a los servicios desde el exterior se gestiona a través de Nginx Proxy Manager con certificados SSL de Let's Encrypt. El acceso a la red local desde el exterior se realiza de forma segura a través de WireGuard.

## ⚙️ Uso

Para levantar un servicio específico, navega al directorio correspondiente y ejecuta:

```bash
docker-compose up -d
```

Para detenerlo:

```bash
docker-compose down
```
