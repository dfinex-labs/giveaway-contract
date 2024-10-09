import { ethers } from 'hardhat'

async function main() {

  const [deployer] = await ethers.getSigners()

  console.log('Deploying contracts with the account: ', deployer.address)

  console.log('Account balance: ', (await deployer.provider.getBalance(deployer.address)).toString())

  const giveawayFactory = await ethers.getContractFactory('DFinexGiveaway')
  const giveaway = await giveawayFactory.deploy()

  console.log('giveaway AIRDROP deployed to:', (await giveaway.getAddress()))
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})