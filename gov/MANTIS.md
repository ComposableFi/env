## Deploy your own contracts

```sh
$BINARY tx wasm store $ORDER_WASM_FILE --from dz --gas=auto -y

$BINARY tx wasm instantiate 30 '{"admin": "centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k", "cvm_address" : "centauri1wpf2szs4uazej8pe7g8vlck34u24cvxx7ys0esfq6tuw8yxygzuqpjsn0d"}' --label "mantis_order_7s" --admin centauri1u2sr0p2j75fuezu92nfxg5wm46gu22ywfgul6k --gas=auto --from=dz -y
```
