{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  outputs = { self, nixpkgs }: {
    nixosConfigurations.juanc = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}