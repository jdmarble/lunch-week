{
  description = "Ansible playbooks and roles for deploying a reference platform cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    mach-nix = {
      url = "github:DavHau/mach-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        pypi-deps-db.url = "github:shebpamm/pypi-deps-db-2";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python-packages = mach-nix.lib."${system}".mkPython {
          requirements = builtins.readFile ./requirements.txt;
        };
      in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          ansible # TODO: Switch to ansible-core
          libiconv # Needed for ripsecrets pre-commit
          pre-commit # Runs ansible-lint (and more) before commit
        ] ++ [ python-packages ];
      };
    });
}
