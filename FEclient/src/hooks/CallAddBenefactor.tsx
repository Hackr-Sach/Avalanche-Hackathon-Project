import  {useMoralis} from "react-moralis";
import CPRinstance from "../abi/CPRinstance.json";
import { useState } from "react";

export const useAddBenefactor = (contractAddress: string, _benefactor: string) => {
  const {Moralis} = useMoralis()
  const[benefactorKeyState, setBenefactorKeyState] = useState<any>({status: "create an address"})
  const {abi} = CPRinstance;
  console.log(_benefactor)
  const handleAddBenefactor = async () => {
    setBenefactorKeyState({status: "creating new keys"});
    console.log(_benefactor)
    console.log(contractAddress)
    const opts = {
      chain: "43113",
      contractAddress: contractAddress,
      functionName: "addBenefactor",
      params: {benefactor: _benefactor},
      abi: abi,
      msgValue: "2"  
    }

    const addBenefactor = await (Moralis as any).executeFunction(opts)
    .then( (res: { data: any; }) => {
      console.log(res)
    }).catch((error: any) => {
      console.log("error ->  ", error)
    });

    if(addBenefactor != null || undefined)
      setBenefactorKeyState({status: "done"});
  } 
return {handleAddBenefactor, benefactorKeyState} 
}