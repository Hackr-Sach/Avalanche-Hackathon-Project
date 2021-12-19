import { 
  Contract, 
  ContractFactory 
} from "ethers"
import { ethers } from "hardhat"

const main = async(): Promise<any> => {
  const CPR: ContractFactory = await ethers.getContractFactory("CPRinstance")
  const cpr: Contract = await CPR.deploy([
    "0x814dDd96FA03f46352c4A2C5787b4836408477fC",
    "0x72D1CbA159e87c017C9e9f672efBab3C2DfBfadA", 
    "0xFb65A9e3B18abcF21F926e1C213887369EbF75Fd",
    "0x816fe97D604744c793656893e9ade34e92B8f13c"
   ])

  await cpr.deployed()
  console.log(`cpr deployed to: ${cpr.address}`)
}
 
main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error)
  process.exit(1)
})
