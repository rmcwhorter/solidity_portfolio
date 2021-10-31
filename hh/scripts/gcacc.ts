const hre = require("hardhat")

async function main() {
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	console.log("Compiling contracts")
	await hre.run('compile')

	console.log("\nRetrieving contracts \"Member\", \"GC\", and \"Accumulator\"")
	const Member = await hre.ethers.getContractFactory("Member")
	const GC = await hre.ethers.getContractFactory("GC")
	const ACC = await hre.ethers.getContractFactory("Accumulator")

	console.log("\nDeploying Alice, Bob, Charlie, and David")
	const alice = await Member.deploy()
	const bob = await Member.deploy()
	const charlie = await Member.deploy()
	const david = await Member.deploy()

	await alice.deployed()
	await bob.deployed()
	await charlie.deployed()
	await david.deployed()


	console.log("\nAlice deployed to:", alice.address)
	console.log("Bob deployed to:", bob.address)
	console.log("Charlie deployed to:", charlie.address)
	console.log("David deployed to:", david.address)

	const gc_1 = await GC.deploy([alice.address, bob.address, charlie.address])
	const gc_2 = await GC.deploy([bob.address, charlie.address, david.address])

	await gc_1.deployed()
	await gc_2.deployed()

	console.log("\nGroup Chat 1 deployed to:", gc_1.address)
	console.log("Group Chat 2 deployed to:", gc_2.address)

	const acc = await ACC.deploy()

    await acc.deployed() 
	console.log("\nAccumulator deployed to:", acc.address)

    console.log("\nBeginning conversations...")

    await alice.send("gm", gc_1.address)
    await bob.send("gm", gc_1.address)
    await charlie.send("gm", gc_1.address)
    await david.send("gm", gc_1.address) // this should fail, David isn't a member of GC1

    await alice.send("hi bob", bob.address)




}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})