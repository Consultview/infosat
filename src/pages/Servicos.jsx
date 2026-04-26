import React from 'react';
import { useNavigate } from 'react-router-dom'; // 1. Importar o hook de navegação
import './servicos.css';

export default function Servicos() {
  const navigate = useNavigate(); // 2. Inicializar o hook

  const servicosRede = [
    // --- REDES ---
    { id: 1, nome: 'Redes', cor: '#ef4444', path: '/redes' }, // Adicionei o path aqui
    { id: 2, nome: 'Usuários', cor: '#3b82f6' },

    // --- RH ---
    { id: 3, nome: 'RH Online', cor: '#8b5cf6', path: '/rhonline' },
    

    // ... restante dos seus itens iguais ...
    { id: 4, nome: 'Frota/GPS', cor: '#10b981', path: '/frota' },
    { id: 5, nome: 'Emergências', cor: '#000000' },
    { id: 6, nome: 'Rastreio Objetos', cor: '#f59e0b' }
  ];

  return (
    <div className="servicos-container">
      <div className="acesso-rapido-banner">
        ACESSO RÁPIDO - INFOSAT ADMIN
      </div>

      <div className="servicos-grid">
        {servicosRede.map((servico) => (
          <div 
            key={servico.id} 
            className="card-servico"
            onClick={() => servico.path && navigate(servico.path)} // 3. Adicionar o evento de clique
            style={{ cursor: servico.path ? 'pointer' : 'default' }} // Deixa a mãozinha no mouse
          >
            <span className="card-nome">{servico.nome}</span>
            <div 
              className="card-indicator" 
              style={{ backgroundColor: servico.cor }}
            ></div>
          </div>
        ))}
      </div>
    </div>
  );
}
