{self, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    system,
    pkgs,
    ...
  }: {
    _module.args = {
      runtimeInputs = with pkgs; [
        bun
        centauri
        cw-cvm-executor
        cw-cvm-outpost
        cw-mantis-order
        dasel
        getoptions
        gex
        grpcurl
        jq
        nix-tree
        osmosis
        hermes
        mantis
        awscli2
        nixos-rebuild
        terranix
        terraform-ls
        opentofu
      ];
      pkgs = import self.inputs.nixpkgs {
        inherit system;
        overlays = with self.inputs; [
          composable-networks.overlays.default

          (final: prev: {
            centauri = self.inputs.cosmos.packages."${system}".centauri;
            osmosis = self.inputs.cosmos.packages."${system}".osmosis;
            hermes = self.inputs.cosmos.packages."${system}".hermes;
            cw-cvm-executor = self.inputs.composable-vm.packages."${system}".cw-cvm-executor;
            cw-cvm-outpost = self.inputs.composable-vm.packages."${system}".cw-cvm-outpost;
            cw-mantis-order = self.inputs.composable-vm.packages."${system}".cw-mantis-order;
            mantis = self.inputs.composable-vm.packages."${system}".mantis;
            mantis-blackbox = self.inputs.composable-vm.packages."${system}".mantis-blackbox;
          })
        ];
      };
    };
  };
}
