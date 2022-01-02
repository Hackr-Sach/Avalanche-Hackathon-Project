import {Button, Container} from 'react-bootstrap';
import { useDispatch } from 'react-redux';
import { keysAdded } from './keysSlice';
import { useMoralis } from 'react-moralis';
import { Avalanche, BinTools} from "avalanche";
import Web3 from 'web3';
import { useAddBenefactor } from "../../hooks";
import { useEffect, useState } from 'react';

export const BenefactorKeyGen = () => {
    const dispatch = useDispatch();
    const {enableWeb3, isAuthenticated} = useMoralis();
    useEffect( () =>{if(isAuthenticated){ enableWeb3()}}, [isAuthenticated])
    const contractAddress = (process.env.REACT_APP_DEPLOYED_CONTRACT as string);

    const[address, setAddress] = useState<any>("");
    const[pubKey, setPubKey] = useState<any>("");

    const binTools = BinTools.getInstance();
    const _netWorkID = 43112;
    const avalanche = new Avalanche("localhost", 9650, "http", _netWorkID);
    const cchain = avalanche.CChain()
    const c_KeyChain = cchain.keyChain()
 
//2do
// need to save the appropiate addresses in an array to be accessed in deploy.
    const makeKey = () => {
        let tmpKeys:any = c_KeyChain.makeKey();
        let tmp = tmpKeys.getPublicKeyString();
        setPubKey(tmp);
        tmp = Web3.utils.keccak256(tmpKeys.getPublicKey());
        tmp = "0x" + tmp.slice(tmp.length - 40, tmp.length);
        setAddress(tmp);
    }

    //
    const importKey = () => {
        let _pk = binTools.stringToBuffer("0x9f376d3e972c18b4479497eb7d3d501f661126817c104ec1d6b03bb76c5fffb4"); 
        let tmpKeys:any  = c_KeyChain.importKey(_pk);
        let pubk = tmpKeys.getPublicKeyString();
        setPubKey(pubk)
        let addr = Web3.utils.keccak256(tmpKeys.getPrivateKey());
        addr = "0x" + pubk.slice(pubk.length - 40, pubk.length);
        setAddress(addr);
    }
    const saveKeys = () => {
        if(address && pubKey){
            dispatch(keysAdded(address, pubKey));
            setPubKey("");
            setAddress("");
        }
    }
    
    const {handleAddBenefactor, benefactorKeyState} = useAddBenefactor(
        contractAddress,
        address, 
        );

    const check = () => {
        console.log("address" + address)
        console.log("pubk" + pubKey)
    }
   
    return(
        <div>
            <h2>KEYGEN</h2>
            <p>"Create key"</p>
            <Button onClick={makeKey}>Make Key</Button>
            <p>"Import private key"</p>
            <Button onClick={importKey}>Import Key</Button>
            <Button onClick={handleAddBenefactor}>Add Benefactor</Button>
            <Button onClick={saveKeys}>save state</Button>
            
        </div>
        
    )
}


//deploy args
// let testPerson = ["0x72D1CbA159e87c017C9e9f672efBab3C2DfBfadA"]; 
// const deployCPR  = () => {
//     const web3 = new Web3(Web3.givenProvider || 'http://localhost:9650');
//     const Contract = new web3.eth.Contract((CPRinstance.abi as any));
//     let res = Contract.deploy({
//         data: CPRinstance.bytecode,
//         arguments:[testPerson],
//     }).send({
//         from: key2add ? key2add : '0x814dDd96FA03f46352c4A2C5787b4836408477fC', // ill need a dynamic arr to old multiple initial benefactors
//         gas: 6596670,
//         gasPrice: '25000000000'
//     },(error, transactionHash) => {})
//     .on('error', (error) => {console.log(error)})
//     .on('transactionHash', (transactionHash) => {console.log(transactionHash)})
//     .on('receipt', (receipt) => {
//         console.log(receipt.contractAddress) // contains the new contract address
//     })
//     .on('confirmation', (confirmationNumber, receipt) => { console.log(
//         "number: " + confirmationNumber + " receipt: " + receipt
//     ) })
//     .then(newContractInstance =>{
//         console.log(newContractInstance.options.address) // instance with the new contract address
//     });

//     console.log(res)
// }