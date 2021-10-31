// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat")

async function main() {
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	console.log("Compiling contracts")
	await hre.run('compile')

	console.log("\nRetrieving contracts \"Chatter\" and \"GroupChat\"")
	const Chatter = await hre.ethers.getContractFactory("Chatter")
	const GC = await hre.ethers.getContractFactory("GroupChat")

	console.log("\nDeploying Alice, Bob, Charlie, and David")
	const alice = await Chatter.deploy()
	const bob = await Chatter.deploy()
	const charlie = await Chatter.deploy()
	const david = await Chatter.deploy()

	await alice.deployed()
	await bob.deployed()
	await charlie.deployed()
	await david.deployed()


	console.log("Alice deployed to:", alice.address)
	console.log("Bob deployed to:", bob.address)
	console.log("Charlie deployed to:", charlie.address)
	console.log("David deployed to:", david.address)

	const gc = await GC.deploy([alice.address, bob.address, charlie.address])

	await gc.deployed()

	console.log("\nGroup Chat deployed to:", gc.address)

	await alice.send("gm", gc.address);
	await david.send("hey fuckers", gc.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})
