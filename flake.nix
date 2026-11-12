{
  description = "Personal agent skills";

  # nixos-unstable (26.11) no longer provides x86_64-darwin. 26.05 still
  # supports every system this flake exports, through the end of 2026.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      skills = import ./nix/skills.nix { };
      inherit (skills) skillNames rawSkill portableSkill;

      packagesFor = pkgs: builtins.listToAttrs (
        map (name: {
          inherit name;
          value = rawSkill pkgs name;
        }) skillNames
      );
    in
    {
      packages = nixpkgs.lib.genAttrs systems (
        system: packagesFor nixpkgs.legacyPackages.${system}
      );

      # Named lists of skill names for `skills.enable`.
      # Nothing is predefined. Add a list here once its members are known:
      #
      #   lib = {
      #     someName = [ /* skill directory names */ ];
      #   };
      #
      # Consumers then write `skills.enable = inputs.skills.lib.someName`.
      lib = { };

      homeManagerModules.default = import ./modules/home-manager.nix {
        inherit rawSkill portableSkill skillNames;
      };
    };
}
