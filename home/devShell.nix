{ pkgs, lib, ... }:

let
  recursiveMergeAttrs = listOfAttrsets: lib.fold (attrset: acc: lib.recursiveUpdate attrset acc) { } listOfAttrsets;

  shellEnv = import ./shellEnv.nix { inherit pkgs; };
  yarnOverride = { nodejs }: pkgs.yarn.overrideAttrs (oldAttrs: {
    buildInputs = [ nodejs ];
  });
  # for use devShell
  # write a file .envrc in some directory with contents:
  # use nix-envs [devShell_Name]
  #
  # for [devShell_Name] see the attributes set of devShells
  # you can combine one or many devShell on environment, example:
  # use nix-env go node14
  devShells = with pkgs; {
    node14 = mkShell {
      buildInputs = [ python27 ];
      packages = [
        nodejs-14_x
        (yarnOverride {
          nodejs = nodejs-14_x;
        })
      ];
    };

    node16 = mkShell
      {
        buildInputs = [ python27 ];
        packages = [
          nodejs-16_x
          (yarnOverride {
            nodejs = nodejs-16_x;
          })
        ];
      };

    node18 = mkShell
      {
        packages = [
          nodejs-18_x
          (yarnOverride {
            nodejs = nodejs-18_x;
          })
        ];
      };
  };

  useNixShell =
    {
      xdg.configFile."direnv/lib/use_nix-env.sh".text = ''
        function use_nix-env(){
          for name in $@; do
            . "$HOME/.config/direnv/nix-envs/''${name}/env"
          done
        }
      '';
    };

  toWriteShell = name: devShell: { xdg.configFile."direnv/nix-envs/${name}".source = shellEnv devShell; };

  devShellsConfigurations = [ useNixShell ] ++ lib.attrsets.mapAttrsToList
    toWriteShell
    devShells;

in

recursiveMergeAttrs
  devShellsConfigurations
