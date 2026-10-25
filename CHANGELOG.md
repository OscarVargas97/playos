# Novedades

Lo que trae cada versión de PlayOS, lo más nuevo arriba.

## PlayOS y Linux (en curso)

`fase/p0-playos` · PR #8 y #9

### Nuevo
- **PlayOS existe**: un flake sobre workos que tu repo privado usa en lugar de workos (`playos.lib.mkHost`). Por ahora arma el mismo sistema que workos; las sesiones Work y Play y lo de juegos llegan en las próximas tareas.
- **Work o Play al entrar**: en la pantalla de acceso, F3 elige la sesión: **Work** es la Hyprland de workos y **Play** es Steam a pantalla completa (la sesión gamescope, como SteamOS). Recuerda la última que usaste.
- **Otteretro viene instalado**, con su entrada en el menú (`programs.otteretro.enable`, encendido por defecto). Se compila con las mismas librerías que el resto del sistema.
- **Otteretro abre solo en Play**: al entrar, PlayOS lo agrega a tu biblioteca de Steam como juego que no es de Steam (si ya tenías accesos directos, guarda antes una copia, `shortcuts.vdf.antes-playos`) y Steam lo abre a pantalla completa. Desde Steam se vuelve a Otteretro como a cualquier juego.
- **Lo de juegos**: Steam con Proton-GE, Remote Play, transferencias por red local y Steam Input en Wayland; Steam ROM Manager, Heroic, Lutris, Bottles, itch, Vesktop, OBS y gpu-screen-recorder; GameMode pone el perfil de energía en rendimiento mientras juegas, MangoHud y LACT; adaptador de mandos Xbox, hardware de Steam y Bluetooth. Cada grupo se apaga con `playos.stores`, `playos.performance` o `playos.controllers` (`.enable = false`).
- **Portátiles Lenovo Legion**: `playos.legion.enable = true;` suma LenovoLegionLinux y OpenRGB.
- **Llavero del sistema**: gnome-keyring se abre con tu contraseña al entrar; ahí guardan sus claves las apps, como Otteretro.
- **VM de prueba**: `nix flake check` evalúa el módulo de PlayOS y una VM con un usuario de ejemplo.
