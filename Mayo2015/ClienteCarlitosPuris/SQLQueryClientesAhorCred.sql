select * from TabCli

--drop table TabCli
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX TabCli_ccodcliente_IXN ON TabCli(ccodcliente)
CREATE NONCLUSTERED INDEX TabCli_cNroDocIde_IXN ON TabCli(cNroDocIde)
CREATE NONCLUSTERED INDEX TabCli_cCodSbs_IXN ON TabCli(cCodSbs)
--------------------****************************************************************************
--delete from tabcli where ccodcliente is null
--Se añada la calificación del cliente y el nombe de la institución en la que presenta deuda. 

alter table TabCli
add calificacionSBS int

alter table TabCli
add NombreEnt varchar(50)

alter table TabCli
add cCodOficin varchar(3)

alter table TabCli
add Deuda money

select cDesOficin,cCodOficin from TabCli
group by cDesOficin,cCodOficin

	--CURSOR COMPLETANDO CODIGO agencia
		Declare @codofi char(3), @desofi varchar(100) 
		Declare cCursor80 CURSOR FOR
			select cDesOficin from TabCli
			group by cDesOficin
		OPEN cCursor80
		FETCH cCursor80 into @desofi
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		  set @codofi = ( Select cCodOficin
						   From [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENTOficinas]  
						   Where cDesOficin = @desofi 
						   )				  

		  Update TabCli 			 										
		  Set cCodOficin = @codofi
		  where cDesOficin = @desofi		  

		FETCH cCursor80 INTO @desofi
		END
		CLOSE cCursor80
		DEALLOCATE cCursor80
------------------------------------------------------------------------------------

select * from TabCli where cCodSbs =''  --(86,294 row(s) affected)
select * from TabCli where cCodSbs =' '     --(86,294 row(s) affected)
select * from TabCli where cCodSbs is null  --(14,569 row(s) affected)

--delete  from TabCli where ccodcliente is null

--------------------------FILTRANDO LA DATA----------------------------------------
--select * from ResulSBS
--drop table ResulSBS
--select * from completosbs
--drop table completosbs
select * from dnisbs --(262267 row(s) affected)

select * from dnisbs where cCodSbs !='' --(159253 row(s) affected)
select len(cCodSbs) from dnisbs where cCodSbs !='' --(159253 row(s) affected)

select * from dnisbs where cCodSbs =' ' --(103014 row(s) affected)
select * from dnisbs where cCodSbs ='' --(103014 row(s) affected)

Update dnisbs
Set cCodSbs = ''
Where cCodSbs is null
--2436
	
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX ResulSBS_ccodsbs_IXN ON ResulSBS(ccodsbs)
CREATE NONCLUSTERED INDEX completosbs_ccodsbs_IXN ON completosbs(ccodsbs)

CREATE NONCLUSTERED INDEX dnisbs_cCodCliente_IXN ON dnisbs(cCodCliente)
CREATE NONCLUSTERED INDEX dnisbs_cNroDocIde_IXN ON dnisbs(cNroDocIde)
CREATE NONCLUSTERED INDEX dnisbs_cCodSbs_IXN ON dnisbs(cCodSbs)
--------------------****************************************************************************

	--CURSOR COMPLETAR CODIGOS SBS 
		Declare @ccodcliente varchar(12), @codsbs varchar(12) 
		Declare cCursor80 CURSOR FOR
			select ccodcliente from TabCli GROUP BY cCodSbs,ccodcliente 
			HAVING LEN(cCodSbs) < 10
			--select ccodcliente from TabCli where cCodSbs IS NULL
			--cCodSbs = 'NULL'
			--cCodSbs is null or cCodSbs ='' 			
		OPEN cCursor80
		FETCH cCursor80 into @ccodcliente
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		
		  set @codsbs = rtrim(( Select cCodSbs
						   From dnisbs 
						   Where cCodCliente = @ccodcliente 
						   and cCodSbs !='' 
						   ))				   			  
		  if @codsbs is not null or @codsbs != '' 
			begin 
				--print @codsbs + space(2) + @ccodcliente	  		   
			  
			  Update TabCli 			 										
			  Set cCodSbs =  @codsbs
			  where ccodcliente = @ccodcliente		  
			  
			end
			/*
		  else 
			begin 
			print 'No Existe'	
			end   	
			*/
		FETCH cCursor80 INTO @ccodcliente
		END
		CLOSE cCursor80
		DEALLOCATE cCursor80
		
------------------------------------------------------------------------------------
select LEN(cCodSbs),cCodSbs,* 
from TabCli 
where --cCodSbs is not null or cCodSbs !='' or cCodSbs = 'NULL' AND 
	 --ccodcliente ='107013102880' OR 
	 cCodSbs = 'NULL' 
		--(2,123 row(s) affected) ANTES DEL CURSOR
		--(2,108 row(s) affected) DESPUES DEL CURSOR

	UPDATE TabCli
	SET cCodSbs = ''
	WHERE cCodSbs = 'NULL' 
            
	--(247,698 row(s) affected) Antes del cursor
	--(247698 row(s) affected) Despues del cursor


select * from TabCli where cCodSbs is null
	--(14,569 row(s) affected) 
select * from TabCli where cCodSbs is null or cCodSbs =''      
	--(100,863 row(s) affected) Antes del cursor
	--(100,414 row(s) affected) Despues del cursor

select LEN(cCodSbs),cCodSbs,* from TabCli where cCodSbs is null 
select LEN(cCodSbs),cCodSbs,* from TabCli where cCodSbs =''  

---NUEVAS CONDICIONES
	select LEN(cCodSbs),cCodSbs,* from TabCli where cCodSbs =''  
	select LEN(cCodSbs),cCodSbs,* from TabCli where cCodSbs !='' 
		select LEN(cCodSbs),cCodSbs from TabCli GROUP BY cCodSbs HAVING LEN(cCodSbs) < 10
		select cCodSbs,ccodcliente from TabCli GROUP BY cCodSbs,ccodcliente 
		HAVING LEN(cCodSbs) < 10
		
		select ccodcliente from TabCli GROUP BY cCodSbs,ccodcliente 
		HAVING LEN(cCodSbs) < 10
		--WHERE LEN(cCodSbs) < 10
				--(87,971 row(s) affected) ANTES DEL CURSOR
		
		---------UPDATE NULL Y VACIOS-----------
		UPDATE TabCli
		SET cCodSbs = 'NO_REGISTRA'
		WHERE LEN(cCodSbs) < 10

		UPDATE TabCli
		SET cCodSbs = 'NO_REGISTRA'
		WHERE cCodSbs IS NULL
	--SOLO CON CODIGO SBS
	SELECT * from TabCli where cCodSbs !='NO_REGISTRA'  --(159,727 row(s) affected)
	SELECT * from TabCli where cCodSbs  ='NO_REGISTRA'  --(102,540 row(s) affected)
	SELECT * from TabCli								--(262,267 row(s) affected)

--------------------------A.cCodSbs !='NO_REGISTRA'------------------------------------------------------

SELECT * from TabCli where cCodSbs !='NO_REGISTRA'
SELECT * FROM [datasbs] B

	Select A.* ,B.CCODSBS, B.CCODEMP, B.NSALDOS AS 'DEUDA'
			,CASE B.CCALEMP
			 WHEN '0' THEN 'NORMAL'
			 WHEN '1' THEN 'CPP'
			 WHEN '2' THEN 'DEFICIENTE'
			 WHEN '3' THEN 'DUDOSO'
			 WHEN '4' THEN 'PERDIDA'
			 END AS 'CALIFICACION'
			,B.ccodempsisfin, B.cNomEmpSisFin
	from [TabCli]	A
		inner join [datasbs] B
			ON B.CCODSBS = A.cCodSbs
	where A.cCodSbs !='NO_REGISTRA' 
		and cCodOficin in ('059','060','061','062','063','064','065','066','067','068','069','070'
		,'071','072','073','074','075','076','077','078','079','080','081','082')
	ORDER BY A.ccodcliente

---------------------- A.cCodSbs ='NO_REGISTRA' ----------------------------------------------------------
	Select A.* ,'NO_REGISTRA' AS CCODSBS, 'NO_REGISTRA' AS CCODEMP, 'NO_REGISTRA' AS NSALDOS
			,CASE B.CCALEMP
			 WHEN '0' THEN 'NORMAL'
			 WHEN '1' THEN 'CPP'
			 WHEN '2' THEN 'DEFICIENTE'
			 WHEN '3' THEN 'DUDOSO'
			 WHEN '4' THEN 'PERDIDA'
			 ELSE 'NO_REGISTRA'
			 END AS 'CALIFICACION'
			,'NO_REGISTRA' AS ccodempsisfin, 'NO_REGISTRA' AS cNomEmpSisFin
	from [TabCli]	A
		left join [datasbs] B
			ON B.CCODSBS = A.cCodSbs
	where A.cCodSbs ='NO_REGISTRA' 
		and cCodOficin in ('068','069','070','071','072','073','074','075','076','077'
		,'078','079','080','081','082')
	ORDER BY A.ccodcliente