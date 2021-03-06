{
  description = "CQ-editor and CadQuery";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    cadquery = {
      url = "github:CadQuery/cadquery";
      flake = false;
    };
    cq-editor = {
      url = "github:CadQuery/CQ-editor";
      flake = false;
    };
    ocp = {
      url = "github:cadquery/ocp/7.4.0";
      flake = false;
    };
    ocp-stubs = {
      url = "github:cadquery/ocp-stubs/7.4.0";
      flake = false;
    };
    pywrap = {
      url = "github:CadQuery/pywrap";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      # someone else who can do the testing might want to extend this to other systems
      systems = [ "x86_64-linux" ];
    in
      flake-utils.lib.eachSystem systems ( system:
        let 
          pkgs = nixpkgs.legacyPackages.${system};
          # keep gcc, llvm and stdenv versions in sync
          gccSet = {
            # have to use gcc9 because freeimage complains with gcc8, could probably build freeimage with gcc8 if I have to, but this is easier.
            gcc = pkgs.gcc9;
            llvmPackages = pkgs.llvmPackages_9;
            stdenv = pkgs.gcc9Stdenv;
          };
        in rec {
          packages = {
            python38 = pkgs.python38.override {
              packageOverrides = python-self : python-super: {
                cadquery = python-self.callPackage ./expressions/cadquery.nix {
                  documentation = false;
                  src = inputs.cadquery;
                };
                cadquery_w_docs = python-self.callPackage ./expressions/cadquery.nix {
                  documentation = true;
                  src = inputs.cadquery;
                };
                ocp = python-self.callPackage ./expressions/OCP {
                  src = inputs.ocp;
                  inherit (gccSet) stdenv gcc llvmPackages;
                  opencascade-occt = packages.opencascade-occt; 
                };
                # TODO keep clang version in sync with llvm
                clang = python-self.callPackage ./expressions/clang.nix { };
                cymbal = python-self.callPackage ./expressions/cymbal.nix { };
                geomdl = python-self.callPackage ./expressions/geomdl.nix { };
                ezdxf = python-self.callPackage ./expressions/ezdxf.nix { };
                sphinx = python-self.callPackage ./expressions/sphinx.nix { };
                nptyping = python-self.callPackage ./expressions/nptyping.nix { };
                typish = python-self.callPackage ./expressions/typish.nix { };
                sphinx-autodoc-typehints = python-self.callPackage ./expressions/sphinx-autodoc-typehints.nix { };
                sphobjinv = python-self.callPackage ./expressions/sphobjinv.nix { };
                stdio-mgr = python-self.callPackage ./expressions/stdio-mgr.nix { };
                sphinx-issues = python-self.callPackage ./expressions/sphinx-issues.nix { };
                pytest-subtests = python-self.callPackage ./expressions/pytest-subtests.nix { };
                sphinxcadquery = python-self.callPackage ./expressions/sphinxcadquery.nix { };
                black = python-self.callPackage ./expressions/black.nix { };
                pybind11 = python-self.callPackage ./expressions/pybind11 { };
                pywrap = python-self.callPackage ./expressions/pywrap {
                  src = inputs.pywrap;
                  inherit (gccSet) stdenv gcc llvmPackages;
                  # clang is also pinned to 6.0.1 in the clang expression
                };
                ocp-stubs = python-self.callPackage ./expressions/OCP/stubs.nix {
                  src = inputs.ocp-stubs;
                };
              };
            };
            cq-editor = pkgs.libsForQt5.callPackage ./expressions/cq-editor.nix {
              python3Packages = packages.python38.pkgs;
              src = inputs.cq-editor;
            };
            opencascade-occt = pkgs.callPackage ./expressions/opencascade-occt {
              inherit (gccSet) stdenv;
            };
            cadquery-docs = packages.python38.pkgs.cadquery_w_docs.doc;
            cadquery-env = packages.python38.withPackages (
              ps: with ps; [ cadquery python-language-server black mypy ocp-stubs ]
            );
            # useful for debugging:
            nixpkgs-in = pkgs;
          };

          defaultPackage = packages.cq-editor;
          defaultApp = {
            type = "app";
            program = defaultPackage + "/bin/cq-editor";
          };
        }
      );
}
