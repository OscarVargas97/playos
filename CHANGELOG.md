# Novedades

Lo que trae cada versión de PlayOS, lo más nuevo arriba.

## PlayOS y Linux (en curso)

`fase/p0-playos` · PR —

### Nuevo
- **PlayOS existe**: un flake sobre workos que tu repo privado usa en lugar de workos (`playos.lib.mkHost`). Por ahora arma el mismo sistema que workos; las sesiones Work y Play y lo de juegos llegan en las próximas tareas.
- **Work o Play al entrar**: en la pantalla de acceso, F3 elige la sesión: **Work** es la Hyprland de workos y **Play** es Steam a pantalla completa (la sesión gamescope, como SteamOS). Recuerda la última que usaste.
- **Llavero del sistema**: gnome-keyring se abre con tu contraseña al entrar; ahí guardan sus claves las apps, como Otteretro.
- **VM de prueba**: `nix flake check` evalúa el módulo de PlayOS y una VM con un usuario de ejemplo.
