import { BrowserRouter, Routes, Route, useLocation } from 'react-router-dom';
import Login from './pages/Login';
import Menu from './components/Menu';
import Servicos from './pages/Servicos';
import Redes from './pages/rede/Redes'; // Importando a nova página
import Frota from './pages/veiculo/Frota';
import RHOnline from './pages/rh/RHOnline';

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
          <Route path="/frota" element={<Frota />} />
		  <Route path="/rhonline" element={<RHOnline />} />
          <Route path="/redes" element={<Redes />} /> {/* Nova rota adicionada */}
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}
