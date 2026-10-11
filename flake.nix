{
  description = "heidisql";

  inputs = { };

  outputs = { self }:
    let
      heidisqlSource = fetchTarball {
        url = "https://github.com/HeidiSQL/HeidiSQL/releases/download/v12.21/build-qt6-v12.21.tgz";
        sha256 = "sha256:01yz8yar20l9rpvi3v987lv77zn07j36yy7ybkyiiyzb4dk2i54i";
      };

      mkHeidisql = pkgs: { extraPackages ? [] }: pkgs.buildFHSEnv {
        name = "heidisql";
        targetPkgs = p: with p; [
          qt6.qtbase
          kdePackages.libqtpas
          libX11
        ] ++ extraPackages;
        runScript = "${heidisqlSource}/heidisql";
        extraInstallCommands = ''
          install -Dm644 ${./heidisql.desktop} $out/share/applications/heidisql.desktop
          install -Dm644 ${heidisqlSource}/heidisql.png $out/share/icons/hicolor/256x256/apps/heidisql.png
        '';
        meta = {
          description = "heidisql";
          mainProgram = "heidisql";
          platforms = [ "x86_64-linux" ];
        };
      };
    in
    {
      homeManagerModules.default = { config, lib, pkgs, ... }: {
        options.programs.heidisql = {
          enable = lib.mkEnableOption "heidisql";
          extraPackages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            example = lib.literalExpression "[ pkgs.postgresql pkgs.mariadb-connector-c ]";
            description = "DB drivers shared libraries";
          };
        };

        config = lib.mkIf config.programs.heidisql.enable {
          home.packages = [
            (mkHeidisql pkgs { extraPackages = config.programs.heidisql.extraPackages; })
          ];
        };
      };
    };
}
