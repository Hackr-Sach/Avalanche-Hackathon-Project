import {Button, Container} from 'react-bootstrap';
import { useMoralis } from 'react-moralis';
import { Avalanche, BinTools, Buffer} from "avalanche";
import { BenefactorKeyGen } from './components/KeyGenerator';
import { CPR_Report } from './components/Report';




export const Dashboard = () => {

    return(
        <Container>
            <h4>"CPR dashboard"</h4>
            <BenefactorKeyGen />
            <CPR_Report />
        </Container>
    )
}