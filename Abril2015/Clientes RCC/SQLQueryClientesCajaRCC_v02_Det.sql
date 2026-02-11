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
	INTO #TMPCLIHYO	 -- DROP TABLE  #TMPCLIHYO	
FROM [dbo].[URIRCCSAL808] B (NOLOCK)
		INNER JOIN @detcta C ON LEFT(B.Cctacon, 4) = C.ccodcta COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE RTRIM(CCODEMP) = '00107' --AND B.CCALEMP = '0' 
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
			select * from #TMP_caja --

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

/*
----------------************************************
					--CREANDO BASE DE DATOS		
		SELECT * into #BD01 FROM  ( Select * from #TMPCLIHYO ) AS Tmp01
		SELECT * FROM #BD01 --(193,744 row(s) affected)
		--DELETE FROM #BD01
		--drop table #BD01

		SELECT * into #BD02 FROM  ( SELECT TOP 1 * FROM #TMPCLIHYO) AS Tmp02
		SELECT * FROM #BD02
		DELETE FROM #BD02

		SELECT * into #BD03 FROM  ( SELECT TOP 1 * FROM #TMPCLIHYO) AS Tmp03
		SELECT * FROM #BD03
		DELETE FROM #BD03
		
				Select CCODSBS, CCODEMP , CCTACON --, len(CCTACON)
				from #TMPRCC (NOLOCK)--order by CODIGO_CLIENTE
				where CCODSBS = '0000063533' 
						--and CCODEMP <> '00107'
			--(7 row(s) affected)		


 	-----------------------------------------
			--CURSOR 
			Declare @ccodsbs char(10), @ccodemp char (5), @cctacon char (14)
			--set @ccodsbs = '0000057045'  -- 0000036021 00169 0000057045 00145, 00107, 00002, 00237
			--0000078824 00002
			--set @ccodemp = '00237'--'00006' --00107
			--set @cctacon = '14110306090000'--'14110302020000'--14110302010000 14110302020000
						--'14110302020000' --14110302010000, 14110306030000
			Declare cCliSbs CURSOR FOR
				--/*
				Select CCODSBS, CCODEMP , CCTACON 
				from #TMPRCC08 (NOLOCK) order by CCODSBS
				--where CCODSBS = @ccodsbs and CCODEMP = @ccodemp and CCTACON = @cctacon
				--*/
			OPEN cCliSbs
			FETCH cCliSbs into @ccodsbs, @ccodemp, @cctacon
			WHILE (@@FETCH_STATUS=0)
			BEGIN
				--cliente exclusivos 	
				/*
				if @ccodemp = '00107'
					begin 					

						INSERT INTO #BD01 
							 SELECT * FROM #TMPCLITOT where CCODSBS = @ccodsbs and CCODEMP = @ccodemp
					end
					*/
					--clientes compartidos con la Caja
				if EXISTS (Select * from #BD01 where CCODSBS = @ccodsbs ) and @ccodemp <> '00107'
						begin 
							INSERT INTO #BD02
								SELECT * FROM #TMPRCC08 where CCODSBS = @ccodsbs and CCODEMP = @ccodemp
																and CCTACON = @cctacon
						end
						--clientes externos
						else if not EXISTS (Select * from #BD01 where CCODSBS = @ccodsbs ) 
													and  @ccodemp <> '00107'
						begin 
							INSERT INTO #BD03
								SELECT * FROM #TMPRCC08 where CCODSBS = @ccodsbs and CCODEMP = @ccodemp
																and CCTACON = @cctacon
						end 		
								
			FETCH cCliSbs INTO @ccodsbs, @ccodemp, @cctacon
			END
			CLOSE cCliSbs
			DEALLOCATE cCliSbs

 -----******************verificando
		select * from #BD01 order by ccodsbs
		select * from #BD02 order by ccodsbs
		select * from #BD03 order by ccodsbs

		--delete from #BD01
		delete from #BD02
		delete from #BD03
 ---************************

/*

------***********************************************************
SELECT  B.CCALEMP  
FROM [URIRCCSAL808] B  (NOLOCK)
group by B.CCALEMP  
--select * from #TMPRCC

SELECT TOP 5 * 
FROM [GENCODSBSEMPSISFIN] C (NOLOCK)

SELECT  * 
FROM [GENCODSBSEMPSISFIN] C (NOLOCK)
WHERE RTRIM(cConEmpSisFin) = 'En operacion'
ORDER BY ccodempsisfin

/*
SELECT TOP 5 *  FROM [URIRCCMAE808] A WHERE CNUDOCI ='43111949'
SELECT TOP 5 *  FROM [URIRCCSAL808] B WHERE CCODSBS = '0029088543'
*/
		--'0029088543' '0135970450'
		 --'0095740049'--'0076639469'

/*
SELECT * FROM #TMPCLIHYO --(193,744 row(s) affected)
		Select CCODEMP FROM #TMPCLIHYO group by CCODEMP
SELECT * FROM #TMPRCC    --(384,707 row(s) affected) con INNER JOIN #TMPCLIHYO
		SELECT CCODEMP FROM #TMPRCC group by CCODEMP
		SELECT DISTINCT CCODSBS, CTIPREG, CCODEMP, CTIPCRE, CCTACON, NCONDIA, NSALDOS, CCALEMP 
		FROM #TMPRCC --(360,994 row(s) affected)
		
SELECT * FROM #TMPRCC 	 --(13,828,998 row(s) affected) sin INNER JOIN #TMPCLIHYO
		
*/

--Clientes de otras instituciones
SELECT CCODSBS , CTIPREG, CCODEMP, CTIPCRE, CCTACON, NCONDIA, NSALDOS, CCALEMP
INTO #TMPCLIOTRAS01 --Drop table #TMPCLIOTRAS01
FROM #TMPRCC
WHERE RTRIM(CCODEMP) != '00107'
ORDER BY CCODSBS, CTIPCRE

select * from #TMPCLIOTRAS01 --(13,635,254 row(s) affected) sin con INNER JOIN #TMPCLIHYO
select * from #TMPCLIOTRAS01 --( 175,587 row(s) affected) con INNER JOIN #TMPCLIHYO
		select CCODEMP from #TMPCLIOTRAS01 group by CCODEMP
--#TMPCLIHYO + #TMPRCC = 	 --(13828998 sin con INNER JOIN #TMPCLIHYO
--#TMPCLIHYO + #TMPRCC = --con INNER JOIN #TMPCLIHYO

--Clientes CMACHYO -
SELECT DISTINCT 
		CCODSBS , CTIPREG, CCODEMP, CTIPCRE, CCTACON, NCONDIA, NSALDOS, CCALEMP
INTO #TMPCLICMAC -- Drop table #TMPCLICMAC
FROM #TMPRCC
WHERE CCODSBS NOT IN (SELECT DISTINCT 
							CCODSBS FROM #TMPCLIOTRAS01)
ORDER BY CCODSBS

Select * from #TMPCLICMAC order by CCODSBS --( 99,453 row(s) affected) con y sin con INNER JOIN #TMPCLIHYO					           
Select CCODEMP from #TMPCLICMAC group by CCODEMP

--Clientes otras ifis y la caja, que no son exclusivos
SELECT DISTINCT CCODSBS , CTIPREG, CCODEMP, CTIPCRE, CCTACON, NCONDIA, NSALDOS, CCALEMP
INTO #TMPCLIOTRAS --drop table #TMPCLIOTRAS
FROM #TMPRCC
WHERE CCODSBS NOT IN (SELECT DISTINCT CCODSBS FROM #TMPCLICMAC)
ORDER BY CCODSBS

select * from #TMPCLIOTRAS --(261,541 row(s) affected)

select * from #TMPCLIOTRAS where RTRIM(CCODEMP) = '00107' --(94,291 row(s) affected)

--Clientes compartidos
SELECT DISTINCT CCODSBS , CTIPREG, CCODEMP, CTIPCRE, CCTACON, NCONDIA, NSALDOS, CCALEMP
INTO #TMPCLICOMP --drop table #TMPCLICOMP
FROM #TMPRCC
WHERE CCODSBS NOT IN (SELECT DISTINCT CCODSBS FROM #TMPCLICMAC)
ORDER BY CCODSBS

Select * from #TMPCLICOMP --(261,541 row(s) affected)
Select * from #TMPCLICOMP where RTRIM(CCODEMP) = '00107'   -- ( 94,291 row(s) affected) solo cAJA
Select * from #TMPCLICOMP where RTRIM(CCODEMP) != '00107'  -- (167,250 row(s) affected) sIN cAJA

 -----******************
	CREATE NONCLUSTERED INDEX #TMPCLITOT_cCodSbs ON #TMPCLITOT(cCodSbs)

	Select len(CCODEMP),* from #TMPCLITOT where RTRIM(CCODEMP) != '00107'  --cAJAS Y OTRAS 
										AND CCODSBS = '0000029769'


--Total clientes
SELECT DISTINCT CCODSBS , CTIPREG, CCODEMP, CTIPCRE, CCTACON, NCONDIA, NSALDOS, CCALEMP
INTO #TMPCLITOT --Drop table #TMPCLITOT
FROM #TMPRCC ORDER BY CCODSBS, CTIPCRE

select * from #TMPCLITOT --(360,994 row(s) affected)

select CTIPCRE from #TMPCLITOT group by CTIPCRE order by CTIPCRE

--Numero de clientes exclusivos
	
	

		SELECT CTIPCRE, COUNT(*) AS nCliExclu
		INTO #TMPCLICMAC1 -- drop table #TMPCLICMAC1
		FROM #TMPCLICMAC
		GROUP BY CTIPCRE ORDER BY CTIPCRE

select * from #TMPCLICMAC
select CTIPCRE from #TMPCLICMAC group by CTIPCRE


--Numero de clientes compartidos
SELECT CTIPCRE, COUNT(*) AS nCliComp
INTO #TMPCLIOTRAS1 -- drop table #TMPCLIOTRAS1
FROM #TMPCLIOTRAS
GROUP BY CTIPCRE ORDER BY CTIPCRE

--Total clientes
SELECT CTIPCRE, COUNT(*) AS TOTCLI
INTO #TMPCLITOT1 -- Drop table #TMPCLITOT1
FROM #TMPCLITOT
GROUP BY CTIPCRE ORDER BY CTIPCRE

*/