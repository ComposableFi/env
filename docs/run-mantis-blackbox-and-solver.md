
In order to be MANTRIS **Solver** one must to call MANTIS **Order** Contract.

Here is provided insruction how to run example solver which calls **Order** contract.

Example **Solver** consits of 2 services.

First service is MANTIS **Blackbox**. 

**Blackbox** finds good cross chain routes using CVM GLT and external Oracle data.

It can be run using [this script](https://github.com/ComposableFi/env/blob/4cde0bb29ef99af73e84d0208ade192b48797788/flake.nix#L72) . Blackbox written in Python and can be configured via [enviroment variables](https://github.com/ComposableFi/composable-vm/blob/main/mantis/blackbox/settings.py). These are HTTP APIS, RPC endpoints and contracts addresses.
Blackbox does not issues transactions onchain, yet it depends on calling 3rd party services which may have a cost.

To run **Solver** service use [next script](https://github.com/ComposableFi/env/blob/4cde0bb29ef99af73e84d0208ade192b48797788/flake.nix#L54). 
You must configure it via command line or enviroment variables with your own private key with PICA to pay gas to **Order** contract.
`router` variable must point to HTTP host of **Blackbox**.

After you run these two, you effectively is **Solver**.

All scripts were tested on Linux and it is recommended system for being solver. 
