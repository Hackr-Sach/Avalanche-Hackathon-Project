import {Button, Container} from 'react-bootstrap';
import { BenefactorKeyGen } from '../features/keys/KeyGenerator';
import { InitInstance } from './deployInstance';

// hook into a benefactors[] state and use this. 


export const Dashboard = () => {

    return(
        <Container>
            <h4 style={{paddingLeft: '25%'}}>"CPR dashboard"</h4>
            <a href='/make_report' style={{paddingLeft: '66%'}}>
                <Button type="button">fill out report</Button>
            </a>
            <Container style={{paddingLeft: '25%'}}>
                <BenefactorKeyGen />
            </Container>
            <Container style={{paddingLeft: '25%'}}>
                <InitInstance />
            </Container>   
        </Container>
    )
}