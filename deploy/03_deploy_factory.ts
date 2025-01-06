import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

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
};
export default func;
func.id = "deploy_factory"; // id required to prevent reexecution
func.tags = ["Factory"];
