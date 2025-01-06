import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { AddressLike } from "ethers";
import { ethers } from "hardhat";

import { Factory, MockERC20, Pair, Router, WETH } from "../../types";
import { deployAMMFixture } from "./amm.fixture";

describe("AMM Test", function () {
  let pair: Pair;
  let factory: Factory;
  let router: Router;
  let weth: WETH;
  let tokenA: MockERC20, tokenB: MockERC20;
  let dev: SignerWithAddress, user1: SignerWithAddress, user2: SignerWithAddress;
  let tokenAAddress: string, tokenBAddress: string, wethAddress: string;

  before(async function () {
    this.loadFixture = loadFixture;
  });
  beforeEach(async function () {
    [dev, user1, user2] = await ethers.getSigners();
    const { mockERC20A, mockERC20B, wethC, factoryC, routerC } = await this.loadFixture(deployAMMFixture);
    tokenA = mockERC20A;
    tokenB = mockERC20B;
    factory = factoryC;
    weth = wethC;
    router = routerC;

    tokenAAddress = await tokenA.getAddress();
    tokenBAddress = await tokenB.getAddress();
    wethAddress = await weth.getAddress();
  });

  describe("Factory Test", function () {
    it("should be able to deploy a new pair", async function () {
      await expect(factory.createPair(tokenAAddress, tokenBAddress, 100)).to.emit(factory, "PairCreated");
      await expect(factory.createPair(wethAddress, tokenBAddress, 100)).to.emit(factory, "PairCreated");
      await expect(factory.createPair(tokenAAddress, tokenBAddress, 100)).to.be.revertedWith("Factory: pair exists");
    });

    it("should be able to set up the new pair", async function () {
      await factory.createPair(tokenAAddress, tokenBAddress, 100);
      pair = (await ethers.getContractAt("Pair", await factory.getPair(tokenAAddress, tokenBAddress))) as Pair;

      expect(await pair.getReserves()).to.be.deep.equal([0, 0]);
      expect(await pair.fee()).to.be.equal(100);
      expect(await pair.factory()).to.be.equal(await factory.getAddress());
    });

    it("should be able to change swap fee", async function () {
      await factory.createPair(tokenAAddress, tokenBAddress, 100);
      const pairAddress = await factory.getPair(tokenAAddress, tokenBAddress);

      const FEESETTER = await factory.PARAMETER_SETTER_ROLE();

      // Set user1 as fee setter role
      await factory.setRole(user1.address, FEESETTER);
      await expect(factory.connect(user1).setFee(pairAddress, 200)).to.emit(factory, "PairFeeChanged");
    });

    it("should be able to lock & unlock a pair", async function () {
      await factory.createPair(tokenAAddress, tokenBAddress, 100);
      const pairAddress = await factory.getPair(tokenAAddress, tokenBAddress);

      const PAUSER = await factory.PAUSER_ROLE();

      // Set user2 as locker role
      await factory.setRole(user2.address, PAUSER);
      await expect(factory.connect(user2).lockPair(pairAddress)).to.emit(factory, "PairLocked");
      await expect(factory.connect(user2).unlockPair(pairAddress)).to.emit(factory, "PairUnlocked");
    });
  });

  describe("Pair Test", function () {});
});
