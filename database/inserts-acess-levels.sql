-- Nivel Acesso 
INSERT INTO nivel_acesso (nome) VALUES 
('ALUNO'),
('PROFESSOR_AUXILIAR'),
('REPRESENTANTE_LEGAL');
// select * FROM nivel_acesso;

-- Situação
INSERT INTO situacao (nome) VALUES 
('ATIVO'),
('INATIVO');
// select * from situacao;

-- Nivel Ingles
INSERT INTO nivel_ingles (nome) VALUES 
('A1'),
('A2'),
('B1'),
('B2'),
('C1'),
('C2');
// select * from nivel_ingles;

-- Nicho
INSERT INTO nicho (nome) VALUES 
('INFANTIL'),
('BUSINESS'),
('TECNICO'),
('TESTES_INTERNACIONAIS'),
('MORADORES_EXTERIOR');
// select * from nicho;

-- Status
INSERT INTO status (nome, descricao) VALUES 
('PENDENTE', 'Agendamento pendente'), 
('CONFIRMADO', 'Agendamento confirmado'), 
('CONCLUIDO', 'Agendamento concluido'), 
('CANCELADO', 'Agendamento cancelado'), 
('TRANSFERIDO', 'Agendamento transferido');
// select * from status;

/*
-- Usuario
INSERT INTO usuario (nome_completo, cpf, telefone, data_nascimento, data_cadastro, autenticado, profissao, email, senha, nivel_acesso_id, situacao_id) VALUES 
('Christian', '300.261.160-30', '11092378173', '1985-05-15', '2024-06-05', TRUE, 'Professor de Inglês', 'christian@email.com', 'christian123', 3, 1),
('João Silva', '123.456.789-00', '11987654321', '1990-07-20', '2024-10-05', TRUE, 'Programador', 'joao.silva@example.com', 'senha123', 1, 1), 
('Maria Souza', '987.654.321-00', '21987654321', '1982-11-30', '2024-05-05', TRUE, 'Piloto de Avião', 'maria.souza@example.com', 'senha456', 1, 1),
('Filho Christian', '546.097.435-00', '11092378173', '1985-05-15', '2024-06-05', TRUE, 'Professor de Inglês', 'filhochristian@email.com', 'Filhochristian123', 2, 1),
('Joana Airton', '743.183.324-01', '11728499339', '1983-03-1', '2024-10-30', TRUE, 'Aeromoça', 'joana.airton@example.com', 'senha789', 1, 1);
// select * from usuario;

-- Horario Professor
INSERT INTO horario_professor (inicio, fim, pausa_inicio, pausa_fim, usuario_id) VALUES 
('08:00:00', '23:00:00', '12:00:00', '13:00:00', 1),
('13:00:00', '17:30:00', '15:00:00', '15:30:00', 4);
// select * from horario_professor;

-- Metas
INSERT INTO meta (qtd_aula, usuario_id) VALUES 
(20, 1),
(20, 4); 

-- Usuario Nivel Ingles
INSERT INTO usuario_nivel_ingles (usuario_id, nivel_ingles_id) VALUES 
(1, 4),
(2, 2),
(3, 5),
(3, 6),
(4, 6);
// select * from usuario_nivel_ingles;

-- Usuario Nicho
INSERT INTO usuario_nicho (usuario_id, nicho_id) VALUES 
(1, 2),
(1, 3),
(2, 1),
(3, 3),
(4, 4);
// select * from usuario_nicho;

INSERT INTO agendamento (data, horario_inicio, horario_fim, assunto, fk_professor, fk_aluno) VALUES 
('2024-10-10', '08:00:00', '08:59:00', 'Aula de Inglês', 1, 5),
('2024-10-10', '13:00:00', '13:59:00', 'Aula de Inglês', 1, 5),
('2024-10-11', '15:00:00', '15:59:00', 'Aula de Inglês', 1, 5);

INSERT INTO historico_agendamento (data_atualizacao, agendamento_id, status_id) VALUES 
('2024-09-07', 1, 1), -- Pendente
('2024-09-07', 1, 2), -- Confirmado
('2024-09-07', 2, 1), -- Pendente
('2024-09-07', 2, 2), -- Confirmado
('2024-09-07', 2, 4), -- cancelado
('2024-09-07', 3, 1), -- Pendente
('2024-09-07', 3, 2); -- Confirmado
*/