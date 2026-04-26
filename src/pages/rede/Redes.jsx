import React from 'react';
import '../servicos.css';

export default function Redes() {
  const servicosRede = [
    { id: 1, nome: 'Buscar IP', cor: '#ef4444' }, // Vermelho
    { id: 2, nome: 'Teste de Ping', cor: '#f59e0b' }, // Laranja
    { id: 3, nome: 'Scanner de Portas', cor: '#ef4444' }, // Vermelho
    { id: 4, nome: 'Status Link', cor: '#10b981' }, // Verde
    { id: 5, nome: 'CFTV Matriz', cor: '#000000' }, // Preto
    { id: 7, nome: 'Speedtest Ookla', cor: '#f59e0b' }, // Laranja
    { id: 9, nome: 'Traceroute', cor: '#10b981' }, // Verde
    { id: 10, nome: 'Configuração Roteador', cor: '#f59e0b' }, // Laranja
   
  ];

  return (
    <div className="servicos-container">
      {/* Banner de Acesso Rápido - Setor Redes */}
      <div className="acesso-rapido-banner">
        GERENCIAMENTO DE REDES - INFOSAT
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
