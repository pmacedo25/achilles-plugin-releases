# Achilles Agent para VS Code

O Achilles é um agente de desenvolvimento integrado ao VS Code. Ele reúne chat, seleção de modelos, conexão com provedores de IA, combos de fallback, acompanhamento de uso e sincronização de skills em uma única extensão.

Este repositório contém somente os artefatos públicos de instalação, manifestos de atualização e documentação de uso. O código-fonte e detalhes internos do plugin não são publicados aqui.

## Requisitos

- Windows 10 ou 11.
- VS Code 1.90 ou superior.
- PowerShell 5.1 ou superior.
- Acesso ao GitHub para baixar a extensão.
- Uma conta ou chave válida em pelo menos um provider de IA.

## Instalação rápida

Abra o PowerShell e execute:

```powershell
irm https://raw.githubusercontent.com/pmacedo25/achilles-plugin-releases/main/install.ps1 | iex
```

O instalador baixa a beta mais recente, verifica o artefato publicado e instala o VSIX usando o CLI da IDE disponível.

Para selecionar explicitamente a IDE:

```powershell
$env:ACHILLES_IDE = "code" # code, cursor ou codium
irm https://raw.githubusercontent.com/pmacedo25/achilles-plugin-releases/main/install.ps1 | iex
```

Você também pode baixar o VSIX pela página de [Releases](https://github.com/pmacedo25/achilles-plugin-releases/releases) e usar **Extensions → … → Install from VSIX…**.

> Revise o conteúdo de [`install.ps1`](install.ps1) antes de executar scripts remotos em ambientes controlados.

## Primeiro uso

1. Recarregue o VS Code após a instalação.
2. Abra o ícone do Achilles na barra lateral.
3. No painel do agente, clique no botão do **Control Plane** para abrir o gerenciamento na área central da IDE.
4. Conecte ao menos um provider.
5. Escolha diretamente um provider/modelo no chat ou crie um combo de fallback.
6. Envie uma mensagem simples para confirmar a conexão.

## Configurar providers

No **Control Plane**, abra a aba **Providers** e clique em **Conectar provider**.

- Providers com login: siga a autorização exibida e conclua o acesso na página oficial aberta pelo Achilles.
- GitHub Copilot: copie o código mostrado pelo Achilles, abra a página oficial indicada e autorize o dispositivo.
- Providers com API key: informe a chave no formulário de conexão.
- Ollama local ou remoto: informe a URL acessível e, quando aplicável, a credencial do serviço.

Depois da conexão:

1. Atualize a lista de modelos do provider.
2. Desative modelos que não deseja oferecer ao agente.
3. Use **Testar** para validar rapidamente a credencial e a comunicação.
4. Volte ao chat e atualize o seletor caso o novo provider ainda não apareça.

Credenciais nunca são apresentadas novamente na tela. Use apenas páginas oficiais e não compartilhe códigos, chaves ou tokens.

## Dashboard e gerenciamento

O Control Plane é aberto pelo botão existente no painel do agente e ocupa a área central do VS Code.

Principais áreas:

- **Visão geral:** uso por período, tokens, custos estimados, cache, RTK e roteamento.
- **Providers:** conexões, modelos disponíveis, teste, ativação, reautenticação e remoção.
- **Quotas:** limites disponibilizados pelos providers conectados.
- **Combos / Modelos:** modelos habilitados e ordem de fallback.
- **Recent Requests:** chamadas recentes e contadores de tokens, sem exibir o conteúdo das conversas.

O refresh automático pode ser ativado no topo do dashboard e, quando ligado, atualiza os dados a cada 10 segundos.

## Criar um combo de fallback

1. Conecte e teste os providers desejados.
2. Abra **Combos / Modelos**.
3. Clique em **Criar combo**.
4. Defina um nome curto.
5. Adicione até três modelos na ordem desejada.
6. Salve e selecione o combo no chat.

O primeiro modelo é a rota principal. Os seguintes são tentados em ordem quando a chamada anterior não pode ser concluída.

## Configurar um repositório pessoal de skills

No chat do Achilles, abra **Settings → Skills**:

1. Informe o repositório no formato `owner/repositorio`.
2. Informe a branch, tag ou commit em **Branch ou ref**.
3. Para repositório privado, informe um token GitHub ou autentique o GitHub CLI com `gh auth login`.
4. Clique em **Salvar e testar sincronização**.
5. Confirme o status e a quantidade de skills carregadas.

O token informado pela tela é guardado pelo cofre seguro da IDE e não é mostrado novamente. Para um repositório público, o token é opcional.

### Estrutura esperada

```text
meu-repositorio/
├── skills/
│   ├── agent/
│   │   └── minha-skill/
│   │       └── SKILL.md
│   ├── plan/
│   ├── testing/
│   └── infra/
└── system-prompts/
    └── project-governance.md
```

- `agent`: skills gerais de desenvolvimento.
- `plan`: análise, requisitos e planejamento.
- `testing`: validação, qualidade e testes.
- `infra`: ambiente, build e infraestrutura.
- `project-governance.md`: regras gerais aplicadas às sessões do agente.

Copie a pasta [`templates/skills-repository`](templates/skills-repository) para iniciar um catálogo próprio. O arquivo [`docs/SKILLS_REPOSITORY.md`](docs/SKILLS_REPOSITORY.md) explica o formato completo.

## Atualizações beta

Em **Settings → Agente**, ative **Receber versões beta**. O Achilles verificará o canal beta e oferecerá versões compatíveis. Desative a opção quando não quiser receber versões de teste.

## Diagnóstico

Se uma operação falhar:

1. Tente novamente após atualizar o dashboard.
2. Confirme que não existe outro login OAuth pendente para o mesmo provider.
3. Em ambiente corporativo, confirme acesso aos sites oficiais do provider e ao GitHub.
4. Abra **Settings → Diagnóstico** para consultar as informações disponibilizadas pelo plugin.
5. Ao reportar um problema, envie versão do plugin, provider, horário aproximado e mensagem sanitizada. Nunca envie tokens ou chaves.

## Versão atual

- Canal: beta.
- Versão: `0.2.9-beta`.
- [Download direto do VSIX](https://github.com/pmacedo25/achilles-plugin-releases/releases/download/v0.2.9-beta/achilles-plugin-0.2.9-beta.vsix).

## Segurança

- Baixe releases somente deste repositório.
- Verifique a origem da página de autenticação antes de autorizar.
- Use tokens com o menor escopo necessário.
- Não inclua credenciais em `SKILL.md`, `AGENTS.md` ou arquivos de governança.
- Revogue imediatamente qualquer credencial exposta por engano.
