import React from 'react';
import '../servicos.css';

export default function Usuario() {
  const servicosUsuario = [
    { id: 1, nome: 'Meus Dados', cor: '#10b981' },       // Verde
    { id: 2, nome: 'Alterar Senha', cor: '#3b82f6' },    // Azul
    { id: 3, nome: 'Histórico de Acessos', cor: '#6b7280' }, // Cinza
    { id: 4, nome: 'Preferências', cor: '#8b5cf6' },     // Roxo
  ];

  return (
    <div className="servicos-container">
      {/* Banner de Acesso Rápido - Setor Usuário */}
      <div className="acesso-rapido-banner">
        PERFIL DO USUÁRIO - INFOSAT
      </div>

      <div className="servicos-grid">
        {servicosUsuario.map((servico) => (
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
