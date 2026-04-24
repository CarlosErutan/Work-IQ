# Plugin Executor MCP

# Construindo o Plugin Executor MCP (Operações de Escrita)

O Work IQ nativo é o **Leitor**. Para que a IA execute **ações** no tenant (criar, atualizar, revogar), você precisa construir um **Plugin Executor** usando o mesmo protocolo MCP.

## Fase 1 — Obter token com permissões de escrita

1. Abra o [Graph Explorer](https://developer.microsoft.com/graph/graph-explorer)
2. Faça login com sua conta admin/dev
3. Acesse a aba **Modify permissions**
4. Adicione as permissões necessárias (ex: `User.ReadWrite`, `Group.ReadWrite.All`)
5. Clique em **Consent** e aceite o pop-up
6. Vá na aba **Access token** e copie o token gerado

> ⚠️ **Segurança:** Tokens JWT são credenciais sensíveis. Nunca os armazene em código, repositórios públicos ou documentos compartilhados. Eles expiram em ~1 hora.
> 

## Fase 2 — Criar a estrutura do projeto

```powershell
# Criar pasta e entrar nela
mkdir mcp-executor-infra
cd mcp-executor-infra

# Iniciar projeto Node.js e instalar SDK MCP
npm init -y
npm install @modelcontextprotocol/sdk
```

## Fase 3 — Criar o servidor MCP (index.mjs)

```jsx
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";

// Token passado como variável de ambiente (NUNCA hardcode)
const TOKEN = process.env.M365_TOKEN;

const server = new Server(
  { name: "executor-entraid", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

// 1. Apresenta a ferramenta para a IA
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [{
    name: "atualizar_cargo",
    description: "Atualiza o cargo do usuário logado diretamente no Entra ID",
    inputSchema: {
      type: "object",
      properties: {
        novoCargo: { type: "string", description: "O título do novo cargo" }
      },
      required: ["novoCargo"]
    }
  }]
}));

// 2. Executa quando a IA solicitar
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name !== "atualizar_cargo") throw new Error("Ferramenta não encontrada.");

  const novoCargo = request.params.arguments.novoCargo;

  const response = await fetch("https://graph.microsoft.com/v1.0/me", {
    method: "PATCH",
    headers: {
      "Authorization": `Bearer ${TOKEN}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ jobTitle: novoCargo })
  });

  if (!response.ok) {
    const errorData = await response.text();
    return { content: [{ type: "text", text: `Falha: ${errorData}` }] };
  }

  return { content: [{ type: "text", text: `Sucesso! Cargo atualizado para: ${novoCargo}` }] };
});

// 3. Liga o servidor (stdio — comunicação invisível com o agente)
const transport = new StdioServerTransport();
await server.connect(transport);
```

## Fase 4 — Executar e testar com o MCP Inspector

```powershell
# PASSO 1: Definir o token como variável de ambiente
# (substitua pelo token copiado do Graph Explorer)
$env:M365_TOKEN="COLE_SEU_TOKEN_AQUI"

# PASSO 2: Iniciar o MCP Inspector (em linha separada!)
npx @modelcontextprotocol/inspector node index.mjs
```

> ⚠️ **Dica crítica do PowerShell:** Defina o token e chame o inspector em **duas linhas separadas**. Colocar tudo na mesma linha causa falha de parsing.
> 

**No navegador:**

1. Acesse `http://localhost:5173`
2. Clique em **Connect**
3. Vá na aba **Tools**
4. Selecione `atualizar_cargo` e passe `"Analista de Infra Master"` no campo JSON
5. Clique em **Run Tool**

---

---