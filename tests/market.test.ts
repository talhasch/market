
import { contractPrincipalCV, principalCV, uintCV } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

describe("example tests", () => {

  it("1- admin whitelist token", () => {
    const result = simnet.callPublicFn("market", "whitelist-ft", [
      contractPrincipalCV(simnet.deployer, "token1")
    ], simnet.deployer);

    expect(result.events.length).toBeGreaterThan(0)

    const result2 = simnet.callPublicFn("market", "create-order", [
      uintCV(125_000000),
      uintCV(10_000000),
      contractPrincipalCV(simnet.deployer, "token1")
    ], address1);

    expect(result2.events.length).toBeGreaterThan(0);

    console.log(simnet.callReadOnlyFn("token1", "get-balance", [
      contractPrincipalCV(simnet.deployer, "market")
    ], address1).result)

    const result3 = simnet.callPublicFn("market", "fill-order", [
      uintCV(0),
      contractPrincipalCV(simnet.deployer, "token1")
    ], address2);
    
    console.log(result3.events)
    
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
