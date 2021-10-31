// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat")

export async function deploy() {
	const ENSContract = await hre.ethers.getContractFactory("ENS")

	const ens_contract = await ENSContract.deploy()
	await ens_contract.deployed()
	console.log("ENS Server deployed to:", ens_contract.address)
	return ens_contract
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

