import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { Empty, MultiSig } from "../../types";
import { deployMultiSigFixture } from "./multisig.fixture";

describe("MultiSig", function () {
  let multiSigContract: MultiSig;
  let emptyContract: Empty;
  let dev: SignerWithAddress, user1: SignerWithAddress, user2: SignerWithAddress;

  before(async function () {
    this.loadFixture = loadFixture;
  });

  beforeEach(async function () {
    [dev, user1, user2] = await ethers.getSigners();
    const { multiSig, empty } = await this.loadFixture(deployMultiSigFixture);
    multiSigContract = multiSig;
    emptyContract = empty;

    await dev.sendTransaction({ to: multiSigContract.getAddress(), value: ethers.parseEther("1") });
  });

  describe("Initial state after deployment", function () {
    it("should have the correct owners", async function () {
      const owners = await multiSigContract.getAllOwners();
      expect(owners.length).to.be.equal(2);
      expect(owners[0]).to.be.equal(dev.address);
      expect(owners[1]).to.be.equal(user1.address);
    });
    it("should have the correct threshold", async function () {
      const requiredConfirmations = await multiSigContract.requiredConfirmations();
      expect(requiredConfirmations).to.be.equal(2);
    });
  });

  describe("Submit transaction", function () {
    it("should be able to submit transaction", async function () {
      await expect(multiSigContract.connect(dev).submitTransaction(await emptyContract.getAddress(), 100, "0x"))
        .to.emit(multiSigContract, "TransactionSubmitted")
        .withArgs(dev.address, 0, await emptyContract.getAddress(), 100, "0x");

      const transaction = await multiSigContract.getTransaction(0);
      expect(transaction.to).to.be.equal(await emptyContract.getAddress());
      expect(transaction.value).to.be.equal(100);
      expect(transaction.data).to.be.equal("0x");
      expect(transaction.executed).to.be.false;
      expect(transaction.numConfirmations).to.be.equal(0);
    });

    it("should be able to submit transaction and confirm", async function () {
      await multiSigContract.connect(dev).submitTransaction(await emptyContract.getAddress(), 100, "0x");
      await expect(multiSigContract.connect(user1).confirmTransaction(0))
        .to.emit(multiSigContract, "TransactionConfirmed")
        .withArgs(user1.address, 0);

      const transaction = await multiSigContract.getTransaction(0);
      expect(transaction.numConfirmations).to.be.equal(1);
    });

    it("should be able to submit transaction and execute", async function () {
      await multiSigContract.connect(dev).submitTransaction(await emptyContract.getAddress(), 1, "0x");

      // Need two confirmations
      await multiSigContract.connect(dev).confirmTransaction(0);
      await multiSigContract.connect(user1).confirmTransaction(0);

      await expect(multiSigContract.connect(dev).executeTransaction(0))
        .to.emit(multiSigContract, "TransactionExecuted")
        .withArgs(dev.address, 0);

      const transaction = await multiSigContract.getTransaction(0);
      expect(transaction.numConfirmations).to.be.equal(2);
      expect(transaction.executed).to.be.true;
    });

    it("should be able to revoke transaction", async function () {
      await multiSigContract.connect(dev).submitTransaction(await emptyContract.getAddress(), 1, "0x");

      // Need two confirmations
      await multiSigContract.connect(dev).confirmTransaction(0);
      await multiSigContract.connect(user1).confirmTransaction(0);

      await multiSigContract.connect(dev).revokeConfirmation(0);

      const transaction = await multiSigContract.getTransaction(0);
      expect(transaction.numConfirmations).to.be.equal(1);
      expect(transaction.executed).to.be.false;
    });
  });

  //   describe("Add & Remove owner", function () {
  //     it("should add new owner", async function () {
  //       await multiSig.connect(dev).addOwner(user1.address);
  //       const owners = await multiSig.getAllOwners();
  //       expect(owners.length).to.be.equal(2);
  //       expect(owners[1]).to.be.equal(user1.address);
  //     });
  //     it("should remove owner", async function () {
  //       await multiSig.connect(dev).addOwner(user1.address);
  //       await multiSig.connect(dev).removeOwner(user1.address);
  //       const owners = await multiSig.getAllOwners();
  //       expect(owners.length).to.be.equal(1);
  //       expect(owners[0]).to.be.equal(dev.address);
  //     });
  //   });
});
