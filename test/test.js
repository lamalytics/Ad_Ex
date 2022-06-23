const { expect } = require("chai");
const { ethers, waffle } = require("hardhat"); // need a provider waffle to get balance in WEI


const provider = waffle.provider;

beforeEach(async function () {

    // Get the ContractFactory and Signers here.

    AEXToken = await ethers.getContractFactory("AEXToken");
    [aexOwner] = await ethers.getSigners();

    // To deploy our contract, we just have to call Token.deploy() and await
    // for it to be deployed(), which happens once its transaction has been
    // mined.
    AEX = await AEXToken.deploy(1000);
    // stores initial supply
    initialSupply = await AEX.totalSupply();

    // swap contract deployment
    swap = await ethers.getContractFactory("Swap");
    [swapOwner, addr1] = await ethers.getSigners();
    Swap = await swap.deploy(AEX.address);

    // mint and approval
    const tokenAmount = 1000000;
    // approve allowance for the swap contract to mint tokenAmount
    await AEX.mint(Swap.address, tokenAmount);
    await AEX.approve(Swap.address, tokenAmount);


    // bid contract deployment
    bid = await ethers.getContractFactory("Bid");
    [bidOwner, addr1] = await ethers.getSigners();
    Bid = await bid.deploy(1, Swap.address);

});



describe("AEXToken contract deployment", function () {
    it("Should set the owner as the contract deployer", async function () {
        expect(await AEX.owner()).to.equal(aexOwner.address);
    })

    // ensure total supply is the same as the contract token balance
    it("Should assign the total supply of tokens to the contract", async function () {
        const aexSupply = await AEX.balanceOf(AEX.address);
        const swapSupply = await AEX.balanceOf(Swap.address);
        const totalSupply = await AEX.totalSupply();
        expect(totalSupply.toString()).to.equal(aexSupply.add(swapSupply).toString());
    });
});


describe("Swap contract deployment", function () {
    it("Should have swap token address equal to AEX token address", async function () {
        expect(await Swap.getTokenAddress()).to.equal(AEX.address);
    });

    it("Should let this contract mint supply with approval", async function () {
        const totalSupply = await AEX.totalSupply();
        const swapBalance = await AEX.balanceOf(Swap.address);
        expect(totalSupply.toString()).to.equal(initialSupply.add(swapBalance).toString());
    });

    it("Should allow anyone to buy tokens", async function () {
        // get initial balance which is token amount
        const initialOwnerBalance = await AEX.balanceOf(Swap.address);

        // purchase tokens 10 wei == 1000 tokens
        await Swap.buyTokens({ from: swapOwner.address, value: 10 });
        const swapOwnerBalance = await AEX.balanceOf(swapOwner.address);
        expect(swapOwnerBalance.toString()).to.equal("1000");

        // connect to another account to buy tokens
        await Swap.connect(addr1).buyTokens({ from: addr1.address, value: 50 });

        // assert contract balance minus 1000+5000 tokens
        const swapContractBalance = await AEX.balanceOf(Swap.address);
        expect(swapContractBalance.toString()).to.equal(initialOwnerBalance.sub(6000).toString());

        // assert contract has 60 wei
        const swapContractWei = await provider.getBalance(Swap.address);
        expect(swapContractWei.toString()).to.equal("60");
    });

    it("should allow anyone to sell tokens with approval", async function () {
        // get initial balance which is token amount
        const initialOwnerBalance = await AEX.balanceOf(Swap.address);
        // set allowance with approve
        const tokenAmount = 5000;
        await AEX.connect(addr1).approve(Swap.address, tokenAmount);

        // buy and sell tokens
        await Swap.connect(addr1).buyTokens({ from: addr1.address, value: 50 });
        await Swap.connect(addr1).sellTokens(3000, { from: addr1.address });

        const swapContractFinal = await AEX.balanceOf(Swap.address);
        // -2000 because initially had 50*100 == 5000 tokens - 3000 tokens sold
        expect(swapContractFinal.toString()).to.equal(initialOwnerBalance.sub(2000).toString());
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
        const initialOwnerBalance = await AEX.balanceOf(Swap.address);

        // Try to send 1 token from addr1 (0 tokens) to owner (1000000 tokens).
        // `require` will evaluate false and revert the transaction.
        await expect(
            Swap.connect(addr1).sellTokens(1)
        ).to.be.revertedWith("you do not have enough tokens");

        // Owner balance shouldn't have changed.
        expect(await AEX.balanceOf(Swap.address)).to.equal(
            initialOwnerBalance
        );
    });

    it("Should fail if contract doesn’t have enough tokens", async function () {
        const initialOwnerBalance = await AEX.balanceOf(Swap.address);

        // Try to send 1 token from addr1 (0 tokens) to owner (1000000 tokens).
        // `require` will evaluate false and revert the transaction.
        await expect(
            Swap.connect(addr1).buyTokens({ from: addr1.address, value: 100000 })
        ).to.be.revertedWith("contract does not have enough tokens");

        // Owner balance shouldn't have changed.
        expect(await AEX.balanceOf(Swap.address)).to.equal(
            initialOwnerBalance
        );
    });
});

describe("Bid contract deployment", function () {

    it("Should have bid swap address equal to swap address", async function () {
        expect(await Bid.getSwap()).to.equal(Swap.address);
    });

    it("Should register addresses not owner", async function () {
        // buy tokens first
        const tokenAmount = 5000;
        await AEX.connect(addr1).approve(addr1.address, tokenAmount);
        await Swap.connect(addr1).buyTokens({ from: addr1.address, value: 50 });

        await Bid.connect(bidOwner).register(addr1.address);
        // test if registered
        // expect(Bid.connect(bidOwner).isRegistered[addr1.address]);
    });

    it("Should update bid if bid is greater than current bid", async function () {
        // buy tokens first
        const tokenAmount = 5000;
        await Swap.connect(addr1).buyTokens({ from: addr1.address, value: 50 });
        const initialBal = await AEX.balanceOf(addr1.address);

        await Bid.connect(bidOwner).register(addr1.address);
        // requires approval to place bid
        // addr1 must approve the transfer of its 1000 tokens
        await AEX.connect(addr1).approve(Bid.address, tokenAmount);
        await Bid.connect(addr1).placeBid(1000);

        // get new token balance after successful bid
        const newTokenBal = await AEX.balanceOf(addr1.address);
        expect(newTokenBal.toString()).to.equal(initialBal.sub(1000).toString());

        const newBid = await Bid.currentBid();

        expect(newBid.toString()).to.equal("1000");
    });
});