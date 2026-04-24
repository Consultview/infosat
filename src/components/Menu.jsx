import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import './menu.css';

export default function Menu() {
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();

  const toggleMenu = () => setIsOpen(!isOpen);

  // Fecha o menu ao clicar em um link
  const closeMenu = () => setIsOpen(false);

  return (
    <>
      <header className="app-header">
        <div className="header-container">
          <h1 className="header-logo">INFOSAT</h1>
          
          <button className={`nav-icon ${isOpen ? 'open' : ''}`} onClick={toggleMenu}>
            <span></span>
            <span></span>
            <span></span>
          </button>
        </div>
      </header>

      {/* MENU GAVETA - AGORA ABRE DA ESQUERDA */}
      <aside className={`sidebar-drawer ${isOpen ? 'active' : ''}`}>
        <div className="drawer-header">
          <span className="drawer-title">Menu Principal</span>
        </div>
        
        <nav className="drawer-nav">
          <Link to="/servicos" className="drawer-link" onClick={closeMenu}>Serviços</Link>
          <Link to="/dashboard" className="drawer-link" onClick={closeMenu}>Dashboard</Link>
          <Link to="/configuracoes" className="drawer-link" onClick={closeMenu}>Configurações</Link>
          
          <div className="drawer-divider"></div>
          
          <Link to="/" className="drawer-logout" onClick={closeMenu}>Sair</Link>
        </nav>
      </aside>

      {/* BACKDROP (Fundo escuro) */}
      {isOpen && <div className="menu-backdrop" onClick={toggleMenu}></div>}
    </>
  );
}
