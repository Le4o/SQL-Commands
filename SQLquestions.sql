------------1 QUESTÃO ------------------------------------------
create or replace procedure CONSULTA_ALUNO
  (
      consult_id in int
  )
  as
    cc int;
  begin
  select count(*) into cc from ALUNO a where (a.ID_ALUNO = consult_id);
     if (cc = 0) then
        dbms_output.put_line('Aluno não encontrado na base de dados');
      else 
        dbms_output.put_line('Aluno encontrado na base de dados');
     end if;
   end;

exec CONSULTA_ALUNO(1);
-----------2 QUESTÃO------------------------------------------

create or replace function FC_CONSULTA_ALUNO
  (
    consult_id in int
  )
  return varchar2
  as
    cc int;
  begin
    select count(*) into cc from ALUNO a where (a.ID_ALUNO = consult_id);
      if (cc = 0) then
        return 'Não';
      else
        return 'Sim';
      end if;
    end;

create or replace procedure call_FC_CONSULTA_ALUNO
  (
    consult_id in int
  )
  as
    resultado varchar2(20);
  begin
    resultado := FC_CONSULTA_ALUNO(consult_id);
    dbms_output.put_line(resultado);
  end;

exec call_FC_CONSULTA_ALUNO(1);

-----------3 QUESTÃO--------------------------------------------

declare
    vUpdate int;
    vMat MATRICULA.Valor_Matricula%TYPE;
    cursor cc is
        select m.Valor_Matricula
        from MATRICULA m 
            inner join ALUNO a on (a.ID_ALUNO = m.ID_ALUNO)
            inner join CALENDARIO c on (m.ID_Calendario = c.ID_Calendario)
        where (c.Ano = 2016 and c.Semestre = 1)
        for update of m.Valor_Matricula;
    
    begin 
        open cc;
        loop
            fetch cc into vMat;
            exit when cc%NOTFOUND;

            if (vMat >= 600) then
                vUpdate := 10;
                dbms_output.put_line('Matricula encontrada no valor de ' || vMat);
            else
                vUpdate := 0;
            end if;

            exception 
                when NO_DATA_FOUND then
                    dbms_output.put_line('Não há matrículas com este valor no 1 semestre de 2016');
                    rollback;
                when others then
                    dbms_output.put_line('Erro não identificado ocorreu');
                    rollback;

            update MATRICULA set Valor_Matricula = Valor_Matricula - (Valor_Matricula * vUpdate/100)
            where current of cc;

        end loop;
        close cc;
    end;

------------------- 4 QUESTÃO--------------------------------------------------------------
create or replace function FC_PROCURA
    (
        nameK in varchar2
    )
    return varchar2(30)
    as
    nameS varchar2(30);
    declare
        cA int;
        cF int;
    begin
        select count(a.Nome) into cA from ALUNO a where (a.Nome = nameS);
        select count(f.Nome) into cF from FUNCIONARIO f where (f.Nome = nameS);

        if (cA > 0 and cF > 0) then
            return 'ALUNO E FUNCIONARIO';

        elsif (cA > 0) then
            return 'ALUNO';

        elsif (cF > 0) then
            return 'FUNCIONARIO';

        else
            return 'NONE';
        end if;
    end;
    
----------------- 5 QUESTÃO ----------------------------------------------------------------

create or replace procedure sp_categoria_alunos
	(
		anoSp in int
	)
	as
	ccName ALUNO.nome%TYPE;
	ccValor MATRICULA.valor_matricula%TYPE;
	cursor cc is
            select a.nome, sum(m.valor_matricula) as TOTAL_MATRICULAS
            from ALUNO a
            join MATRICULA m on (a.id_aluno = m.id_aluno)
            join CALENDARIO c on (m.id_calendario = c.id_calendario)
            where (c.ano = anoSp)
            group by a.nome;
	begin
		open cc;
		loop
			fetch cc into ccName, ccValor;
			exit when cc%NOTFOUND;

			if ccValor > 1500 then
				DBMS_OUTPUT.PUT_LINE(ccName || ' CATEGORIA A');
			elsif ccValor > 1200 and ccValor < 1500 then
				DBMS_OUTPUT.PUT_LINE(ccName || ' CATEGORIA B');
			else
				DBMS_OUTPUT.PUT_LINE(ccName || ' CATEGORIA C');
            end if;
		end loop;
		close cc;

		exception
			when NO_DATA_FOUND then
			DBMS_OUTPUT.PUT_LINE('Nenhuma tupla encontrada');
			close cc;
			when others then
			DBMS_OUTPUT.PUT_LINE('Erro não identificado ocorreu');
			close cc;
	end;

exec sp_categoria_alunos(2016);

---------------------------6 QUESTÃO-----------------------------------------------

create or replace trigger tr_log_direito
before insert
on MATRICULA
for each row
declare
    curso varchar2(30);
begin
    select c.sigla into curso
    from CURSO c
    join ALUNO a on (c.id_curso = a.id_curso)
    join MATRICULA m on (a.id_aluno = m.id_aluno)
    where (m.id_matricula = :new.id_matricula);

    if (curso = 'DIR') then
        rollback;
        RAISE_APPLICATION_ERROR(-20001,'O curso em questão teve suas atividades finalizadas');
        return;
    end if;
end;

------------------------------7 QUESTÃO-------------------------------------------------

create table LOG_ALUNO
(
    id_log        	int                            not null,
    nome_aluno          varchar(30)                    not null,
    nome_usuario        smallint                       not null,
    data_exclusao	date 			       not null
);

create sequence sk_log;

create or replace trigger exclusao_aluno
before delete on ALUNO
for each row
	begin
		delete from MATRICULA m where (:old.id_aluno = m.id_aluno);
		insert into LOG_ALUNO (id_log, nome_aluno, nome_usuario, data_exclusao) 
		values (sk_log.nextval, :old.nome, user, sysdate);
	end;
