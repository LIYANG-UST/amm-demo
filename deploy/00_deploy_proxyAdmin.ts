import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const proxyAdmin = await deploy("ProxyAdmin", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(`--[[${network}]]-- ProxyAdmin is deployed to: ${proxyAdmin.address}`);
};
export default func;
func.id = "deploy_proxyAdmin"; // id required to prevent reexecution
func.tags = ["ProxyAdmin"];
