#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Dragon Banner Maker Pro - Automatic Dependency Setup
# Run this script in Termux from the folder containing:
#   Dragon-Banner-Maker.sh
# ============================================================

set -u

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

APP_NAME="Dragon Banner Maker Pro"
MAKER_NAME="Dragon-Banner-Maker.sh"
INSTALL_DIR="$HOME"
MAKER_PATH="$INSTALL_DIR/$MAKER_NAME"

say()  { printf "%b\n" "${CYAN}$*${RESET}"; }
ok()   { printf "%b\n" "${GREEN}[OK] $*${RESET}"; }
warn() { printf "%b\n" "${YELLOW}[!] $*${RESET}"; }
fail() { printf "%b\n" "${RED}[ERROR] $*${RESET}" >&2; }

clear 2>/dev/null || true
say "=============================================="
say "       DRAGON BANNER MAKER PRO - SETUP"
say "=============================================="
echo

# Verify that this is running inside Termux.
if [[ ! -d "/data/data/com.termux/files/usr" ]] || ! command -v pkg >/dev/null 2>&1; then
    fail "This setup script is intended for Termux."
    exit 1
fi

# Locate the main maker script beside this setup script,
# or in the current working directory.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
SOURCE_MAKER="$SCRIPT_DIR/$MAKER_NAME"

if [[ ! -f "$SOURCE_MAKER" && -f "$PWD/$MAKER_NAME" ]]; then
    SOURCE_MAKER="$PWD/$MAKER_NAME"
fi

if [[ ! -f "$SOURCE_MAKER" && ! -f "$MAKER_PATH" ]]; then
    fail "Cannot find $MAKER_NAME."
    echo "Keep setup.sh and $MAKER_NAME in the same folder, then run setup.sh again."
    exit 1
fi

say "[1/5] Updating Termux package lists..."
pkg update -y || {
    fail "Package update failed. Check your internet connection and Termux repositories."
    exit 1
}

say "[2/5] Installing required packages..."
if ! pkg install -y bash cowsay ruby coreutils grep sed gawk; then
    fail "One or more required packages could not be installed."
    exit 1
fi
ok "Required Termux packages installed."

say "[3/5] Installing optional rainbow dependency (lolcat)..."
if ! command -v lolcat >/dev/null 2>&1; then
    # Try the Termux package first; fall back to RubyGems.
    if ! pkg install -y lolcat >/dev/null 2>&1; then
        gem install lolcat --no-document
    fi
fi

if command -v lolcat >/dev/null 2>&1; then
    ok "lolcat is available (rainbow output enabled)."
else
    warn "lolcat could not be installed. The banner can still use solid colours."
fi

say "[4/5] Installing the banner maker..."
if [[ -f "$SOURCE_MAKER" ]]; then
    if [[ "$SOURCE_MAKER" != "$MAKER_PATH" ]]; then
        cp -f -- "$SOURCE_MAKER" "$MAKER_PATH" || {
            fail "Could not copy the banner maker into Termux home."
            exit 1
        }
    fi
fi

chmod 700 "$MAKER_PATH" || {
    fail "Could not set permissions on $MAKER_PATH."
    exit 1
}
ok "Banner maker is ready at: $MAKER_PATH"

say "[5/5] Checking optional commands..."
for cmd in bash cowsay ruby grep sed awk shuf; do
    if command -v "$cmd" >/dev/null 2>&1; then
        ok "$cmd"
    else
        warn "$cmd not found; some features may be unavailable."
    fi
done

echo
say "=============================================="
ok "$APP_NAME setup completed!"
say "=============================================="
echo
echo "Start the banner maker with:"
printf '  bash "%s"\n' "$MAKER_PATH"
echo
read -rp "Launch Dragon Banner Maker Pro now? [Y/n]: " launch
if [[ ! "$launch" =~ ^[Nn]$ ]]; then
    exec bash "$MAKER_PATH"
fi

echo
ok "Setup finished. You can launch it anytime using:"
printf 'bash "%s"\n' "$MAKER_PATH"
