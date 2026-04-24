import { BrowserRouter, Routes, Route, useLocation } from 'react-router-dom';
import Login from './pages/Login';
import Menu from './components/Menu';
import Servicos from './pages/Servicos';

function Layout({ children }) {
  const location = useLocation();
  const isLoginPage = location.pathname === '/';

  return (
    <div className="flex-container">
      {!isLoginPage && <Menu />}
      <div className="main-content">{children}</div>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<Login />} />
          <Route path="/servicos" element={<Servicos />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}
