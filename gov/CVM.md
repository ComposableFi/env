## How to deploy and configure mainnet

```sh
nix develop composable#centauri-mainnet --impure
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=auto
$BINARY tx wasm instantiate 31 '{"admin": "centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k", "network_id" : 2}' --label "composable_cvm_outpost" --admin centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k --gas=auto --from=dz

$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=auto -y

$BINARY tx wasm execute ASD "$(cat cvm.json)" --from=dz -y --gas=500000
```

```sh
nix develop "composable#osmosis-mainnet --impure"
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=25000000 --fees=75000uosmo -y

$BINARY tx wasm instantiate 271 '{"admin": "osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh", "network_id" : 3}' --label "composable_cvm_outpost" --admin osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh --gas=400000 --from=dz --fees=1000uosmo

$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=25000000 --fees=75000uosmo -y

$BINARY tx wasm execute ASD "$(cat cvm.json)" --from=dz -y --gas=500000 --fees=1500uosmo
```

```sh
nix develop "composable#neutron-mainnet --impure"
```

```sh
$BINARY tx wasm store "$OUTPOST_WASM_FILE" --from dz --gas=25000000 --fees=75000uosmo -y

$BINARY tx wasm instantiate 271 '{"admin": "ASD", "network_id" : 3}' --label "composable_cvm_outpost" --admin ASD --gas=400000 --from=dz --fees=1000uosmo

$BINARY tx wasm store "$EXECUTOR_WASM_FILE" --from dz --gas=25000000 --fees=75000uosmo -y

$BINARY tx wasm execute ASD "$(cat cvm.json)" --from=dz -y --gas=500000 --fees=1500uosmo
```
