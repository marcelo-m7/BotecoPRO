# BotecoPRO – Migração de Repositórios

> Fase 0 – Consolidação  
> Data: agosto 2025

---

## 1. Contexto

O projeto BotecoPRO existia em dois repositórios separados:

| Repositório | Branch | Conteúdo |
|---|---|---|
| `marcelo-m7/BotecoPro-app` | `odoo` | Aplicativo Flutter (mobile/POS) |
| `marcelo-m7/BotecoPRO-website` | `odoo` | Website público (React SPA) |

Este repositório (`marcelo-m7/BotecoPRO`) é o novo **Single Source of Truth** (monorepo).

---

## 2. Estratégia Escolhida: `git subtree`

### Por que `git subtree` e não `git submodule`?

| Critério | `git submodule` | `git subtree` ✅ |
|---|---|---|
| Histórico preservado | Referência externa | **Internalizado no monorepo** |
| Clone simples | Requer `--recurse-submodules` | `git clone` normal |
| Independência dos repos antigos | Dependente de acesso | **Independente após merge** |
| Complexidade de uso diário | Alta (dois repos para sincronizar) | Baixa (um repo) |
| Push seletivo de volta | N/A | `git subtree push` possível |

**Decisão:** `git subtree --squash` para importar o histórico comprimido de cada repositório.

O flag `--squash` cria um único commit de merge que consolida todo o histórico do repo de origem, mantendo o histórico do monorepo limpo sem misturar centenas de commits dos projetos anteriores.

Para recuperar o histórico completo de cada projeto, o comando `git log apps/mobile/` ou `git log apps/website/` após um `git fetch` dos remotes originais é suficiente.

---

## 3. Comandos Executados

### Preparação

```bash
# Adicionar remotes dos repositórios originais
git remote add app-upstream https://github.com/marcelo-m7/BotecoPro-app.git
git remote add website-upstream https://github.com/marcelo-m7/BotecoPRO-website.git

# Buscar as branches odoo de cada repositório
git fetch app-upstream odoo
git fetch website-upstream odoo
```

### Importação do Flutter App

```bash
git subtree add \
  --prefix=apps/mobile \
  app-upstream/odoo \
  --squash
```

**Resultado:** Diretório `apps/mobile/` criado com todo o conteúdo da branch `odoo` de `BotecoPro-app`. Dois commits criados no monorepo:
1. Commit squash com o snapshot do histórico (`Squashed 'apps/mobile/' content from commit ...`)
2. Commit de merge (`Merge commit 'apps/mobile' from app-upstream/odoo`)

### Importação do Website

```bash
git subtree add \
  --prefix=apps/website \
  website-upstream/odoo \
  --squash
```

**Resultado:** Diretório `apps/website/` criado com todo o conteúdo da branch `odoo` de `BotecoPRO-website`.

---

## 4. Estrutura Resultante

```
apps/
├── mobile/          ← BotecoPro-app@odoo (squashed)
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
└── website/         ← BotecoPRO-website@odoo (squashed)
    ├── src/
    ├── package.json
    └── ...
```

---

## 5. Atualizar o Monorepo com Mudanças dos Repos Originais

Enquanto os repositórios antigos ainda receberem commits, é possível puxar as atualizações:

```bash
# Atualizar remote
git fetch app-upstream odoo

# Fazer pull subtree (preserva histórico de ambos os lados)
git subtree pull \
  --prefix=apps/mobile \
  app-upstream/odoo \
  --squash
```

> **Nota:** Após a Fase 1, os repositórios antigos devem ser arquivados. O monorepo passa a ser a única fonte de verdade.

---

## 6. Enviar Mudanças do Monorepo de Volta para os Repos Originais

Se necessário (ex: durante período de transição):

```bash
git subtree push \
  --prefix=apps/mobile \
  app-upstream \
  odoo-from-monorepo
```

---

## 7. Estado dos Repositórios Originais

| Repositório | Estado | Ação Recomendada |
|---|---|---|
| `marcelo-m7/BotecoPro-app` | Mantido intacto | Arquivar após Fase 1 |
| `marcelo-m7/BotecoPRO-website` | Mantido intacto | Arquivar após Fase 1 |

Os repositórios originais **não foram modificados** durante a Fase 0.

---

## 8. Verificação

```bash
# Confirmar que os arquivos estão presentes
ls apps/mobile/lib/
ls apps/website/src/

# Ver os commits de migração
git log --oneline --graph | head -20

# Ver histórico de um arquivo específico do mobile
git log --oneline apps/mobile/pubspec.yaml
```
