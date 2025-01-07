/**
 * Remember to use this function in the root path of your hardhat project
 */
import * as fs from "fs";

///
/// Deployed Contract Address Info Record
///
export const readAddressList = function () {
  // const filePath = __dirname + "/address.json"
  return JSON.parse(fs.readFileSync("info/address.json", "utf-8"));
};

export const storeAddressList = function (addressList: object) {
  fs.writeFileSync("info/address.json", JSON.stringify(addressList, null, "\t"));
};

export const clearAddressList = function () {
  const emptyList = {};
  fs.writeFileSync("info/address.json", JSON.stringify(emptyList, null, "\t"));
};

export const getWETHAddress = function (networkName: string) {
  const wethAddress = {
    mainnet: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    fuji: "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
    localhost: "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
  };

  switch (networkName) {
    case "mainnet":
      return wethAddress.mainnet;
    case "fuji":
      return wethAddress.fuji;
    default:
      return wethAddress.localhost;
  }
};
