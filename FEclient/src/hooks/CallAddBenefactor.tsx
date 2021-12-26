import  {useMoralis} from "react-moralis";
import CPRinstance from "../abi/CPRinstance.json";
import { useState } from "react";

export const useAddBenefactor = (contractAddress: string, benefactor: string) => {
  const {Moralis} = useMoralis()
  const[benefactorKeyState, setBenefactorKeyState] = useState<any>({status: "create an address"})
  const {abi} = CPRinstance;

  const handleAddBenefactor = async () => {
    
    setBenefactorKeyState({status: "creating new keys"})
    
    const opts = {
      chain: "43112",
      contractAddress: contractAddress,
      functionName: "addBenefactor",
      params: {benefactor},
      abi: abi,
      msgValue: "1"  
    }

    const addBenefactor = await (Moralis as any).executeFunction(opts)
    .then( (res: { data: any; }) => {
      console.log(res)
    }).catch((error: any) => {
      console.log("error ->  ", error)
    });

    if(addBenefactor != null || undefined)
    setBenefactorKeyState({status: "done"})
  } 
return {handleAddBenefactor, benefactorKeyState} 
}