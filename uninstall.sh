#!/usr/bin/env bash
# ==============================================================================
# Antigravity RTL Persian/Arabic Display Kit - Uninstaller
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

GLOBAL_FILE="${HOME}/.gemini/config/rules/persian-rtl.md"
WORKSPACE_FILE="./.agents/rules/persian-rtl.md"

MODE="both"

while [[ $# -gt 0 ]]; do
  case $1 in
    --workspace|-w)
      MODE="workspace"
      shift
      ;;
    --global|-g)
      MODE="global"
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -g, --global     Remove global rule (~/.gemini/config/rules/persian-rtl.md)"
      echo "  -w, --workspace  Remove workspace rule (./.agents/rules/persian-rtl.md)"
      echo "  -h, --help       Show this help message"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

echo -e "${CYAN}➜ Antigravity RTL Uninstaller${NC}"

REMOVED=0

remove_file() {
  local target="$1"
  local desc="$2"
  if [ -f "$target" ]; then
    rm -f "$target"
    echo -e "  ${GREEN}✓ Removed ${desc}:${NC} ${target}"
    REMOVED=$((REMOVED + 1))
  else
    echo -e "  ${YELLOW}ℹ ${desc} was not found:${NC} ${target}"
  fi
}

if [ "$MODE" = "global" ] || [ "$MODE" = "both" ]; then
  remove_file "$GLOBAL_FILE" "Global rule"
fi

if [ "$MODE" = "workspace" ] || [ "$MODE" = "both" ]; then
  remove_file "$WORKSPACE_FILE" "Workspace rule"
fi

echo ""
if [ $REMOVED -gt 0 ]; then
  echo -e "${GREEN}✓ Successfully uninstalled Antigravity RTL rule (${REMOVED} file(s) removed).${NC}"
else
  echo -e "${BLUE}ℹ No active installations found to remove.${NC}"
fi
