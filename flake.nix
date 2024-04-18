{
  description = "env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    composable-vm.url = "github:ComposableFi/composable-vm";
    composable-nix.url = "github:ComposableFi/nix";
    composable-networks.url = "github:ComposableFi/networks";
    cosmos = {
      url = "github:informalsystems/cosmos.nix/dz/38";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    composable-networks,
    composable-nix,
    composable-vm,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./args.nix
      ];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        buildInputs,
        runtimeInputs,
        ...
      }: let
              networks = pkgs.networksLib.networks;
        bootstrap-config-module = {
          system.stateVersion = "23.05";
          services.openssh.enable = true;
          environment.systemPackages = [];
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/PGg+j/Y5gP/e7zyMCyK+f0YfImZgKZ3IUUWmkoGtT dz@pop-os" # dzmitry-lahoda
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNY+BfeToEN1+1HTSggNrFHYhYFl9H9dPgIJy558OgWHsYrhMA7PHUy3VK0DjnIT9jFU1PF3/v1tpgUij9bOm6Md6N7Dn2/XL6/FqPNJ9i408V6DdCmH65aJ2tnSJJ4aicD9P39MHVG6tYPKJX9BrHiGzLPLi+c/4CWXIcj/u4aAuvspfCu6a5jWPj03XBwUUbkmdgyvEJ7wJoiOKE1b/Ilxiithau7w0GgHG3e1RUMeVy4aaNET3sTlhiJf4k+cL+7MIM13wUiqjglyzBfMGQKPsaHFuMMsfK4lHploLkBZeopiIxyRzQeRODFsuUSR+J/oL7TiIyMALCEqErRb8OrmPI7NKYRqokfU20YTgOSW+t7JxCx5vtYHyw2HVMZTnSeHAFfcclBh1Vi4vqHymNhJXEh35k/iLdUNdcMgHyqmjZZecpAT3fIULOlGfyfc6kKFmfAYWFcci+ByE0e0T82BlLWJHBuQTByu2w+IzUA81uKBqBqNgLayi49Bpwg5k= dz@pop-os
" # dzmitry-lahoda
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAsGO0KDHzP5swgMDDqCOo7siBoEvKnyAAXcI7CKhBHg dz@pop-os" # GH actions of env
          ];
        };

        mantis-solver-pica-osmo = ''
          ${builtins.readFile ./setup_secrets.sh}
          RUST_BACKTRACE=1 RUST_TRACE=trace ${composable-vm.packages.${system}.mantis}/bin/mantis solve --rpc-centauri "https://composable-rpc.polkachu.com:443" --grpc-centauri "https://composable-grpc.polkachu.com:22290" --cvm-contract "centauri1wpf2szs4uazej8pe7g8vlck34u24cvxx7ys0esfq6tuw8yxygzuqpjsn0d" --wallet "$MANTIS_COSMOS_MNEMONIC" --order-contract "centauri10tpdfqavjtskze6325ragz66z2jyr6l76vq9h9g4dkhqv748sses6pzs0a"  | tee /var/log/mantis.log
        '';

        mantis-solver-simulator = ''
          ${builtins.readFile ./setup_secrets.sh}
          RUST_BACKTRACE=1 RUST_TRACE=trace watch --no-title  --interval=60 --exec ${composable-vm.packages.${system}.mantis}/bin/mantis mantis simulate --rpc-centauri "${networks.pica.mainnet.RPC}" --grpc-centauri "${networks.pica.mainnet.GRPC}" --order-contract "$ORDER_CONTRACT" --wallet "$MANTIS_COSMOS_MNEMONIC" --coins "200000ppica,10ibc/EF48E6B1A1A19F47ECAEA62F5670C37C0580E86A9E88498B7E393EB6F49F33C0" --cvm-contract "$CVM_CONTRACT" --main-chain-id="$CHAIN_ID" | tee /var/log/mantis.log
        '';

        mantis-blackbox-script = ''
          RUST_BACKTRACE=1 RUST_TRACE=trace ${composable-vm.packages.${system}.mantis-blackbox}/bin/mantis-blackbox | tee /var/log/blackbox.log
        '';

        mkLiveConfigModule = script: {
          networking.firewall.enable = true;
          networking.firewall.allowedTCPPorts = [80 22 443 22290];
          environment.systemPackages = [composable-vm.packages.${system}.mantis composable-vm.packages.${system}.mantis-blackbox];
          systemd.services.mantis = {
            enable = true;
            wantedBy = ["multi-user.target"];
            after = ["network.target"];
            inherit script;
            unitConfig = {
              StartLimitIntervalSec = 0;
              StartLimitBurst = 2147483647;
            };
            serviceConfig = {
              Restart = "always";
              Type = "simple";
            };
          };
        };

        nixos-config-mantis-blackbox =
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              bootstrap-config-module

              {
                networking.firewall.enable = true;
                networking.firewall.allowedTCPPorts = [80 22 443 22290 8000];
                environment.systemPackages = [composable-vm.packages.${system}.mantis-blackbox];
                systemd.services.mantis = {
                  enable = true;
                  wantedBy = ["multi-user.target"];
                  after = ["network.target"];
                  script = mantis-blackbox-script;
                  unitConfig = {
                    StartLimitIntervalSec = 0;
                    StartLimitBurst = 2147483647;
                  };
                  serviceConfig = {
                    Restart = "always";
                    Type = "simple";
                  };
                };
              }

              "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
            ];
          })
          .config
          .system
          .build
          .toplevel;

        mantis-vm = inputs.nixos-generators.nixosGenerate {
          inherit pkgs;
          format = "vm";
          modules = [
            bootstrap-config-module
            {
              services.getty.autologinUser = "root";
              virtualisation.forwardPorts = [
                {
                  from = "host";
                  host.port = 8000;
                  guest.port = 80;
                }
              ];
            }
            (mkLiveConfigModule mantis-solver-pica-osmo)
          ];
        };

        bootstrap-img-name = "nixos-bootstrap-${system}";
        bootstrap-img = inputs.nixos-generators.nixosGenerate {
          inherit pkgs;
          format = "amazon";
          modules = [
            bootstrap-config-module
            {amazonImage.name = bootstrap-img-name;}
          ];
        };

        nixos-config-mantis-solver-pica-osmo =
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              bootstrap-config-module
              (mkLiveConfigModule mantis-solver-pica-osmo)
              "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
            ];
          })
          .config
          .system
          .build
          .toplevel;

        nixos-config-mantis-solver-simulator =
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              bootstrap-config-module
              (mkLiveConfigModule mantis-solver-simulator)
              "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
            ];
          })
          .config
          .system
          .build
          .toplevel;

        bootstrap-img-path = "${bootstrap-img}/${bootstrap-img-name}.vhd";

        deploy-shell = pkgs.mkShell {
          packages = [pkgs.opentofu];
          TF_VAR_bootstrap_img_path = bootstrap-img-path;
          TF_VAR_live_config_path_0 = "${nixos-config-mantis-solver-pica-osmo}";
          TF_VAR_MANTIS_SOLVER_SIMULATOR_CONFIG = "${nixos-config-mantis-solver-simulator}";
        };

        terraform = pkgs.writeShellApplication {
          name = "terraform";
          runtimeInputs = [pkgs.opentofu];
          text = ''
            if [ -f .env ]; then
              # shellcheck disable=SC1091
              source .env
            fi
            export TF_VAR_bootstrap_img_path="${bootstrap-img-path}"
            export TF_VAR_live_config_path_0="${nixos-config-mantis-solver-pica-osmo}"
            export TF_VAR_MANTIS_SOLVER_SIMULATOR_CONFIG="${nixos-config-mantis-solver-simulator}"
            export TF_VAR_MANTIS_BLACKBOX_CONFIG_PATH="${nixos-config-mantis-blackbox}"
            export TF_VAR_AWS_REGION="eu-central-1"
            # (
            #   cd terraform/github.com
            #   # shellcheck disable=SC2068
            #   tofu $@
            # )
            (
              cd terraform/aws
              # shellcheck disable=SC2068
              tofu $@
            )
          '';
        };
      in rec {
        formatter = pkgs.alejandra;
        packages = {
          inherit
            mantis-vm
            bootstrap-img
            terraform
            ;
          mantis-node-1 = pkgs.writeShellScriptBin "mantis-node-1" mantis-solver-pica-osmo;
        };
        devShells.default = let
          networks = pkgs.networksLib.networks;
          sh = pkgs.networksLib.sh;
        in
          pkgs.mkShell {
            TF_VAR_bootstrap_img_path = bootstrap-img-path;
            TF_VAR_live_config_path_0 = "${nixos-config-mantis-solver-pica-osmo}";
            buildInputs = runtimeInputs;
            EXECUTOR_WASM_FILE = "${
              pkgs.cw-cvm-executor
            }/lib/cw_cvm_executor.wasm";
            OUTPOST_WASM_FILE = "${
              pkgs.cw-cvm-outpost
            }/lib/cw_cvm_outpost.wasm";
            ORDER_WASM_FILE = "${
              pkgs.cw-mantis-order
            }/lib/cw_mantis_order.wasm";
            shellHook = ''
              
              rm --force --recursive ~/.banksy
              mkdir --parents ~/.banksy/config
              echo 'keyring-backend = "os"' >> ~/.banksy/config/client.toml
              echo 'output = "json"' >> ~/.banksy/config/client.toml
              echo 'node = "${networks.pica.mainnet.NODE}"' >> ~/.banksy/config/client.toml
              echo 'chain-id = "${networks.pica.mainnet.CHAIN_ID}"' >> ~/.banksy/config/client.toml
              rm ~/.osmosisd/config/client.toml
              osmosisd set-env mainnet
            '';
          };
      };
    };
}
