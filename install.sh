#!/bin/bash
# harbour-whatsapp Installer
# Führe dieses Skript auf deinem Sailfish-Gerät aus:
#   bash install.sh

set -e

VERSION="1.2.0"
REPO="maxytmaxyt/harbour-whatsapp"
BASE_URL="https://github.com/$REPO/releases/download/v$VERSION"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC}   $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERR]${NC}  $1"; exit 1; }

echo ""
echo "  💬 harbour-whatsapp v$VERSION Installer"
echo "  ======================================="
echo ""

# --- Detect architecture ---
ARCH=$(uname -m)
case "$ARCH" in
  aarch64)          RPM_ARCH="aarch64" ;;
  armv7l|armv7hl)  RPM_ARCH="armv7hl" ;;
  i486|i686|x86_64) RPM_ARCH="i486"   ;;
  *) error "Unbekannte Architektur: $ARCH" ;;
esac
info "Erkannte Architektur: $ARCH → RPM-Paket: $RPM_ARCH"

# --- Install dependencies ---
info "Installiere Abhängigkeiten..."
DEPS="qt5-qtwebview nemo-qml-plugin-dbus-qt5 nemo-qml-plugin-notifications-qt5 python3 python3-dbus"
for dep in $DEPS; do
  if pkcon search name "$dep" 2>/dev/null | grep -q "^Installed"; then
    success "$dep ist bereits installiert"
  else
    info "Installiere $dep ..."
    pkcon install -y "$dep" 2>/dev/null && success "$dep installiert" || warn "$dep konnte nicht installiert werden (möglicherweise nicht nötig)"
  fi
done

# --- Download RPM ---
RPM_FILE="harbour-whatsapp-${VERSION}-1.${RPM_ARCH}.rpm"
RPM_URL="$BASE_URL/$RPM_FILE"
TMP_DIR=$(mktemp -d)
TMP_RPM="$TMP_DIR/$RPM_FILE"

info "Lade $RPM_FILE herunter..."
if command -v curl &>/dev/null; then
  curl -L --progress-bar -o "$TMP_RPM" "$RPM_URL" || error "Download fehlgeschlagen: $RPM_URL"
elif command -v wget &>/dev/null; then
  wget -q --show-progress -O "$TMP_RPM" "$RPM_URL" || error "Download fehlgeschlagen: $RPM_URL"
else
  error "Weder curl noch wget gefunden. Bitte manuell herunterladen: $RPM_URL"
fi
success "Download abgeschlossen"

# --- Install RPM ---
info "Installiere harbour-whatsapp..."
pkcon install-local -y "$TMP_RPM" || error "Installation fehlgeschlagen"
success "harbour-whatsapp v$VERSION erfolgreich installiert!"

# --- Cleanup ---
rm -rf "$TMP_DIR"

# --- Start daemon ---
info "Starte Hintergrund-Daemon..."
systemctl --user enable harbour-whatsapp-daemon 2>/dev/null || true
systemctl --user start  harbour-whatsapp-daemon 2>/dev/null || true
success "Daemon gestartet"

echo ""
echo -e "  ${GREEN}✅ Installation abgeschlossen!${NC}"
echo ""
echo "  Starte WhatsApp über das App-Menü."
echo "  Beim ersten Start QR-Code scannen:"
echo "  WhatsApp auf dem Handy → Verknüpfte Geräte → Gerät verknüpfen"
echo ""
