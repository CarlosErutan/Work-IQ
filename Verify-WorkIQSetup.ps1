<#
.SYNOPSIS
    Verifica a configuração do Work IQ no tenant (somente leitura).

.DESCRIPTION
    Script de diagnóstico que verifica se o Work IQ está corretamente
    configurado no tenant sem fazer nenhuma alteração.

.EXAMPLE
    .\Verify-WorkIQSetup.ps1

.NOTES
    Este script é seguro para executar em produção — apenas leitura.
    Referência: github.com/microsoft/work-iq
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [string]$TenantId = ""
)

$WorkIQApps = @(
    @{ Name = "Work IQ Tools";      AppId = "e1ef8955-6b2c-4f30-9e71-8ede31ae55ee" },
    @{ Name = "Work IQ Mail";       AppId = "4765e6d8-9c3a-4b2f-8e1a-7c9d5f3a2b1e" },
    @{ Name = "Work IQ Calendar";   AppId = "2b8f3c1d-7e4a-4f9b-8c2d-5a6e1b3f4c7d" },
    @{ Name = "Work IQ Teams";      AppId = "9c4d5e2f-1b3a-4e8c-7d6f-2a9b5c3e1d4f" }
)

Write-Host "`n🔍 Work IQ — Diagnóstico do Tenant`n" -ForegroundColor Cyan
Write-Host "Conectando ao Microsoft Graph (somente leitura)..." -ForegroundColor Yellow

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "❌ Microsoft.Graph não instalado. Execute:" -ForegroundColor Red
    Write-Host "   Install-Module Microsoft.Graph -Scope CurrentUser" -ForegroundColor White
    exit 1
}

Import-Module Microsoft.Graph.Applications -ErrorAction Stop
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

try {
    $ConnectParams = @{ Scopes = @("Application.Read.All", "Directory.Read.All") }
    if ($TenantId) { $ConnectParams.TenantId = $TenantId }
    Connect-MgGraph @ConnectParams -ErrorAction Stop

    $Context = Get-MgContext
    Write-Host "✅ Conectado: $($Context.Account) | Tenant: $($Context.TenantId)`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Falha na autenticação: $_" -ForegroundColor Red
    exit 1
}

$AllOK = $true

foreach ($App in $WorkIQApps) {
    $SP = Get-MgServicePrincipal -Filter "appId eq '$($App.AppId)'" -ErrorAction SilentlyContinue
    if ($SP) {
        Write-Host "  ✅ $($App.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($App.Name) — NÃO encontrado" -ForegroundColor Red
        $AllOK = $false
    }
}

Write-Host ""
if ($AllOK) {
    Write-Host "✅ Configuração OK! O Work IQ está habilitado neste tenant.`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  Configuração incompleta. Execute Enable-WorkIQToolsForTenant.ps1`n" -ForegroundColor Yellow
}

Disconnect-MgGraph | Out-Null
