# Lo de juegos que PlayOS suma a workos. Cada parte llega con su tarea:
# las sesiones Work y Play (P0.9) y Steam, rendimiento y mandos (P0.10).
{ lib, pkgs, ... }:
let
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
in
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true; # trae steam-gamescope
  };

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
