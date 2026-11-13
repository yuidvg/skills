# Vendored launcher: skills/impeccable/scripts/impeccable
# It execs the sibling binary scripts/bin/<os>-<arch>/impeccable before any
# user cache, PATH hit, or network download. This derivation is that skill
# folder plus one pinned engine asset for the build system.
#
# Engine version is scripts/VERSION (engine-v0.1.16 for this skill). Each
# hash is the release asset and matches that asset's upstream .sha256 sidecar.
# Both Linux assets are statically linked (linux-x64 is static-pie, no
# PT_INTERP, no NEEDED), so they run on NixOS without patchelf.
{
  pkgs,
  skillsRoot,
}:
let
  inherit (pkgs) lib;

  version = lib.strings.trim (builtins.readFile (skillsRoot + "/impeccable/scripts/VERSION"));

  targets = {
    aarch64-darwin = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256:5c00c3130b961f3aa1066f04ed0e1f58e87808ad153efa00f1c44184800084f2";
    };
    x86_64-darwin = {
      os = "darwin";
      arch = "x64";
      hash = "sha256:278b028848348b4dc21a20ee0a0bb33f09a8d14c5484b1a2f554df32e1d44f43";
    };
    aarch64-linux = {
      os = "linux";
      arch = "arm64";
      hash = "sha256:a9a18bfa6d70642701446ed3b12a3e5e6eefe4a4b4c56effe30b449ccb329c4b";
    };
    x86_64-linux = {
      os = "linux";
      arch = "x64";
      hash = "sha256:a890a5b4b7d9d79ec54aa74612b5e924e5f5b422600a25fde8bcbda11b031787";
    };
  };

  system = pkgs.stdenv.hostPlatform.system;
  target = targets.${system} or (throw "impeccable engine: no release asset for ${system}");

  engine = pkgs.fetchurl {
    url = "https://github.com/pbakaus/impeccable/releases/download/engine-v${version}/impeccable-${target.os}-${target.arch}";
    inherit (target) hash;
  };

  skillSrc = skillsRoot + "/impeccable";
in
pkgs.runCommand "impeccable"
  {
    meta = {
      description = "Impeccable skill with the upstream engine beside the launcher";
      license = lib.licenses.asl20;
      platforms = builtins.attrNames targets;
    };
  }
  ''
    mkdir -p "$out"
    cp -R -- ${skillSrc}/. "$out/"
    # Store sources are mode 0555. cp preserves that, so scripts/ is not
    # writable until this bit is restored. The copied launcher stays executable.
    chmod u+w "$out/scripts"
    install -D -m755 ${engine} "$out/scripts/bin/${target.os}-${target.arch}/impeccable"
  ''
