#!/usr/bin/env bash
# ==============================================================================
# Antigravity RTL Persian/Arabic Display Kit - Setup Verification Script
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}=== Antigravity RTL Verification ===${NC}\n"

ERRORS=0
WARNINGS=0

# 1. OS Check
OS_NAME="$(uname -s)"
echo -e "${BLUE}[1/4] Operating System:${NC} ${OS_NAME} ($(uname -m))"

# 2. Font Check (Vazirmatn)
echo -e "\n${BLUE}[2/4] Typography & Font Verification:${NC}"
FONT_FOUND=false

if [ "$OS_NAME" = "Darwin" ]; then
  if find /Library/Fonts ~/Library/Fonts /System/Library/Fonts -iname "*vazirmatn*" 2>/dev/null | grep -q .; then
    FONT_FOUND=true
    FONT_PATH=$(find /Library/Fonts ~/Library/Fonts /System/Library/Fonts -iname "*vazirmatn*" 2>/dev/null | head -n 1)
  elif command -v brew >/dev/null 2>&1 && brew list --cask 2>/dev/null | grep -q "font-vazirmatn"; then
    FONT_FOUND=true
    FONT_PATH="Homebrew Cask (font-vazirmatn)"
  fi
elif [ "$OS_NAME" = "Linux" ]; then
  if command -v fc-list >/dev/null 2>&1 && fc-list : family | grep -qi "vazirmatn"; then
    FONT_FOUND=true
    FONT_PATH="$(fc-list : family | grep -i vazirmatn | head -n 1)"
  elif find /usr/share/fonts ~/.local/share/fonts ~/.fonts -iname "*vazirmatn*" 2>/dev/null | grep -q .; then
    FONT_FOUND=true
    FONT_PATH=$(find /usr/share/fonts ~/.local/share/fonts ~/.fonts -iname "*vazirmatn*" 2>/dev/null | head -n 1)
  fi
fi

if [ "$FONT_FOUND" = true ]; then
  echo -e "  ${GREEN}✓ Vazirmatn is installed:${NC} ${FONT_PATH}"
else
  echo -e "  ${YELLOW}⚠ Vazirmatn font not found on system.${NC}"
  echo -e "    Fallback fonts (Tahoma, system-ui) will be used, but Vazirmatn is strongly recommended."
  if [ "$OS_NAME" = "Darwin" ]; then
    echo -e "    Run: ${BOLD}brew install --cask font-vazirmatn${NC}"
  else
    echo -e "    Run: ${BOLD}sudo apt-get install fonts-vazirmatn${NC} (or install from rastikerdar/vazirmatn)"
  fi
  WARNINGS=$((WARNINGS + 1))
fi

# 3. Rule Files Check
echo -e "\n${BLUE}[3/4] Antigravity Rules Check:${NC}"
GLOBAL_RULE="${HOME}/.gemini/config/rules/bidi-rtl.md"
WORKSPACE_RULE="./.agents/rules/bidi-rtl.md"
LEGACY_GLOBAL_RULE="${HOME}/.gemini/config/rules/persian-rtl.md"

RULE_ACTIVE=false

check_rule() {
  local path="$1"
  local type="$2"

  if [ -f "$path" ]; then
    if grep -q "trigger: always_on" "$path"; then
      echo -e "  ${GREEN}✓ ${type} Rule Active & Valid:${NC} ${path}"
      RULE_ACTIVE=true
    else
      echo -e "  ${YELLOW}⚠ ${type} Rule found but missing 'trigger: always_on':${NC} ${path}"
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    echo -e "  ${NC}- ${type} Rule not present (${path})${NC}"
  fi
}

check_rule "$GLOBAL_RULE" "Global (bidi-rtl.md)"
check_rule "$WORKSPACE_RULE" "Workspace (bidi-rtl.md)"

if [ -f "$LEGACY_GLOBAL_RULE" ]; then
  echo -e "  ${YELLOW}ℹ Notice: Legacy persian-rtl.md found. Run ./install.sh to migrate to bidi-rtl.md.${NC}"
fi

if [ "$RULE_ACTIVE" = false ]; then
  echo -e "  ${RED}✗ No active RTL rule found.${NC}"
  echo -e "    Run ${BOLD}./install.sh${NC} to install the rule."
  ERRORS=$((ERRORS + 1))
fi

# 4. Antigravity Environment Directory
echo -e "\n${BLUE}[4/4] Environment Check:${NC}"
if [ -d "${HOME}/.gemini/antigravity" ]; then
  echo -e "  ${GREEN}✓ Antigravity App Data directory detected:${NC} ~/.gemini/antigravity"
else
  echo -e "  ${YELLOW}ℹ Antigravity App Data directory not created yet (will be created when Antigravity runs)${NC}"
fi

# Final Summary
echo -e "\n${BOLD}=== Verification Summary ===${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✓ Perfect! Your Antigravity RTL Persian environment is completely configured.${NC}\n"
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}✓ Operational with ${WARNINGS} recommendation(s). (See above)${NC}\n"
else
  echo -e "${RED}✗ Setup incomplete: ${ERRORS} error(s) found. Run ./install.sh to fix.${NC}\n"
  exit 1
fi
