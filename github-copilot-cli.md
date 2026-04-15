# 🤖 Demo: Work IQ no GitHub Copilot CLI

> Use linguagem natural no terminal para consultar seus dados do M365.

---

## Instalação Rápida

```bash
# 1. Abrir GitHub Copilot CLI
copilot

# 2. Adicionar marketplace (uma única vez)
/plugin marketplace add microsoft/work-iq

# 3. Instalar plugins
/plugin install workiq@work-iq
/plugin install workiq-productivity@work-iq

# 4. Sair e reiniciar o Copilot CLI
```

---

## Exemplos de Uso

### 📅 Reuniões e Calendário
```
Você: Quais são minhas reuniões de hoje?
Você: Tenho alguma reunião esta semana com a equipe de vendas?
Você: Qual é o custo desta reunião recorrente de segunda-feira?
Você: Quem organizou a reunião de ontem às 14h?
```

### 📧 E-mails
```
Você: Resuma os e-mails não lidos de hoje
Você: Existem e-mails urgentes da Sarah sobre o orçamento?
Você: Qual é o status do projeto X nos e-mails recentes?
```

### 📄 Documentos
```
Você: Encontre documentos em que trabalhei ontem
Você: Quais arquivos do SharePoint estão relacionados ao cliente Contoso?
Você: Existe alguma spec do projeto Y nos meus documentos?
```

### 👥 Pessoas e Organização
```
Você: Quem é meu gestor?
Você: Quais são meus subordinados diretos?
Você: Qual é o cargo de Maria Silva?
Você: Como entro em contato com o time de infraestrutura?
```

### 💡 Contexto para Código
```
Você: Quais requisitos foram discutidos na reunião de ontem com o cliente?
Você: Existem especificações técnicas para o módulo de autenticação nos meus documentos?
Você: O que o cliente Contoso solicitou no último e-mail sobre a API?
```

---

## Modo CLI Direto (sem Copilot)

```bash
# Instalar globalmente
npm install -g @microsoft/workiq

# Aceitar termos
workiq accept-eula

# Perguntas diretas
workiq ask -q "Quais reuniões tenho amanhã?"
workiq ask -q "Resuma meus e-mails da última hora"

# Especificando tenant
workiq ask -t "seu-tenant-id" -q "Quais documentos modifiquei hoje?"

# Modo interativo
workiq ask
```

---

## Referências

- [GitHub Work IQ README](https://github.com/microsoft/work-iq/blob/main/README.md)
- [Microsoft Learn — Work IQ CLI](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/workiq-overview)
