# Repositório de skills do Achilles

Este guia descreve somente o contrato público necessário para manter um catálogo pessoal de skills.

## Estrutura mínima

```text
skills/
└── agent/
    └── minha-skill/
        └── SKILL.md
system-prompts/
└── project-governance.md
```

As categorias reconhecidas são `agent`, `plan`, `testing` e `infra`. Cada skill fica em uma pasta própria e deve conter um `SKILL.md`.

## Formato do SKILL.md

```markdown
---
name: minha-skill
description: Explique quando usar e quando não usar esta skill.
---

# Minha skill

## Objetivo

Descreva o resultado esperado.

## Quando usar

- Situações objetivas que ativam a skill.

## Quando não usar

- Situações semelhantes que pertencem a outro fluxo.

## Procedimento

1. Passos verificáveis e em ordem.

## Validações

- Evidências necessárias antes de concluir.

## Restrições

- Limites de segurança, escopo e qualidade.
```

Regras recomendadas:

- Use `name` em letras minúsculas, números e hífens.
- Escreva uma descrição curta que diferencie claramente quando usar e quando não usar.
- Mantenha instruções determinísticas, verificáveis e independentes de credenciais.
- Use caminhos relativos quando a skill referenciar arquivos do próprio repositório.
- Nunca grave tokens, chaves, senhas, certificados privados ou dados pessoais no catálogo.

## Governança do projeto

`system-prompts/project-governance.md` contém regras gerais compartilhadas pelas sessões do agente. Use-o para padrões duráveis, como qualidade, segurança, validações e convenções de projeto. Não coloque ali dados de ambiente ou instruções temporárias.

## Repositórios privados

Você pode usar uma destas opções:

- Token informado em **Settings → Skills**.
- GitHub CLI autenticado com `gh auth login`.

Prefira um token com acesso somente ao repositório necessário. O repositório deve estar acessível para a conta correspondente.

## Configuração no Achilles

1. Publique a estrutura no GitHub.
2. Abra **Settings → Skills** no Achilles.
3. Informe `owner/repositorio` e a branch, tag ou commit.
4. Informe a credencial somente se o repositório for privado.
5. Clique em **Salvar e testar sincronização**.
6. Confira se o status aparece como sincronizado e se a contagem de skills está correta.

## Checklist

- [ ] O caminho começa em `skills/<categoria>/<nome>/SKILL.md`.
- [ ] O frontmatter contém `name` e `description`.
- [ ] A descrição explica quando usar e quando não usar.
- [ ] Existe `system-prompts/project-governance.md`.
- [ ] Nenhum segredo foi versionado.
- [ ] A branch ou ref configurada existe.
- [ ] A sincronização foi validada pela tela do Achilles.

