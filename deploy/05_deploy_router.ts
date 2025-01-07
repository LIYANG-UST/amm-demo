import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { readAddressList } from "../scripts/contractAddress";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const addressList = readAddressList();
  const factoryAddress = addressList[network.name].Factory;
  const wethAddress = addressList[network.name].WETH;

  const router = await deploy("Router", {
    from: deployer,
    args: [],
    log: true,
    proxy: {
      proxyContract: "TransparentUpgradeableProxy",
      viaAdminContract: "ProxyAdmin",
      execute: {
        init: {
          methodName: "initialize",
          args: [factoryAddress, wethAddress],
        },
      },
    },
  });

  console.log(`--[[${network}]]-- Router is deployed to: ${router.address}`);
};
export default func;
func.id = "deploy_router"; // id required to prevent reexecution
func.tags = ["Router"];
