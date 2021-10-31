// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat")
const Web3 = require("web3")


function sign_message(message: string, private_key: string): [string, string, string, string] {
    var web3 = new Web3(Web3.givenProvider || 'ws://some.local-or-remote.node:8546');
    const signiture = web3.eth.accounts.sign(message, private_key);

    const v = signiture.v
	const r = signiture.r
	const s = signiture.s
	const message_hash = signiture.messageHash

    return [message_hash, r, s, v]

}

async function main() {
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	console.log("Compiling contracts")
	await hre.run('compile')

	console.log("\nRetrieving contracts and deploying libraries")
	const Deser = await hre.ethers.getContractFactory("Deserialize");
    const deser = await Deser.deploy()
    await deser.deployed()
	const Ser = await hre.ethers.getContractFactory("Serialize");
    const ser = await Ser.deploy()
    await ser.deployed()
	const Alice = await hre.ethers.getContractFactory("Test")
	/*const Alice = await hre.ethers.getContractFactory("Test", {
		libraries: {
			Deserialize: deser.address,
			Serialize: ser.address
		}
	})*/

	const test = await Alice.deploy()

	await test.deployed()


    const msg = "gm"
	const pk = "f0eb6d90282e923fd1975e178ead95220582c9b7fa175d9cd2c568e82c0d8e80"
	const [hash, r, s, v] = sign_message(msg, pk)

	await test.b32(hash)


	await test.test_ser();

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})
