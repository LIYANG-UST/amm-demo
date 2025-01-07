import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { readAddressList, storeAddressList } from "../scripts/contractAddress";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const addressList = readAddressList();

  const mockERC20 = await deploy("MockERC20", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(`--[[${network}]]-- MockERC20 is deployed to: ${mockERC20.address}`);

  addressList[network.name].MockERC20 = mockERC20.address;
  storeAddressList(addressList);
};
export default func;
func.id = "deploy_mockERC20"; // id required to prevent reexecution
func.tags = ["MockERC20"];
