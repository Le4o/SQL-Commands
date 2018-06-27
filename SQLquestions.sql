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
