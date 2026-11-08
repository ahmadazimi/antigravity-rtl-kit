#!/usr/bin/env bash
# ==============================================================================
# Antigravity RTL Persian/Arabic Display Kit - Installer
# Supports macOS and Linux (x86_64 / arm64)
# ==============================================================================

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

RAW_GITHUB_BASE="https://raw.githubusercontent.com/m-ahm-adi/antigravity-rtl-kit/main"

print_banner() {
  cat << "EOF"

    _          _   _                      _ _         ____ _____ _     
   / \   _ __ | |_(_) __ _ _ __ __ ___   _(_) |_ _   |  _ \_   _| |    
  / _ \ | '_ \| __| |/ _` | '__/ _` \ \ / / | __| | | | |_) || | | |    
 / ___ \| | | | |_| | (_| | | | (_| |\ V /| | |_| |_| |  _ < | | | |___ 
/_/   \_\_| |_|\__|_|\__, |_|  \__,_| \_/ |_|\__|\__, |_| \_\|_| |_____|
                     |___/                       |___/                 
           Persian & Arabic Display Kit for Google Antigravity
EOF
  echo ""
}

print_banner

# Determine execution directory or remote curl execution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
LOCAL_RULE_FILE="${SCRIPT_DIR}/rules/persian-rtl.md"

# Parse CLI arguments
INSTALL_MODE="global"
while [[ $# -gt 0 ]]; do
  case $1 in
    --workspace|-w)
      INSTALL_MODE="workspace"
      shift
      ;;
    --global|-g)
      INSTALL_MODE="global"
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -g, --global     Install globally into ~/.gemini/config/rules/ (Default - applies to all projects)"
      echo "  -w, --workspace  Install locally into current workspace (./.agents/rules/)"
      echo "  -h, --help       Show this help message"
      exit 0
      ;;
    *)
      echo -e "${YELLOW}Unknown option: $1. Defaulting to global install.${NC}"
      shift
      ;;
  esac
done

# Step 1: Detect OS
OS_TYPE="unknown"
case "$(uname -s)" in
  Darwin*) OS_TYPE="macos" ;;
  Linux*)  OS_TYPE="linux" ;;
  *)       OS_TYPE="unsupported" ;;
esac

echo -e "${CYAN}➜ Detected Operating System:${NC} ${BOLD}${OS_TYPE}${NC}"
if [ "$OS_TYPE" = "unsupported" ]; then
  echo -e "${RED}Error: Unsupported operating system. Antigravity RTL supports macOS and Linux.${NC}"
  exit 1
fi

# Step 2: Determine Target Path
if [ "$INSTALL_MODE" = "workspace" ]; then
  TARGET_DIR="./.agents/rules"
  TARGET_FILE="${TARGET_DIR}/persian-rtl.md"
  echo -e "${BLUE}➜ Installation scope:${NC} ${BOLD}Workspace${NC} (${TARGET_FILE})"
else
  TARGET_DIR="${HOME}/.gemini/config/rules"
  TARGET_FILE="${TARGET_DIR}/persian-rtl.md"
  echo -e "${BLUE}➜ Installation scope:${NC} ${BOLD}Global${NC} (${TARGET_FILE})"
fi

# Create target directory
mkdir -p "$TARGET_DIR"

# Step 3: Install Rule File
echo -e "${CYAN}➜ Installing Persian RTL rule file...${NC}"

if [ -f "$LOCAL_RULE_FILE" ]; then
  cp "$LOCAL_RULE_FILE" "$TARGET_FILE"
else
  # Running via curl / remote pipe
  echo -e "  Fetching rule from GitHub repository..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${RAW_GITHUB_BASE}/rules/persian-rtl.md" -o "$TARGET_FILE"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TARGET_FILE" "${RAW_GITHUB_BASE}/rules/persian-rtl.md"
  else
    echo -e "${RED}Error: Neither curl nor wget found. Unable to fetch rule file.${NC}"
    exit 1
  fi
fi

if [ -f "$TARGET_FILE" ]; then
  echo -e "  ${GREEN}✓ Rule installed at:${NC} ${BOLD}${TARGET_FILE}${NC}"
else
  echo -e "${RED}✗ Failed to install rule file.${NC}"
  exit 1
fi

# Step 4: Font Check (Vazirmatn)
echo -e "${CYAN}➜ Checking typography requirements (Vazirmatn font)...${NC}"
FONT_FOUND=false

if [ "$OS_TYPE" = "macos" ]; then
  if find /Library/Fonts ~/Library/Fonts /System/Library/Fonts -iname "*vazirmatn*" 2>/dev/null | grep -q .; then
    FONT_FOUND=true
  elif command -v brew >/dev/null 2>&1 && brew list --cask 2>/dev/null | grep -q "font-vazirmatn"; then
    FONT_FOUND=true
  fi
elif [ "$OS_TYPE" = "linux" ]; then
  if command -v fc-list >/dev/null 2>&1 && fc-list : family | grep -qi "vazirmatn"; then
    FONT_FOUND=true
  elif find /usr/share/fonts ~/.local/share/fonts ~/.fonts -iname "*vazirmatn*" 2>/dev/null | grep -q .; then
    FONT_FOUND=true
  fi
fi

if [ "$FONT_FOUND" = true ]; then
  echo -e "  ${GREEN}✓ Vazirmatn font is already installed on your system!${NC}"
else
  echo -e "  ${YELLOW}⚠ Vazirmatn font was not detected.${NC}"
  echo -e "    While Tahoma/system-ui fallback is active, installing ${BOLD}Vazirmatn${NC} gives you pixel-perfect rendering."
  if [ "$OS_TYPE" = "macos" ]; then
    echo -e "    To install via Homebrew on macOS, run:"
    echo -e "    ${BOLD}brew install --cask font-vazirmatn${NC}"
  elif [ "$OS_TYPE" = "linux" ]; then
    echo -e "    To install on Debian/Ubuntu, run:"
    echo -e "    ${BOLD}sudo apt-get install fonts-vazirmatn${NC}  (or download from https://github.com/rastikerdar/vazirmatn)"
  fi
fi

# Step 5: Completion Summary
echo ""
echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN}${BOLD}🎉 Installation Complete!${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo -e "Your Antigravity agent will now automatically format Persian and Arabic"
echo -e "responses in beautiful, high-contrast RTL cards with BiDi token isolation."
echo ""
echo -e "To verify your setup anytime, run: ${CYAN}./scripts/verify_setup.sh${NC}"
echo -e "To uninstall anytime, run:          ${CYAN}./uninstall.sh${NC}"
echo ""
