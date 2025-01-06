import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const mockERC20 = await deploy("MockERC20", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(`--[[${network}]]-- MockERC20 is deployed to: ${mockERC20.address}`);
};
export default func;
func.id = "deploy_mockERC20"; // id required to prevent reexecution
func.tags = ["MockERC20"];
