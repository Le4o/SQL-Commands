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
