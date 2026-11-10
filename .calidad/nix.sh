# ia-qa, perfil nix: nixfmt (formato), deadnix (código muerto) y statix (anti-patrones) en los rápidos; `nix flake check` en el CI.
nix_archivos() { find . -name '*.nix' -not -path './.git/*' -not -path './legacy/*' -not -path './result*' | sort; }
# Flakes activados aquí (fuera del CI no vienen por defecto); nixpkgs fijado a una rama estable, cámbiala en .calidad/local.sh con NIX_PKGS.
nix_cmd() { nix --extra-experimental-features 'nix-command flakes' "$@"; }
nix_tool() { t=$1; shift; nix_cmd run "${NIX_PKGS:-github:NixOS/nixpkgs/nixos-25.05}#$t" -- "$@"; }

# Cambio respecto del catálogo: en rapidos, sin nix en el PATH (p. ej. Windows) se salta con aviso; el CI lo exige siempre.
nix_rapidos() {
  command -v nix >/dev/null 2>&1 || { echo "aviso: sin nix, se saltan nixfmt/deadnix/statix (el CI los corre)" >&2; return 0; }
  nix_lint
}

nix_lint() {
  echo "== nixfmt"
  # shortcut: rutas sin espacios, cuando haya .nix con espacios pasar a un bucle while read.
  nix_tool nixfmt --check $(nix_archivos)
  echo "== deadnix"
  nix_tool deadnix --fail .
  echo "== statix"
  nix_tool statix check .
}

nix_ci() {
  nix_lint
  echo "== nix flake check"
  nix_cmd flake check
}
