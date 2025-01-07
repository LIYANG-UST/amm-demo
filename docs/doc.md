# AMM-DEMO Documents

This is a demo of "Constant Product AMM (xy=k)" protocol.
Users can swap between ETH and other ERC20 tokens.
Liquidity providers can provide liquidity to the pools to earn trading fees.

## Characteristics

- Upgradeable

- Role-based access control

- Pasuable pairs

- Dynamic swap fees


## File Structure

- Access Control
  - MultiSig: A multi-signature wallet act as the controller of this protol.
  - RoleAccess: A role-based access control contract to enable different roles control different functions.
  - RoleAccessUpgradeable: The upgradeable version of the previous role-based access contract.
- Mock
  - MockERC20: Mock ERC20 tokens used for tests.
  - WETH: A mock WETH contract for tests and local deployment.
  
- Proxy
  - ProxyAdmin: Admin contract for managing upgrades.
  - Proxy: A EIP-1967 proxy contract.
  
- Empty: An empty contract which can receive ethers.
- Factory: Factory contract to deploy new pairs and change some parameters.
- Pair: Trading pairs with two ERC20 tokens inside.
- Router: The router contract to help users swap between tokens and manage slippage.


## Functions & Parameters