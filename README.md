# skills

Personal agent skills as a Nix flake. Each directory under `skills/` is one package. Enable only the skills a machine should carry.

## Home Manager

```nix
{
  inputs.skills.url = "github:yuidvg/skills";
}

# inside a Home Manager module (nix-darwin or Linux):
{
  imports = [ inputs.skills.homeManagerModules.default ];

  skills.enable = [ "cosense" "yomiyasu" ];

  # a named list from this flake, once one is defined:
  # skills.enable = inputs.skills.lib.ue;

  # or compose a named list with extra names:
  # skills.enable = inputs.skills.lib.ue ++ [ "haskell" ];
}
```

`skills.enable` is a list of skill directory names. There is no separate enable-sets option. Named lists are ordinary values on the flake's `lib` output. This repo does not define any yet (including `ue`). Add one in `flake.nix` when the members are known:

```nix
lib = {
  someName = [ /* skill directory names */ ];
};
```

Selected skills are linked into:

- `~/.claude/skills/<name>` — the skill folder as packaged
- `~/.codex/skills/<name>` — a portable projection that supplies `SKILL.md` with YAML frontmatter
- `~/.pi/agent/skills/<name>` — the same portable projection

Leaving a name out of `skills.enable` does not install it. Large reference skills are ordinary packages; omit them and they stay off the machine.

## Packages

`packages.<system>.<skillName>` for `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`, and `x86_64-linux`.

```bash
nix build github:yuidvg/skills#cosense
nix flake show github:yuidvg/skills
```

The package output is that skill's folder. The portable `SKILL.md` adjustment is applied only for Codex and Pi.

`impeccable` also ships the upstream engine next to the vendored launcher, at `scripts/bin/<os>-<arch>/impeccable`, for all four systems (`darwin-arm64`, `darwin-x64`, `linux-arm64`, `linux-x64`). The launcher finds that sibling binary itself, so hosts no longer need an `IMPECCABLE_BIN` binding. The Codex and Pi projection copies this package and includes the same binary.

Host-specific wiring stays in nix-darwin: template includes from other `prompt/` files, XcodeBuildMCP, Claude Desktop skill ZIPs, and Claude managed settings.
