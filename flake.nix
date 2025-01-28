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
        pkgs = import nixpkgs { inherit system; };
      });
      buildpkgs = import nixpkgs { system = "x86_64-linux"; };
      gems = buildpkgs.bundlerEnv {
        name = "ruby-dancing-banana";
        ruby = buildpkgs.ruby_3_2;
        gemfile = ./Gemfile;
        lockfile = ./Gemfile.lock;
        gemset = ./gemset.nix;
      };
    in
    {
      defaultPackage.x86_64-linux =
      buildpkgs.dockerTools.buildImage {
        name = "ruby-dancing-banana";
        created = "now";
        tag = "latest";
        copyToRoot = buildpkgs.buildEnv {
          name = "image-root";
          paths = [
            gems
          ];
          postBuild = ''
            mkdir -p $out/app
            cp ${./main.rb} $out/app/main.rb
            cp -r ${./ascii_frames} $out/app/ascii_frames
          '';
        };
        config = {
          Cmd = [ "${gems.wrappedRuby}/bin/ruby" "/app/main.rb" "-o" "0.0.0.0" ];
          WorkingDir = "/app";
          ExposedPorts = { "4567/tcp" = {}; };
        };
      };

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            bundix
            gems.wrappedRuby
            gems
          ];
        };
      });
    };
}
