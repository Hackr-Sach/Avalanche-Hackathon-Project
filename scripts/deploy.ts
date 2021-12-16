import { 
  Contract, 
  ContractFactory 
} from "ethers"
import { ethers } from "hardhat"

const main = async(): Promise<any> => {
  const CPR: ContractFactory = await ethers.getContractFactory("CPRinstance")
  const cpr: Contract = await CPR.deploy()

  await cpr.deployed()
  console.log(`cpr deployed to: ${cpr.address}`)
}
 
main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error)
  process.exit(1)
})
