#!/usr/bin/env bash
# bootstrap_vault.sh — generate a PARA-structured Second Brain vault for Obsidian
# Based on Maxi Contieri's methodology: atomic Zettelkasten notes + PARA organization
# Usage: bash bootstrap_vault.sh [VAULT_PATH]
#   VAULT_PATH defaults to ~/SecondBrain

set -euo pipefail

VAULT="${1:-$HOME/SecondBrain}"

echo "=== Bootstrapping Second Brain vault at: $VAULT ==="

# ──────────────────────────────────────────────
# 1. PARA folder structure
# ──────────────────────────────────────────────
mkdir -p "$VAULT"/{Projects,Areas,Resources,Archives}

# Subfolders under Projects (active endeavors)
mkdir -p "$VAULT"/Projects/{InfiniteBrain,SecondBrain2}

# Subfolders under Areas (ongoing responsibilities)
mkdir -p "$VAULT"/Areas/{Career,Health,Finance,Learning,DevOps}

# Subfolders under Resources (reference material)
mkdir -p "$VAULT"/Resources/{Design-Patterns,Architectural-Decisions,Algorithms,Tools,Cheatsheets}

# Subfolders under Archives (completed projects / stale content)
mkdir -p "$VAULT"/Archives/{Completed-Projects,Deprecated-Notes}

# Templates folder (Obsidian convention)
mkdir -p "$VAULT"/Templates

# Daily notes folder
mkdir -p "$VAULT"/Daily

echo "  [+] PARA folders created"

# ──────────────────────────────────────────────
# 2. Root AGENTS.md
# ──────────────────────────────────────────────
cat > "$VAULT/AGENTS.md" << 'AGENTS_EOF'
# AGENTS.md — Second Brain Vault Map

> This file is the AI entry point. When working with this vault, read this file
> first to orient yourself before exploring notes.

## Vault Structure

```
SecondBrain/
├── Projects/     # Active endeavors with a clear finish line
├── Areas/        # Ongoing responsibilities (no end date)
├── Resources/    # Reference material & reusable knowledge
├── Archives/     # Completed or deprecated items
├── Templates/    # Note templates (YAML front matter + structure)
├── Daily/        # Daily/standup notes
└── AGENTS.md     # You are here
```

## How to Navigate

| If you need...           | Go to...                                  |
|--------------------------|-------------------------------------------|
| Active project context   | `Projects/<ProjectName>/AGENTS.md`       |
| Domain knowledge         | `Areas/<AreaName>/`                       |
| Reference patterns       | `Resources/<Topic>/`                      |
| Past decisions           | `Resources/Architectural-Decisions/`      |
| Today's standup          | `Daily/YYYY-MM-DD.md`                     |

## Naming Conventions

- **Atomic notes**: one idea per file, snake_case filenames (e.g., `event_sourcing_basics.md`)
- **Zettelkasten IDs**: use date-based IDs `YYYYMMDDHHMM` as filename prefix when linking
  granular thoughts (e.g., `202605190930_why_immutability_matters.md`)
- **MOCs** (Maps of Content): prefixed `moc_` (e.g., `moc_design_patterns.md`)
- **Architectural Decisions**: prefixed `adr_` with sequence number (e.g., `adr_001_choose_postgres.md`)

## Note Types

| Type       | Purpose                                    |
|------------|--------------------------------------------|
| `zettel`   | Atomic idea, single concept                |
| `adr`      | Architectural Decision Record              |
| `moc`      | Map of Content — hub linking related notes |
| `project`  | Project overview, goals, status            |
| `resource` | Reference material, cheatsheet, pattern    |
| `daily`    | Standup / daily log                        |
| `area`     | Area definition & health checklist         |

## AI Instructions

1. Always read the relevant `AGENTS.md` before interpreting notes in a folder.
2. Respect the YAML front matter — use `type`, `status`, and `tags` for filtering.
3. When creating notes, use the templates in `Templates/`.
4. Link early and often — semantic wikilinks explain *why* two concepts relate,
   not just *that* they relate.
5. Never modify archived notes without updating their `status` to `revised`.
AGENTS_EOF

echo "  [+] Root AGENTS.md written"

# ──────────────────────────────────────────────
# 3. Project-level AGENTS.md files
# ──────────────────────────────────────────────
cat > "$VAULT/Projects/InfiniteBrain/AGENTS.md" << 'IB_EOF'
# InfiniteBrain Project

## Overview
FastAPI "second brain" knowledge graph app. See root AGENTS.md for vault-wide conventions.

## Key Files
- Source code: `~/Projects/InfiniteBrain/`
- Stack: FastAPI + Celery + Redis + Playwright

## Active Threads
<!-- Update this section as work evolves -->
- [ ] Voice ingestion pipeline
- [ ] FolderWatcher improvements
IB_EOF

cat > "$VAULT/Projects/SecondBrain2/AGENTS.md" << 'SB_EOF'
# SecondBrain2 Project

## Overview
This vault itself — the PARA-organized, Zettelkasten-linked knowledge base.

## Key Files
- Templates: `Templates/`
- Dataview queries: embedded in notes using ` ```dataview ` blocks

## Active Threads
- [ ] Seed initial Zettelkasten notes from InfiniteBrain learnings
- [ ] Set up Ollama local LLM for private querying
SB_EOF

echo "  [+] Project AGENTS.md files written"

# ──────────────────────────────────────────────
# 4. Templates
# ──────────────────────────────────────────────

# --- Zettel (atomic note) template ---
cat > "$VAULT/Templates/zettel.md" << 'TMPL_EOF'
---
title: "{{title}}"
type: zettel
status: draft        # draft | active | mature | revised | deprecated
component: ""        # e.g., "api", "frontend", "infra", "concept"
tags: []
created: "{{date:YYYY-MM-DD}}"
related: []
---
# {{title}}

## Context
<!-- Why does this idea matter? What problem does it solve? -->

## Insight
<!-- The core idea in 1-3 sentences. -->

## Evidence
<!-- Links to code, papers, or real-world examples. -->

## Implications
<!-- What follows from this insight? What does it enable or prevent? -->

## Related
- [[]]
TMPL_EOF

# --- ADR (Architectural Decision Record) template ---
cat > "$VAULT/Templates/adr.md" << 'TMPL_EOF'
---
title: "{{title}}"
type: adr
status: proposed     # proposed | accepted | deprecated | superseded
component: ""
tags: [adr, architecture]
created: "{{date:YYYY-MM-DD}}"
related: []
decision_id: ""      # e.g., "ADR-001"
---
# {{title}}

## Status
**{{status}}** — {{date:YYYY-MM-DD}}

## Context
<!-- What is the issue that motivates this decision? -->

## Decision
<!-- What is the change that we're proposing/making? -->

## Alternatives Considered
| Option          | Pros               | Cons               |
|-----------------|--------------------|--------------------|
| <!-- option --> | <!-- pros -->      | <!-- cons -->      |

## Consequences
<!-- What becomes easier or harder because of this decision? -->

## Related
- [[]]
TMPL_EOF

# --- MOC (Map of Content) template ---
cat > "$VAULT/Templates/moc.md" << 'TMPL_EOF'
---
title: "{{title}}"
type: moc
status: active
component: ""
tags: [moc]
created: "{{date:YYYY-MM-DD}}"
related: []
---
# {{title}}

> A map of content aggregating all notes related to **{{title}}**.

## Core Ideas
- [[]]

## Patterns
- [[]]

## Open Questions
- [ ] 

## Related
- [[]]
TMPL_EOF

# --- Project note template ---
cat > "$VAULT/Templates/project.md" << 'TMPL_EOF'
---
title: "{{title}}"
type: project
status: active       # planning | active | on-hold | completed | archived
component: ""
tags: [project]
created: "{{date:YYYY-MM-DD}}"
related: []
deadline: ""
---
# {{title}}

## Goal
<!-- One-sentence description of the desired outcome. -->

## Milestones
- [ ] Milestone 1
- [ ] Milestone 2

## Key Decisions
- [[]]

## Notes
<!-- Freeform project log -->

## Related
- [[]]
TMPL_EOF

echo "  [+] Templates created (zettel, adr, moc, project)"

# ──────────────────────────────────────────────
# 5. Seed ADR example
# ──────────────────────────────────────────────
cat > "$VAULT/Resources/Architectural-Decisions/adr_001_local_first_privacy.md" << 'ADR1_EOF'
---
title: "Choose Local-First Privacy Architecture"
type: adr
status: accepted
component: infrastructure
tags: [adr, architecture, privacy, local-first]
created: "2026-05-19"
related: []
decision_id: "ADR-001"
---
# Choose Local-First Privacy Architecture

## Status
**accepted** — 2026-05-19

## Context
We need a knowledge management system that preserves privacy and works without
cloud dependencies. Our coding projects contain proprietary logic, trade secrets,
and personal notes that should never leave the local machine.

## Decision
We adopt a local-first architecture:

1. **Storage**: Plain `.md` files in an Obsidian vault (no proprietary DB).
2. **Query**: Dataview plugin for in-vault SQL-like queries.
3. **AI**: Local LLM via Ollama — no external API calls.
4. **Sync**: Git for version control; optional Syncthing for multi-device.

## Alternatives Considered

| Option                | Pros                     | Cons                              |
|----------------------|--------------------------|-----------------------------------|
| Obsidian + local md  | Mature, portable, fast   | No real-time collab               |
| Notion               | Web native, collab       | Cloud-only, proprietary format    |
| Logseq               | Open source, outliner    | Smaller ecosystem, less polished  |
| Plain git repo       | Maximal control          | No rendering, poor mobile UX      |

## Consequences
- Data never leaves the machine (privacy guaranteed).
- Must manage backups independently (git + Syncthing).
- No real-time collaboration by default (acceptable trade-off).
- Full offline capability.

## Related
- [[]]
ADR1_EOF

echo "  [+] Seed ADR-001 created"

# ──────────────────────────────────────────────
# 6. Seed Zettel example
# ──────────────────────────────────────────────
cat > "$VAULT/Resources/Design-Patterns/202605190930_why_immutability_matters.md" << 'ZET1_EOF'
---
title: "Why Immutability Matters"
type: zettel
status: active
component: concept
tags: [immutability, functional-programming, design-patterns]
created: "2026-05-19"
related:
  - "[[adr_001_local_first_privacy]]"
  - "[[202605191000_event_sourcing_basics]]"
---
# Why Immutability Matters

## Context
When designing systems that must be debuggable, thread-safe, and predictable,
mutability is the enemy. Every shared mutable state is a potential race condition
or inconsistent read.

## Insight
Immutable data structures eliminate an entire class of bugs by making
state transitions explicit rather than implicit. Instead of mutating in place,
you create new versions — making the history of changes visible and reversible.

This connects directly to [[adr_001_local_first_privacy|our local-first architecture]]:
if we store notes as immutable snapshots (git commits), we never lose data and
can always roll back — **because we chose not to mutate**.

## Evidence
- Clojure's persistent data structures — practical immutability at scale.
- Event sourcing: every state change is an event, never a mutation.
- Git itself: content-addressed storage means blobs are immutable by hash.

## Implications
- Prefer `const` / `final` by default; mutate only when profiling proves it matters.
- Design APIs that return new objects rather than modifying existing ones.
- When mutability is unavoidable, isolate it to a single owner (e.g., a reducer).

## Related
- [[adr_001_local_first_privacy|why we chose local-first instead of cloud]] *(architecture enables immutability)*
- [[202605191000_event_sourcing_basics]] *(pattern that leverages immutability)*
ZET1_EOF

echo "  [+] Seed Zettel note created"

# ──────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────
echo ""
echo "=== Vault bootstrapped successfully ==="
echo ""
echo "  Location:  $VAULT"
echo ""
echo "  Next steps:"
echo "    1. Open this folder in Obsidian (File > Open Vault)"
echo "    2. Install the Dataview plugin (Community Plugins)"
echo "    3. Install the Templater plugin (for date variables in templates)"
echo "    4. Run:  git init && git add -A && git commit -m 'Initial vault structure'"
echo ""