# solidity_portfolio

## Installation instructions: 

Each directory contains a project I've worked on or am working on. To build any project, cd into it and run npm install. Everything can be compiled with npx hardhat compile, but the demo scripts will automatically compile everything for you when you run them.

## Point Messaing Protocol (./hh)

This is service that allows you to create Timeline contracts (representing a Twitter instance), and Groupchat contracts (self explanitory). Messages (defined in PMPS.sol) are signed by ECDSA. I wrote a TypeScript helper function to actually sign messages, and there's a bunch of stuff to verify messages whenever they're sent on-chain. Beyond just DMs, Timelines also implement PubSub, so you can blast messages to lots of people at once.

Run npx ts-node scripts/run_me.ts for a demo that shows how everything works.

## Sign In With ENS (./sign_in)

ENS is coming out with the feature soon; I figured I'd build an ENS clone and try to actually implement it myself. This allows you to sign in securely either on chain (not advised), or to query your ENS profile and sign in client side. Pretty basic but I think it'll be really cool when we actually get this for real on the ENS.

Run npx ts-node scripts/main.ts for a demo.

## CapTable (./captable)

I wrote this back when we were talking about modeling Cap Tables on chain. No demo scripts, this was mostly just me messing around with OpenZeppelin and seeing how that works. You can see my original voting system code (or the start of it, really), compared with how you would go about implementing ERC-20 with votes on OZ. It's much easier. No demos scripts this time, but you can compile it with npx hardhat compile

## Automated Market Maker (./amm1)

I started this two days ago. I'm still building it, obviously, but you can see how I would go about building an exchange from scratch if I had to. No demos scripts but everything should compile (which is npx hardhat compile).