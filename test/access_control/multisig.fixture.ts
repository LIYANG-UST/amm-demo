import { ethers } from "hardhat";

import { MultiSig, MultiSig__factory } from "../../types";

export async function deployMultiSigFixture() {
  const [owner, otherAccount] = await ethers.getSigners();

  const MultiSig = (await ethers.getContractFactory("MultiSig")) as MultiSig__factory;
  const multiSig = (await MultiSig.deploy([owner.address, otherAccount.address], 2)) as MultiSig;
  
  const multiSig_address = await multiSig.getAddress();

  return { multiSig, multiSig_address, owner, otherAccount };
}
