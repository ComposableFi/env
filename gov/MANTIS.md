## Deploy your own contracts

```sh
export BINARY=centaurid
$BINARY tx wasm store "$ORDER_WASM_FILE" --from=dz --gas=auto -y

$BINARY tx wasm instantiate 45 '{"admin": "centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k", "cvm_address" : "centauri19dw7w5cm48aeqwszva8kxmnfnft7wp4xt4s73ksyhdya704r3cdq389szq"}' --label="composable_mantis_order" --admin="centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k" --gas=auto --from=dz -y
```

```sh
export BINARY=osmosisd
$BINARY tx wasm store "$ORDER_WASM_FILE" --from=dz --gas=auto --gas-adjustment=1.5 --fees=75000uosmo -y

$BINARY tx wasm instantiate 322 '{"admin": "osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh", "cvm_address" : "osmo1sy7pdmawyerekcl6xwz4v2p87j726auntcu48fvhsy24rkhv7n4s9yg267"}' --label="composable_mantis_order" --admin=osmo1u2sr0p2j75fuezu92nfxg5wm46gu22yw9ezngh --gas=auto --gas-adjustment=1.5 --from=dz -y --fees=20000uosmo
```


