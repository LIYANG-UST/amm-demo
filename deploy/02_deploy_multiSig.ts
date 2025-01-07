import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { readAddressList, storeAddressList } from "../scripts/contractAddress";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const addressList = readAddressList();

  const multisig = await deploy("MultiSig", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log(`--[[${network}]]-- MultiSig is deployed to: ${multisig.address}`);

  addressList[network.name].MultiSig = multisig.address;
  storeAddressList(addressList);
};
export default func;
func.id = "deploy_multiSig"; // id required to prevent reexecution
func.tags = ["MultiSig"];
