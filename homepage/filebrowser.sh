#!/bin/bash

# Script para instalar FileBrowser y arreglar dashboard
# Autor: Generado para Diego's Homeserver
# Fecha: $(date)

set -e  # Salir si hay algún error

echo "🚀 Iniciando instalación de FileBrowser y corrección del dashboard..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
HOMEPAGE_DIR="$HOME/docker/homepage"
FILEBROWSER_DIR="$HOME/docker/filebrowser"
FILEBROWSER_USER="darva"
FILEBROWSER_PASS="Darva123***"

echo -e "${BLUE}📁 Creando estructura de directorios para FileBrowser...${NC}"
mkdir -p $FILEBROWSER_DIR/config
mkdir -p $FILEBROWSER_DIR/data

echo -e "${BLUE}📝 Creando docker-compose.yml para FileBrowser...${NC}"
cat > $FILEBROWSER_DIR/docker-compose.yml << 'EOF'
version: '3.8'

services:
  filebrowser:
    image: filebrowser/filebrowser:v2
    container_name: filebrowser
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - /home/darva-ubuntu:/srv
      - ./config:/config
      - ./data:/database
    environment:
      - PUID=1000
      - PGID=1000
    command: --config /config/filebrowser.json --database /database/filebrowser.db
    networks:
      - homepage-network

networks:
  homepage-network:
    external: true
EOF

echo -e "${BLUE}⚙️ Creando archivo de configuración de FileBrowser...${NC}"
cat > $FILEBROWSER_DIR/config/filebrowser.json << EOF
{
  "port": 80,
  "baseURL": "",
  "address": "",
  "log": "stdout",
  "database": "/database/filebrowser.db",
  "root": "/srv",
  "username": "$FILEBROWSER_USER",
  "password": "$FILEBROWSER_PASS",
  "auth": {
    "method": "json"
  },
  "branding": {
    "name": "Diego's File Manager",
    "files": "/config/branding"
  }
}
EOF

echo -e "${BLUE}🖼️ Descargando y arreglando iconos...${NC}"
cd $HOMEPAGE_DIR/config/icons/

# Descargar icono de FileBrowser
echo -e "${YELLOW}📥 Descargando icono de FileBrowser...${NC}"
wget -O filebrowser.png "https://raw.githubusercontent.com/filebrowser/logo/main/icon.png" 2>/dev/null || {
    echo -e "${YELLOW}⚠️ No se pudo descargar el icono de FileBrowser, creando uno alternativo...${NC}"
    # Crear un icono simple con ImageMagick si está disponible
    if command -v convert >/dev/null 2>&1; then
        convert -size 64x64 xc:blue -fill white -gravity center -pointsize 20 -annotate +0+0 "FB" filebrowser.png
    else
        # Copiar un icono existente como fallback
        cp ubuntu.png filebrowser.png
    fi
}

# Arreglar icono de TekSavvy (descargar uno genérico de ISP/Router)
echo -e "${YELLOW}🔧 Arreglando icono de TekSavvy...${NC}"
wget -O teksavvy_new.png "https://www.shareicon.net/download/2016/07/13/606936_router_512x512.png" 2>/dev/null || {
    echo -e "${YELLOW}⚠️ Creando icono alternativo para TekSavvy...${NC}"
    if command -v convert >/dev/null 2>&1; then
        convert -size 64x64 xc:darkblue -fill white -gravity center -pointsize 16 -annotate +0+0 "NET" teksavvy_new.png
        mv teksavvy_new.png teksavvy.png
    fi
}

# Arreglar icono del Mini PC
echo -e "${YELLOW}🔧 Arreglando icono del Mini PC...${NC}"
wget -O minipc_new.png "https://www.shareicon.net/download/2016/07/26/801946_computer_512x512.png" 2>/dev/null || {
    echo -e "${YELLOW}⚠️ Creando icono alternativo para Mini PC...${NC}"
    if command -v convert >/dev/null 2>&1; then
        convert -size 64x64 xc:gray -fill white -gravity center -pointsize 14 -annotate +0+0 "PC" minipc_new.png
        mv minipc_new.png minipc.png
    fi
}

echo -e "${BLUE}📝 Actualizando configuración del dashboard...${NC}"
cd $HOMEPAGE_DIR/config/

# Backup de la configuración actual
cp services.yaml services.yaml.backup.$(date +%Y%m%d_%H%M%S)

# Actualizar services.yaml agregando FileBrowser
cat > services.yaml << 'EOF'
# Homepage Dashboard Configuration
# Generated automatically - backup created before modification

- Network & Security:
    - Pi-hole:
        href: http://192.168.0.50:8081/admin
        description: Network-wide Ad Blocking & DNS
        icon: si-pihole
        ping: http://192.168.0.50:8081

    - WireGuard:
        href: http://192.168.0.50:51821
        description: VPN - Secure Remote Access
        icon: si-wireguard
        ping: http://192.168.0.50:51821

- Management:
    - Portainer:
        href: http://192.168.0.50:9000
        description: Docker Container Management
        icon: si-portainer
        ping: http://192.168.0.50:9000

    - Nginx Proxy Manager:
        href: http://192.168.0.50:81
        description: Reverse Proxy & SSL Certificates
        icon: si-nginx
        ping: http://192.168.0.50:81

    - Homepage:
        href: http://192.168.0.50:3000
        description: This Dashboard
        icon: si-homepage
        ping: http://192.168.0.50:3000

    - FileBrowser:
        href: http://192.168.0.50:8080
        description: Web File Manager & Explorer
        icon: /icons/filebrowser.png
        ping: http://192.168.0.50:8080

- Applications:
    - Vaultwarden:
        href: http://192.168.0.50:8000
        description: Self-hosted Password Manager
        icon: si-bitwarden
        ping: http://192.168.0.50:8000

- Server Infrastructure:
    - TRIGKEY N100 Mini PC:
        href: http://192.168.0.50:9000
        description: Ubuntu Server 24.04 • Docker Host
        icon: /icons/minipc.png
        ping: http://192.168.0.50

    - TekSavvy Router:
        href: http://192.168.0.1
        description: Gateway & Modem
        icon: /icons/teksavvy.png
        ping: http://192.168.0.1

- Development:
    - Github:
        href: https://github.com
        description: Code Repository
        icon: si-github

    - Docker Hub:
        href: https://hub.docker.com
        description: Container Registry
        icon: si-docker

- Entertainment:
    - Youtube:
        href: https://youtube.com
        description: Video Streaming
        icon: si-youtube

    - Reddit:
        href: https://reddit.com
        description: Social News & Discussion
        icon: si-reddit

- Tools & Utilities:
    - Speedtest:
        href: https://speedtest.net
        description: Internet Speed Testing
        icon: si-speedtest

    - What's My IP:
        href: https://whatismyipaddress.com
        description: IP Address Information
        icon: si-ipinfo
EOF

echo -e "${BLUE}🐳 Iniciando FileBrowser...${NC}"
cd $FILEBROWSER_DIR

# Verificar si la red existe, si no, crearla
if ! docker network ls | grep -q "homepage-network"; then
    echo -e "${YELLOW}🔗 Creando red homepage-network...${NC}"
    docker network create homepage-network
fi

# Detener contenedor existente si existe
docker-compose down 2>/dev/null || true

# Iniciar FileBrowser
docker-compose up -d

echo -e "${BLUE}♻️ Reiniciando Homepage para aplicar cambios...${NC}"
cd $HOMEPAGE_DIR
docker-compose down
docker-compose up -d

echo -e "${GREEN}✅ Instalación completada!${NC}"
echo ""
echo -e "${BLUE}📊 Resumen de servicios:${NC}"
echo -e "• FileBrowser: ${GREEN}http://192.168.0.50:8080${NC}"
echo -e "  👤 Usuario: ${YELLOW}$FILEBROWSER_USER${NC}"
echo -e "  🔑 Contraseña: ${YELLOW}$FILEBROWSER_PASS${NC}"
echo ""
echo -e "• Homepage Dashboard: ${GREEN}http://192.168.0.50:3000${NC}"
echo ""
echo -e "${BLUE}🔍 Verificando servicios...${NC}"
sleep 5

# Verificar que los servicios estén ejecutándose
echo -e "${BLUE}📈 Estado de contenedores:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(homepage|filebrowser)"

echo ""
echo -e "${GREEN}🎉 ¡Todo listo! Tu homeserver ahora incluye FileBrowser.${NC}"
echo -e "${BLUE}💡 Accede a FileBrowser en: http://192.168.0.50:8080${NC}"
echo -e "${BLUE}🏠 Dashboard actualizado en: http://192.168.0.50:3000${NC}"

# Mostrar logs de FileBrowser por si hay problemas
echo -e "${YELLOW}📋 Últimos logs de FileBrowser:${NC}"
docker logs filebrowser --tail=10
EOF
