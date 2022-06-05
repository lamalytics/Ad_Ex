// scripts/deploy.js
async function main() {
    // We get the contract to deploy
    const Bid = await ethers.getContractFactory('Bid');
    console.log('Deploying Bid...');
    const bid = await Bid.deploy(1);
    await bid.deployed();
    console.log('Bid deployed to:', bid.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });