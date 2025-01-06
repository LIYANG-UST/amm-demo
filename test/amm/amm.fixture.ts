import { ethers } from "hardhat";

import {
  Factory,
  Factory__factory,
  MockERC20,
  MockERC20__factory,
  Router,
  Router__factory,
  WETH,
  WETH__factory,
} from "../../types";

export async function deployAMMFixture() {
  const [dev] = await ethers.getSigners();

  const MockERC20A = (await ethers.getContractFactory("MockERC20")) as MockERC20__factory;
  const mockERC20A = (await MockERC20A.deploy("TokenA", "TokenA")) as MockERC20;

  const MockERC20B = (await ethers.getContractFactory("MockERC20")) as MockERC20__factory;
  const mockERC20B = (await MockERC20B.deploy("TokenB", "TokenB")) as MockERC20;

  const WETH_Factory = (await ethers.getContractFactory("WETH")) as WETH__factory;
  const wethC = (await WETH_Factory.deploy()) as WETH;

  const Factory = (await ethers.getContractFactory("Factory")) as Factory__factory;
  const factoryC = (await Factory.deploy()) as Factory;
  await factoryC.initialize(dev.address);

  const Router = (await ethers.getContractFactory("Router")) as Router__factory;
  const routerC = (await Router.deploy()) as Router;
  await routerC.initialize(await factoryC.getAddress(), await wethC.getAddress());

  return { mockERC20A, mockERC20B, wethC, factoryC, routerC };
}
