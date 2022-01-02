import {Button, Container} from 'react-bootstrap';
import { useMoralis } from 'react-moralis';
import { Avalanche, BinTools, Buffer} from "avalanche";
import { BenefactorKeyGen } from '../features/keys/KeyGenerator';
import { CPR_Report } from './Report';

// hook into a benefactors[] state and use this. 


export const Dashboard = () => {

    return(
        <Container>
            <h4>"CPR dashboard"</h4>
            <BenefactorKeyGen />
            <CPR_Report />
            {/* <Button onClick={deployCPR}>deploy cpr contract</Button> */}
        </Container>
    )
}