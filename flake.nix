{
  description = "env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    composable.url = "github:ComposableFi/composable";
    cvm.url = "github:ComposableFi/cvm";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    cvm,
    composable,
    nixpkgs-stable,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        bootstrap-config-module = {
          system.stateVersion = "23.05";
          services.openssh.enable = true;
          environment.systemPackages = [ pkgs.chkservice];
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/PGg+j/Y5gP/e7zyMCyK+f0YfImZgKZ3IUUWmkoGtT dz@pop-os" # dzmitry-lahoda
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNY+BfeToEN1+1HTSggNrFHYhYFl9H9dPgIJy558OgWHsYrhMA7PHUy3VK0DjnIT9jFU1PF3/v1tpgUij9bOm6Md6N7Dn2/XL6/FqPNJ9i408V6DdCmH65aJ2tnSJJ4aicD9P39MHVG6tYPKJX9BrHiGzLPLi+c/4CWXIcj/u4aAuvspfCu6a5jWPj03XBwUUbkmdgyvEJ7wJoiOKE1b/Ilxiithau7w0GgHG3e1RUMeVy4aaNET3sTlhiJf4k+cL+7MIM13wUiqjglyzBfMGQKPsaHFuMMsfK4lHploLkBZeopiIxyRzQeRODFsuUSR+J/oL7TiIyMALCEqErRb8OrmPI7NKYRqokfU20YTgOSW+t7JxCx5vtYHyw2HVMZTnSeHAFfcclBh1Vi4vqHymNhJXEh35k/iLdUNdcMgHyqmjZZecpAT3fIULOlGfyfc6kKFmfAYWFcci+ByE0e0T82BlLWJHBuQTByu2w+IzUA81uKBqBqNgLayi49Bpwg5k= dz@pop-os
" # dzmitry-lahoda
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAsGO0KDHzP5swgMDDqCOo7siBoEvKnyAAXcI7CKhBHg dz@pop-os" # GH actions of env
          ];
        };

        mantis-solver-pica-osmo = ''
          if [ -f /root/.env ]; then
            source /root/.env
          else
            echo "No .env file found"
          fi
          RUST_BACKTRACE=1 RUST_TRACE=trace ${cvm.packages.${system}.mantis}/bin/mantis solve --rpc-centauri "https://composable-rpc.polkachu.com:443" --grpc-centauri "https://composable-grpc.polkachu.com:22290" --cvm-contract "centauri1wpf2szs4uazej8pe7g8vlck34u24cvxx7ys0esfq6tuw8yxygzuqpjsn0d" --wallet "$MANTIS_COSMOS_MNEMONIC" --order-contract "centauri10tpdfqavjtskze6325ragz66z2jyr6l76vq9h9g4dkhqv748sses6pzs0a" --simulate "200000ppica,10ibc/EF48E6B1A1A19F47ECAEA62F5670C37C0580E86A9E88498B7E393EB6F49F33C0" | tee /var/log/mantis.log
        '';

        mantis-solver-pica-ntrn = ''
          if [ -f /root/.env ]; then
            source /root/.env
          else
            echo "No .env file found"
          fi
          RUST_BACKTRACE=1 RUST_TRACE=trace ${cvm.packages.${system}.mantis}/bin/mantis solve --rpc-centauri "https://composable-rpc.polkachu.com:443" --grpc-centauri "https://composable-grpc.polkachu.com:22290" --cvm-contract "centauri1wpf2szs4uazej8pe7g8vlck34u24cvxx7ys0esfq6tuw8yxygzuqpjsn0d" --wallet "$MANTIS_COSMOS_MNEMONIC" --order-contract "centauri10tpdfqavjtskze6325ragz66z2jyr6l76vq9h9g4dkhqv748sses6pzs0a" --simulate "200000ppica,100ibc/43C92566AEA8C100CF924DB324BD8F699B6374CA5B93BF6BCFEC4777B62D50D1" | tee /var/log/mantis.log
        '';

        live-config-module = script: {
          networking.firewall.enable = true;
          networking.firewall.allowedTCPPorts = [80 22 443 22290];
          environment.systemPackages = [cvm.packages.${system}.mantis];
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
            (live-config-module mantis-solver-pica-osmo)
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

        live-config =
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              bootstrap-config-module
              (live-config-module mantis-solver-pica-osmo)
              "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
            ];
          })
          .config
          .system
          .build
          .toplevel;

        live-config-1 =
          (inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              bootstrap-config-module
              (live-config-module mantis-solver-pica-ntrn)
              "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
            ];
          })
          .config
          .system
          .build
          .toplevel;

        bootstrap-img-path = "${bootstrap-img}/${bootstrap-img-name}.vhd";

        deploy-shell = pkgs.mkShell {
          packages = [pkgs.terraform];
          TF_VAR_bootstrap_img_path = bootstrap-img-path;
          TF_VAR_live_config_path_0 = "${live-config}";
          TF_VAR_live_config_path_1 = "${live-config-1}";
        };

        terraform = pkgs.writeShellScriptBin "terraform" ''
          if [ -f .env ]; then
            source .env
          fi
          export TF_VAR_bootstrap_img_path="${bootstrap-img-path}"
          export TF_VAR_live_config_path_0="${live-config}"
          export TF_VAR_live_config_path_1="${live-config-1}"
          export TF_VAR_AWS_REGION="eu-central-1"
          cd terraform/aws
          ${inputs.nixpkgs-stable.legacyPackages.${system}.terraform}/bin/terraform $@
        '';
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

        devShells.default = pkgs.mkShell {
          TF_VAR_bootstrap_img_path = bootstrap-img-path;
          TF_VAR_live_config_path_0 = "${live-config}";
          buildInputs = with pkgs; [
            awscli2
            nixos-rebuild
            inputs.nixpkgs-stable.legacyPackages.${system}.terraform
            terranix
            terraform-ls
            opentofu
            composable.packages.${system}.centaurid
          ];
        };
      };
    };
}
