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
      ];
      pkgs = import self.inputs.nixpkgs {
        inherit system;
        overlays = with self.inputs; [
          composable-networks.overlays.default
          # cosmos.overlays.default
          (final: prev: {
            cw-cvm-executor = self.inputs.composable-vm.packages."${system}".cw-cvm-executor;
            cw-cvm-outpost = self.inputs.composable-vm.packages."${system}".cw-cvm-outpost;
            cw-mantis-order = self.inputs.composable-vm.packages."${system}".cw-mantis-order;
            mantis = self.inputs.composable-vm.packages."${system}".mantis;
          })
        ];
      };
    };
  };
}
