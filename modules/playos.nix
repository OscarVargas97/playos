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
    Comment=Steam a pantalla completa, con Otteretro encima
    Exec=${play}
    Type=Application
    EOF
  '';

  ppd = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl";

  # Otteretro como juego que no es de Steam (#129): Steam solo muestra en la
  # sesión Play lo que lanza él (playos#6). El appid es el que usaría Steam ROM
  # Manager: crc32 de Exe + AppName, con el bit alto encendido.
  otteretroAppId = 3250732779;
  otteretroGameId = "13961790973873750016"; # (appid << 32) | 0x02000000

  # Agrega Otteretro a los accesos directos de cada cuenta de Steam si no está.
  # Steam los lee al arrancar y los reescribe al salir: por eso corre antes.
  steamShortcut = pkgs.writers.writePython3Bin "playos-steam-shortcut"
    { libraries = [ pkgs.python3Packages.vdf ]; flakeIgnore = [ "E501" ]; } ''
    import glob
    import os
    import shutil
    import vdf

    APPID = ${toString otteretroAppId}
    EXE = '"/run/current-system/sw/bin/Otteretro"'

    for config in glob.glob(os.path.expanduser("~/.local/share/Steam/userdata/*/config")):
        path = os.path.join(config, "shortcuts.vdf")
        data = {"shortcuts": {}}
        if os.path.exists(path):
            with open(path, "rb") as f:
                data = vdf.binary_loads(f.read())
        items = data.setdefault("shortcuts", {})
        if any(int(s.get("appid", 0)) & 0xFFFFFFFF == APPID for s in items.values()):
            continue
        if os.path.exists(path) and not os.path.exists(path + ".antes-playos"):
            shutil.copy2(path, path + ".antes-playos")
        items[str(max(map(int, items), default=-1) + 1)] = {
            "appid": APPID - 2**32,  # Steam lo guarda como entero con signo
            "AppName": "Otteretro",
            "Exe": EXE,
            "StartDir": '"/run/current-system/sw/bin/"',
            "icon": "/run/current-system/sw/share/icons/hicolor/128x128/apps/otteretro.png",
            "ShortcutPath": "", "LaunchOptions": "", "IsHidden": 0,
            "AllowDesktopConfig": 1, "AllowOverlay": 1, "OpenVR": 0, "Devkit": 0,
            "DevkitGameID": "", "DevkitOverrideAppID": 0, "LastPlayTime": 0,
            "FlatpakAppID": "", "tags": {},
        }
        with open(path + ".tmp", "wb") as f:
            f.write(vdf.binary_dumps(data))
        os.replace(path + ".tmp", path)
  '';

  # La sesión Play: el acceso directo (si falla, Steam abre igual) y Steam,
  # que abre Otteretro solo (steamArgs).
  play = pkgs.writeShellScript "playos-play" ''
    ${steamShortcut}/bin/playos-steam-shortcut || echo "playos: no se pudo agregar Otteretro a Steam" >&2
    exec /run/current-system/sw/bin/steam-gamescope
  '';
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
      # Otteretro, la primera app de la sesión Play (#114, #129).
      programs.otteretro.enable = lib.mkDefault true;

      # Steam siempre: la sesión Play es Steam (#129).
      programs.steam = {
        enable = true;
        gamescopeSession.enable = true; # trae steam-gamescope
        # Los de nixpkgs más abrir Otteretro al arrancar (playos#6).
        gamescopeSession.steamArgs = [ "-tenfoot" "-pipewire-dmabuf" "steam://rungameid/${otteretroGameId}" ];
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
