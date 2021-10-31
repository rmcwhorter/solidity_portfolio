import { deploy } from "./deploy";
const hre = require("hardhat")
import { Keccak } from 'sha3';

async function main() {
    // compile the contract
    console.log("\nCompiling the contract")
    await hre.run('compile')

    // deploy the contract
    console.log("\nDeploying the contract")
    const ens_contract = await deploy()

    // profile data
    console.log("\nCreating my profile on the hardhat test chain")
    const my_password = "this is my password"
    const my_salt = rand_string(20)
    const my_hash = gen_psk_hash(my_password, my_salt)

    const my_json_profile = '{"first_name": "Ryan",' +
        '"last_name": "McWhorter",' + 
        '"email": "ryan.mcwhorter@utexas.edu",' + 
        '"pfp_url": "asdf.com/my_profile_pic.jpg"}'

    // create my profile on my version of ENS
    const creation_rst = await ens_contract.create_profile("ryan_mcwhorter.royal", my_salt, my_hash, my_json_profile)

    // can we get my profile data off the blockchain?
    console.log("\nCan we get my profile data off the blockchain?")
    const pull_rst_1 = await ens_contract.get_profile("ryan_mcwhorter.royal")
    console.log("Profile data: ", pull_rst_1.json_data) // great, we can!

    // validate my password through solidity (crypto version of server side)
    console.log("\nCan we validate a password on the contract's side?")
    const sol_result = await ens_contract.verify_password("ryan_mcwhorter.royal", "this is my password");
    console.log("Here's what the contract returned: ", sol_result) // on chain validation works!

    console.log("\nCan we validate the password client side?")
    // let's do off chain validation, because you shouldn't be putting your password on the blockchain 
    // first, we grab our profile 
    const pull_rst_2 = await ens_contract.get_profile("ryan_mcwhorter.royal")
    const local_salt = pull_rst_2.salt 
    const local_hash = pull_rst_2.psk_hash 

    const my_input_password = "this is my password" // same as before
    const my_claimed_hash = gen_psk_hash(my_input_password, local_salt)

    console.log("Here's the hash on the blockchain: \n\t", local_hash.toString())
    console.log("Here's the hash we computed from the password the user gave us: \n\t", my_claimed_hash.toString())
    console.log("Are they the same? ", local_hash.eq(my_claimed_hash))
    if (local_hash.eq(my_claimed_hash)) {
        console.log("Great, they are - this is enough to log the user in")
    }

    console.log("\nLet's update our on-chain password.")
    const new_psk = "This is my new password"
    const new_salt = rand_string(30)
    const new_hash = gen_psk_hash(new_psk, new_salt)

    console.log("Here's the new data:")
    console.log("\tNew Password:", new_psk)
    console.log("\tNew Salt:", new_salt)
    console.log("\tNew Hash:", new_hash.toString())

    const [main_owner, attacker] = await hre.ethers.getSigners();
    const attacker_update_result = await ens_contract.connect(attacker).update_password("ryan_mcwhorter.royal", new_salt, new_hash)
    const pull = await ens_contract.get_profile("ryan_mcwhorter.royal")

    console.log("Is the on chain password correct now? ", (pull.salt === new_salt) && (pull.psk_hash.eq(new_hash)))
    console.log("Why? We connected as an attacker - someone who doesn't own that ENS profile.")
    console.log("If we do everything again as the owner, here's what we get:")
    const owner_update_result = await ens_contract.update_password("ryan_mcwhorter.royal", new_salt, new_hash)
    const pull2 = await ens_contract.get_profile("ryan_mcwhorter.royal")
    console.log("Is the on chain password correct now? ", (pull2.salt === new_salt) && (pull2.psk_hash.eq(new_hash)))

    
    

}

function gen_psk_hash(password: string, salt: string) {
    const hasher = new Keccak(256)
    hasher.update(password + salt)
    const my_hash = hasher.digest('hex')
    return hre.ethers.BigNumber.from("0x"+my_hash)
}

// taken from stackoverflow
function rand_string(size: number): string {
    const charset: string =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  
    return [...Array(size)]
        .map((_) => charset[Math.floor(Math.random() * charset.length)])
        .join("")
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });