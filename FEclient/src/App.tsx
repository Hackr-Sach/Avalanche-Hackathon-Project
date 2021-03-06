import {Button, Container} from 'react-bootstrap';
import { useMoralis } from 'react-moralis';
import { Avalanche } from "avalanche";
import { Auth } from './components/Auth';
import { Dashboard } from './components/Dashboard';

function App() {
  const { isAuthenticated, logout } = useMoralis();

  if (isAuthenticated) {
    return (
      <div id="app-inner">
        <Container>
          <Button onClick={() => logout()}>Logout</Button>
          <Dashboard />
        </Container>
      </div>
    );
  }

  return (
    <div id="app-inner">  
        <Auth />
    </div>
  );
}

export default App;
