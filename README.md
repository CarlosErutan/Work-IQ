# 🤖 Work IQ MCP — Guia de Habilitação para Microsoft 365

> **Repositório de referência em português** para habilitação do Microsoft Work IQ CLI e MCP Servers no ambiente corporativo Microsoft 365.  
> Baseado em: [microsoft/work-iq](https://github.com/microsoft/work-iq) • Modelo: [AzureBrasil-cloud](https://github.com/AzureBrasil-cloud)

---

## 📋 O que é o Work IQ?

O **Microsoft Work IQ** é uma CLI e um servidor MCP (Model Context Protocol) que conecta assistentes de IA aos seus dados do Microsoft 365 Copilot. Com ele, você pode consultar e-mails, reuniões, documentos, mensagens do Teams e insights corporativos usando **linguagem natural**.

```
"Quais reuniões tenho amanhã?"
"Resuma os e-mails da Sarah sobre o orçamento"
"Encontre documentos em que trabalhei ontem"
```

> ⚠️ **Public Preview**: Recursos e APIs podem mudar.  
> Requer licença **Microsoft 365 Copilot** (add-on).

---

## 🗺️ Índice

1. [Pré-requisitos](#-pré-requisitos)
2. [Caminho Admin: Habilitar Frontier + Consentimento](#-caminho-admin-habilitar-frontier--consentimento)
3. [Instalação da CLI](#-instalação-da-cli)
4. [Configuração dos MCP Servers](#-configuração-dos-mcp-servers)
5. [Uso no GitHub Copilot CLI](#-uso-no-github-copilot-cli)
6. [Uso no VS Code](#-uso-no-vs-code)
7. [Scripts de Habilitação (Admin)](#-scripts-de-habilitação-admin)
8. [Demos e Exemplos](#-demos-e-exemplos)
9. [Troubleshooting](#-troubleshooting)

---

## ✅ Pré-requisitos

| Requisito | Detalhe |
|-----------|---------|
| Licença M365 Copilot | Obrigatório — sem ela o Work IQ não funciona |
| Node.js ≥ 18 | Inclui NPM e NPX |
| Conta GitHub Copilot | Para uso via GitHub Copilot CLI |
| Permissão Admin (tenant) | Para consentir as permissões MCP |
| PowerShell 7+ | Para executar os scripts de habilitação |

### Instalar Node.js
```bash
# Windows (winget)
winget install OpenJS.NodeJS.LTS

# macOS (brew)
brew install node

# Linux (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## 🛡️ Caminho Admin: Habilitar Frontier + Consentimento

> Esta seção é para **Administradores do Tenant M365**. Se você não for admin, envie este link ao seu administrador.

### Passo 1 — Habilitar o Programa Frontier (Microsoft 365 Admin Center)

O Work IQ MCP faz parte das funcionalidades de **pré-visualização do Frontier** da Microsoft.

1. Acesse [admin.microsoft.com](https://admin.microsoft.com)
2. Navegue até **Configurações → Configurações da Organização → Serviços**
3. Procure por **Microsoft 365 Insider (Frontier)**
4. Habilite o programa para os usuários desejados

> 📌 Sem o Frontier ativo, os MCP Servers do Work IQ não aparecerão no catálogo do Copilot Studio.

### Passo 2 — Consentimento Rápido (URL de 1 clique)

Use a URL de consentimento rápido para aprovar todas as permissões necessárias:

```
https://login.microsoftonline.com/common/adminconsent?client_id=<WORK_IQ_APP_ID>
```

> O App ID do Work IQ CLI está documentado em [ADMIN-INSTRUCTIONS.md](./docs/ADMIN-INSTRUCTIONS.md).

### Passo 3 — Executar Script de Habilitação PowerShell

Se o consentimento rápido falhar (erro `AADSTS650052`), execute o script:

```powershell
# Pré-requisito
Install-Module Microsoft.Graph -Scope CurrentUser

# Executar script de habilitação
.\scripts\Enable-WorkIQToolsForTenant.ps1
```

O script irá:
- Criar os Service Principals dos MCP Servers no seu tenant
- Conceder admin consent para todas as permissões necessárias
- Verificar a configuração do Microsoft 365 Copilot

### Passo 4 — Gerenciar MCP no Admin Center

Após a habilitação:
1. Acesse [admin.microsoft.com](https://admin.microsoft.com)
2. Navegue até **Agentes e Ferramentas**
3. Visualize e gerencie os MCP Servers ativos:
   - Work IQ Mail
   - Work IQ Calendar
   - Work IQ Teams
   - Work IQ OneDrive / SharePoint
4. Permita ou bloqueie servidores por política organizacional

---

## 💻 Instalação da CLI

### Opção A: Via GitHub Copilot CLI (Recomendada)

```bash
# 1. Abra o GitHub Copilot CLI
copilot

# 2. Adicionar o marketplace de plugins (uma única vez)
/plugin marketplace add microsoft/work-iq

# 3. Instalar os plugins Work IQ
/plugin install workiq@work-iq
/plugin install workiq-productivity@work-iq
/plugin install microsoft-365-agents-toolkit@work-iq

# 4. Aceitar os termos de uso (obrigatório)
workiq accept-eula
```

### Opção B: Instalação Global via NPM

```bash
# Instalar globalmente
npm install -g @microsoft/workiq

# Aceitar EULA
workiq accept-eula

# Testar
workiq ask -q "Quais reuniões tenho hoje?"
```

### Opção C: Uso direto com NPX (sem instalação)

```bash
npx -y @microsoft/workiq@latest ask -q "Quais reuniões tenho hoje?"
```

---

## ⚙️ Configuração dos MCP Servers

### VS Code — settings.json

Adicione ao seu `settings.json` do VS Code:

```json
{
  "github.copilot.chat.mcp.servers": {
    "workiq": {
      "command": "npx",
      "args": ["-y", "@microsoft/workiq@latest", "mcp"],
      "tools": ["*"]
    }
  }
}
```

Arquivo de configuração pronto: [`mcp-configs/vscode-settings.json`](./mcp-configs/vscode-settings.json)

### Claude Desktop / Cursor / Outros Clientes MCP

```json
{
  "mcpServers": {
    "workiq": {
      "command": "npx",
      "args": ["-y", "@microsoft/workiq@latest", "mcp"],
      "tools": ["*"]
    }
  }
}
```

Arquivo de configuração pronto: [`mcp-configs/mcp-config.json`](./mcp-configs/mcp-config.json)

---

## 🐙 Uso no GitHub Copilot CLI

Após instalar os plugins:

```bash
# Modo interativo
copilot

# Exemplos de perguntas
"Quais são minhas próximas reuniões esta semana?"
"Resuma os e-mails não lidos de hoje"
"Encontre documentos sobre o projeto X"
"Quem são meus subordinados diretos?"
"Qual é o custo desta reunião recorrente?"
```

---

## 💡 Uso no VS Code

1. Abra o VS Code com a extensão GitHub Copilot instalada
2. Clique no ícone 🔧 **Ferramentas** no painel do Copilot Chat
3. Ative o servidor **workiq**
4. Faça perguntas diretamente no chat do Copilot

---

## 📁 Scripts de Habilitação (Admin)

| Script | Descrição |
|--------|-----------|
| [`Enable-WorkIQToolsForTenant.ps1`](./scripts/Enable-WorkIQToolsForTenant.ps1) | Habilita todos os MCP Servers e concede admin consent |
| [`Verify-WorkIQSetup.ps1`](./scripts/Verify-WorkIQSetup.ps1) | Verifica se a configuração está correta (somente leitura) |
| [`setup-workiq-cli.sh`](./scripts/setup-workiq-cli.sh) | Instala a CLI Work IQ no Linux/macOS |
| [`setup-workiq-cli.ps1`](./scripts/setup-workiq-cli.ps1) | Instala a CLI Work IQ no Windows |

---

## 🎮 Demos e Exemplos

| Demo | Descrição |
|------|-----------|
| [`demos/install-mcp-frontier.md`](./demos/install-mcp-frontier.md) | Walkthrough completo: Frontier → Admin Consent → MCP no Copilot Studio |
| [`demos/github-copilot-cli.md`](./demos/github-copilot-cli.md) | Exemplos de uso no GitHub Copilot CLI |
| [`demos/vscode-integration.md`](./demos/vscode-integration.md) | Configuração e uso no VS Code |

---

## 🔧 Troubleshooting

### Erro: `AADSTS650052`
O Service Principal do Work IQ Tools não foi provisionado no tenant.
**Solução**: Execute o script `Enable-WorkIQToolsForTenant.ps1`

### Erro: `Access Denied` no consentimento
Você não tem permissão de admin.
**Solução**: Contate um Global Admin, Cloud Application Admin ou Application Admin.

### MCP não aparece no Copilot Studio
O programa Frontier pode não estar ativo.
**Solução**: Habilite via **Admin Center → Configurações → Microsoft 365 Insider**

### Dados do M365 não retornam
O Work IQ requer licença M365 Copilot ativa.
**Solução**: Verifique em [admin.microsoft.com](https://admin.microsoft.com) se a licença está atribuída.

---

## 📚 Referências

- [Microsoft Work IQ — Repositório Oficial](https://github.com/microsoft/work-iq)
- [Work IQ CLI — Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/workiq-overview)
- [Work IQ MCP Overview — Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview)
- [Work IQ Admin Instructions](https://github.com/microsoft/work-iq/blob/main/ADMIN-INSTRUCTIONS.md)
- [AzureBrasil Cloud](https://github.com/AzureBrasil-cloud)

---

## 🤝 Contribuindo

PRs são bem-vindos! Veja [`CONTRIBUTING.md`](./CONTRIBUTING.md) para detalhes.

---

> **Aviso**: Este repositório é uma referência comunitária em português. Não é afiliado oficialmente à Microsoft.  
> O Work IQ é um produto da Microsoft em Public Preview.
