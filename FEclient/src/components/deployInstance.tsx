import {Button, Container} from 'react-bootstrap';
import { useMoralis } from 'react-moralis';
import Web3 from 'web3';
import { useEffect, useState } from 'react';
import CPRinstance from "../abi/CPRinstance.json"

export const initInstance = () => {
    const {enableWeb3, isAuthenticated} = useMoralis();
    useEffect( () =>{if(isAuthenticated){ enableWeb3()}}, [isAuthenticated])

    let testPerson = ["0x72D1CbA159e87c017C9e9f672efBab3C2DfBfadA"];
    
    const deployCPR  = () => {
        const web3 = new Web3(Web3.givenProvider || 'http://localhost:9650');
        const Contract = new web3.eth.Contract((CPRinstance.abi as any));
        let res = Contract.deploy({
            data: CPRinstance.bytecode,
            arguments:[testPerson],
        }).send({
            from: key2add ? key2add : '0x814dDd96FA03f46352c4A2C5787b4836408477fC', // ill need a dynamic arr to old multiple initial benefactors
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
           
        </div>
        
    )
}
