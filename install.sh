#!/bin/bash

set -Eeuo pipefail
IFS=$'\n\t'
umask 077

VERSION="1.2.0"
REPO="maxytmaxyt/harbour-whatsapp"
BASE_URL="https://github.com/${REPO}/releases/download/v${VERSION}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TMP_DIR=""

info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

success() {
    printf "${GREEN}[ OK ]${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

error() {
    printf "${RED}[ERR ]${NC} %s\n" "$1" >&2
    exit 1
}

cleanup() {
    if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
        rm -rf -- "$TMP_DIR"
    fi
}

trap cleanup EXIT
trap 'error "Fehler in Zeile $LINENO."' ERR

printf "\n"
printf "  💬 harbour-whatsapp v%s Installer\n" "$VERSION"
printf "  ==================================\n\n"

if [[ "$(id -u)" -eq 0 ]]; then
    warn "Das Skript läuft als root."
else
    info "Benutzer: $(id -un)"
fi

for cmd in uname rpm pkcon mktemp; do
    command -v "$cmd" >/dev/null 2>&1 || error "Benötigtes Programm nicht gefunden: $cmd"
done

ARCH="$(uname -m)"

case "$ARCH" in
    aarch64)
        RPM_ARCH="aarch64"
        ;;
    armv7l|armv7hl|armv7hnl)
        RPM_ARCH="armv7hl"
        ;;
    i486|i586|i686)
        RPM_ARCH="i486"
        ;;
    x86_64)
        RPM_ARCH="x86_64"
        ;;
    *)
        error "Nicht unterstützte Architektur: $ARCH"
        ;;
esac

info "Architektur: $ARCH → RPM: $RPM_ARCH"

DEPS=(
    "qt5-qtwebview"
    "nemo-qml-plugin-dbus-qt5"
    "nemo-qml-plugin-notifications-qt5"
    "python3"
    "python3-dbus"
)

info "Prüfe Abhängigkeiten..."

for dep in "${DEPS[@]}"; do
    if rpm -q "$dep" >/dev/null 2>&1; then
        success "$dep ist installiert"
        continue
    fi

    info "Installiere $dep..."

    if pkcon install -y "$dep" >/dev/null 2>&1; then
        success "$dep installiert"
    else
        error "Abhängigkeit konnte nicht installiert werden: $dep"
    fi
done

TMP_DIR="$(mktemp -d -t harbour-whatsapp.XXXXXX)"

RPM_FILE="harbour-whatsapp-${VERSION}-1.${RPM_ARCH}.rpm"
RPM_URL="${BASE_URL}/${RPM_FILE}"
TMP_RPM="${TMP_DIR}/${RPM_FILE}"

info "Download: $RPM_FILE"

if command -v curl >/dev/null 2>&1; then
    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --proto '=https' \
        --tlsv1.2 \
        --output "$TMP_RPM" \
        "$RPM_URL"
elif command -v wget >/dev/null 2>&1; then
    wget \
        --https-only \
        --secure-protocol=TLSv1_2 \
        --quiet \
        --output-document="$TMP_RPM" \
        "$RPM_URL"
else
    error "Weder curl noch wget ist installiert."
fi

[[ -s "$TMP_RPM" ]] || error "Die heruntergeladene RPM-Datei ist leer."

success "Download abgeschlossen"

info "Prüfe RPM-Paket..."

rpm -qp "$TMP_RPM" >/dev/null 2>&1 || error "Die heruntergeladene Datei ist kein gültiges RPM-Paket."

PACKAGE_NAME="$(rpm -qp --queryformat '%{NAME}' "$TMP_RPM")"
PACKAGE_VERSION="$(rpm -qp --queryformat '%{VERSION}' "$TMP_RPM")"
PACKAGE_ARCH="$(rpm -qp --queryformat '%{ARCH}' "$TMP_RPM")"

[[ "$PACKAGE_NAME" == "harbour-whatsapp" ]] ||
    error "Falsches Paket: $PACKAGE_NAME"

[[ "$PACKAGE_VERSION" == "$VERSION" ]] ||
    error "Falsche Version: erwartet $VERSION, erhalten $PACKAGE_VERSION"

[[ "$PACKAGE_ARCH" == "$RPM_ARCH" ]] ||
    error "Falsche Architektur: erwartet $RPM_ARCH, erhalten $PACKAGE_ARCH"

success "RPM-Paket ist gültig"

info "Installiere harbour-whatsapp v${VERSION}..."

if pkcon install-local -y "$TMP_RPM"; then
    success "harbour-whatsapp installiert"
else
    error "Installation des RPM-Pakets fehlgeschlagen"
fi

if command -v systemctl >/dev/null 2>&1; then
    if systemctl --user daemon-reload >/dev/null 2>&1; then
        info "Systemd User-Service aktualisiert"
    fi

    if systemctl --user enable harbour-whatsapp-daemon >/dev/null 2>&1; then
        success "Daemon für Autostart aktiviert"
    else
        warn "Daemon konnte nicht für Autostart aktiviert werden"
    fi

    if systemctl --user restart harbour-whatsapp-daemon >/dev/null 2>&1; then
        success "Daemon gestartet"
    else
        warn "Daemon konnte nicht gestartet werden"
        warn "Prüfe den Status mit: systemctl --user status harbour-whatsapp-daemon"
    fi

    if systemctl --user is-active --quiet harbour-whatsapp-daemon; then
        success "Daemon läuft"
    else
        warn "Daemon läuft momentan nicht"
    fi
else
    warn "systemctl wurde nicht gefunden"
fi

printf "\n"
printf "${GREEN}✅ Installation abgeschlossen!${NC}\n"
printf "\n"
printf "WhatsApp über das App-Menü starten.\n"
printf "Beim ersten Start QR-Code scannen:\n"
printf "WhatsApp → Verknüpfte Geräte → Gerät verknüpfen\n"
printf "\n"
