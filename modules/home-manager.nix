# One Home Manager module for every skill in this flake.
#
#   imports = [ inputs.skills.homeManagerModules.default ];
#   skills.enable = [ "cosense" "yomiyasu" ];
#
# Claude Code gets the packaged folder. Codex and Pi get the portable
# projection. Paths match nix-darwin's claude-code module:
#   ~/.claude/skills, ~/.codex/skills, ~/.pi/agent/skills.
{ rawSkill, portableSkill, skillNames }:
{ config, lib, pkgs, ... }:
let
  selected = lib.unique config.skills.enable;

  claudeSources = lib.genAttrs selected (rawSkill pkgs);

  portableSources = lib.genAttrs selected (
    name: portableSkill pkgs claudeSources.${name} name
  );

  linkTree =
    base: sources:
    lib.mapAttrs' (name: source: {
      name = "${base}/${name}";
      value = {
        inherit source;
      };
    }) sources;
in
{
  options.skills.enable = lib.mkOption {
    type = lib.types.listOf (lib.types.enum skillNames);
    default = [ ];
    example = [
      "cosense"
      "yomiyasu"
    ];
    description = ''
      Skill names to install into the agent skill directories.

      Each selected skill is linked at:

      - `~/.claude/skills/<name>` — the packaged skill folder
      - `~/.codex/skills/<name>` — portable projection (`SKILL.md` with frontmatter)
      - `~/.pi/agent/skills/<name>` — the same portable projection

      Pass a list of skill names, a named list from this flake's `lib`
      output (`inputs.skills.lib.<name>`), or a concatenation of those
      (`inputs.skills.lib.<name> ++ [ "haskell" ]`).
      Unknown names are rejected. Names left out of the list are not installed.
    '';
  };

  config = lib.mkIf (selected != [ ]) {
    home.file = linkTree ".claude/skills" claudeSources
      // linkTree ".codex/skills" portableSources
      // linkTree ".pi/agent/skills" portableSources;
  };
}
