[中文](README_cn.md)

# Claude Code Humanizer

A plain-language communication layer for Claude Code.

It makes Claude Code answer like a real person: direct, simple, and easy to follow. No academic preamble, no dense engineering language, no bullet spam, and no robotic closing lines like “Let me know if you'd like me to elaborate.”

It keeps Claude Code’s full coding behavior intact — tool use, file edits, tests, planning, and the whole agent loop.

It only changes how Claude talks.

This is a single markdown file dropped into `~/.claude/output-styles/`. It rewrites Claude Code's system prompt at session start, so the rules are baked in for every turn without paying input tokens per message.

---

## Contents

- `plain.md` — the output style itself
- `install.sh` — sets it up and makes it the global default
- `uninstall.sh` — reverts everything cleanly
- `README_en.md` / `README_cn.md` — this guide, in English and Chinese

---

## Starting from zero (no Claude Code yet?)

If Claude Code isn't installed on your machine, do these three steps first.

### 1. Get a paid Claude account

Claude Code isn't in the free tier. Any of these work:

- **Claude Pro** ($20/month) — covers most personal use
- **Claude Max** — higher rate limits for heavy users
- **Claude Team / Enterprise** — for team accounts
- **Anthropic Console with API credits** — pay-as-you-go via API key

### 2. Install Claude Code

Anthropic's native installer is the recommended method since October 2025. No Node.js needed, auto-updates in background.

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Homebrew (macOS / Linux)
brew install --cask claude-code

# Legacy npm method (requires Node.js 18+)
npm install -g @anthropic-ai/claude-code
```

Verify with `claude --version` — it should print a version number. If you get "command not found", close the terminal and reopen — the installer adds to PATH, but the current shell hasn't picked it up.

### 3. First-run authentication

```bash
claude
```

A browser tab opens for OAuth. Sign in to your Claude account, authorize the CLI, then return to the terminal. Claude Code is now ready.

If you're using Console API key auth instead, the first-run flow lets you paste the key directly.

Now continue with Quick install below.

---

## Quick install

Put all files in the same folder, then:

```bash
chmod +x install.sh && ./install.sh
```

The script does two things:

1. Copies `plain.md` to `~/.claude/output-styles/plain.md`
2. Adds `"outputStyle": "plain"` to `~/.claude/settings.json` (backing up any existing file as `settings.json.bak`)

Start a new Claude Code session — or `/clear` inside an existing one — for the new style to take effect.

## Manual install

If you'd rather not run a script:

```bash
mkdir -p ~/.claude/output-styles
cp plain.md ~/.claude/output-styles/
```

Then either of these to activate it:

- **Per project (one-time)**: open Claude Code in the project, run `/output-style plain`. The choice persists in that project's `.claude/settings.local.json`.
- **Global default**: add `"outputStyle": "plain"` to `~/.claude/settings.json`. Every project picks it up unless overridden locally.

## Verify it's working

In Claude Code, run `/output-style`. You should see `plain` marked as the active style. For a behavioral gut-check, ask Claude something open-ended like "explain dependency injection" — under Plain it should answer in 3–5 sentences of prose, no headers, no "Great question!", no closing offer to elaborate.

---

## What's inside `plain.md`

Each section is independent — keep, edit, or delete to taste. The file has YAML frontmatter plus several rule sections.

### Frontmatter

```yaml
---
name: Plain
description: Direct, concrete, no filler. ...
keep-coding-instructions: true
---
```

`keep-coding-instructions: true` is the important one. It tells Claude Code to *layer* this style on top of its existing coding instructions — file editing, tool use, test verification, all preserved. Remove it (or set to `false`) only if you're repurposing Claude Code as a non-coding assistant; for normal dev work, leave it.

### Voice

Sets the role: "senior engineer talking to another engineer, not a textbook." Role framing has stronger effect on Claude's latent style than direct rules like "be concise". This is the foundation; most other sections wouldn't bite as hard without it.

### Banned openings

Strips out "Great question", "Let me", "Certainly", "You're right", etc. These are the cheapest readability win. If you want Claude to acknowledge before answering (tutoring contexts, emotional content), relax this section.

### Banned filler

A blacklist of high-frequency Claude tics: "fundamentally", "essentially", "leverage" (as verb), "delve into", "robust", "holistic", and so on. Claude will sometimes route around the blacklist with synonyms — the pull here is directional, not a hard filter — but the overall density drops noticeably.

### Concrete before abstract

Affects reasoning structure rather than wording: lead with the specific case, generalize after. The single highest-impact rule for "this answer reads like a textbook" complaints.

### Prose by default

Curbs Claude's tendency to fragment everything into bullets and nested headers. Bullets stay available for genuinely parallel content (lists of options, steps, items) — they just don't get used for paragraphs that should have been paragraphs.

### Length matches stakes

Stops the "always give a recap section" reflex. One-line questions get one-line answers. Big questions still get big answers.

### Disagreement

Tells Claude to push back directly when you're wrong, instead of "you raise a good point, however". Useful when you're using Claude Code as a thinking partner and need real signal.

### Hedging

Permits genuine uncertainty, forbids reflex hedging. "It depends" is fine only if followed by what it depends on.

---

## How Output Styles actually work

Claude Code has three layers that shape its behavior:

| Layer | File | Scope | Mechanism |
|---|---|---|---|
| **Output style** | `~/.claude/output-styles/*.md` | Communication style, role, format | Modifies the system prompt |
| **CLAUDE.md** | `~/.claude/CLAUDE.md` or `<project>/CLAUDE.md` | Project conventions, codebase facts | Injected as user-side memory |
| **Hooks** | `~/.claude/settings.json` → `hooks` key | Lifecycle / tool events | Spawn external scripts |

Output Style is the right primitive for communication style because:

1. **System-prompt level** — has stronger pull on Claude's generation trajectory than user-side context. Whether Claude answers like a textbook or like a coworker is set before token zero, in the part of the prompt that defines its self-model.
2. **Cached** — system prompts hit prompt caching. Zero ongoing token cost per turn.
3. **One file** — easy to share, version, fork, replace.

Hooks can technically inject style reminders into every user message (`UserPromptSubmit` hook), but they re-spend input tokens every turn and exert a weaker pull. Use hooks for conditional or dynamic injection (e.g. "tighten the style when prompt contains the word 'architecture'"), not as the default mechanism.

---

## Customizing

Edit `~/.claude/output-styles/plain.md` directly. Changes take effect on the next session start or after `/clear`.

Common edits:

- **Relax banned openings** — delete that section if you're using Claude Code for tutoring or emotional support contexts.
- **Add domain rules** — append a section like `## Project context` describing conventions specific to a domain. Though for project-specific rules, `CLAUDE.md` is usually the better home — Output Style is for *how* Claude talks, not *what* it knows.
- **Tune the voice** — change the "senior engineer talking to another engineer" framing to whatever role suits you. "Staff engineer reviewing a PR", "tech lead in a standup", "pair-programming partner". Role framing is the highest-leverage knob.
- **Add or remove banned words** — the filler list is empirical, not exhaustive. Add any phrase you keep seeing.

After editing, run `/clear` in an existing Claude Code session or start a new one. The style is read at session start and held for the whole session — mid-session edits won't apply until reload.

---

## Switching styles

```
/output-style              # interactive menu of available styles
/output-style plain        # switch to plain
/output-style default      # revert to Claude Code's built-in style
/output-style explanatory  # built-in: adds teaching "Insights" while coding
/output-style learning     # built-in: collaborative, asks you to write some code
```

Each switch saves to the current project's `.claude/settings.local.json`. The user-level default in `~/.claude/settings.json` applies to projects that haven't set their own.

---

## File locations and precedence

Settings are merged across layers. For `outputStyle`, higher in this list wins:

1. `<project>/.claude/settings.local.json` — local-only, not committed (per-project, per-machine)
2. `<project>/.claude/settings.json` — committed (per-project, shared with team)
3. `~/.claude/settings.json` — user-level global default
4. Claude Code's built-in default

The installer writes to (3). `/output-style` writes to (1). If a project seems stuck on the wrong style, check `.claude/settings.local.json` in that project — it overrides everything global.

The style file itself (`plain.md`) can live in either `~/.claude/output-styles/` (available everywhere) or `<project>/.claude/output-styles/` (project-local style). The installer puts it in the user-level location.

---

## Sharing with your team

Three patterns that work:

- **Gist + curl** — host `plain.md` and `install.sh` on a gist, share a one-liner: `curl -fsSL <gist-raw>/install.sh | bash`. Best for personal distribution.
- **Internal repo** — drop the files into a `dotfiles` or `engineering-tools` repo, document the install command in team onboarding.
- **Team-wide project default** — commit `.claude/settings.json` and `.claude/output-styles/plain.md` into a project repo. Anyone who clones gets Plain mode automatically when they open Claude Code there.

For the team-wide pattern, keep `keep-coding-instructions: true` — it preserves Claude Code's coding behavior, which is almost always what you want.

---

## Uninstall

```bash
chmod +x uninstall.sh && ./uninstall.sh
```

What it does:

1. Removes `~/.claude/output-styles/plain.md`
2. Restores `~/.claude/settings.json` from `.bak` if the installer left one
3. Otherwise strips just the `outputStyle` key from settings, leaving everything else intact
4. Refuses to touch settings if `outputStyle` is set to something other than `plain` — avoids stomping on later customizations

`/clear` or a new session to apply.

Manual version:

```bash
rm ~/.claude/output-styles/plain.md
# Then edit ~/.claude/settings.json and remove the "outputStyle" line
```

---

## Troubleshooting

**Style didn't change anything.** Did you start a new session or `/clear`? Output styles load once per session.

**`/output-style` doesn't list Plain.** The file isn't where Claude Code expects. Check `ls ~/.claude/output-styles/` — should contain `plain.md`. Path is case-sensitive.

**Some banned words still show up.** Expected. The blacklist is a strong directional nudge, not a hard filter. If a specific word keeps slipping through, add a sharper rule (e.g. "Never write the word 'leverage' — use 'use' instead").

**Plain works in some projects but not others.** Check `.claude/settings.local.json` in the affected project — it likely has `"outputStyle"` set to something else, overriding the global default. Either edit that file or run `/output-style plain` in that project.

**I broke `settings.json`.** The installer left a backup at `~/.claude/settings.json.bak`. Restore it: `mv ~/.claude/settings.json.bak ~/.claude/settings.json`.

**Claude Code session won't start after install.** Almost always malformed JSON in `settings.json`. Validate it: `python3 -m json.tool < ~/.claude/settings.json`. Fix or restore from `.bak`.

**`claude --version` says "command not found".** PATH not refreshed. Close the terminal, open a new one. If still broken, the installer log will say where it placed the binary — typically `~/.local/bin/claude`.

---

## Notes

- **macOS / Linux only for the scripts.** Windows: use WSL, or do the manual install in PowerShell with paths adjusted to `$HOME\.claude\...`.
- **Multilingual.** The style file is written in English, but Claude follows the language of your input. Chinese in, Chinese out. The style rules apply regardless.
- **Updating.** To pull in a newer version of `plain.md`, just re-run `./install.sh`. It overwrites the style file and re-asserts the settings.
- **Coexists with other styles.** You can have many `.md` files in `~/.claude/output-styles/` and switch between them with `/output-style`. Plain doesn't interfere.
- **Don't remove `keep-coding-instructions: true`** unless you've thought hard about it. Without it, Claude Code drops its built-in coding behavior and runs purely on whatever this file says — not enough to be a competent coder on its own.
