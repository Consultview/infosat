import React from 'react';
import './servicos.css';

export default function Servicos() {
  const servicosRede = [
    { id: 1, nome: 'Buscar IP', cor: '#ef4444' }, // Vermelho
    { id: 2, nome: 'Teste de Ping', cor: '#f59e0b' }, // Laranja
    { id: 3, nome: 'Monitoramento', cor: '#3b82f6' }, // Azul
    { id: 4, nome: 'Configurações', cor: '#f59e0b' }, // Laranja
    { id: 5, nome: 'Dashboard', cor: '#000000' }, // Preto
    { id: 6, nome: 'Scanner Portas', cor: '#ef4444' }, // Vermelho
    { id: 7, nome: 'Traceroute', cor: '#10b981' }, // Verde
    { id: 8, nome: 'Status Link', cor: '#10b981' }, // Verde
    { id: 9, nome: 'Protocolo Pânico', cor: '#ef4444' }, // Vermelho
    { id: 10, nome: 'Reservas', cor: '#8b5cf6' }, // Roxo
    { id: 11, nome: 'Usuários', cor: '#3b82f6' }  // Azul
  ];

  return (
    <div className="servicos-container">
      {/* Banner de Acesso Rápido */}
      <div className="acesso-rapido-banner">
        ACESSO RÁPIDO - INFOSAT ADMIN
      </div>

      <div className="servicos-grid">
        {servicosRede.map((servico) => (
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
