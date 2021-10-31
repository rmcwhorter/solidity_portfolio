const hre = require("hardhat")
const Web3 = require("web3")




async function main() {
    console.log("=====SOF=====")
    console.log("Compiling contracts")
	await hre.run('compile')

	//console.log(Web3.modules)

	//var web3 = new Web3(Web3.givenProvider || 'ws://some.local-or-remote.node:8546');

    console.log("\nRetreiving Signers")
    const [owner, ryan, tim, employee1, employee2, employee3, geoff, peter, a16z, rando] = await hre.ethers.getSigners();

    console.log("Ryan: ", ryan.address)
    console.log("Tim: ", tim.address)
    console.log("E1: ", employee1.address)
    console.log("E2: ", employee2.address)
    console.log("E3: ", employee3.address)
    console.log("Geoff: ", geoff.address)
    console.log("Peter: ", peter.address)
    console.log("A16Z: ", a16z.address)

    const Company = await hre.ethers.getContractFactory("Company")
	const co = await Company.deploy()
	await co.deployed()

    console.log(await co.connect(ryan).general_shares_addr())


    console.log("=====EOF=====")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})
