const hre = require("hardhat")
const Web3 = require("web3")
import { pack_sign_message } from "./ecdsa";

function sign_message(message: string, private_key: string) {
    var web3 = new Web3(Web3.givenProvider || 'ws://some.local-or-remote.node:8546');
    const signiture = web3.eth.accounts.sign(message, private_key);

    const v = signiture.v
	const r = signiture.r
	const s = signiture.s
	const message_hash = signiture.messageHash

    return {"hash": message_hash, "r": r, "s": s, "v": v}
}

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

async function main() {
    console.log("\nCompiling contracts")
    await hre.run('compile')

    console.log("\nRetrieving contracts.")
    const IML = await hre.ethers.getContractFactory("IterableSet");
    const iml = await IML.deploy()
    await iml.deployed()
	const Timeline = await hre.ethers.getContractFactory("Timeline", {
        libraries: {
            IterableSet: iml.address
        }
    })
    const GroupChat = await hre.ethers.getContractFactory("GroupChat", {
        libraries: {
            IterableSet: iml.address
        }
    })

    console.log("\nLoading wallets")
    const [owner, alice, bob, charlie, david] = await hre.ethers.getSigners();

    const [owner_pk, alice_pk, bob_pk, charlie_pk, david_pk] = [
        "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
        "59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
        "5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a",
        "7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
        "47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a"
    ]

    console.log("\tOwner:", owner.address)
    console.log("\tAlice:", alice.address)
    console.log("\tBob:", bob.address)
    console.log("\tCharlie:", charlie.address)
    console.log("\tDavid:", david.address)

    console.log("\nGenerating Timelines")
    const alice_tl = await Timeline.connect(alice).deploy()
    const bob_tl = await Timeline.connect(bob).deploy()
    const charlie_tl = await Timeline.connect(charlie).deploy()
    const david_tl = await Timeline.connect(david).deploy()

    await alice_tl.deployed()
    await bob_tl.deployed()
    await charlie_tl.deployed()
    await david_tl.deployed()

    console.log("Timelines Deployed")
    console.log("\tAlice TL:", alice_tl.address)
    console.log("\tBob TL:", bob_tl.address)
    console.log("\tCharlie TL:", charlie_tl.address)
    console.log("\tDavid TL:", david_tl.address)

    console.log("\nBuilding Alice's Group Chat")
    const gc = await GroupChat.connect(alice).deploy(alice_tl.address)
    await gc.deployed()

    await gc.status()

    await gc.connect(alice).add_member(bob_tl.address) // added bob's timeline
    await gc.connect(alice).add_member(charlie_tl.address)

    await gc.status()

    console.log("\nLet's have a conversation now.")

    var msg = sign_message("gm", alice_pk)
    await alice_tl.connect(alice).send_helper(alice.address, "gm", msg.hash, msg.r, msg.s, msg.v, gc.address)
    
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})