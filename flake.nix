{
  description = "PLB Scrapers";
  inputs = {
    nixpkgs.url = "github:TheAncientGoat/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "mach-nix/3.4.0";
    mach-nix.inputs.nixpkgs.follows = "nixpkgs";
    mach-nix.inputs.pypi-deps-db.url = "github:DavHau/pypi-deps-db";
  };
  outputs = { self, nixpkgs, flake-utils, mach-nix }:
    # TODO: possibly use this pattern to freeze mach inputs: https://github.com/nesyamun/nix-flake-python-example/blob/main/flake.nix
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        pythonInputs = mach-nix.lib."${system}".mkPython {
          ignoreDataOutdated = true;
          requirements = ''
            pandas-profiling
            pandera
            modin[dask] == 0.12.1
          '';
        };
        buildInputs = with pkgs; [
          pkgs.python3Packages.flake8
          gcc
          unzip
          mypy
          pyright
          python3Packages.aiohttp
          python3Packages.cupy
          python3Packages.openbabel-bindings
          python3Packages.pathvalidate
          python3Packages.pint
          python3Packages.pyarrow
          python3Packages.rdkit
          python3Packages.requests
          python3Packages.tables
          python3Packages.tqdm
          python3Packages.pytest
          python39Packages.polars
          python3Packages.dask
          python3Packages.numpy
          python3Packages.pandas
          python3Packages.pandas-stubs
          python3Packages.gql
          python3Packages.requests-mock
          (dvc.override { enableGoogle = true; })
          pythonInputs
        ];
      in {
        devShell = with pkgs;
          mkShell {
            inherit buildInputs;
            shellHook = ''
              export PYTHONPATH=$PYTHONPATH:$(pwd)
            '';
          };
      });
}
