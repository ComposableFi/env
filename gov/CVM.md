## How to deploy and configure mainnet

```sh
nix develop composable#centauri-mainnet" --impure
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=auto -y
$BINARY tx wasm instantiate 40 '{"admin": "centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k", "network_id" : 2}' --label "composable_cvm_outpost" --admin centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k --gas=auto --from=dz -y
 
$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=auto -y

```

```sh
nix develop "composable#osmosis-mainnet" --impure
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=auto --gas-adjustment 1.5 --fees=117500uosmo -y

$BINARY tx wasm instantiate 320 '{"admin": "osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh", "network_id" : 3}' --label "composable_cvm_outpost" --admin osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh --gas=auto --gas-adjustment 1.5 --from=dz --fees=1000uosmo

$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=auto --gas-adjustment 1.5 --fees=75000uosmo -y
```

```sh
nix develop "composable#neutron-mainnet" --impure
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=auto --gas-adjustment=1.5 --fees=4362418untrn -y

$BINARY tx wasm instantiate 580 '{"admin": "neutron1u2sr0p2j75fuezu92nfxg5wm46gu22ywfacpyz", "network_id" : 4}' --label "composable_cvm_outpost" --admin neutron1u2sr0p2j75fuezu92nfxg5wm46gu22ywfacpyz --gas=auto --gas-adjustment=1.3 --from=dz --fees=158143untrn -y

$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=auto --gas-adjustment=1.5 --fees=3111155untrn -y
```


## Configure

```sh
centaurid tx wasm execute $(cat cvm.json  | jq '.config.force[] | select ( .force_network.network_id == 2) | .force_network.outpost.cosm_wasm.contract' -r) "$(cat cvm.json)" --from=dz -y --gas=auto --gas-adjustment 1.5 -y
neutrond tx wasm execute $(cat cvm.json  | jq '.config.force[] | select ( .force_network.network_id == 4) | .force_network.outpost.cosm_wasm.contract' -r) "$(cat cvm.json)" --from=dz -y --gas=auto --gas-adjustment 1.5 -y --fees=451536untrn
osmosisd tx wasm execute $(cat cvm.json  | jq '.config.force[] | select ( .force_network.network_id == 3) | .force_network.outpost.cosm_wasm.contract' -r) "$(cat cvm.json)" --from=dz -y --gas=auto --gas-adjustment 1.5 -y
```






