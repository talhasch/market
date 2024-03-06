
import { contractPrincipalCV, principalCV, uintCV } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

const whitelisToken = () => {
  return simnet.callPublicFn("market", "whitelist-ft", [
    contractPrincipalCV(simnet.deployer, "token1")
  ], simnet.deployer);
}

describe("tests", () => {

  const expectMatchSnapshot = (msg: string, a: any) => {
    expect(a).toMatchSnapshot(msg)
  }

  it("basic trade test", () => {
    whitelisToken();

    expectMatchSnapshot('1- balances before trade', simnet.getAssetsMap());

    expectMatchSnapshot('2- order created',
      simnet.callPublicFn("market", "create-order", [
        uintCV(125_000000),
        uintCV(10_000000),
        contractPrincipalCV(simnet.deployer, "token1")
      ], address1).result);

    expectMatchSnapshot('3- balances after order creation', simnet.getAssetsMap());

    expectMatchSnapshot('4- order filled',
      simnet.callPublicFn("market", "fill-order", [
        uintCV(0),
        contractPrincipalCV(simnet.deployer, "token1")
      ], address2).result)

    expectMatchSnapshot('5- balances after trade', simnet.getAssetsMap())
  });



  /*
  it("token not whitelisted", () => {
    const { result } = simnet.callPublicFn("market", "create-order", [
      uintCV(125_000000),
      uintCV(15_340000),
      contractPrincipalCV(simnet.deployer, "token1")
    ], address1);

    console.log(result)
    

    expect(simnet.blockHeight).toBeDefined();

  });*/

  // it("shows an example", () => {
  //   const { result } = simnet.callReadOnlyFn("counter", "get-counter", [], address1);
  //   expect(result).toBeUint(0);
  // });
});
