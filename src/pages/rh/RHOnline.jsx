import React from 'react';
import '../servicos.css';

export default function RHOnline() {
  const servicosRH = [
    { id: 1, nome: 'Mérito por ser Extraordinário', cor: '#f59e0b' }, // Laranja/Ouro
    { id: 2, nome: 'Treinamentos', cor: '#3b82f6' },                // Azul
    { id: 8, nome: 'Avaliação de Desempenho', cor: '#f59e0b' },     // Laranja
  ];

  return (
    <div className="servicos-container">
      {/* Banner de Acesso Rápido - Setor RH */}
      <div className="acesso-rapido-banner">
        RH ONLINE - INFOSAT
      </div>

      <div className="servicos-grid">
        {servicosRH.map((servico) => (
          <div key={servico.id} className="card-servico">
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
