import { Avalanche, BinTools, Buffer, BN} from "avalanche";
import { InitialStates, SECPTransferOutput } from "avalanche/dist/apis/avm";
import { buffer } from "node:stream/consumers";
import { Container } from "react-bootstrap";

export const TryOutAvalancheJs = () => {

// instance setup
const binTools = BinTools.getInstance();
const _netWorkID = 43112;
const avalanche = new Avalanche("localhost", 9650, "http", _netWorkID);
const xchain = avalanche.XChain();

// Managing X-Chain Keys
//
// the keychain is accessed through the xchain and can be accesed directly or through refference var
const _KeyChain = xchain.keyChain();
// the keychain has the ability to create new keypairs and return the address associated.
const address1 = _KeyChain.makeKey();
console.log("addr1 from keyChain.makeKey: " + address1.getAddressString());
// you can also import a private key to the keychain using a buffer
const _pk = binTools.cb58Decode('276sdKJHBJidshvkQk1HQRVJx5dKpk4P6WN2D55MEpsjeVDJ7ehPbgJmnDF63PY1PYkaCtH4W48BWzGyqKE8MLEbDQrK9EHAemd718rp7PaxaebTp66Wncc5h6Df95J1ppU417VKd2SwF9gunYso8g59uSySrXbWbcGomFCjPhbs7bYdogiXEgARJLNeMvyiZv6MsowafRdXrTgnEBRz1THqq99cc4');
const address2 = _KeyChain.importKey(_pk);
console.log("addr2 from import pk: " + address2.getAddressString());
// or a CB58 string works
const _pk2 = 'PrivateKey-JaCCSxdoWfo3ao5KwenXrJjJR7cBTQ287G1C5qpv2hr2tCCdb';
const address3 = _KeyChain.importKey(_pk2);
console.log("addr3 from string: " + address3.getAddressString());

// WORKING WITH KEYCHAINS
const addresses = _KeyChain.getAddresses(); // returns an array of buffers for addresses
// console.log(addresses)
const stringAddresses = _KeyChain.getAddressStrings();
console.log("keychain getAddrStrings: " + stringAddresses);
const exists = _KeyChain.hasKey(addresses[0]); // returns true if the key is managed
console.log("Does it exist? " + exists);
const keypair = _KeyChain.getKey(addresses[0]); // returns the KeyPair class
console.log("Keypair class: " + keypair.getChainID());

// WORKING WITH KEYPAIRS
const address = keypair.getAddress(); // returns buffer
console.log("this is a buffer of keypair address: " + binTools.cb58Encode(address));
const addressString = keypair.getAddressString(); // returns str
console.log("this is the keypair address as string: " + addressString);
const pKey = keypair.getPublicKey(); // returns buffer
console.log("tihs is a buffer of public key: " + binTools.cb58Encode(pKey));
const pKeyStr = keypair.getPublicKeyString(); // str
console.log("this is public key as string: " + pKeyStr);
const prKey = keypair.getPrivateKey(); // buffer
const prKeyStr = keypair.getPrivateKeyString();
console.log("private key as a string: " + prKeyStr);
let randomKeyPair = keypair.generateKey(); // create random keypair
const myPK = binTools.cb58Decode("24jUJ9vZexUM6expyMcT48LBx27k1m7xpraoV62oSQAHdziao5");
const successful = keypair.importKey(myPK); // returns bool if true
console.log("imported myPK successful? " + successful);
const message = Buffer.from("from the bottom al the way to the top");
console.log(message.toString());
const signature = keypair.sign(message); // returns a buffer with the signature
console.log("signature: " + binTools.cb58Encode(signature));
const signerPubKey = keypair.recover(message, signature);
console.log("signer pubkey: "+ binTools.cb58Encode(signerPubKey));
const isValid = keypair.verify(message, signature);
console.log("is valid: " + isValid);
 
/*
    Creating an asset
*/

// Describe new asset
const name = "Aedyn";
const symbol = "ADN";
const denomination = 9;

const xAddresses:any = xchain.keyChain().getAddresses();
const initialStates =  new InitialStates();
xAddresses.forEach((element: Buffer) => {
    console.log("xAddresses: " + binTools.cb58Encode(element));
});

    // Create outputs for the asset's initial state
    const secpOutput1 = new SECPTransferOutput(
        new BN(400), 
        (xAddresses as any),
        (new BN(400) as any), 
        (1 as any)
    );
    const secpOutput2 = new SECPTransferOutput(
        new BN(500),
        ([xAddresses[0]] as any),
        (new BN(400) as any),
        (1 as any) 
    );
    const secpOutput3 = new SECPTransferOutput(
        new BN(600),
        ([
        addresses[1],
        addresses[2],
        ] as any),
        new BN(400),
        (1 as any)
    );

    // populate the intitialStates with the outputs
    initialStates.addOutput(secpOutput1);
    initialStates.addOutput(secpOutput2);
    initialStates.addOutput(secpOutput3);
    console.log("init states: " + binTools.fromBufferToArrayBuffer(initialStates.toBuffer()));

// creating the signed transaction
const createSignedTX = async() =>{
    const utxos:any = await xchain.getUTXOs(xAddresses)
    .then(element => {console.log("sucess" + element)})
    .catch(Error => {console.log("Error in createSingedTX: " + Error)});

    // make an unsigned create asset tx from the data we just compiled
    const unsigned = await xchain.buildCreateAssetTx(
        (utxos as any), //the UTXO set containing the utxo were going to spend
        (xAddresses as any), //the address which will pay the fees
        (xAddresses as any),//the address which will recieve change from the utxos
        initialStates, //init state to be created for this asset
        name, // full name of the asset
        symbol, //short ticker for symbol
        denomination 
    )
    .then(async(element) => {
        const signed = element.sign((xchain as any));
        console.log("signed" + signed);
        // issue the signed tx
        // const txid = await xchain.issueTx(signed.toString());
        // const txid = await xchain.issueTx(signed.toBuffer());
        const txid = await xchain.issueTx(signed)
            .then(element => {
            // get the status of the tx
            const status = xchain.getTxStatus(element); // Statuses: Rejected, Accepeted, Processing, Unknown
            console.log("txid" + txid);
            })
            .catch(Error => {console.log("error in issuing TX: " + Error)}); 
    })
    .catch(Error => {console.log("error in creating asset: " + Error)});
   
    
}
createSignedTX();
/*
    Sending an asset
*/
// getting the utxo set
// const a_addresses = xchain.keyChain().getAddresses();
// const a_addressString = xchain.keyChain().getAddressStrings();

// const u = await xchain.getUTXOs((a_addresses as any));
// const a_utxos = u.utxos;
// // spending the UTXOs
// const assetID =  "3SG899DUxzxBkFSxDA3hwDNXBB7xaYGLZTGtGK6J4WTueKupj"; //cb58 string
// const myBalance = a_utxos.getBalance(xddresses, assetID); // returns 400 as Big Number (BN)
// console.log(myBalance)

    return(
        <Container>
            <h4>"Avalanche test"</h4>
            
        </Container>
    )
}


