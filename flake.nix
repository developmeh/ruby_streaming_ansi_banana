{
  description = "A Nix-flake-based Protobuf development environment";

  inputs.nixpkgs = {
    type = "github";
    owner = "ninjapanzer";
    repo = "nixpkgs";
    rev = "ee8a7accf156e3c1bde14f21f6acfc14ccec133f";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        system = system;  # Ensure the 'system' is passed into the function
        pkgs = import nixpkgs { inherit system; };
      });

      # Define gems directly for each system
      gems = system: let
        buildpkgs = import nixpkgs { system = system; };
      in buildpkgs.bundlerEnv {
        name = "ruby-dancing-banana";
        ruby = buildpkgs.ruby_3_2;
        gemfile = ./Gemfile;
        lockfile = ./Gemfile.lock;
        gemset = ./gemset.nix;
      };

      # Build the docker image for each system dynamically
      buildImage = systemAttrs: let
        buildpkgs = import nixpkgs { system = systemAttrs.system; };
        gemEnv = gems systemAttrs.system;
      in buildpkgs.dockerTools.buildImage {
        name = "ruby-dancing-banana";
        created = "now";
        tag = "latest";
        copyToRoot = buildpkgs.buildEnv {
          name = "image-root";
          paths = [
            gemEnv
          ];
          postBuild = ''
            mkdir -p $out/app
            cp ${./main.rb} $out/app/main.rb
            cp -r ${./ascii_frames} $out/app/ascii_frames
          '';
        };
        config = {
          Cmd = [ "${gemEnv.wrappedRuby}/bin/ruby" "/app/main.rb" "-o" "0.0.0.0" ];
          WorkingDir = "/app";
          ExposedPorts = { "4567/tcp" = {}; };
        };
      };

    in
    {
      # Default package for each supported system
      defaultPackage = forEachSupportedSystem (systemAttrs: buildImage systemAttrs);

      # DevShells for all supported systems
      devShells = forEachSupportedSystem (systemAttrs: let
        pkgs = systemAttrs.pkgs;
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            bundix
            (gems systemAttrs.system).wrappedRuby
            (gems systemAttrs.system)
          ];
        };
      });
    };
}
