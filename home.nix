{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  recursiveSeedSource = pkgs.runCommand "hm-mutable-recursive-seed-source" { } ''
    mkdir -p $out/sub
    echo "seed-alpha" > $out/alpha.txt
    echo "seed-bravo" > $out/sub/bravo.txt
  '';

  recursiveForceSource = pkgs.runCommand "hm-mutable-recursive-force-source" { } ''
    mkdir -p $out/sub
    echo "force-alpha" > $out/alpha.txt
    echo "force-bravo" > $out/sub/bravo.txt
  '';
in
{
  programs.home-manager.enable = true;
  home.username = lib.mkDefault "test";
  home.homeDirectory = lib.mkDefault "/home/test";
  home.stateVersion = osConfig.system.stateVersion;

  # Optional: customize where mutable files are stored
  # Uncomment to use XDG state directory instead of default ~/.home-manager/mutable
  # home.mutableDirectory = "${config.xdg.stateHome}/home-manager/mutable";

  # ============================================================================
  # MUTABLE FILES TEST EXAMPLES
  # ============================================================================

  # Example 1: SEED MODE - Seed once per store path, never touch again
  # Follows new store paths, but never overwrites an existing working copy
  home.file."test/mutable-seed.txt" = {
    text = ''
      Seed mode test file.
      Edit me; changes should persist for this store path.
    '';
    mutable = {
      enable = true;
      mode = "seed";
    };
  };

  # Example 2: FORCE MODE (default) - Re-seed on every switch for the current store path
  # Keeps the working copy aligned with the current store seed
  home.file."test/mutable-force.txt" = {
    text = ''
      Force mode test file.
      Changes are overwritten on each switch for the current store path.
    '';
    mutable = {
      enable = true;
      mode = "force";
    };
  };

  # Immutable file for comparison
  home.file."test/immutable.txt" = {
    text = ''
      This is an immutable Home Manager file.
      It is a symlink to the Nix store and cannot be edited.
    '';
  };

  # Recursive directories (seed vs force)
  home.file."test/recursive-seed" = {
    source = recursiveSeedSource;
    recursive = true;
    mutable = {
      enable = true;
      mode = "seed";
    };
  };

  home.file."test/recursive-force" = {
    source = recursiveForceSource;
    recursive = true;
    mutable = {
      enable = true;
      mode = "force";
    };
  };

  # Basic packages for testing
  home.packages = with pkgs; [
    htop
    tree
    jq
    (import ./scripts/selftest.nix {
      inherit pkgs;
      mutableDirectory = config.home.mutableDirectory;
    })
  ];

}
