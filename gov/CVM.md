## How to deploy and configure mainnet

```sh
nix develop composable#centauri-mainnet" --impure
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=auto -y
$BINARY tx wasm instantiate 38 '{"admin": "centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k", "network_id" : 2}' --label "composable_cvm_outpost" --admin centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k --gas=auto --from=dz -y
 
$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=auto -y

```

```sh
nix develop "composable#osmosis-mainnet" --impure
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=auto --gas-adjustment 1.5 ----fees=117500uosmo -y

$BINARY tx wasm instantiate 320 '{"admin": "osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh", "network_id" : 3}' --label "composable_cvm_outpost" --admin osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh --gas=auto --gas-adjustment 1.5 --from=dz --fees=1000uosmo

$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=auto --gas-adjustment 1.5 --fees=75000uosmo -y

```

```sh
nix develop "composable#neutron-mainnet" --impure
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=auto --gas-adjustment=1.5 --fees=4362418untrn -y

$BINARY tx wasm instantiate 271 '{"admin": "neutron1u2sr0p2j75fuezu92nfxg5wm46gu22ywfacpyz", "network_id" : 4}' --label "composable_cvm_outpost" --admin neutron1u2sr0p2j75fuezu92nfxg5wm46gu22ywfacpyz --gas=400000 --from=dz --fees=1000uosmo

$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=25000000 --fees=75000uosmo -y

```


## Configure

$BINARY tx wasm execute centauri1xt9eujt2sv89srjkt5n2lxtys8skumrjh0z6ldu9sr9uslndqlxqtpnj0e "$(cat cvm.json)" --from=dz -y --gas=auto --gas-adjustment 1.5

$BINARY tx wasm execute osmo1sy7pdmawyerekcl6xwz4v2p87j726auntcu48fvhsy24rkhv7n4s9yg267 "$(cat cvm.json)" --from=dz -y --gas=auto --gas-adjustment 1.5