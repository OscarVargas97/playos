# Lo de juegos que PlayOS suma a workos: las sesiones Work y Play (P0.9) y
# Steam, tiendas, rendimiento, mandos y Legion (P0.10, decisiones 110 y 111).
# Cada grupo se apaga con su opción playos.<grupo>.enable.
{ config, lib, pkgs, ... }:
let
  cfg = config.playos;
  group = name: default: lib.mkOption {
    type = lib.types.bool;
    inherit default;
    description = "PlayOS: ${name}.";
  };

  # Las dos sesiones que ofrece el login (#105, #129): Work es la Hyprland de
  # workos; Play es la sesión gamescope de Steam, como SteamOS.
  sessions = pkgs.runCommand "playos-sessions" { } ''
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/work.desktop <<EOF
    [Desktop Entry]
    Name=Work
    Comment=Hyprland de workos
    Exec=start-hyprland
    Type=Application
    EOF
    cat > $out/share/wayland-sessions/play.desktop <<EOF
    [Desktop Entry]
    Name=Play
    Comment=Steam a pantalla completa
    Exec=steam-gamescope
    Type=Application
    EOF
  '';

  ppd = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl";
in
{
  options.playos = {
    stores.enable = group "tiendas y apps de juego (Heroic, Lutris, Bottles, itch, Steam ROM Manager, Vesktop, OBS)" true;
    performance.enable = group "rendimiento (GameMode con perfil de energía, MangoHud, LACT)" true;
    controllers.enable = group "mandos (adaptador Xbox, hardware de Steam)" true;
    legion.enable = group "Lenovo Legion (LenovoLegionLinux y OpenRGB); solo en esos portátiles" false;
  };

  config = lib.mkMerge [
    {
      # Steam siempre: la sesión Play es Steam (#129).
      programs.steam = {
        enable = true;
        gamescopeSession.enable = true; # trae steam-gamescope
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extest.enable = true; # Steam Input en Wayland
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
      programs.gamescope.enable = true;

      # Igual que el login de workos (hosts/vm/configuration.nix), más la lista de
      # sesiones (F3 en tuigreet) y recordar la última elegida.
      # ponytail: copia el comando de workos; si workos lo cambia, se copia de nuevo.
      services.greetd.settings.default_session.command = lib.mkForce (lib.concatStringsSep " " [
        "${pkgs.tuigreet}/bin/tuigreet --time"
        "--sessions ${sessions}/share/wayland-sessions --remember-session --cmd start-hyprland"
        "--background matrix --matrix-colors '#00FF41,#008F11,#003B00'"
        "--custom-title 'playos // acceso'"
        "--greeting '  (=^.^=)\\n (\")_(\")\\nF3: Work o Play'"
        "--asterisks --container-padding 2 --window-padding 2"
      ]);

      # Llavero para las apps (Otteretro guarda ahí su llave maestra, otteretro#9):
      # se abre con la contraseña al entrar por greetd.
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
    }

    (lib.mkIf cfg.stores.enable {
      environment.systemPackages = with pkgs; [
        steam-rom-manager heroic lutris bottles itch vesktop obs-studio
      ];
      programs.gpu-screen-recorder.enable = true;
    })

    (lib.mkIf cfg.performance.enable {
      # Perfil de energía de rendimiento mientras hay un juego abierto.
      services.power-profiles-daemon.enable = true;
      programs.gamemode = {
        enable = true;
        settings.custom = {
          start = "${ppd} set performance";
          end = "${ppd} set balanced";
        };
      };
      environment.systemPackages = [ pkgs.mangohud ];
      services.lact.enable = true;
    })

    (lib.mkIf cfg.controllers.enable {
      hardware.xone.enable = true;
      hardware.steam-hardware.enable = true;
      hardware.bluetooth.enable = true;
    })

    (lib.mkIf cfg.legion.enable {
      boot.extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
      environment.systemPackages = [ pkgs.lenovo-legion ];
      services.hardware.openrgb.enable = true;
    })
  ];
}
