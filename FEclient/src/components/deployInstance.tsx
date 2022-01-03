import {Button, Container} from 'react-bootstrap';
import { useMoralis } from 'react-moralis';
import { useSelector } from 'react-redux'
import store from '../app/store';
import Web3 from 'web3';
import { useEffect, useState } from 'react';
import CPRinstance from "../abi/CPRinstance.json"

export const InitInstance = () => {
    const {enableWeb3, isAuthenticated} = useMoralis();
    useEffect( () =>{if(isAuthenticated){ enableWeb3()}}, [isAuthenticated])

    let keys = useSelector((state: string[] ) => state.keys);
    let appropriators = store.getState()

    const deployCPR  = () => {
        const web3 = new Web3(Web3.givenProvider || 'http://localhost:9650');
       console.log("app " + appropriators.keys[keys.length-1])
        const Contract = new web3.eth.Contract((CPRinstance.abi as any));
        let res = Contract.deploy({
            data: CPRinstance.bytecode,
            arguments:[appropriators.keys[keys.length-1]],
        }).send({
            from: web3.defaultAccount ? web3.defaultAccount : '0x814dDd96FA03f46352c4A2C5787b4836408477fC', // ill need a dynamic arr to old multiple initial benefactors
            gas: 6596670,
            gasPrice: '25000000000'
        },(error, transactionHash) => {})
        .on('error', (error) => {console.log(error)})
        .on('transactionHash', (transactionHash) => {console.log(transactionHash)})
        .on('receipt', (receipt) => {
            console.log(receipt.contractAddress) // contains the new contract address
        })
        .on('confirmation', (confirmationNumber, receipt) => { console.log(
            "number: " + confirmationNumber + " receipt: " + receipt
        ) })
        .then(newContractInstance =>{
            console.log(newContractInstance.options.address) // instance with the new contract address
        });

        console.log(res)
    }

    return(
        <div>
            <p>Deploy</p>
            <Button onClick={deployCPR}>deploy CPR instance</Button>
        </div>
        
    )
}
