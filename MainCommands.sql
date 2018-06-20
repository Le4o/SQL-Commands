-----------CURSOR COM UPDATE-------------------------------------------
declare
	
	vPreco tb_Livro.Preco%TYPE;
	vDescEditora tb_Editora.Descricao%TYPE;
	vPrecReajuste number;

	cursor cLivros is
		select
			L.Preco,
			upper(E.Descricao)
		from 
			tb_Livro L
		join 
			tb_Editora E on (L.ID_Editora = E.ID_Editora)
		for update of l.preco;

begin

	open cLivros;
	loop
	fetch cLivros into vPreco, vDescEditora;
	exit when cLivros%NOTFOUND;

	if 	vDescEditora = 'CAMPUS' then
		vPercReajuste := 5;
	else
		vPercReajuste := 10;
	end if;

	update tb_livro set preco = preco + (preco * vPrecreajuste/100) where current of cLivros;

	end loop;

close cLivros;

end;

---------TRATAMENTO DE ERRO----------------------------------------------------------

select * from tb_Editora;
declare
	vValor1 number := 100;
	vValor2 number := 0;

begin

	vValor1 := vValor1 / vValor2;
	insert into tb_Editora values (sq_editora.nextval, 'teste1', 'eee');

	select
		preco
	into
		vValor1
	from 
		tb_Livro
	where
		ID_Livro = 100;

	exception

		when ZERO_DIVIDE then
			DBMS_OUTPUT.PUT_LINE('Valor 2 não pode ser zero');
		when others then 
			DBMS_OUTPUT.PUT_LINE('Erro não identificado ocorreu');

end;

--------------EXCEPTION QUE APAGA O PRÓPRIO COMANDO--------------------
--As procedures não são atomicas, alguns elementos são compilados / Serve para apagar estes comando quando dá erro

EXCEPTION

	when NO_DATA_FOUND then
		DBMS_OUTPUT.PUT_LINE('Consulta não retornou nenhum registro');
		rollback;
	when TOO_MANY_ROWS then
		DBMS_OUTPUT.PUT_LINE('Consulta retornou mais de um registro');
		rollback;
	when others then
		DBMS_OUTPUT.PUT_LINE('Erro não identificado ocorreu');
		rollback;

--------------CRIANDO UMA EXCEÇÃO------------------------------------------

alter session set nls_date_formate = 'dd/mm/yyyy';
declare
	vData date = '01/01/2010';
	DATA_INVALIDA EXCEPTION;
	vCodigo number;
	verro varchar2(64);

begin

	if vData < SYSDATE then
		RAISE DATA_INVALIDA;
	end if;

exception

	when DATA_INVALIDA then
		DBMS_OUTPUT.PUT_LINE('Data anterior a data do servidor');
	when others then
		vCodigo := SQLCODE;
		vErro := substr(SQLERRM, 1, 64);
		DBMS_OUTPUT.PUT_LINE('Erro: ' || vCodigo || ' : ' || vErro);

end;

---------------------CRIANDO UMA PROCEDURE----------------------------

create or replace procedure SP_TESTES
	(
		pParam1 in number;
		pParam2 in out number;
		pParam3 out number
	)
	as 
	begin

		DBMS_OUTPUT.PUT_LINE('Valores dentro da procedure (1): ' || pParam1 || ' ' || pParam2 || ' ' || pParam3);
		pParam2 := pParam1 * 2;
		pParam3 := pParam1 * 3;

		DBMS_OUTPUT.PUT_LINE('Valores dentro da procedure (2): '|| pParam1 || ' ' || pParam2 || ' ' || pParam3);

	end; 

	declare
		vParam1 number := 100;
		vParam2 number := 100;
		vParam3 number := 100;

		begin

			SP_TESTES(vParam1,vParam2, vParam3);
			DBMS_OUTPUT.PUT_LINE('Valors fora da procedure: ' || vParam1 || ' ' || vParam2 || ' ' || vParam3);
		end;

------------------------------SOBRECARREGANDO UMA PROCEDURE-------------------------------

create or replace procedure SP_CALCULA_AREA_RETANGULO
	(
		pBase number,
		pAltura number,
		pArea out number
	)
	as
	begin
		pArea := pBase * pAltura;
	end;

create or replace procedure SP_CALCULA_AREA
	as
	vArea number;
	begin
		SP_CALCULA_AREA_RETANGULO(2, 4, vArea);
		DBMS_OUTPUT.PUT_LINE('A área da figura é: ' || vArea);

	end

--Da pra chamar a procedure com EXEC SP_CALCULA_AREA

	declare
		begin

			SP_CALCULA_AREA();
			
		end;

--------------------------COMANDO SQL DINAMICO----------------------------------------------

create or replace function SP_CRIA_TABELA
	as
	VNOME_ATRIBUTO VARCHAR2(30);
	VCOMANDO VARCHAR2(200);
	VPRIMEIRO_ATRIBUTO BOOLEAN := true;
	CURSOR cEditora is
		select
			replace(E.Descricao,' ', '_')
		from tb_editora E;

	begin
		open cEditora;
		VCOMANDO := 'CREATE TABLE TB_TESTE ( ';
		loop
			fetch cEditora into VNOME_ATRIBUTO;
			exit when cEditora%NOTFOUND;
			if VPRIMEIRO_ATRIBUTO then
				VPRIMEIRO_ATRIBUTO := false;
			else
				VCOMANDO := VCOMANDO || ' , ';
			end if;
			VCOMANDO := VCOMANDO || VNOME_ATRIBUTO || ' varchar2(10)';
		end loop;
		close cEditora;
		VCOMANDO := VCOMANDO || ' )';
		DBMS_OUTPUT.PUT_LINE('comando: || VCOMANDO');
		EXECUTE IMMEDIATE VCOMANDO;
	end;


-------------------------CRIANDO UMA TRIGGER----------------------------------------

create or replace trigger TR_LOG_AUTOR
before insert
on tb_autor

begin
	insert into tb_log values (SQ_LOG.NEXTVAL,USER, SYSDATE,'Inserção de um autor');
end;

-----------------------CRIANDO UMA TRIGGER DMI--------------------------------------

create or replace trigger TR_MENOR_16_ANOS
before insert or update
on TB_AUTOR
for each row
declare vidade INT;
begin
	vIdade := extract (YEAR FROM SYSDATE) - extract (YEAR FROM: NEW.Data_Nascimento);
	if (vIdade = 16) then
		if (
		    extract (MONTH FROM SYSDATE) > extract (MONTH FROM: NEW.Data_Nascimento)
		   ) then
		   	vIdade := vIdade - 1;
		end if;
	end if;
	
	if (vIdade < 16) then
		RAISE_APPLICATION_ERROR(-20301, 'Autor não pode ter menos de 16 anos');
	end if;
end;

----------------------CRIANDO TRIGGER GENÉRICA PARA UMA TABELA------------------------
--Não é possível fazer um trigger para todas as tabelas por conta de ele trabalhar com as variáveis da própria tabela

create or replace trigger TB_LOG_EDITORA
after delete or insert or update
on TB_EDITORA
for each row

declare vOperacao varchar2(100);

begin 
    if inserting then
        vOperacao := 'NOVA EDITORA - ' || :NEW.DESCRICAO;
    else
        if deleting then
            vOperacao := 'EDITORA EXCLUÍDA - ' || :OLD.DESCRICAO;
        else
            if updating('ENDERECO') then
                vOperacao := 'ENDEREÇO ALTERADO - ' || :NEW.ENDERECO || ' - ' || :OLD.ENDERECO;
            else
                vOperacao := 'EDITORA ALTERADA - ' || :NEW.DESCRICAO || ' - ' || :OLD.DESCRICAO;
            end if;
        end if;
    end if;
    
    insert into tb_log values (SQ_LOG.NEXTVAL, USER, SYSDATE, vOperacao);
end;
