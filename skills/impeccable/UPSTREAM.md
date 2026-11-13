# Upstream

- Repository: https://github.com/pbakaus/impeccable
- Commit: 5cb95eea9c96479f57afe0732a45470d30183326
- Imported directory: .agents/skills/impeccable
- Skill version: 4.7.0; engine version: 0.1.16
- License: Apache-2.0; upstream LICENSE and NOTICE.md included.

The canonical files are vendored here and projected by the skills flake
into Claude Code, Codex, and Pi. The flake ships the hash-pinned engine
next to the launcher (`scripts/bin/<os>-<arch>/impeccable`) for
aarch64-darwin, x86_64-darwin, aarch64-linux, and x86_64-linux. Hosts no
longer need an `IMPECCABLE_BIN` binding, and the launcher does not download
an engine on first use.
Desktop ZIPs preserve the upstream portable launcher.

To update, replace the skill payload from a reviewed upstream commit and update
this record plus the engine version and release checksums in
nix/impeccable-engine.nix.
Validate and activate using docs/nix-agent-tooling-runbook.md.
