# Skill directories under ../skills become derivations.
# A raw package is the folder itself. The portable projection is the same
# folder with a Codex/Pi-compatible SKILL.md, matching nix-darwin's
# portableSkillSources (frontmatter only; no host-specific substitutions).
# impeccable also installs the upstream engine beside the vendored launcher
# (nix/impeccable-engine.nix). The portable projection copies that package,
# so Codex and Pi receive the binary too.
{
  skillsRoot ? ../skills,
}:
let
  entries = builtins.readDir skillsRoot;

  skillNames = builtins.sort builtins.lessThan (
    builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries)
  );

  copyTree = src: ''
    mkdir -p "$out"
    cp -R -- ${src}/. "$out/"
  '';

  # The fetched engine makes impeccable a remote-input package, so it does
  # not take the pure-local allowSubstitutes / preferLocalBuild flags.
  rawSkill =
    pkgs: name:
    if name == "impeccable" then
      import ./impeccable-engine.nix { inherit pkgs skillsRoot; }
    else
      pkgs.runCommand name
        {
          allowSubstitutes = false;
          preferLocalBuild = true;
        }
        (copyTree (skillsRoot + "/${name}"));

  # Keep the original Claude sources intact. Codex and Pi want SKILL.md
  # whose first line is YAML frontmatter. index.md stands in for SKILL.md
  # when a skill was vendored as a document tree.
  portableSkill =
    pkgs: raw: name:
    pkgs.runCommand "portable-skill-${name}"
      {
        allowSubstitutes = false;
        preferLocalBuild = true;
      }
      ''
        ${copyTree raw}

        if [ ! -f "$out/SKILL.md" ] && [ -f "$out/index.md" ]; then
          cp -- "$out/index.md" "$out/SKILL.md"
        fi

        if [ -f "$out/SKILL.md" ]; then
          first_line="$(${pkgs.coreutils}/bin/head -n 1 -- "$out/SKILL.md" || true)"
          if [ "$first_line" != "---" ]; then
            {
              echo "---"
              echo "name: ${name}"
              echo "description: Shared ${name} skill from the Claude Code skillpack."
              echo "---"
              echo
              cat -- "$out/SKILL.md"
            } > "$out/SKILL.md.with-frontmatter"
            mv -- "$out/SKILL.md.with-frontmatter" "$out/SKILL.md"
          fi
        fi
      '';
in
{
  inherit skillsRoot skillNames rawSkill portableSkill;
}
