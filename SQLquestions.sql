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

