<#
.SYNOPSIS
    Instala e configura o Work IQ CLI no Windows.

.DESCRIPTION
    Script de setup completo para Windows que:
    - Verifica pré-requisitos (Node.js)
    - Instala o Work IQ CLI via NPM
    - Aceita a EULA
    - Configura o VS Code para usar o MCP Server
    - Configura o GitHub Copilot CLI

.EXAMPLE
    .\setup-workiq-cli.ps1

.NOTES
    Referência: github.com/microsoft/work-iq
#>

#Requires -Version 7.0

function Write-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    Work IQ CLI — Setup (Windows)         ║" -ForegroundColor Cyan
    Write-Host "║    github.com/AzureBrasil-cloud          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step { param([string]$T) Write-Host "→ $T" -ForegroundColor Yellow }
function Write-OK   { param([string]$T) Write-Host "  ✅ $T" -ForegroundColor Green }
function Write-Warn { param([string]$T) Write-Host "  ⚠️  $T" -ForegroundColor Yellow }
function Write-Fail { param([string]$T) Write-Host "  ❌ $T" -ForegroundColor Red }

Write-Banner

# ─── Verificar Node.js ─────────────────────────────────────
Write-Step "Verificando Node.js..."

try {
    $NodeVersion = node --version 2>$null
    Write-OK "Node.js $NodeVersion encontrado"
} catch {
    Write-Fail "Node.js não encontrado!"
    Write-Host ""
    Write-Host "  Instale o Node.js usando um dos métodos:" -ForegroundColor Cyan
    Write-Host "  • winget:  winget install OpenJS.NodeJS.LTS" -ForegroundColor White
    Write-Host "  • Site:    https://nodejs.org/pt-br/download" -ForegroundColor White
    Write-Host ""
    exit 1
}

# ─── Instalar Work IQ CLI ──────────────────────────────────
Write-Step "Instalando @microsoft/workiq globalmente..."
npm install -g @microsoft/workiq
if ($LASTEXITCODE -eq 0) {
    Write-OK "Work IQ CLI instalado com sucesso"
} else {
    Write-Fail "Falha na instalação. Verifique permissões do NPM."
    exit 1
}

# ─── Aceitar EULA ──────────────────────────────────────────
Write-Step "Aceitando EULA (obrigatório na primeira execução)..."
workiq accept-eula
Write-OK "EULA aceito"

# ─── Configurar VS Code ────────────────────────────────────
Write-Step "Configurando MCP no VS Code..."

$VSCodeSettingsPath = "$env:APPDATA\Code\User\settings.json"

if (Test-Path $VSCodeSettingsPath) {
    Write-Warn "settings.json já existe. Verifique e adicione manualmente se necessário."
    Write-Host "     Arquivo: $VSCodeSettingsPath" -ForegroundColor Gray
    Write-Host "     Config necessária: mcp-configs/vscode-settings.json" -ForegroundColor Gray
} else {
    $MCPConfig = @{
        "github.copilot.chat.mcp.servers" = @{
            workiq = @{
                command = "npx"
                args    = @("-y", "@microsoft/workiq@latest", "mcp")
                tools   = @("*")
            }
        }
    } | ConvertTo-Json -Depth 5

    New-Item -Path (Split-Path $VSCodeSettingsPath) -ItemType Directory -Force | Out-Null
    $MCPConfig | Set-Content -Path $VSCodeSettingsPath -Encoding UTF8
    Write-OK "VS Code configurado em: $VSCodeSettingsPath"
}

# ─── Instalar no GitHub Copilot CLI (opcional) ─────────────
Write-Step "Verificando GitHub Copilot CLI..."

$CopilotAvailable = Get-Command copilot -ErrorAction SilentlyContinue
if ($CopilotAvailable) {
    Write-OK "GitHub Copilot CLI encontrado"
    Write-Host "  Execute manualmente no Copilot CLI:" -ForegroundColor Cyan
    Write-Host "  /plugin marketplace add microsoft/work-iq" -ForegroundColor White
    Write-Host "  /plugin install workiq@work-iq" -ForegroundColor White
} else {
    Write-Warn "GitHub Copilot CLI não encontrado"
    Write-Host "  Instale em: https://githubnext.com/projects/copilot-cli" -ForegroundColor Gray
}

# ─── Teste rápido ──────────────────────────────────────────
Write-Step "Testando a instalação..."
$WorkIQVersion = workiq --version 2>$null
if ($WorkIQVersion) {
    Write-OK "Work IQ CLI: $WorkIQVersion"
} else {
    Write-OK "Work IQ CLI instalado (use 'workiq --version' para verificar)"
}

# ─── Sumário ───────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           INSTALAÇÃO CONCLUÍDA!          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Testar a CLI:" -ForegroundColor White
Write-Host "     workiq ask -q 'Quais reuniões tenho hoje?'" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. No VS Code — ativar o MCP:" -ForegroundColor White
Write-Host "     Copilot Chat → ícone 🔧 Ferramentas → ativar 'workiq'" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Via GitHub Copilot CLI:" -ForegroundColor White
Write-Host "     copilot → /plugin install workiq@work-iq" -ForegroundColor Gray
Write-Host ""
Write-Host "  📖 Docs: https://github.com/microsoft/work-iq" -ForegroundColor Cyan
Write-Host ""
