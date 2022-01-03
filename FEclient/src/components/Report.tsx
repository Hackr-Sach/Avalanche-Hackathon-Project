import {Button, Container} from 'react-bootstrap';
import { useState } from 'react';
import store from '../app/store';


// this will be evolving 
// initial mvp reports will be basic
// @param resouorce capacity
// @param rates for distribution, etc
export const CPR_Report = () => {
    
    const state = store.getState();
    let apprtrs = state.keys[state.keys.length]
    const [resourceCAP, setResourceCAP] = useState<Number>(0);
    const [distributionRate, setDistributionRate ] = useState<Number>(0);


    return(
        <div>
            <p>"report"</p>  
            <p>{apprtrs}</p>

        </div>
        
    )
}