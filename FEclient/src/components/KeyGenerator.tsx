import {Button, Container} from 'react-bootstrap';
import { useMoralis } from 'react-moralis';
import { Avalanche, BinTools, Buffer, BN} from "avalanche";
import { InitialStates, SECPTransferOutput } from "avalanche/dist/apis/avm";
import { useAddBenefactor } from "../hooks";
import { KeyPair } from 'avalanche/dist/apis/evm';

export const BenefactorKeyGen = () => {
    const contractAddress = (process.env.REACT_APP_DEPLOYED_CONTRACT as string);
    const binTools = BinTools.getInstance();
    const _netWorkID = 43112;
    const avalanche = new Avalanche("localhost", 9650, "http", _netWorkID);
    const xchain = avalanche.XChain();
    const _KeyChain = xchain.keyChain();
    let newBenefactorKey:any;

    const makeKey = () => {
        newBenefactorKey = _KeyChain.makeKey();
        console.log(newBenefactorKey.getAddressString())
    }

    //
    const importKey = () => {
        let _pk = binTools.stringToBuffer("0x9f376d3e972c18b4479497eb7d3d501f661126817c104ec1d6b03bb76c5fffb4"); 
        newBenefactorKey = _KeyChain.importKey(_pk);
        console.log(newBenefactorKey.getAddressString())
    }

    const {handleAddBenefactor, benefactorKeyState} = useAddBenefactor(
        contractAddress,
        newBenefactorKey
        );


    return(
        <div>
            <h2>KEYGEN</h2>
            <p>"Create key"</p>
            <Button onClick={makeKey}>Make Key</Button>
            <p>"Import private key"</p>
            <Button onClick={importKey}>Import Key</Button>
        </div>
        
    )
}