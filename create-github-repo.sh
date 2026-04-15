#!/bin/bash
# =============================================================
# create-github-repo.sh
# Cria o repositório work-iq-br no GitHub e faz o push inicial
# 
# USO:
#   chmod +x create-github-repo.sh
#   ./create-github-repo.sh
#
# PRÉ-REQUISITOS:
#   - git instalado
#   - GitHub CLI (gh) instalado: https://cli.github.com
#   - Autenticado no GitHub CLI: gh auth login
# =============================================================

set -e

REPO_NAME="work-iq-br"
REPO_DESCRIPTION="Guia em português para habilitação do Microsoft Work IQ CLI e MCP Servers no ambiente M365"
VISIBILITY="public"   # "public" ou "private"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║  Criar Repositório GitHub: work-iq-br   ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ─── Verificar dependências ────────────────────────────────
echo -e "${YELLOW}→ Verificando dependências...${NC}"

if ! command -v git &>/dev/null; then
    echo "❌ git não encontrado. Instale em: https://git-scm.com"
    exit 1
fi

if ! command -v gh &>/dev/null; then
    echo "❌ GitHub CLI (gh) não encontrado."
    echo ""
    echo "  Instale o GitHub CLI:"
    echo "  • macOS:  brew install gh"
    echo "  • Linux:  https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo "  • Windows: winget install GitHub.cli"
    echo ""
    echo "  Depois faça login: gh auth login"
    exit 1
fi

# Verificar autenticação
if ! gh auth status &>/dev/null; then
    echo "❌ Não autenticado no GitHub CLI."
    echo "   Execute: gh auth login"
    exit 1
fi

echo -e "${GREEN}  ✅ git e GitHub CLI encontrados${NC}"

# ─── Criar repositório no GitHub ───────────────────────────
echo -e "${YELLOW}→ Criando repositório ${REPO_NAME} no GitHub...${NC}"

gh repo create "$REPO_NAME" \
    --description "$REPO_DESCRIPTION" \
    --$VISIBILITY \
    --confirm || {
        echo ""
        echo "  Se o repositório já existe, prossiga para o passo de push."
    }

echo -e "${GREEN}  ✅ Repositório criado!${NC}"

# ─── Inicializar git e fazer push ──────────────────────────
echo -e "${YELLOW}→ Inicializando git e fazendo push...${NC}"

# Obter nome de usuário do GitHub
GH_USER=$(gh api user --jq '.login')

cd "$(dirname "$0")/.."   # Vai para a raiz do repositório work-iq-br

git init
git add .
git commit -m "feat: initial commit — Work IQ BR setup scripts and guides

- README.md em português com guia completo
- scripts/Enable-WorkIQToolsForTenant.ps1 — habilitação admin
- scripts/Verify-WorkIQSetup.ps1 — verificação tenant
- scripts/setup-workiq-cli.sh — instalação Linux/macOS
- scripts/setup-workiq-cli.ps1 — instalação Windows
- mcp-configs/ — configurações prontas para VS Code e outros clientes
- demos/ — walkthroughs: Frontier, GitHub Copilot CLI, VS Code

Baseado em: github.com/microsoft/work-iq
Modelo: github.com/AzureBrasil-cloud"

git branch -M main
git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
git push -u origin main

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        REPOSITÓRIO CRIADO COM SUCESSO!   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  🔗 URL: ${GREEN}https://github.com/${GH_USER}/${REPO_NAME}${NC}"
echo ""
echo "  Próximos passos sugeridos:"
echo "  1. Adicione uma licença (Settings → License)"
echo "  2. Configure branch protection para 'main'"
echo "  3. Adicione tópicos: azure, microsoft365, mcp, workiq, copilot"
echo ""
