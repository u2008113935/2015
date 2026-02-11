select * from limasur
--drop table limasur
select len(COD_SBS1) from limasur

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX limasur_CODIGO_CLIENTE_IXN ON limasur(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX limasur_COD_SBS1_IXN ON limasur(COD_SBS1)
CREATE NONCLUSTERED INDEX limasur_CODIGO_CREDITO_IXN ON limasur(CODIGO_CREDITO)
--------------------****************************************************************************

select A.CMESPRO, A.CCODSBS, A.CNUDOCI, A.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_FEB15] A (NOLOCK)
where A.ccodsbs = '0086863359'

select B.CMESPRO,B.CCODSBS,B.CNUDOCI,B.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_ENE15] B (NOLOCK)
where B.ccodsbs = '0086863359'

select C.CMESPRO,C.CCODSBS,C.CNUDOCI,C.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_DIC14] C (NOLOCK)
where C.ccodsbs = '0086863359'

select D.CMESPRO,D.CCODSBS,D.CNUDOCI,D.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_NOV14] D (NOLOCK)
where D.ccodsbs = '0086863359'

select E.CMESPRO,E.CCODSBS,E.CNUDOCI,E.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_OCT14] E (NOLOCK)
where E.ccodsbs = '0086863359'

select F.CMESPRO,F.CCODSBS,F.CNUDOCI,F.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_SET14] F (NOLOCK)
where F.ccodsbs = '0086863359'


Select AA.CMESPRO, AA.CCODSBS, AA.CNUDOCI, AA.CCLAFIN 
from HYO00410.URIESGOS.dbo.[URIRCCMAE808_MAR15] AA (NOLOCK)
where AA.ccodsbs = '0086863359'

	---alter table a Lima por req de la Jefatura Regional
	Alter Table limasur
	add RCC_MAR2015 char(20)	
	
	select * from LIMASUR

-------------------CURSOR-------------------------------------------------
	Declare @ccodsbs1 varchar(10), @mar2015 char(12), @feb2015 char(12) , @ene2015 char(12)
		, @dic2014 char(12), @nov2014 char(12), @oct2014  char(12), @set2014 char(12)
		Declare cClienteRCC CURSOR FOR					
			select COD_SBS1 from limasur (NOLOCK) 
					
		OPEN cClienteRCC
		FETCH cClienteRCC into @ccodsbs1
		WHILE (@@FETCH_STATUS=0)
		BEGIN		
	--MAR2015
	set @mar2015 = 
		(select AA.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_MAR15] AA  (NOLOCK)
		where AA.ccodsbs =  @ccodsbs1 ) 										
								Update limasur
								Set RCC_MAR2015 = @mar2015
								WHERE COD_SBS1 = @ccodsbs1
	/*
	--FEB2015
	set @feb2015 = 
		(select A.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_FEB15] A (NOLOCK)
		where A.ccodsbs =  @ccodsbs1 ) 										
								Update limasur
								Set RCC_FEB2015 = @feb2015
								WHERE COD_SBS1 = @ccodsbs1
	--ENE2015
	set @ene2015 = 
			(select B.CCLAFIN 
			from HYO00410.URIESGOS.dbo.[URIRCCMAE808_ENE15] B (NOLOCK)
			where B.ccodsbs = @ccodsbs1 ) 						
					Update limasur
								Set RCC_ENE2015 = @ene2015
								WHERE COD_SBS1 = @ccodsbs1									
	--DIC2014
	set @dic2014 = 
		(select C.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_DIC14] C (NOLOCK)
		where C.ccodsbs = @ccodsbs1 ) 			
								Update limasur
								Set RCC_DIC2014 = @dic2014
								WHERE COD_SBS1 = @ccodsbs1		
	--NOV2014
	set @nov2014 = 
		(select D.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_NOV14] D (NOLOCK)
		where D.ccodsbs = @ccodsbs1 ) 											
								Update limasur
								Set RCC_NOV2014 = @nov2014
								WHERE COD_SBS1 = @ccodsbs1							
	--OCT2014
	set @oct2014 = 
		(select E.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_OCT14] E (NOLOCK)
		where E.ccodsbs = @ccodsbs1 ) 				
								Update limasur
								Set RCC_OCT2014 = @oct2014
								WHERE COD_SBS1 = @ccodsbs1				
	--SET2014
	set @set2014 = 
		(select F.CCLAFIN 
		from HYO00410.URIESGOS.dbo.[URIRCCMAE808_SET14] F (NOLOCK)
		where F.ccodsbs = @ccodsbs1) 									
								Update limasur
								Set RCC_SET2014 = @set2014
								WHERE COD_SBS1 = @ccodsbs1					
		*/			
			FETCH cClienteRCC INTO @ccodsbs1
			END
			CLOSE cClienteRCC
			DEALLOCATE cClienteRCC			

------------------------------------------------------------------------------------------------

	--Se detecto duplicados 64 registros
	select * from LIMASUR order by CODIGO_CLIENTE

	select CODIGO_CLIENTE,COUNT(CODIGO_CLIENTE)
	from LIMASUR 
	GROUP by CODIGO_CLIENTE
	HAVING COUNT(CODIGO_CLIENTE) > 1

	SELECT * into #a FROM  (
	select DISTINCT (CODIGO_CREDITO) as 'cCodCred', * 
	from LIMASUR WHERE CODIGO_CLIENTE = '107013950898'	
	) as tmp70
	select * from #a	
	alter table #a
	drop column cCodCred

	SELECT * into #b FROM  (
	select DISTINCT (CODIGO_CREDITO) as 'cCodCred', * 
	from LIMASUR WHERE CODIGO_CLIENTE = '107015133224'
	) as tmp68
	select * from #b	
	alter table #b
	drop column cCodCred

	SELECT * into #c FROM  (
	select DISTINCT (CODIGO_CREDITO) as 'cCodCred', * 
	from LIMASUR WHERE CODIGO_CLIENTE = '107017311211'
	) as tmp67
	select * from #c	
	alter table #c
	drop column cCodCred
	
	SELECT * into #d FROM  (
	select DISTINCT (CODIGO_CREDITO) as 'cCodCred', * 
	from LIMASUR WHERE CODIGO_CLIENTE = '107019137329'
	) as tmp66
	select * from #d	
	alter table #d
	drop column cCodCred

	SELECT * into #e FROM  (
	select DISTINCT (CODIGO_CREDITO) as 'cCodCred', * 
	from LIMASUR WHERE CODIGO_CLIENTE = '107021040082'	
	) as tmp65
	select * from #e	
	alter table #e
	drop column cCodCred

	--Eliminando los 64 duplicados
	Delete  from LIMASUR where CODIGO_CLIENTE = '107013950898'
	Delete  from LIMASUR where CODIGO_CLIENTE = '107015133224'
	Delete  from LIMASUR where CODIGO_CLIENTE = '107017311211'
	Delete  from LIMASUR where CODIGO_CLIENTE = '107019137329'
	Delete  from LIMASUR where CODIGO_CLIENTE = '107021040082'

	--Insertando los nuevos registros
	--insert into LIMASUR
	--select * from #a	
	--select * from #b	
	--select * from #c
	--select * from #d	
	--select * from #e	

	select CODIGO_CREDITO,COUNT(CODIGO_CREDITO)
	from LIMASUR 
	GROUP by CODIGO_CREDITO
	HAVING COUNT(CODIGO_CREDITO) > 1


	SELECT * into LIMASURV01 FROM  (
	Select A.*
		,SOLI.cCodUsuAna AS 'COD_ANALISTA_ORIGEN'
		,SP1.cNomPerson AS 'NOMBRE_ANALISTA_ORIGEN'
	from LIMASUR A (NOLOCK)
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] B 
			on B.cCodCtaCre  COLLATE SQL_Latin1_General_CP1_CI_AS	=
				A.CODIGO_CREDITO
			--ANALISTA ORIGEN
		 INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[kpymsolicitud] SOLI	
			ON SOLI.cCodSolCre = B.cCodSolCre
		 Inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP1 
				ON SP1.cCodPerson = SOLI.cCodUsuAna
	Where cEntFin <=2
	--order by A.CODIGO_CLIENTE	
	--(26,866 row(s) affected)
	--(26,866 row(s) affected)
	) as tmp64

	Select * from LIMASURV01 
	Order by CODIGO_CLIENTE
