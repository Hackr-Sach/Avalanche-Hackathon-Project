import { Input } from 'avalanche/dist/common';
import React, { useState, useEffect} from 'react';
import {Container, Button, Alert, InputGroup, FormControl} from 'react-bootstrap';
import { useMoralis, AuthError} from 'react-moralis';
import { BuyCrypto } from './components/BuyCrptoBtn';


export const Auth = () => {
  const {enableWeb3, authenticate, isAuthenticated, isAuthenticating, authError, signup, login } = useMoralis();
  const [email, setEmail] = useState<string>('');
  const [password, setPassword] = useState<string>('');
  

  useEffect( () =>{if(isAuthenticated){ enableWeb3()}}, [isAuthenticated])
  
  function AlertAuth() {
    const [show, setShow] = useState(true);
    if (show) {
      return (
        <Alert variant="danger" onClose={() => setShow(false)} dismissible>
          <Alert.Heading>Oh snap! You got an error!</Alert.Heading>
          <p>{authError == null ? "null" : authError.message}</p>
        </Alert>
      );
    }
    return <Button onClick={() => setShow(true)}>Show Alert</Button>;
  }

  return (
    <Container id="authWrapper">
      <BuyCrypto />
      <h2>
          Log in or sign up
      </h2>
      --------wallet auth----------- <br/>
      {authError && <AlertAuth />}
      <Button onClick={() => authenticate()}>
        Authenticate via Metamask
      </Button>
      <p text-align="center">
        <em>or</em>
      </p>
      --------email sign up-------------- <br/>
      <Container className='signup'>
        <InputGroup> 
          <InputGroup.Text id="signupEmail">Email: </InputGroup.Text>
            <FormControl
              placeholder="Email"
              aria-label="Email"
              aria-describedby="signupEmail"
              value={email}
              onChange={(event:{currentTarget:{value: React.SetStateAction<string>;};})=> 
                setEmail(event.currentTarget.value)}
            /> <br/>
          <InputGroup.Text id="signupPassword">Password: </InputGroup.Text>
            <FormControl
              placeholder="Password"
              type="password"
              value={password}
              onChange={(event) => setPassword(event.currentTarget.value)}
            /> <br/>
          <Button onClick={() => signup(email, password, email)}>Sign up</Button>
        </InputGroup> 
      </Container>

      <p text-align="center">
        <em>or</em>
      </p>
      ---------email login------------ <br/>
      <Container>
        <InputGroup>
          <InputGroup.Text id="loginEmail">Email: </InputGroup.Text>
            <FormControl
              placeholder="Email"
              type="email"
              value={email}
              onChange={(event) => setEmail(event.currentTarget.value)}
            /> <br/>
          <InputGroup.Text id="loginEmail">Password: </InputGroup.Text>
            <FormControl
              placeholder="Password"
              type="password"
              value={password}
              onChange={(event) => setPassword(event.currentTarget.value)}
            /> <br/>
            <Button onClick={() => login(email, password)}>Login</Button>
        </InputGroup>
      </Container>
    </Container>
  );
};
