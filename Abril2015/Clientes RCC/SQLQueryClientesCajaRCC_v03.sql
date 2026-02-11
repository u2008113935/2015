--USE URIESGOS
DECLARE @DETCTA TABLE
       (ccodcta CHAR(4)COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY)

--No incluye créditos indirectos, ni castigados
INSERT INTO @detcta

       VALUES
       ('1411'), --Credito Microempresa Soles
       ('1413'), --Credito Reestructurado Soles
       ('1414'), --Creditos Refinanciados Soles
       ('1415'), --Creditos Vencidos Soles
       ('1416'), --Cred Cobranza Judicial Soles
       ('1421'), --Credito Microempresa Dolares
       ('1423'), --Credito Reestructurado Dolares
       ('1424'), --Creditos Refinanciados Dolares
       ('1425'), --Creditos Vencidos Dolares
       ('1426')  --Cred Cobranza Judicial Dolares


SELECT DISTINCT B.CCODSBS
		, B.CTIPREG, B.CCODEMP, B.CTIPCRE, B.CCTACON, B.NCONDIA, B.NSALDOS, B.CCALEMP
  INTO #TMPRCC --DROP TABLE  #TMPRCC   
FROM [dbo].[URIRCCSAL808] B (NOLOCK) 
  --INNER JOIN #TMPCLIHYO X ON X.CCODSBS = B.CCODSBS
  inner JOIN #TMP_caja X ON X.CCODSBS = B.CCODSBS 
		--(360,994 row(s) affected) feb 2015
		--(358,809 row(s) affected) dic 2014
  INNER JOIN @detcta C ON LEFT(B.Cctacon, 4) = C.ccodcta COLLATE SQL_Latin1_General_CP1_CI_AS
where RTRIM(CCODEMP) != '00107'
	
  		
CREATE NONCLUSTERED INDEX #TMPRCC_cCodSbs ON #TMPRCC(cCodSbs)

Select *  from #TMPRCC
--(193744 row(s) affected)

Select *  from #TMPRCC --(167,250 row(s) affected)
	Select *  from #TMPRCC where CCODSBS not in (select CCODSBS from #TMP_caja)
	Select *  from #TMP_caja where CCODSBS not in (select CCODSBS from #TMPRCC)
select * from #TMP_caja --(186,491 row(s) affected)


--where RTRIM(CCODEMP) = '00107'
--where RTRIM(CCODEMP) = '00107' --(358809 row(s) affected)

----
select ccodsbs, count (ccodsbs) as 'Repetidos'
	into #tmpRepRcc --dROP TABLE #tmpRepRcc
from  #TMPRCC (NOLOCK) 		
group by ccodsbs
having count (ccodsbs) > 1	

		SELECT * FROM #tmpRepRcc		

select ccodsbs, count (ccodsbs) as 'Repetidos'
	into #tmpUniRcc --DROP TABLE #tmpUniRcc
from #TMPRCC (NOLOCK) 		
group by ccodsbs
having count (ccodsbs) = 1			

		SELECT * FROM #tmpUniRcc 

	SELECT * into #TMP_CajaRCC FROM (select top 1 CCODSBS from #tmpUniRcc ) as tmp02	
		
		delete from #TMP_CajaRCC		
		select * from #TMP_CajaRCC
		--drop table #TMP_CajaRCC
		
		insert into #TMP_CajaRCC 
			select CCODSBS from #tmpRepRcc 					

		insert into #TMP_CajaRCC 
			select CCODSBS from #tmpUniRcc 					

			--verificando
			select * from #TMP_CajaRCC 
			
					select ccodsbs, count (ccodsbs) as 'Repetidos'				
					from #TMP_CajaRCC (NOLOCK)
					group by ccodsbs
					having count (ccodsbs) = 1 
					


----***************************************************************************
DECLARE @DETCTA TABLE
       (ccodcta CHAR(4)COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY)

--No incluye créditos indirectos, ni castigados
INSERT INTO @detcta
       VALUES
       ('1411'), --Credito Microempresa Soles
       ('1413'), --Credito Reestructurado Soles
       ('1414'), --Creditos Refinanciados Soles
       ('1415'), --Creditos Vencidos Soles
       ('1416'), --Cred Cobranza Judicial Soles
       ('1421'), --Credito Microempresa Dolares
       ('1423'), --Credito Reestructurado Dolares
       ('1424'), --Creditos Refinanciados Dolares
       ('1425'), --Creditos Vencidos Dolares
       ('1426')  --Cred Cobranza Judicial Dolares

-- SOLO VIGENTES EN CMAC HYO
SELECT DISTINCT B.CCODSBS 		
		, B.CTIPREG, B.CCODEMP, B.CTIPCRE, B.CCTACON, B.NCONDIA, B.NSALDOS, B.CCALEMP	
	--INTO #TMPCLIHYO	 -- DROP TABLE  #TMPCLIHYO	
FROM [dbo].[URIRCCSAL808_DIC12] B (NOLOCK)
		INNER JOIN @detcta C ON LEFT(B.Cctacon, 4) = C.ccodcta COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE RTRIM(CCODEMP) = '00107' 
		and B.NSALDOS = 0
  -- Select * from #TMPCLIHYO order by ccodsbs
--(193,744 row(s) affected) FEB 2015
--(192,113 row(s) affected) DIC 2014

CREATE NONCLUSTERED INDEX #TMPCLIHYO_cCodSbs ON #TMPCLIHYO(cCodSbs)

---**********CONTANDO-----
select *
from #TMPCLIHYO (NOLOCK)
--where CCODSBS = '0000350575'
order by ccodsbs 
--(192113 row(s) affected)

select ccodsbs, count (ccodsbs) as 'Repetidos'
	into #tmpRep --drop table #tmpRep
FROM #TMPCLIHYO (NOLOCK) --
group by ccodsbs
having count (ccodsbs) > 1 
		
		select count(ccodsbs) from #tmpRep
		select * from #tmpRep

select ccodsbs, count (ccodsbs) as 'Repetidos'
	into #tmpUni --drop table #tmpUni
from #TMPCLIHYO (NOLOCK) --
group by ccodsbs
having count (ccodsbs) = 1 

		select count(ccodsbs) from #tmpUni
		select * from #tmpUni
				
		SELECT * into #TMP_caja FROM (select top 1 CCODSBS from #tmpUni ) as tmp01		
				
		delete from  #TMP_caja		
		SELECT * from #TMP_caja
		--drop table #TMP_caja

		insert into #TMP_caja 
			select CCODSBS from #tmpRep 

		insert into #TMP_caja 
			select CCODSBS from #tmpUni 

			--verificando
			select * from #TMP_caja 			
			--(186,491 row(s) affected) FEB_2015
			--(163,563 row(s) affected) DIC 2013
			--(185,570 row(s) affected) DIC 2014
			--(153,823 row(s) affected) DIC_2012
			--(153,823 row(s) affected)
			--(148972 row(s) affected) AGO 2012
			--(148188 row(s) affected) JULIO 2012
			--(147278 row(s) affected) junio 2012
			--(147596 row(s) affected) mayo 2012	
			--(145737 row(s) affected) ABRIL 2012
			--(144932 row(s) affected) MARZO 2012
			--(154620 row(s) affected) JULIO 2013
			--(153659 row(s) affected) JUNIO 2013
			--(154106 row(s) affected) MAYO 2013
			--(152754 row(s) affected) ABRIL 2013
			--(139054 row(s) affected)  DIC 2011
			

					select ccodsbs, count (ccodsbs) as 'Repetidos'				
					from #TMP_caja (NOLOCK)					
					group by ccodsbs
					having count (ccodsbs) = 1 					

			---------final----------------------
			select * from #TMP_caja			--
			select * from #TMP_CajaRCC      --

			--UNICOS
			select count(X.CCODSBS ) as 'Clientes_Exclusivos'
			from #TMP_caja X
			WHERE X.CCODSBS NOT IN (select Y.CCODSBS from #TMP_CajaRCC Y)

			--Compartidos
			select   --count(X.CCODSBS,)
					 COUNT (Y.CCODSBS ) AS 'Clientes_Compartidos'
			from #TMP_caja X
				inner join #TMP_CajaRCC  Y 
						on X.CCODSBS = Y.CCODSBS		
														

			--BORRANDO
			DROP TABLE  #TMPCLIHYO	
			DROP TABLE  #TMPRCC
			dROP TABLE #tmpRepRcc 
			DROP TABLE #tmpUniRcc
			drop table #TMP_CajaRCC 
			drop table #tmpRep
			drop table #tmpUni
			drop table #TMP_caja