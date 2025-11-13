#!/bin/bash

echo "🚀 Configurando nginx-proxy-manager con subdominios..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    error "docker-compose.yml no encontrado. Ejecutar desde ~/docker/pihole"
    exit 1
fi

log "Creando backup completo antes de cambios..."
mkdir -p ~/backups/$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/backups/$(date +%Y%m%d_%H%M%S)
cp docker-compose.yml $BACKUP_DIR/
sudo cp -r etc-pihole $BACKUP_DIR/ 2>/dev/null || warn "No se pudo hacer backup de etc-pihole"
sudo cp /etc/hosts $BACKUP_DIR/hosts.backup
log "Backup creado en: $BACKUP_DIR"

log "Verificando que PiHole funciona correctamente..."
if ! curl -s http://192.168.0.50/admin > /dev/null; then
    error "PiHole no está respondiendo en puerto 80. Verificar antes de continuar."
    exit 1
fi

log "Paso 1: Modificando configuración de PiHole para usar puertos específicos..."

# Crear nueva configuración preservando contraseña y configuración actual
cat > docker-compose.yml << 'EOF'
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "8082:80"      # Interfaz web en puerto 8082
      - "53:53/tcp"    # DNS TCP
      - "53:53/udp"    # DNS UDP  
    environment:
      TZ: 'America/Toronto'
      WEBPASSWORD: 'Q.dvFT4BUlDKCtMc.ca'
      PIHOLE_DNS_: '8.8.8.8;8.8.4.4;2001:4860:4860::8888;2001:4860:4860::8844'
      IPv6: 'true'
      DNSMASQ_LISTENING: 'all'
    volumes:
      - './etc-pihole:/etc/pihole'
      - './etc-dnsmasq.d:/etc/dnsmasq.d'
    restart: unless-stopped
EOF

log "Paso 2: Reiniciando PiHole con nueva configuración..."
sudo docker stop pihole
sudo docker rm pihole
sudo docker compose up -d pihole

log "Paso 3: Verificando que PiHole funciona en puerto 8082..."
sleep 15
if ! curl -s http://192.168.0.50:8082/admin > /dev/null; then
    error "PiHole no responde en puerto 8082. Restaurando configuración..."
    cp $BACKUP_DIR/docker-compose.yml ./
    sudo docker stop pihole
    sudo docker rm pihole
    sudo docker compose up -d pihole
    error "Configuración restaurada. Revisar manualmente."
    exit 1
fi

log "✅ PiHole funcionando en puerto 8082!"

log "Paso 4: Verificando que DNS sigue funcionando..."
sleep 5
if ! nslookup doubleclick.net 192.168.0.50 | grep -q "0.0.0.0"; then
    error "DNS no está bloqueando. Restaurando configuración..."
    cp $BACKUP_DIR/docker-compose.yml ./
    sudo docker stop pihole
    sudo docker rm pihole  
    sudo docker compose up -d pihole
    error "Configuración restaurada."
    exit 1
fi

log "✅ DNS bloqueando correctamente!"

log "Paso 5: Creando configuración para nginx-proxy-manager..."
cd ~/docker

# Crear directorio para nginx-proxy-manager
mkdir -p nginx-proxy-manager/{data,letsencrypt}

# Crear docker-compose para nginx-proxy-manager
cat > nginx-proxy-manager-compose.yml << 'EOF'
services:
  nginx-proxy-manager:
    container_name: nginx-proxy-manager
    image: jc21/nginx-proxy-manager:latest
    ports:
      - "80:80"      # Puerto principal para subdominios
      - "81:81"      # Puerto admin
      - "443:443"    # HTTPS
    volumes:
      - ./nginx-proxy-manager/data:/data
      - ./nginx-proxy-manager/letsencrypt:/etc/letsencrypt
    restart: unless-stopped
EOF

log "Paso 6: Iniciando nginx-proxy-manager..."
sudo docker compose -f nginx-proxy-manager-compose.yml up -d

log "Paso 7: Esperando que nginx-proxy-manager inicie..."
sleep 20

log "Paso 8: Verificando que nginx-proxy-manager está corriendo..."
if ! curl -s http://192.168.0.50:81 > /dev/null; then
    warn "nginx-proxy-manager puede tardar en iniciar. Continuar..."
fi

log "Paso 9: Configurando hosts file local..."
# Agregar entradas locales
cat << 'EOF' | sudo tee -a /etc/hosts

# Homeserver local services  
192.168.0.50 pihole.local
192.168.0.50 dashboard.local
192.168.0.50 vault.local
192.168.0.50 files.local
192.168.0.50 proxy.local
EOF

log "✅ Configuración base completada!"
echo ""
warn "📋 SIGUIENTES PASOS MANUALES (5 minutos):"
echo ""
echo "1. 🌐 Accede a nginx-proxy-manager: http://192.168.0.50:81"
echo "   - Usuario: admin@example.com"
echo "   - Contraseña: changeme"
echo "   - CAMBIAR a: darvaset@gmail.com / [tu nueva contraseña]"
echo ""
echo "2. 🔧 Configura estos Proxy Hosts:"
echo "   Domain: pihole.local → Forward: 192.168.0.50:8082"
echo "   Domain: dashboard.local → Forward: 192.168.0.50:3000"
echo "   Domain: vault.local → Forward: 192.168.0.50:8080" 
echo "   Domain: files.local → Forward: 192.168.0.50:9000"
echo ""
echo "3. ✅ Verifica todo funciona:"
echo "   - PiHole: http://192.168.0.50:8082/admin (contraseña actual)"
echo "   - DNS: nslookup doubleclick.net 192.168.0.50"
echo "   - Subdominios: http://pihole.local/admin (después del paso 2)"
echo ""
log "📁 Backup guardado en: $BACKUP_DIR"
warn "🔄 Si algo falla: cp $BACKUP_DIR/docker-compose.yml ~/docker/pihole/ && cd ~/docker/pihole && sudo docker compose up -d"
echo ""
warn "⚠️  IMPORTANTE: PiHole ahora está en puerto 8082 en lugar de 80"
warn "⚠️  Todos los subdominios funcionarán después del paso 2"
