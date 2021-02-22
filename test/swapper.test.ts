import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer, BigNumber, constants, ContractFactory } from "ethers";
describe("SLD", function () {
  let accounts : Signer[];

  let swapper : Contract;

  let owner : Signer;
  let sender : Signer;
  let recipient : Signer;
  let spender : Signer;
  let burner : Signer;
  let locked : Signer;
  let others : Signer[];

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    [owner, sender, recipient, spender, locked, ...others] = accounts;

    const SwapperFactory = await ethers.getContractFactory("Swapper");
    swapper = await SwapperFactory.deploy();
    await swapper.initialize();
  });

  describe("#view functions", () => {
    let amount = BigNumber.from("1000000000000000000");
    beforeEach(() => {
      console.log("using " + ethers.utils.formatUnits(amount, "ether") + " amount of eth");
    });
    describe('arbARtoW', () => {
      it('profits', async () => {
        let res = await swapper.arbARSushitoWSushi(amount);
        console.log("profit sushi -> sushi : " + ethers.utils.formatUnits(res.sub(amount),"ether"));
        res = await swapper.arbARSushitoWUni(amount);
        console.log("profit sushi -> uni : " + ethers.utils.formatUnits(res.sub(amount),"ether"));
        res = await swapper.arbARUnitoWSushi(amount);
        console.log("profit uni -> sushi : " + ethers.utils.formatUnits(res.sub(amount),"ether"));
        res = await swapper.arbARUnitoWUni(amount);
        console.log("profit suni -> uni : " + ethers.utils.formatUnits(res.sub(amount),"ether"));
      });

      it.skip('uni -> sushi', async function(){
        const before = await owner.getBalance();
        await swapper.wToARUniToSushi({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });

      it.skip('uni -> uni', async function(){
        const before = await owner.getBalance();
        await swapper.wToARUniToUni({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });

      it.skip('sushi -> sushi', async function(){
        const before = await owner.getBalance();
        await swapper.wToARSushiToSushi({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });

      it.skip('sushi -> uni', async function(){
        const before = await owner.getBalance();
        await swapper.wToARSushiToUni({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });

    });
    describe('arbWtoAR', () => {
      it('profits', async () => {
        let res = await swapper.arbWSushitoARSushi(amount);
        console.log("profit sushi -> sushi : " + ethers.utils.formatUnits(res.sub(amount), "ether"));
        res = await swapper.arbWSushitoARUni(amount);
        console.log("profit sushi -> uni : " + ethers.utils.formatUnits(res.sub(amount),"ether"));
        res = await swapper.arbWUnitoARSushi(amount);
        console.log("profit uni -> sushi : " + ethers.utils.formatUnits(res.sub(amount), "ether"));
        res = await swapper.arbWUnitoARUni(amount);
        console.log("profit uni -> uni : " + ethers.utils.formatUnits(res.sub(amount),"ether"));
      });

      it('sushi -> sushi', async function(){
        const before = await owner.getBalance();
        await swapper.arToWSushiToSushi({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });

      it('sushi -> uni', async function(){
        const before = await owner.getBalance();
        await swapper.arToWSushiToUni({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });

      it('uni -> sushi', async function(){
        const before = await owner.getBalance();
        await swapper.arToWUniToSushi({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });

      it('uni -> uni', async function(){
        const before = await owner.getBalance();
        await swapper.arToWUniToUni({value:amount});
        const after = await owner.getBalance();
        console.log("DIFF : " + ethers.utils.formatUnits(after.sub(before), "ether"));
      });
    });
  });
});
