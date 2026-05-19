# SecondBrain2

A local-first, privacy-respecting knowledge base built on [Obsidian](https://obsidian.md), [Ollama](https://ollama.com), and the PARA method. Your second brain stays on your machine — no cloud, no third-party APIs, no data leaving your network.

## What It Does

- **Obsidian Vault** with PARA-structured folders (Projects, Areas, Resources, Archives) and Zettelkasten linking
- **Local LLM Querying** via Ollama (qwen3:1.7b) — ask natural-language questions against your vault with GPU-accelerated inference
- **Atomic Notes** with typed relationships (Zettelkasten, MOCs, ADRs) and YAML front matter
- **One-Command Startup** — launches Ollama, checks GPU status, and opens the vault in Obsidian

## Architecture

```
SecondBrain2/
├── Research/                    # Obsidian vault (open this in Obsidian)
│   └── .obsidian/              # Obsidian config (graph, plugins, theme)
├── bootstrap_vault.sh          # Create a new PARA-structured vault from scratch
├── scripts/
│   ├── start_sb2.sh            # Start Ollama + Obsidian + health check
│   └── stop_sb2.sh            # Close Obsidian, optionally stop Ollama
├── icons/
│   ├── start_sb2.svg/.png      # Desktop launcher icons
│   └── stop_sb2.svg/.png
├── OPTIMIZED_LLM_RECOMMENDATIONS.md  # LLM model benchmarks & config guide
├── infinitebrain-architecture-notes.json  # Architecture knowledge notes
└── Research/Welcome.md         # Obsidian vault welcome note
```

### Vault Structure (created by `bootstrap_vault.sh`)

```
Vault/
├── Projects/          # Active endeavors with a clear finish line
├── Areas/             # Ongoing responsibilities (no end date)
├── Resources/         # Reference material & reusable knowledge
├── Archives/          # Completed or deprecated items
├── Templates/         # Note templates (zettel, adr, moc, project)
├── Daily/             # Daily/standup notes
├── AGENTS.md          # AI entry point & navigation map
└── vault_query.py     # Local LLM query engine (in ~/SecondBrain/)
```

## Quick Start

### 1. Bootstrap the vault

```bash
bash bootstrap_vault.sh [VAULT_PATH]
# Default: ~/SecondBrain
```

This creates the full PARA folder structure, note templates, seed content (ADR-001, example zettel), and root/project-level `AGENTS.md` files.

### 2. Start Second Brain 2

```bash
scripts/start_sb2.sh
```

This script:
- Starts Ollama if not running (checks `localhost:11434`)
- Verifies the `qwen3:1.7b` model is available
- Checks GPU acceleration status (AMD Radeon Vulkan)
- Opens the vault in Obsidian
- Shows a health summary (note count, scripts, query command)

For non-interactive use:
```bash
scripts/start_sb2.sh --no-prompt
```

### 3. Stop Second Brain 2

```bash
scripts/stop_sb2.sh              # Close Obsidian, keep Ollama running
scripts/stop_sb2.sh --stop-ollama  # Also stop Ollama
```

### 4. Query your vault

```bash
python3 ~/SecondBrain/vault_query.py --interactive
```

Uses qwen3:1.7b locally via Ollama. No data leaves your machine.

## LLM Configuration

The project uses **qwen3:1.7b** as the default local model — the best speed/quality balance for CPU+GPU inference:

| Model | Size | Est. tok/s | Quality |
|-------|------|------------|---------|
| qwen3:0.6b | ~0.5 GB | 40-60+ | Simple retrieval |
| **qwen3:1.7b** | **~1.4 GB** | **25-40** | **Best balance (recommended)** |
| qwen3:4b | ~2.5 GB | 15-25 | Best quality under 5B |

Install the model:
```bash
ollama pull qwen3:1.7b
```

For deep reasoning, use `--think` flag. For fastest responses, `--no-think` (default).

See [OPTIMIZED_LLM_RECOMMENDATIONS.md](OPTIMIZED_LLM_RECOMMENDATIONS.md) for full benchmarks and alternative models.

## GPU Acceleration

On AMD Radeon RX Vega 56/64 (gfx900, 8GB VRAM):
- Uses **Vulkan** backend (`OLLAMA_VULKAN=1`)
- ~91 tok/s with GPU vs ~22 tok/s CPU-only
- ~1.5-3s queries (was 4-6s on CPU)
- ROCm is unsupported by Ollama for gfx900 — use Vulkan instead

The start script auto-detects GPU status via `ollama` API and `journalctl`.

## Note Types & Naming Conventions

| Type | Purpose | Filename pattern |
|------|---------|------------------|
| `zettel` | Atomic idea, single concept | `YYYYMMDDHHMM_idea_name.md` |
| `adr` | Architectural Decision Record | `adr_NNN_decision_name.md` |
| `moc` | Map of Content — hub linking notes | `moc_topic.md` |
| `project` | Project overview & status | `project_name.md` |
| `resource` | Reference, cheatsheet, pattern | `topic_name.md` |
| `daily` | Standup / daily log | `YYYY-MM-DD.md` |

All notes use YAML front matter with `type`, `status`, `component`, and `tags` fields.

## Design Principles

1. **Local-first privacy** — Data never leaves your machine. No cloud APIs.
2. **Plain files** — Markdown in an Obsidian vault, not a proprietary database.
3. **Zettelkasten linking** — Every idea is atomic; links explain *why*, not just *that*.
4. **PARA organization** — Projects, Areas, Resources, Archives for intuitive filing.
5. **Git + Syncthing** — Version control and optional multi-device sync.
6. **AI-augmented** — Local LLM for querying, but you own all the data.

## InfiniteBrain Architecture Notes

The `infinitebrain-architecture-notes.json` file contains captured architectural insights from the companion [InfiniteBrain](https://github.com/xcode4tux/InfiniteBrain) project, including patterns for:

- JSON file-per-node storage with soft-delete
- Celery + Redis async ingestion pipeline
- FAISS on-demand index builds with lazy rebuilds
- Hybrid search (keyword + semantic score fusion)
- Thread-safe in-process state management
- LLM response caching with TTL and capacity eviction

These notes can be ingested into the vault as Zettelkasten atomic notes.

## Requirements

- **Obsidian** — for vault editing and visualization
- **Ollama** — for local LLM inference (auto-started by start script)
- **Python 3** — for `vault_query.py`
- **AMD GPU (optional)** — Vulkan-accelerated inference for faster queries

## License

Personal knowledge base. See individual notes for attribution.