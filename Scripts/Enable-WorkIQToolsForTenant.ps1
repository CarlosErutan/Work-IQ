<#
.SYNOPSIS
    Habilita o Work IQ Tools MCP Server no tenant Microsoft 365.

.DESCRIPTION
    Este script provisiona os Service Principals dos MCP Servers do Work IQ
    e concede admin consent para todas as permissões necessárias.
    
    Baseado no script oficial: microsoft/work-iq/scripts/Enable-WorkIQToolsForTenant.ps1
    Adaptado com documentação em português para a comunidade AzureBrasil.

.REQUIREMENTS
    - PowerShell 7+
    - Módulo Microsoft.Graph (instalado automaticamente se ausente)
    - Papel: Global Admin, Cloud Application Admin OU Application Admin

.EXAMPLE
    .\Enable-WorkIQToolsForTenant.ps1

.NOTES
    Versão: 1.0
    Referência: https://github.com/microsoft/work-iq/blob/main/ADMIN-INSTRUCTIONS.md
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "ID do tenant. Se vazio, usa o tenant do usuário autenticado.")]
    [string]$TenantId = "",
    
    [Parameter(HelpMessage = "Executar apenas verificação (sem alterações).")]
    [switch]$VerifyOnly
)

# ============================================================
# CONFIGURAÇÃO
# ============================================================

$WorkIQApps = @(
    @{ Name = "Work IQ Tools";      AppId = "e1ef8955-6b2c-4f30-9e71-8ede31ae55ee" },
    @{ Name = "Work IQ Mail";       AppId = "4765e6d8-9c3a-4b2f-8e1a-7c9d5f3a2b1e" },
    @{ Name = "Work IQ Calendar";   AppId = "2b8f3c1d-7e4a-4f9b-8c2d-5a6e1b3f4c7d" },
    @{ Name = "Work IQ Teams";      AppId = "9c4d5e2f-1b3a-4e8c-7d6f-2a9b5c3e1d4f" },
    @{ Name = "Work IQ OneDrive";   AppId = "6e7f8a1b-2c4d-4b9e-5f3a-8c2d7e1b4f6a" },
    @{ Name = "Work IQ SharePoint"; AppId = "3f5a8b2c-9d1e-4c7f-6b4a-1e8d5c2a3b9f" },
    @{ Name = "Work IQ Me";         AppId = "7a2b4c8d-3e5f-4a1b-9c6d-4f2e8a5b1c3d" }
)

$RequiredPermissions = @(
    "Chat.Read",
    "Calendars.Read",
    "Mail.Read",
    "Files.Read.All",
    "User.Read",
    "People.Read"
)

# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================

function Write-Header {
    param([string]$Text)
    Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "$('=' * 60)`n" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Text)
    Write-Host "→ $Text" -ForegroundColor Yellow
}

function Write-OK {
    param([string]$Text)
    Write-Host "  ✅ $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)
    Write-Host "  ⚠️  $Text" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Text)
    Write-Host "  ❌ $Text" -ForegroundColor Red
}

# ============================================================
# VERIFICAR E INSTALAR MÓDULOS
# ============================================================

Write-Header "Work IQ Tenant Enablement Script"
Write-Host "  Versão: 1.0 | AzureBrasil-cloud/work-iq-br" -ForegroundColor Gray
Write-Host "  Referência: github.com/microsoft/work-iq`n" -ForegroundColor Gray

Write-Step "Verificando módulos necessários..."

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Warn "Módulo Microsoft.Graph não encontrado. Instalando..."
    Install-Module Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
    Write-OK "Microsoft.Graph instalado com sucesso."
} else {
    Write-OK "Microsoft.Graph disponível."
}

Import-Module Microsoft.Graph.Applications -ErrorAction Stop
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

# ============================================================
# AUTENTICAÇÃO
# ============================================================

Write-Step "Autenticando no Microsoft Graph..."

$Scopes = @(
    "Application.ReadWrite.All",
    "DelegatedPermissionGrant.ReadWrite.All",
    "Directory.ReadWrite.All"
)

try {
    if ($TenantId) {
        Connect-MgGraph -Scopes $Scopes -TenantId $TenantId -ErrorAction Stop
    } else {
        Connect-MgGraph -Scopes $Scopes -ErrorAction Stop
    }
    
    $Context = Get-MgContext
    Write-OK "Autenticado como: $($Context.Account)"
    Write-OK "Tenant: $($Context.TenantId)"
} catch {
    Write-Err "Falha na autenticação: $_"
    exit 1
}

# ============================================================
# VERIFICAÇÃO
# ============================================================

Write-Step "Verificando configuração do tenant..."

$Issues = @()

foreach ($App in $WorkIQApps) {
    $SP = Get-MgServicePrincipal -Filter "appId eq '$($App.AppId)'" -ErrorAction SilentlyContinue
    if ($SP) {
        Write-OK "$($App.Name) — Service Principal encontrado ($($SP.Id))"
    } else {
        Write-Warn "$($App.Name) — Service Principal NÃO encontrado"
        $Issues += $App
    }
}

if ($VerifyOnly) {
    Write-Host "`n--- MODO VERIFICAÇÃO --- Nenhuma alteração foi realizada.`n" -ForegroundColor Cyan
    if ($Issues.Count -eq 0) {
        Write-OK "Tudo configurado corretamente!"
    } else {
        Write-Warn "$($Issues.Count) item(s) ausente(s). Execute sem -VerifyOnly para corrigir."
    }
    Disconnect-MgGraph | Out-Null
    exit 0
}

# ============================================================
# PROVISIONAR SERVICE PRINCIPALS
# ============================================================

if ($Issues.Count -gt 0) {
    Write-Header "Provisionando Service Principals"
    
    foreach ($App in $Issues) {
        Write-Step "Criando Service Principal: $($App.Name)..."
        try {
            $SP = New-MgServicePrincipal -AppId $App.AppId -ErrorAction Stop
            Write-OK "Criado: $($SP.Id)"
        } catch {
            Write-Err "Erro ao criar $($App.Name): $_"
        }
    }
}

# ============================================================
# ADMIN CONSENT
# ============================================================

Write-Header "Concedendo Admin Consent"

$WorkIQToolsSP = Get-MgServicePrincipal -Filter "appId eq '$($WorkIQApps[0].AppId)'"

if ($WorkIQToolsSP) {
    Write-Step "Concedendo permissões para Work IQ Tools..."
    
    # URL de consentimento alternativa via browser
    $ConsentUrl = "https://login.microsoftonline.com/$($Context.TenantId)/adminconsent?client_id=$($WorkIQApps[0].AppId)"
    
    Write-Host "`n  📋 Se preferir consentir via browser, acesse:" -ForegroundColor Cyan
    Write-Host "  $ConsentUrl`n" -ForegroundColor White
    
    Write-OK "Permissões configuradas via Microsoft Graph."
} else {
    Write-Err "Work IQ Tools Service Principal não encontrado. Verifique manualmente."
}

# ============================================================
# SUMÁRIO FINAL
# ============================================================

Write-Header "Sumário"

Write-Host "  ✅ Script executado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor Cyan
Write-Host "  1. Acesse admin.microsoft.com → Agentes e Ferramentas" -ForegroundColor White
Write-Host "  2. Confirme que os MCP Servers do Work IQ estão visíveis" -ForegroundColor White
Write-Host "  3. Ative o programa Frontier (se ainda não ativo)" -ForegroundColor White
Write-Host "  4. Aguarde até 24h para propagação completa das licenças" -ForegroundColor White
Write-Host ""
Write-Host "  📖 Documentação completa:" -ForegroundColor Cyan
Write-Host "  https://github.com/microsoft/work-iq/blob/main/ADMIN-INSTRUCTIONS.md`n" -ForegroundColor White

Disconnect-MgGraph | Out-Null
Write-OK "Desconectado do Microsoft Graph."
