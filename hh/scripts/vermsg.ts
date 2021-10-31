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

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms))
}

async function main() {
    console.log("Resolving Addresses")
    const [owner, addr1, addr2] = await hre.ethers.getSigners();

    console.log("Owner: ", owner)
    console.log("Addr1: ", addr1)
    console.log("Addr2: ", addr2)

	console.log("Compiling contracts")
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
	//const Account = await hre.ethers.getContractFactory("Account")
	//const Nothing = await hre.ethers.getContractFactory("Nothing")

    const alice = await Timeline.deploy()
    const bob = await Timeline.deploy()
    const charlie = await Timeline.deploy()
    const david = await Timeline.deploy()
    
    await alice.deployed()
    await bob.deployed()
    await charlie.deployed()
    await david.deployed()

    // we create a new GC as alice.
    const groupchat = await GroupChat.deploy()
    
    await groupchat.deployed()

    console.log("Timeline deployed")
    console.log("Account deployed")

    // courtesy of keys.lol/ethereum/
    const dummy_keys = [
        ["f0eb6d90282e923fd1975e178ead95220582c9b7fa175d9cd2c568e82c0d8e80", "c4A706c498841E7Af439777f8E38FdfC782Dcceb"],
        ["93d1f260f336bce65e6bcfe5cf5d14e4df13cbe83f254184f7aea65602968880", "7ddF5db0133f8fC990c18e9cb8E0eC111059Dbe8"],
        ["bb9554814ef67b08ed2a98140a24f7d641ae65b85c7d6311764a8c268a3cd500", "E68a0d162b34834E7a8ecD849Feadb0a3da0ceF4"],
        ["38f0c205a7e5cd80e894f3797f3a601c8476bdd968232c224706748deaea8100", "0Deb2Df680389885641FAd52A469c9Cfb1772397"]
    ]

    const gc_address = groupchat.address 

    await groupchat.add_member(alice.address)
    await groupchat.add_member(bob.address)
    await groupchat.add_member(charlie.address)
    await groupchat.add_member(david.address)

    await alice.status()
    await bob.status()
    await charlie.status()
    await david.status()
    await groupchat.status()

    const alice_pub = dummy_keys[0][1]
    const alice_priv = dummy_keys[0][0]

    const bob_pub = dummy_keys[1][1]
    const bob_priv = dummy_keys[1][0]

    const charlie_pub = dummy_keys[2][1]
    const charlie_priv = dummy_keys[2][0]

    const david_pub = dummy_keys[3][1]
    const david_priv = dummy_keys[3][0]

    console.log("\nAlice Pub: ", alice_pub)
    console.log("Alice Priv: ", alice_priv)
    console.log("Bob Pub: ", bob_pub)
    console.log("Bob Priv: ", bob_priv)
    console.log("Charlie Pub: ", charlie_pub)
    console.log("Charlie Priv: ", charlie_priv)
    console.log("David Pub: ", david_pub)
    console.log("David Priv: ", david_priv, "\n")

    console.log("\nAlice TL: ", alice.address)
    console.log("Bob TL: ", bob.address)
    console.log("Charlie TL: ", charlie.address)
    console.log("David TL: ", david.address, "\n")

    console.log("\nGC Address: ", groupchat.address, "\n")

    const msg = "gm"

    const [hash, r, s, v] = sign_message(msg, dummy_keys[0][0])
    await alice.send_helper(
        dummy_keys[0][1],
        msg,
        hash,
        r,
        s,
        v,
        groupchat.address
    )

    await sleep(1000)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().then(() => process.exit(0))
.catch((error) => {
	console.error(error)
	process.exit(1)
})