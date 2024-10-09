import { ethers } from 'hardhat'
import type { Signer } from 'ethers'
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'

import { Giveaway } from './../typechain-types/Giveaway'
import { Giveaway__factory } from './../typechain-types/factories/Giveaway__factory'

chai.use(chaiAsPromised)

const { expect } = chai

describe('Giveaway', () => {
  let giveawayFactory: Giveaway__factory
  let giveaway: Giveaway

  describe('Deployment', () => {

    beforeEach(async () => {

      giveawayFactory = new Giveaway__factory()

      giveaway = await giveawayFactory.deploy()

      await giveaway.deployed()
      
    })

    it('should have the correct address', async () => {
      expect(giveaway.address)
    })
  })
})