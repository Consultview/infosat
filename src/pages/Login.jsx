import React from 'react';
import { useNavigate } from 'react-router-dom';
import './login.css';

export default function Login() {
  const navigate = useNavigate();

  return (
    <div className="login-container-app">
      <header className="page-header">
        <h1 className="header-brand">INFOSAT</h1>
        <div className="header-menu-icon">
          <span></span><span></span>
        </div>
      </header>

      <main className="login-content">
        <div className="brand-hero">
          <h2 className="main-logo">INFOSAT</h2>
          <p className="main-tagline">Tecnologia e Automação</p>
        </div>

        <div className="login-card-box">
          <form onSubmit={(e) => { e.preventDefault(); navigate('/servicos'); }}>
            <div className="input-group-app">
              <label>E-mail Corporativo</label>
              <input type="email" placeholder="nome@infosat.com.br" required />
            </div>

            <div className="input-group-app">
              <div className="label-row">
                <label>Senha</label>
                <a href="#" className="forgot-pass">Esqueceu a senha?</a>
              </div>
              <input type="password" placeholder="********" required />
            </div>

            <button type="submit" className="btn-enter">Entrar na plataforma</button>

            <div className="divider-app">
              <span>ou</span>
            </div>

            <button type="button" className="btn-google-app">
              Continuar com Google
            </button>
          </form>
        </div>

        <footer className="dev-signature-app">
          Desenvolvido por <a href="https://detoxitsolutions.onrender.com" target="_blank" rel="noopener noreferrer">DETOX IT SOLUTIONS</a>
        </footer>
      </main>
    </div>
  );
}
