import React, { useState, useEffect} from 'react';
import {Container, Button, Alert} from 'react-bootstrap';
import { useMoralis, AuthError} from 'react-moralis';
import { BuyCrypto } from './components/BuyCrptoBtn';


export const Auth = () => {
  const {enableWeb3, authenticate, isAuthenticated, isAuthenticating, authError, signup, login } = useMoralis();
  const [email, setEmail] = useState<string>('');
  const [password, setPassword] = useState<string>('');
  

  useEffect( () =>{if(isAuthenticated){ enableWeb3()}}, [isAuthenticated])
  
  return (
    <Container>
     
    </Container>
  );
};
