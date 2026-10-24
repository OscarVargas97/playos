# playos

Mod de [workos](https://github.com/OscarVargas97/workos) para jugar: suma a workos lo de juegos (sesiones Work y Play, Steam, rendimiento, mandos y [Otteretro](https://github.com/OscarVargas97/otteretro)). Todo lo que tienes en workos sigue igual.

> En construcción: hoy el flake ya arma un sistema workos con el módulo de PlayOS, pero el módulo todavía está vacío. Las sesiones y los juegos llegan en las próximas tareas.

## Cómo se usa

Igual que workos: no se instala directo, lo instala tu repo privado. En el `flake.nix` de tu repo privado (el que creaste desde `workos-template`), cambia `workos` por `playos`:

```nix
{
  inputs.playos.url = "github:OscarVargas97/playos";

  outputs = { playos, ... }: {
    nixosConfigurations.mi-pc = playos.lib.mkHost [ ./identity.nix ./home.nix ./hosts/mi-pc ];
  };
}
```

`playos.lib.mkHost` recibe lo mismo que `workos.lib.mkHost` y le agrega `playos.nixosModules.playos`. Si prefieres seguir con `workos.lib.mkHost`, suma ese módulo a la lista.

## Probarlo

```bash
nix flake check   # evalúa el módulo y la VM de prueba (hosts/vm.nix)
```

Necesita Nix con flakes en Linux. Desde Windows, por ssh a una máquina con Nix.

## Qué trae

| Ruta | Qué es |
|---|---|
| `flake.nix` | `lib.mkHost`, `nixosModules.playos` y la VM de prueba `nixosConfigurations.vm` |
| `modules/playos.nix` | Lo que PlayOS suma a workos |
| `hosts/vm.nix` | Usuario de ejemplo de la VM de prueba |
| `docs/DECISIONS.md` | Dónde están las decisiones |
