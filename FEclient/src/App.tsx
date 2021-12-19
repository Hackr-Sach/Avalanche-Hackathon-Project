import {Button, Container} from 'react-bootstrap';
import { useMoralis } from 'react-moralis';
import { Avalanche } from "avalanche";
import { Auth } from './Auth';


function App() {
  const { isAuthenticated, logout } = useMoralis();

  if (isAuthenticated) {
    return (
      <div id="app-inner">
        <Container>
          <h1>Commons dashboard</h1>
          <Button onClick={() => logout()}>Logout</Button>
        </Container>
      </div>
    );
  }

  return (
    <div id="app-inner">
      <Container>
        <h1>
          Welcome - Log in or sign up
        </h1>
        <Button>Login</Button>
        <Auth />
      </Container>
    </div>
  );
}

export default App;
