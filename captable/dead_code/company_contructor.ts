const hre = require("hardhat")
const Web3 = require("web3")

async function build(signer_deployer: any) {
    const Company = await hre.ethers.getContractFactory("Company")
}


async function main() {
    console.log("=====SOF=====")
    console.log("Compiling contracts")
	await hre.run('compile')

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
	const co = await Company.connect(ryan).deploy("Symplectic Technologies", "SYTX")
	await co.deployed()


    console.log("=====EOF=====")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})
