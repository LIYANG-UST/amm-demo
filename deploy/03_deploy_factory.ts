import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { readAddressList, storeAddressList } from "../scripts/contractAddress";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  const addressList = readAddressList();

  const factory = await deploy("Factory", {
    from: deployer,
    args: [],
    log: true,
    proxy: {
      proxyContract: "TransparentUpgradeableProxy",
      viaAdminContract: "ProxyAdmin",
      execute: {
        init: {
          methodName: "initialize",
          args: [deployer],
        },
      },
    },
  });

  console.log(`--[[${network}]]-- Factory is deployed to: ${factory.address}`);

  addressList[network.name].Factory = factory.address;
  storeAddressList(addressList);
};
export default func;
func.id = "deploy_factory"; // id required to prevent reexecution
func.tags = ["Factory"];
