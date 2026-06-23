use car_rent;

alter table clientes engine=InnoDB;
alter table veiculos engine=InnoDB;
alter table modelos engine=InnoDB;
alter table marcas engine=InnoDB;
alter table rent engine=InnoDB;

set autocommit = 0;

start transaction;
-- inserir novo cliente
insert into clientes (nome, ncc, nif) 
	values ('Ana Costa', 'D-12345', 123456789);
    
-- registrar o aluguel desse cliente no veículo 2, usando last_insert_id() que usa o id gerado pelo insert acima
insert into rent (data_inicio, data_fim, veiculo_id, person_id)
	values ('2026-07-01', '2026-07-05', 2, last_insert_id());  
commit;

select * from clientes;

SELECT @@autocommit;
set autocommit = 0;

start transaction;
insert into marcas (nome_marca) values ('Toyota');
savepoint depois_da_marca; -- ponto de retorno
insert into modelos (nome, marca_id) values ('Corolla', last_insert_id());
-- se o modelo tiver errado, volta só até o savepoint
-- neste momento, caso volte para o savepoint, a marca toyota já foi inserida
-- então poderiamos continuar com insert do modelo com os dados corretos
rollback to depois_da_marca;
commit;

select * from marcas;
select * from modelos;

delimiter €€
create procedure registrar_aluguel(
	in p_person_id smallint unsigned,
    in p_veiculo_id smallint unsigned,
    in p_data_inicio date,
    in p_data_fim date
)
begin
	declare conflito int default 0;
    
    -- handler: se qualquer erro ocorrer, faz rollback
    declare exit handler for sqlexception
    begin
		rollback;
		resignal;
	end;

	start transaction;
    
		-- 1. verifica se o veículo está disponível no período
		select count(*) into conflito
			from rent
			where veiculo_id = p_veiculo_id and data_inicio < p_data_fim and data_fim > p_data_inicio;
            
		-- 2. se houver conflito, lança erro e faz rollback
		if conflito > 0 then
			signal sqlstate '45000'
				set message_text = 'Veículo indisponível nesse período.';
		end if;

		-- 3. se estiver livre, insere o alguel
		insert into rent (data_inicio, data_fim, veiculo_id, person_id)
			values (p_data_inicio, p_data_fim, p_veiculo_id, p_person_id);
    
	commit;

	select 'Aluguel registrado com sucesso.' as resultado;
end €€

delimiter ;

DROP PROCEDURE IF EXISTS registrar_aluguel;

call registrar_aluguel(4, 3, '2026-08-01', '2026-08-05');
call registrar_aluguel(1, 1, '2020-06-26', '2020-06-28');

select * from rent;

show table status from car_rent;

call registrar_aluguel(1, 5, '2026-06-23', '2026-06-30');
call registrar_aluguel(1, 4, '2026-06-23', '2026-06-30'); -- erro