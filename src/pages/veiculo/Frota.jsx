import React from 'react';
import '../servicos.css';

export default function Frota() {
  const servicosFrota = [
    { id: 1, nome: 'Checklist Veicular', cor: '#10b981' }, // Verde
    { id: 2, nome: 'Controle de Viagens', cor: '#3b82f6' }, // Azul
    { id: 3, nome: 'Manutenção Preventiva', cor: '#f59e0b' }, // Laranja
    { id: 4, nome: 'Abastecimento', cor: '#10b981' }, // Verde
    { id: 5, nome: 'Rastreamento GPS', cor: '#000000' }, // Preto
    { id: 6, nome: 'Multas e Documentos', cor: '#ef4444' }, // Vermelho
    { id: 7, nome: 'Seguro Frota', cor: '#3b82f6' }, // Azul
    
  ];

  return (
    <div className="servicos-container">
      {/* Banner de Acesso Rápido - Setor Frota */}
      <div className="acesso-rapido-banner">
        CONTROLE DE FROTA - INFOSAT
      </div>

      <div className="servicos-grid">
        {servicosFrota.map((servico) => (
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
