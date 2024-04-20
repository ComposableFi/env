In order to be a **MANTRIS Solver**, one must call the **MANTIS Order** Contract.

Here are the provided instructions on how to run an example solver that calls the **Order** contract.

The example **Solver** consists of two services:

1. First service is the **MANTIS Blackbox**.
   - **Blackbox** finds optimal cross-chain routes using CVM GLT and external Oracle data.
   - It can be run using [this script](https://github.com/ComposableFi/env/blob/4cde0bb29ef99af73e84d0208ade192b48797788/flake.nix#L72). **Blackbox** is written in Python and can be configured via [environment variables](https://github.com/ComposableFi/composable-vm/blob/main/mantis/blackbox/settings.py), including HTTP APIs, RPC endpoints, and contract addresses.
   - **Blackbox** does not issue transactions on-chain; however, it relies on calling third-party services, which may incur costs.

2. To run the **Solver** service, use the [following script](https://github.com/ComposableFi/env/blob/4cde0bb29ef99af73e84d0208ade192b48797788/flake.nix#L54).
   - You must configure it via command line or environment variables with your own private key and PICA to pay gas to the **Order** contract.
   - The `router` variable must point to the HTTP host of **Blackbox**.

After you run these two services, you are effectively a **Solver**.

All scripts have been tested on Linux, which is the recommended system for operating as a solver.

A deeper technical dive into the solver infrastructure is available [here](https://www.youtube.com/watch?v=nimg8qdSy70).
