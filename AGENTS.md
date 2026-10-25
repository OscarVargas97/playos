# PlayOS — instrucciones para agentes de IA

Mod público de [workos](https://github.com/OscarVargas97/workos) para juegos. Un flake que importa `workos` y le suma un módulo: sesiones Work y Play, Steam, rendimiento, mandos y Otteretro. La guía para humanos es el `README.md`.

**Antes de leer o tocar algo de workos:** `git pull --ff-only` en `workos`, `workos-template` y el repo privado. Se editan desde varias máquinas.

## Invariantes (los de workos, no romper nunca)

1. **Cero datos personales**: ni nombres, emails, usuarios, hostnames reales, IPs, claves SSH, rutas `/home/<alguien>` ni empresas. Vale también para comentarios, ejemplos y mensajes de commit. Lo de cada persona va en su repo privado.
2. **Cero secretos**, en ningún repo.
3. **Nada destructivo sin confirmación humana** (particionar, formatear, borrar). El `rebuild` con sudo lo hace la persona.
4. **Todo declarativo**: un cambio de sistema es un cambio en un `.nix` versionado.
5. **La IA nunca desbloquea Bitwarden.**

## Cómo se conectan las piezas

```
repo privado/flake.nix
  └─ playos.lib.mkHost [ identidad, hardware, host ]
       └─ workos.lib.mkHost [ playos.nixosModules.playos, … ]
```

`modules/playos.nix` es el único lugar donde PlayOS cambia el sistema. Lo común a toda máquina workos se cambia en workos, no acá.

## Comandos

| Para | Comando |
|---|---|
| Validar (módulo y VM de prueba) | `nix flake check` |
| Actualizar workos | `nix flake update workos` y commitear `flake.lock` |

Desde Windows no hay Nix: se prueba por ssh en una máquina Linux con Nix, copiando el repo a una carpeta temporal.

## Cómo se trabaja

- **Decisiones**: en el registro de Otteretro (`docs/DECISIONS.md` dice dónde).
- **Tareas**: issues de este repo, en el milestone de su fase y en el Project de PlayOS. Sin issue no hay trabajo.
- **Ramas**: la de la fase (`fase/<n>-<nombre>`, la misma que en Otteretro) o `feat|fix|chore|docs/<nombre>`, desde `main` y por PR.
- **Commits**: Conventional Commits en español, con `Refs #n` de la tarea.
- **CHANGELOG.md**: cada PR suma arriba lo que trae.
- **Idioma**: identificadores y opciones de Nix en inglés; comentarios, docs y commits en español neutro.
