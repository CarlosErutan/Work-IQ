#!/bin/bash
# =============================================================
# setup-workiq-cli.sh
# Instala e configura o Work IQ CLI no Linux / macOS
# Referência: github.com/microsoft/work-iq
# =============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║     Work IQ CLI — Setup (Linux/macOS)    ║"
echo "║     github.com/AzureBrasil-cloud         ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ─── Verificar Node.js ─────────────────────────────────────
echo -e "${YELLOW}→ Verificando Node.js...${NC}"
if ! command -v node &>/dev/null; then
    echo -e "${RED}❌ Node.js não encontrado. Instale em: https://nodejs.org${NC}"
    echo ""
    echo "  macOS:   brew install node"
    echo "  Ubuntu:  sudo apt install nodejs npm"
    exit 1
fi

NODE_VER=$(node --version)
echo -e "${GREEN}  ✅ Node.js ${NODE_VER} encontrado${NC}"

# ─── Instalar Work IQ CLI ──────────────────────────────────
echo -e "${YELLOW}→ Instalando @microsoft/workiq globalmente...${NC}"
npm install -g @microsoft/workiq

echo -e "${GREEN}  ✅ Work IQ CLI instalado${NC}"

# ─── Aceitar EULA ──────────────────────────────────────────
echo -e "${YELLOW}→ Aceitando EULA (obrigatório)...${NC}"
workiq accept-eula
echo -e "${GREEN}  ✅ EULA aceito${NC}"

# ─── Configurar VS Code ────────────────────────────────────
echo ""
echo -e "${YELLOW}→ Configurando MCP para VS Code...${NC}"

VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
if [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
fi

mkdir -p "$VSCODE_SETTINGS_DIR"
SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

# Verificar se settings.json já existe
if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}  ⚠️  settings.json já existe. Verifique manualmente se necessário.${NC}"
    echo "     Arquivo: $SETTINGS_FILE"
    echo "     Adicione o conteúdo de: mcp-configs/vscode-settings.json"
else
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "github.copilot.chat.mcp.servers": {
    "workiq": {
      "command": "npx",
      "args": ["-y", "@microsoft/workiq@latest", "mcp"],
      "tools": ["*"]
    }
  }
}
EOF
    echo -e "${GREEN}  ✅ VS Code configurado em: ${SETTINGS_FILE}${NC}"
fi

# ─── Teste rápido ──────────────────────────────────────────
echo ""
echo -e "${YELLOW}→ Testando instalação...${NC}"
VERSION=$(workiq --version 2>/dev/null || echo "instalado")
echo -e "${GREEN}  ✅ Work IQ CLI: ${VERSION}${NC}"

# ─── Sumário ───────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              INSTALAÇÃO CONCLUÍDA        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "  Próximos passos:"
echo ""
echo "  1. Execute um teste:"
echo "     workiq ask -q 'Quais reuniões tenho hoje?'"
echo ""
echo "  2. No VS Code — ative o MCP:"
echo "     Copilot Chat → ícone 🔧 Ferramentas → ativar 'workiq'"
echo ""
echo "  3. Via GitHub Copilot CLI:"
echo "     copilot"
echo "     /plugin install workiq@work-iq"
echo ""
echo "  📖 Documentação: https://github.com/microsoft/work-iq"
echo ""
