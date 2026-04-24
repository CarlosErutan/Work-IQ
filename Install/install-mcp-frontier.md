# 🚀 Demo: Habilitar MCP Frontier no Microsoft 365

> Walkthrough completo: da habilitação do Frontier até o MCP ativo no Copilot Studio.

---

## Visão Geral do Fluxo

```
Admin M365              Copilot Studio          Usuário Final
    │                        │                       │
    ├─ 1. Ativa Frontier ───►│                       │
    │                        │                       │
    ├─ 2. Admin Consent ────►│                       │
    │   (PowerShell script)  │                       │
    │                        │                       │
    │                        ├─ 3. Adiciona MCP ────►│
    │                        │   Work IQ User         │
    │                        │   Work IQ Calendar     │
    │                        │                       │
    │                        │                       ├─ 4. Testa agent
    │                        │                       │   "Quem é meu gestor?"
    │                        │◄──────────────────────┤
    │                        │   Resposta do M365    │
```

---

## PARTE 1 — Admin: Habilitar o Frontier

### 1.1 Acessar o Microsoft 365 Admin Center

1. Acesse: [https://admin.microsoft.com](https://admin.microsoft.com)
2. Faça login com conta de **Administrador Global**

### 1.2 Ativar o Programa Frontier

1. No menu lateral: **Configurações** → **Configurações da Organização**
2. Clique na aba **Serviços**
3. Procure por **"Microsoft 365 Insider"** ou **"Frontier"**
4. Clique em **Ativar** e selecione os usuários ou grupos desejados
5. Aguarde a propagação (pode levar até 24h)

> 💡 Sem o Frontier, os MCP Servers do Work IQ não aparecem no catálogo do Copilot Studio.

### 1.3 Executar o Script de Habilitação

```powershell
# Passo 1: Instalar módulo (se necessário)
Install-Module Microsoft.Graph -Scope CurrentUser

# Passo 2: Executar script de habilitação
cd scripts/
.\Enable-WorkIQToolsForTenant.ps1

# Passo 3: Verificar configuração
.\Verify-WorkIQSetup.ps1
```

**Ou use a URL de consentimento rápido:**
```
https://login.microsoftonline.com/SEU_TENANT_ID/adminconsent?client_id=e1ef8955-6b2c-4f30-9e71-8ede31ae55ee
```

---

## PARTE 2 — Copilot Studio: Adicionar MCP Servers

### Pré-requisitos para o Copilot Studio
- Acesso ao [Copilot Studio](https://copilotstudio.microsoft.com)
- Licença Microsoft 365 Copilot
- Frontier habilitado (Parte 1)

### 2.1 Abrir o Copilot Studio

1. Acesse: [https://copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)
2. Selecione o ambiente correto no canto superior direito

### 2.2 Criar ou Abrir um Agent

1. Clique em **+ Criar** ou selecione um agent existente
2. Nomeie o agent (ex: `Assistente Work IQ`)
3. Clique em **Criar**

### 2.3 Adicionar Work IQ User MCP

1. Na página de configuração do agent, clique em **Ferramentas** no menu lateral
2. Clique em **+ Adicionar ferramenta**
3. No catálogo, filtre por **Provedor: Microsoft**
4. Localize **Work IQ User (Preview)**
5. Clique em **Adicionar e configurar**
6. Clique em **Salvar**

### 2.4 Adicionar Work IQ Calendar MCP

Repita os passos acima para adicionar:
- **Work IQ Calendar (Preview)**

> 💡 Cada MCP Server é adicionado como **uma única ferramenta** que expõe múltiplas ações — diferente dos conectores tradicionais.

### 2.5 Testar o Agent

1. Clique em **Testar** no painel lateral
2. Envie: `"Quem é meu gestor?"`
3. O agent solicitará conexão — clique em **Abrir gerenciador de conexões**
4. Estabeleça a conexão para **Work IQ User MCP**
5. Volte ao painel e clique em **Tentar novamente**

**Prompts de teste sugeridos:**
```
"Quem é meu gestor?"
"Quais são meus subordinados diretos?"
"Quais reuniões tenho nas próximas 24 horas?"
"Qual é o cargo de [nome de colega]?"
```

---

## PARTE 3 — Azure AI Foundry: Configuração Pro-Code

Para desenvolvimento com Microsoft Foundry:

1. Acesse [ai.azure.com](https://ai.azure.com) e abra seu projeto
2. Clique em **Começar a Construir** → crie um agent (ex: `A365`)
3. Na configuração, selecione o modelo (ex: GPT-4o)
4. Clique em **+ Adicionar** em **Ferramentas**
5. No catálogo, filtre por **Provedor: Microsoft**
6. Adicione os **Microsoft 365 Frontier tools**:
   - User Profile
   - Outlook Calendar
   - Copilot Search

---

## PARTE 4 — Governança e Monitoramento

### Gerenciar no Admin Center

1. Acesse [admin.microsoft.com](https://admin.microsoft.com)
2. Navegue até **Agentes e Ferramentas**
3. Visualize todos os MCP Servers ativos
4. Use **Permitir** / **Bloquear** por política organizacional

### Monitorar via Microsoft Defender

```kusto
// Query no Advanced Hunting
// Inspecionar chamadas de ferramentas MCP
DeviceEvents
| where ActionType == "MCPToolCall"
| project Timestamp, DeviceName, ToolName, Parameters
| order by Timestamp desc
```

---

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `AADSTS650052` | Service Principal ausente | Execute `Enable-WorkIQToolsForTenant.ps1` |
| `Access Denied` | Sem permissão admin | Contate o Global Admin |
| MCP não aparece no catálogo | Frontier não ativo | Habilite via Admin Center |
| Sem dados retornando | Sem licença Copilot | Verifique licença em admin.microsoft.com |

---

## Referências

- [Work IQ Admin Instructions](https://github.com/microsoft/work-iq/blob/main/ADMIN-INSTRUCTIONS.md)
- [Copilot Studio — Use Work IQ](https://learn.microsoft.com/en-us/microsoft-copilot-studio/use-work-iq)
- [Agent Academy — Mission 10: MCP Servers](https://microsoft.github.io/agent-academy/operative/10-mcp/)
