import { ethers } from "hardhat";

import { Empty, Empty__factory, MultiSig, MultiSig__factory } from "../../types";

export async function deployMultiSigFixture() {
  const [dev, user1] = await ethers.getSigners();

  const MultiSig = (await ethers.getContractFactory("MultiSig")) as MultiSig__factory;
  const multiSig = (await MultiSig.deploy([dev.address, user1.address], 2)) as MultiSig;

  const Empty = (await ethers.getContractFactory("Empty")) as Empty__factory;
  const empty = (await Empty.deploy()) as Empty;

  return { multiSig, empty };
}
