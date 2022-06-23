const { ethers } = require("hardhat");

// scripts/deploy.js
async function main() {
    // We get the contract to deploy
    const token = await ethers.getContractFactory('AEXToken');
    console.log('Deploying token...');
    const Token = await token.deploy(ethers.utils.parseUnits("10000", "ether"));
    await Token.deployed();
    console.log('Token deployed to: ', Token.address);

    const swap = await ethers.getContractFactory('Swap');
    console.log('Deploying Swap...');
    const Swap = await swap.deploy(Token.address);
    await Swap.deployed();
    console.log('Swap deployed to: ', Swap.address);

    const bid = await ethers.getContractFactory('Bid');
    console.log('Deploying Bid...');
    const Bid = await bid.deploy(100, Swap.address);
    await Bid.deployed();
    console.log('Bid deployed to:', Bid.address);
}



main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    }); 