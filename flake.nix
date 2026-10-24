{
  description = "playos — mod de workos para juegos: sesiones Work y Play, Steam y Otteretro";

  # Todo lo de workos sigue igual; PlayOS solo suma lo de juegos encima.
  inputs.workos.url = "github:OscarVargas97/workos";

  outputs = { self, workos, ... }: {
    # Igual que workos.lib.mkHost, con el módulo de PlayOS incluido. Lo
    # personal (identidad, hardware, host) llega en `modules` desde el repo
    # privado de quien lo usa: este repo no conoce a nadie.
    lib.mkHost = modules: workos.lib.mkHost ([ self.nixosModules.playos ] ++ modules);

    nixosModules.playos = ./modules/playos.nix;

    # VM de prueba con un usuario de ejemplo. `nix flake check` la evalúa.
    nixosConfigurations.vm = self.lib.mkHost [ workos.nixosModules.vm ./hosts/vm.nix ];
  };
}
