# Repository migration status

The monorepo keeps `apps/mobile` and `apps/website` as Git submodules. The
mobile source of truth remains `marcelo-m7/BotecoPro-app`; the monorepo stores a
gitlink to a published app commit.

For the Odoo Online MVP:

```text
BotecoPRO                 feat/odoo-online-mvp
└── apps/mobile           BotecoPro-app@feat/odoo-online-mvp
```

The old subtree narrative and the old `odoo` app branch are historical context,
not the update mechanism for this integration. Update the mobile repository,
push its commit, then update the monorepo gitlink.
