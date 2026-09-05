# Phase 1: Directory Scaffold
_Depends on: nothing — run first_

Create these directories (add .gitkeep to empty ones):

```
Inbox/
Inbox/_archive/
1on1s/
Meetings/
Projects/
Projects/product-strategy/
Projects/product-strategy/inputs/
Projects/product-strategy/drafts/
Decisions/
Knowledge/
Knowledge/annotated/
Knowledge/wiki/
Knowledge/wiki/concepts/
Knowledge/wiki/market/
People/
Interviews/
profile/
profile/preferences/
profile/career/
_system/
_system/data/
_system/logs/
_system/scripts/
_system/queues/
_system/briefings/
_system/templates/
_system/workflows/
.claude/
.claude/commands/
```

After creating directories, create these system files:

**`Inbox/_index.md`**
```markdown
| File | Type | Status | Added |
|------|------|--------|-------|
```

**`Inbox/_unrouted.md`**
```markdown
# Inbox — Unrouted Files

Files the nightly router couldn't classify. Rename or move them to help it next time.

```

**`Decisions/_index.md`**
```markdown
# Decisions

_One row per decision record. Standalone records live in `Decisions/<slug>/`, project-scoped
ones in `Projects/<project>/decisions/<slug>/`. Both are indexed here._

| Decision | Scope | Status | Reversibility | Approver | Opened | Decided | Review |
|----------|-------|--------|---------------|----------|--------|---------|--------|
```

**`Knowledge/wiki/log.md`**
```markdown
# Wiki Activity Log

_Append-only. Written by nightly synthesis and /personal-os-remember._
_Format: `## [YYYY-MM-DD] [operation] | [description]`_
_Operations: ingest | created | pattern | synthesis | remember | lint_

```
