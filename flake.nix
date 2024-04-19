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

        # run by 3rd party
        mantis-solver = ''
          ${builtins.readFile ./setup_secrets.sh}
          RUST_BACKTRACE=full RUST_TRACE=debug ${composable-vm.packages.${system}.mantis}/bin/mantis solve --rpc-centauri "${networks.pica.mainnet.RPC}" --grpc-centauri "${networks.pica.mainnet.GRPC}" --cvm-contract "centauri19dw7w5cm48aeqwszva8kxmnfnft7wp4xt4s73ksyhdya704r3cdq389szq" --wallet "$MANTIS_COSMOS_MNEMONIC" --order-contract "centauri19gddjsu00zdlpjkw3s43fuxvftvsfg5usara65awwzn63v3lqj0s57la25" --main-chain-id="${networks.pica.mainnet.CHAIN_ID}"  --router="http://ec2-54-246-72-76.eu-west-1.compute.amazonaws.com:8000" | tee /var/log/mantis.log
        '';


        mantis-solver-simulator = ''
          ${builtins.readFile ./setup_secrets.sh}
          RUST_BACKTRACE=1 RUST_TRACE=trace ${composable-vm.packages.${system}.mantis}/bin/mantis simulate --rpc-centauri "${networks.pica.mainnet.RPC}" --grpc-centauri "${networks.pica.mainnet.GRPC}" --order-contract "centauri19gddjsu00zdlpjkw3s43fuxvftvsfg5usara65awwzn63v3lqj0s57la25" --wallet "$MANTIS_COSMOS_MNEMONIC" --cvm-contract "centauri19dw7w5cm48aeqwszva8kxmnfnft7wp4xt4s73ksyhdya704r3cdq389szq" --main-chain-id="${networks.pica.mainnet.CHAIN_ID}"  --coins="20000000000ppica,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="1000ibc/F34DC2408B2EB193D2A82388AC5F9AC86282B14BBF623A8581BBE075654547CD,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="10000ibc/0168A27E5B93E22E51DDF474FF86C6E43F8074B9D2454C6A8EE993490B169F13,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="100000ibc/4472060867B1527ECE6456D82B463A536EAF4ABC57E0099FF5302F4C93D8C65E,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="10000ibc/C727DE941C39B6A780B10FF3B3CD72B7DAFAF625C2902433C3CD5A672B33A94B,10000ibc/47BD209179859CDE4A2806763D7189B6E6FE13A17880FE2B42DE1E6C1E329E23" --coins="10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87,10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609" --coins="1000ibc/F34DC2408B2EB193D2A82388AC5F9AC86282B14BBF623A8581BBE075654547CD,10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609" --coins="10000ibc/0168A27E5B93E22E51DDF474FF86C6E43F8074B9D2454C6A8EE993490B169F13,10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609" --coins="3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718,10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609" --coins="100000ibc/4472060867B1527ECE6456D82B463A536EAF4ABC57E0099FF5302F4C93D8C65E,10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609" --coins="10000ibc/C727DE941C39B6A780B10FF3B3CD72B7DAFAF625C2902433C3CD5A672B33A94B,10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609" --coins="10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609,10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87" --coins="1000ibc/F34DC2408B2EB193D2A82388AC5F9AC86282B14BBF623A8581BBE075654547CD,10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87" --coins="10000ibc/0168A27E5B93E22E51DDF474FF86C6E43F8074B9D2454C6A8EE993490B169F13,10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87" --coins="3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718,10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87" --coins="100000ibc/4472060867B1527ECE6456D82B463A536EAF4ABC57E0099FF5302F4C93D8C65E,10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87" --coins="10000ibc/C727DE941C39B6A780B10FF3B3CD72B7DAFAF625C2902433C3CD5A672B33A94B,10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87" --coins="10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609,3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718" --coins="10000ibc/247DEF7C0E022DC3FAF5EB13A38C616252B5B85651803E03710CCBD581673C87,3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718" --coins="1000ibc/F34DC2408B2EB193D2A82388AC5F9AC86282B14BBF623A8581BBE075654547CD,3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718" --coins="10000ibc/0168A27E5B93E22E51DDF474FF86C6E43F8074B9D2454C6A8EE993490B169F13,3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718" --coins="100000ibc/4472060867B1527ECE6456D82B463A536EAF4ABC57E0099FF5302F4C93D8C65E,3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718" --coins="10000ibc/B063BCBCD45084893C9889EBE472D666F7E6F56300897DCECDFD7EB88C3E8609,3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718" --coins="10000ibc/C727DE941C39B6A780B10FF3B3CD72B7DAFAF625C2902433C3CD5A672B33A94B,3571632929589ibc/F472078E60F4AA887DA65A6009E501882594AAA5721C3C13F54724E6B29F1718" | tee /var/log/mantis.log
        '';

        # run by 3rd party
        mantis-blackbox-script = ''
          export CVM_ADDRESS='osmo15rquxg3zw8tcgj82hkz2qzy4f69nzzt5yl2qlgqkw6l9drlhfvcsr2yc8y'
          RUST_BACKTRACE=1 RUST_TRACE=trace ${composable-vm.packages.${system}.mantis-blackbox}/bin/mantis-blackbox | tee /var/log/blackbox.log
        '';

        mkLiveConfigModule = script: {
          networking.firewall.enable = true;
          networking.firewall.allowedTCPPorts = [80 22 443 22290];
          environment.systemPackages = [
            composable-vm.packages.${system}.mantis
            composable-vm.packages.${system}.mantis-blackbox
            pkgs.procps
          ];
          systemd.services = {
            mantis = {
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
                RestartSec = 2;
              };
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
            (mkLiveConfigModule mantis-solver)
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

        nixos-config-mantis-solver =
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              bootstrap-config-module
              (mkLiveConfigModule mantis-solver)
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
          TF_VAR_MANTIS_SOLVER_CONFIG_PATH = "${nixos-config-mantis-solver}";
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
            export TF_VAR_MANTIS_SOLVER_CONFIG_PATH="${nixos-config-mantis-solver}"
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
          mantis-node-1 = pkgs.writeShellScriptBin "mantis-node-1" mantis-solver;
        };
        devShells.default = let
          networks = pkgs.networksLib.networks;
          sh = pkgs.networksLib.sh;
        in
          pkgs.mkShell {
            TF_VAR_bootstrap_img_path = bootstrap-img-path;
            TF_VAR_MANTIS_SOLVER_CONFIG_PATH = "${nixos-config-mantis-solver}";
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
