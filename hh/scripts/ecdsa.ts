const hre = require("hardhat")
const Web3 = require("web3")


export function pack_sign_message(originator: any, message: any, private_key: any, target: any) {
	var web3 = new Web3(Web3.givenProvider || 'ws://some.local-or-remote.node:8546')
	const sig = web3.eth.accounts.sign(message, private_key)

	return [originator, message, sig.messageHash, sig.r, sig.s, sig.v, target]
}

/*async function main() {
	console.log(Web3.modules)

	var web3 = new Web3(Web3.givenProvider || 'ws://some.local-or-remote.node:8546');

	const msg = "Hello World!"
	const pvt = "1cf9d087c33cbc490111f31e477aa6adf2e2be0ab92007bd67af06464a87f3b1"
	const pub = "c89d0DF923CbB29186e4d5c3F932513ff3049c23"

    const signiture = web3.eth.accounts.sign(msg, pvt);

	console.log("Message  : ", msg)
	console.log("Private  : ", pvt)
	console.log("Public   : ", pub)
	console.log("Signiture: ", signiture)

	const v = signiture.v
	const r = signiture.r
	const s = signiture.s
	const message_hash = signiture.messageHash

	console.log(typeof v)
	console.log(typeof r)
	console.log(typeof s)

	const rcvr = web3.eth.accounts.recover(msg, v,r,s)

	
	console.log("Compiling contracts")
	await hre.run('compile')
	const ECDSA = await hre.ethers.getContractFactory("VerifySignature")

	const ecdsa = await ECDSA.deploy()

	await ecdsa.deployed()

	await ecdsa.recover_vrs(message_hash, r, s, v)
	await ecdsa.test()

	

	console.log(rcvr)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})*/
