import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const weth = await deploy("WETH", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(`--[[${network}]]-- WETH is deployed to: ${weth.address}`);
};
export default func;
func.id = "deploy_weth"; // id required to prevent reexecution
func.tags = ["WETH"];
