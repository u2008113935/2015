
	/*
		SELECT *
		FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
		Where cCodFecMes = '201509'
			and cCodEstado in ('F','H')
	*/

	/*
		SELECT count(distinct cCodCliente)
		FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
		Where cCodFecMes = '201509'			
			and nMonSalCre > 0
			and nMonSalTot > 0
			--and cCodNorRef = 'N'
			and cCodEstado in ('F','H')


		Select cCodEstado
		FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
		Group by cCodEstado


		Select TOP 5 *
		FRom [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
		where cCodFecMes = '201509'
			
	----------------------------------------------------------------
	
	Select * from CRICMACHYO_DIARIO.dbo.URIRCCSAL A
	Select * from CRICMACHYO_DIARIO.dbo.URIRCCMAE B 	

	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCSAL A
	WHERE CCODEMP = '00107'
		AND 
			LEFT(A.Cctacon, 4) IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
	
	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCMAE B 	

	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCMAE    -- set 2015
	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCMAE_1  -- ago 2015
	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCMAE_8  -- ENE 2015
	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCMAE_18  -- marzo 2014

	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCSAL 
	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCSAL_1
	Select TOP 5 * from CRICMACHYO_DIARIO.dbo.URIRCCSAL_18	

	-- 01
	/*
	SE TIENE LA CANTIDAD TOTAL DE CLIENTES A 
	SEPTIEMBRE 203,301, DESDE AQUI SACAMOS LOS
	EXCLUSIVOS Y NO EXCLUSIVOS
	*/
	Select COUNT(DISTINCT B.CCODSBS)
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE B
		INNER JOIN CRICMACHYO_DIARIO.dbo.URIRCCSAL A
			ON B.CCODSBS = A.CCODSBS 		
	WHERE CCODEMP = '00107'
		AND LEFT(A.Cctacon, 4) IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		-- 203,301 - (203,309-GPI)
	
	-- PROBANDO AGOSTO 2015
	Select COUNT(DISTINCT B.CCODSBS)
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE_1 B
		INNER JOIN CRICMACHYO_DIARIO.dbo.URIRCCSAL_1 A
			ON B.CCODSBS = A.CCODSBS 		
	WHERE CCODEMP = '00107'
		AND LEFT(A.Cctacon, 4) IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		-- 201,594 - (201,600-GPI) 

	-- PROBANDO JULIO 2015
	Select COUNT(DISTINCT B.CCODSBS)
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE_2 B
		INNER JOIN CRICMACHYO_DIARIO.dbo.URIRCCSAL_2 A
			ON B.CCODSBS = A.CCODSBS 		
	WHERE CCODEMP = '00107'
		AND LEFT(A.Cctacon, 4) IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		-- 198,689 - (198,696-GPI) 

	-- PROBANDO JUNIO 2015
	Select COUNT(DISTINCT B.CCODSBS)
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE_3 B
		INNER JOIN CRICMACHYO_DIARIO.dbo.URIRCCSAL_3 A
			ON B.CCODSBS = A.CCODSBS 		
	WHERE CCODEMP = '00107'
		AND LEFT(A.Cctacon, 4) IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		-- 196,986 - (196,992-GPI) 

	-- PROBANDO ENERO 2015
	Select COUNT(DISTINCT B.CCODSBS)
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE_8 B
		INNER JOIN CRICMACHYO_DIARIO.dbo.URIRCCSAL_8 A
			ON B.CCODSBS = A.CCODSBS 		
	WHERE CCODEMP = '00107'
		AND LEFT(A.Cctacon, 4) IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
		-- 184,792 - (184,797-GPI) 

	*/

	/*
	Select COUNT(DISTINCT B.CCODSBS)
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE B
		INNER JOIN CRICMACHYO_DIARIO.dbo.URIRCCSAL A
			ON B.CCODSBS = A.CCODSBS 		
	WHERE CCODEMP = '00107'
		AND 
		 LEFT(A.Cctacon, 4) 
			IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')



	Select count(distinct CCODSBS)
	From CRICMACHYO_DIARIO.dbo.URIRCCMAE B 	

		SELECT * From URIRCCMAE808 B WHERE CCODSBS IN ('0122551105','0139679237')

		SELECT TOP 50 * From URIRCCMAE808 B where CTIPPER != 1

		SELECT CTIDOTR From URIRCCMAE808 GROUP BY CTIDOTR -- 2 3
		SELECT CTIDOCI From URIRCCMAE808 GROUP BY CTIDOCI 
			CTIDOCI
				1
				2
				3
				4
				5
				9
					
					SELECT TOP 10 * From URIRCCMAE808 WHERE CTIPPER = '3'

		SELECT CTIPPER From URIRCCMAE808 GROUP BY CTIPPER


	SELECT TOP 5 * From URIRCCMAE808 B
			SELECT TOP 1 * From URIRCCMAE808 B		 -- 20150930
			SELECT TOP 1 * From URIRCCMAE808_JUN15 B -- 20150630



	SELECT TOP 5 * From URIRCCSAL808 A
			SELECT TOP 1 * From URIRCCSAL808 A      -- 20150930
			SELECT TOP 1 * From URIRCCSAL808_JUN15 A      -- 20150930

	*/


-- 01 RELACIONANDO CON LA EMPRESA

	-- Drop table #codsbs
	SELECT * INTO #codsbs FROM ( 	
		Select DISTINCT B.CCODSBS, 
		NroDoc = 
		Case B.CTIPPER 
		WHEN '1' THEN  CASE B.CNUDOCI WHEN '' THEN B.CNUDOTR ELSE B.CNUDOCI END
		WHEN '2' THEN CASE B.CNUDOTR WHEN '' THEN B.CNUDOCI ELSE B.CNUDOTR END
		WHEN '3' THEN CASE B.CNUDOTR WHEN '' THEN B.CNUDOCI ELSE B.CNUDOTR END
		END	
		,A.CCODEMP
		--,CantEnt = count(A.CCODEMP)
			   --B.CCODSBS, B.CNUDOCI, A.CCODEMP
		--From CRICMACHYO_DIARIO.dbo.URIRCCMAE808 B		
		From URIRCCMAE808 B 
		--From URIRCCMAE808_OCT15 B 
		--From URIRCCMAE808_SET15 B 
		--From URIRCCMAE808_JUN15 B 			
		--From URIRCCMAE808_MAR15 B 		
		--From URIRCCMAE808_DIC14 B 	
		--From URIRCCMAE808_SET14 B 	
		--From URIRCCMAE808_JUN14 B 	
		--From URIRCCMAE808_MAR14 B 	
			INNER JOIN URIRCCSAL808 A
			--INNER JOIN URIRCCSAL808_OCT15 A
			--INNER JOIN URIRCCSAL808_SET15 A
			--INNER JOIN URIRCCSAL808_JUN15 A
			--INNER JOIN URIRCCSAL808_MAR15 A
			--INNER JOIN URIRCCSAL808_DIC14 A
			--INNER JOIN URIRCCSAL808_SET14 A
			--INNER JOIN URIRCCSAL808_JUN14 A
			--INNER JOIN URIRCCSAL808_MAR14 A
				ON B.CCODSBS = A.CCODSBS 		
		WHERE A.CCODEMP = '00107' AND 
			LEFT(A.Cctacon, 4) 
				IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')			
		--GROUP BY B.CCODSBS, B.CTIPPER, B.CNUDOCI , B.CNUDOTR
			) as tmp

	-- Select * from #codsbs ORDER BY CCODSBS
	-- Select COUNT (DISTINCT CCODSBS) from #codsbs
		-- (212,313 row(s) affected)  -- NOV 2015
		-- (207,609 row(s) affected)  -- OCT 2015
		-- (203,301 row(s) affected)  -- SEP 2015
		-- (196,986 row(s) affected)  -- JUN 2015
		-- (188,526 row(s) affected)  -- MAR 2015
		-- (185,570 row(s) affected)  -- DIC 2014
		-- (179,497 row(s) affected)  -- SET 2014
		-- (175,319 row(s) affected)  -- JUN 2014
		-- (170,705 row(s) affected)  -- MAR 2014

	CREATE NONCLUSTERED INDEX #codsbs_cCodSbs ON #codsbs (cCodSbs)	

	/*

	SELECT * FROM #codsbs 
	WHERE NroDoc = ''

	SELECT CCODSBS,	NroDoc,	CCODEMP = count(CCODEMP)
	FROM #codsbs 
	Group by CCODSBS,	NroDoc

	SELECT CCODSBS,count(CCODSBS) FROM #codsbs group by CCODSBS having count(CCODSBS) > 1 

	SELECT * FROM #codsbs
	WHERE CCODSBS IN ('0122551105','0139679237')

	Select * From #codsbs 
	WHERE CCODSBS = '0121552655'

	Select CCODSBS, COUNT(CCODSBS)
	From #codsbs 
	gROUP bY CCODSBS
	HAVING COUNT(CCODSBS) > 1
	ORDER BY COUNT(CCODSBS) DESC

	*/

-- 02
	-- CLIENTES NO EXCLUSIVOS

		-- DROP TABLE #ClieNoExc
		SELECT * into #ClieNoExc from (
			SELECT DISTINCT A.CCODSBS,B.NroDoc ,A.CCODEMP
				-- , CantEnt = count(distinct A.CCODEMP)
				 -- A.CCODSBS , A.CCODEMP
			--FROM CRICMACHYO_DIARIO.dbo.URIRCCSAL A
			FROM URIRCCSAL808 A
			--FROM URIRCCSAL808_OCT15 A
			--FROM URIRCCSAL808_SET15 A
			--FROM URIRCCSAL808_JUN15 A
			--FROM URIRCCSAL808_MAR15 A
			--FROM URIRCCSAL808_DIC14 A
			--FROM URIRCCSAL808_SET14 A
			--FROM URIRCCSAL808_JUN14 A
			--FROM URIRCCSAL808_MAR14 A
				INNER JOIN #codsbs B
					ON A.CCODSBS = B.CCODSBS
			WHERE LEFT(A.Cctacon, 4) 
					IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')			
				AND A.CCODSBS IN (Select CCODSBS from #codsbs)
				and A.CCODEMP != '00107'
			--GROUP BY A.CCODSBS,B.NroDoc,A.CCODEMP
			--ORDER BY A.CCODSBS	
				
				-- Agregando Codigo Entidad
				-- (149,814 row(s) affected)

				-- Sin agregar Codigo Entidad
				-- (157,501 row(s) affected)  -- NOV 2015
				-- (153,131 row(s) affected)  -- OCT 2015
				-- ( 97,039 row(s) affected)  -- SEP 2015
				-- ( 94,771 row(s) affected)  -- JUN 2015
				-- ( 91,357 row(s) affected)  -- MAR 2015
				-- ( 90,638 row(s) affected)  -- DIC 2014
				-- ( 88,116 row(s) affected)  -- SET 2014
				-- ( 86,978 row(s) affected)  -- JUN 2014
				-- ( 84,559 row(s) affected)  -- MAR 2014

				) as tmp

		CREATE NONCLUSTERED INDEX #ClieNoExc_cCodSbs ON #ClieNoExc (cCodSbs)	

		/*
			Select * from #ClieNoExc Order By CCODSBS
			
			Select CCODSBS, count(CCODSBS)
			From #ClieNoExc
			group by CCODSBS
			having count(CCODSBS) > 1

		*/

--03
	-- CLIENTES EXCLUSIVOS

		-- Drop table #CliExc
		Select * into #CliExc from (
				Select A.CCODSBS, A.NroDoc, A.CCODEMP
				FROM #codsbs A					
				WHERE A.CCODSBS not in (Select CCODSBS from #ClieNoExc)
				GROUP BY A.CCODSBS, A.NroDoc, A.CCODEMP
					-- (110,470) -- NOV 2015
					-- (108,403 row(s) affected) -- OCT 2015
					-- (106,262 row(s) affected) -- SET 2015
					-- (102,215 row(s) affected) -- JUN 2015
					-- (97,169 row(s) affected)  -- MAR 2015
					-- (94,932 row(s) affected)  -- DIC 2014
					-- (91,381 row(s) affected)  -- SET 2014
					-- (88,341 row(s) affected)  -- JUN 2014
					-- (86,146 row(s) affected)  -- MAR 2014
				) as tmp		
		
		CREATE NONCLUSTERED INDEX #CliExc_cCodSbs ON #CliExc (cCodSbs)			
		
		-------------------------------------------------------------------------------------

	/*
		Select * from #ClieNoExc 
		Select * from #CliExc    
		

				Select * from #ClieNoExc
				-- where CNUDOCI is null 
				Where CNUDOCI = ''

				Select * from #CliExc    -- (106,262 row(s) affected)
		
		Select CCODSBS,count(CCODSBS)
		From #CliExc
		Group By CCODSBS
		Having count(CCODSBS) > 1
		Order by count(CCODSBS) desc


		Select CCODSBS,count(CCODSBS)
		From #ClieNoExc
		Group By CCODSBS
		Having count(CCODSBS) > 1
		Order by count(CCODSBS) desc


		SELECT TOP 500 *
		FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
		WHERE CCODFECMES = '201509'
			AND CCODESTADO <> 'K'
			AND LEN(cNroDocIde) > 8

	*/

--04
	-- TRABAJANDO CON CLIENTES EXCLUSIVOS PARA OBTENER LA AGENCIA
	
	-- DROP TABLE #tab01

	Select * into #tab01 from ( 
			SELECT 				 
				 DISTINCT 
				 A.cNroDocIde ,A.cCodCliente --,C.cCodSBS
				 ,A.cCodOficin ,B.*
			FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera A			
				INNER join #CliExc B
					on B.NroDoc COLLATE SQL_Latin1_General_CP1_CI_AS = A.cNroDocIde
			WHERE A.CCODFECMES = '201511'
			--WHERE A.CCODFECMES = '201510'
			--WHERE A.CCODFECMES = '201509'
			--WHERE A.CCODFECMES = '201506'
			--WHERE A.CCODFECMES = '201503'
			--WHERE A.CCODFECMES = '201412'
			--WHERE A.CCODFECMES = '201409'
			--WHERE A.CCODFECMES = '201406'
			--WHERE A.CCODFECMES = '201403'
				AND A.CCODESTADO <> 'K'			
			-- ORDER BY A.cNroDocIde
		) as tmp

			SELECT DISTINCT A.cCodCliente
			FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera A
				INNER JOIN #CliExc B
					ON A.cNroDocIde	COLLATE SQL_Latin1_General_CP1_CI_AS =	B.NroDoc
			WHERE A.CCODFECMES = '201511'
					AND A.cNroDocIde	COLLATE SQL_Latin1_General_CP1_CI_AS 	IN	(SELECT NroDoc FROM #CliExc)
								
			--	110,470

			SELECT * FROM #CliExc 			

			SELECT COUNT(DISTINCT (CCODSBS)) FROM #CliExc 	-- 110470		

			SELECT * FROM #tab01

			SELECT DISTINCT cCodCliente FROM #tab01		-- 110,467
			

			SELECT COUNT(DISTINCT (cCodCliente)) FROM #tab01	-- 110467
			SELECT COUNT(DISTINCT (CCODSBS)) FROM #tab01	-- 110467

			SELECT CCODSBS, COUNT ( (CCODSBS))
			FROM #CliExc
			GROUP BY CCODSBS
			HAVING COUNT ( (CCODSBS)) > 1
			ORDER BY CCODSBS ASC

			SELECT CCODSBS, COUNT ( (CCODSBS))
			FROM #tab01
			GROUP BY CCODSBS
			HAVING COUNT ( (CCODSBS)) > 1
			ORDER BY CCODSBS ASC


			/*
				SELECT * FROM #tab01 ORDER BY cCodSBS
					-- (110,787 row(s) affected)  -- NOV 2015
					-- (108,711 row(s) affected)  -- OCT 2015
					-- (106,582 row(s) affected)  -- SET 2015
					-- (102,532 row(s) affected)  -- JUN 2015
					-- (97,457 row(s) affected)   -- MAR 2015
					-- (95,223 row(s) affected)   -- DIC 2014
					-- (91,665 row(s) affected)   -- SET 2014
					-- (88,628 row(s) affected)   -- JUN 2014
					-- (86,367 row(s) affected)   -- MAR 2014

					SELECT count(distinct NroDoc) FROM #tab01 		-- 106,260	
					SELECT count(distinct cNroDocIde) FROM #tab01	-- 106,260
					SELECT count(distinct CCODSBS) FROM #tab01		-- 106,260

					Select * from #CliExc    -- (106,262 row(s) affected)

			*/

		CREATE NONCLUSTERED INDEX #tab01_cCodSbs ON #tab01 (cCodSbs)	

			/*
			-- REPETIDOS
			SELECT cCodSBS, COUNT(cCodSBS) 
			FROM #tab01 
			group BY cCodSBS
			HAVING COUNT(cCodSBS) > 1
			ORDER BY COUNT(cCodSBS) DESC

			SELECT * FROM #tab01 
			WHERE cCodSBS = '0062701382'
			ORDER BY cCodSBS

			*/												
				
			/*
				SELECT * FROM #tab01 ORDER BY cCodSBS 								

				SELECT * 
				FROM #tab01 
				WHERE cCodSBS = '0062701382'
				ORDER BY cCodSBS 								

				SELECT cCodSBS, COUNT(cCodSBS) 								
				FROM #tab01 
				GROUP BY cCodSBS 								
				HAVING COUNT(cCodSBS) > 1 								
				ORDER BY COUNT(cCodSBS) DESC							

			*/

		-- DROP TABLE #tab001
		Select * into #tab001 from (	
				SELECT cCodOficin ,cCodSBS,cNroDocIde,NroDoc 
					,CantEnt1  = case when COUNT(CCODEMP) = 1  then 1  else 0 end
					,CantEnt2  = case when COUNT(CCODEMP) = 2  then 1  else 0 end
					,CantEnt3  = case when COUNT(CCODEMP) = 3  then 1  else 0 end
					,CantEnt4  = case when COUNT(CCODEMP) = 4  then 1  else 0 end
					,CantEnt5  = case when COUNT(CCODEMP) = 5  then 1  else 0 end
					,CantEnt6  = case when COUNT(CCODEMP) = 6  then 1  else 0 end
					,CantEnt7  = case when COUNT(CCODEMP) = 7  then 1  else 0 end
					,CantEnt8  = case when COUNT(CCODEMP) = 8  then 1  else 0 end
					,CantEnt9  = case when COUNT(CCODEMP) = 9  then 1  else 0 end
					,CantEnt10 = case when COUNT(CCODEMP) = 10 then 1  else 0 end
				FROM #tab01
				--WHERE cCodSBS = '0052559570' --'0099724943' '0091946971' -- '0036432705'
				GROUP BY cCodOficin ,cCodSBS,cNroDocIde,NroDoc
				--ORDER BY cCodOficin ,cCodSBS
				) as TMP

			CREATE NONCLUSTERED INDEX #tab001_cCodSbs ON #tab001 (cCodSbs)						
					
			/*
				SELECT * FROM #tab022
				ORDER BY cCodOficin ,cCodSBS
			*/

		-- DROP TABLE #tab011
		SELECT * into #tab011 from  (
			SELECT CodOficina = cCodOficin,	CantCliExc = COUNT(cCodSBS) 
				 ,CantEnt1  = SUM(CantEnt1),		CantEnt2 = SUM(CantEnt2),		CantEnt3 =  SUM(CantEnt3)
				 ,CantEnt4  = SUM(CantEnt4),	    CantEnt5 = SUM(CantEnt5),		CantEnt6 =  SUM(CantEnt6)
				 ,CantEnt7  = SUM(CantEnt7), 		CantEnt8 = SUM(CantEnt8),	    CantEnt9 =  SUM(CantEnt9)
				 ,CantEnt10 = SUM(CantEnt10)	 
			FROM #tab001
			GROUP BY cCodOficin
			--ORDER BY cCodOficin
			) AS TMP


		-- 04.1 -- NO SE CONSIDERA PORQUE ESTA LA CANTIDAD DE ENTIDADES
		-- AGRUPANDO POR AGENCIA CLIENTES EXCLUSIVOS				
	/*
		SELECT * into #tab011 from  (
			SELECT CodOficina = cCodOficin, CantCliExc = COUNT(NroDoc)
				,CantEntUno = COUNT(CCODEMP)
			FROM #tab01 
			GROUP BY cCodOficin
			--ORDER BY cCodOficin
			) as tmp
	*/
		-- Select * from #tab011 Order By CodOficina
			
--05
	-- TRABAJANDO CON CLIENTES NO EXCLUSIVOS PARA OBTENER LA AGENCIA
	
	-- DROP TABLE #tab02

	Select * into #tab02 from ( 
			SELECT 				 
				 DISTINCT 
				 A.cNroDocIde  --,C.cCodSBS
				 ,A.cCodOficin ,B.*			
			FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera A			
				INNER join #ClieNoExc B
					on B.NroDoc COLLATE SQL_Latin1_General_CP1_CI_AS = A.cNroDocIde
			WHERE A.CCODFECMES = '201511'
			--WHERE A.CCODFECMES = '201509'
			--WHERE A.CCODFECMES = '201506'
			--WHERE A.CCODFECMES = '201503'
			--WHERE A.CCODFECMES = '201412'
			--WHERE A.CCODFECMES = '201409'
			--WHERE A.CCODFECMES = '201406'
			--WHERE A.CCODFECMES = '201403'
				AND A.CCODESTADO <> 'K'	
				--AND B.cCodSBS = '0099724943' -- '0052559570'		
			-- ORDER BY A.cNroDocIde				
		) as tmp

			/*
				SELECT * FROM #tab02 ORDER BY cCodSBS
					-- CON CAMPO ENTIDAD
					-- (150,515 row(s) affected)

					-- SIN CAMPO ENTIDAD
					-- (97,448 row(s) affected)  -- SET 2015
					-- (95,177 row(s) affected)  -- JUN 2015
					-- (91,770 row(s) affected)  -- MAR 2015
					-- (91,081 row(s) affected)  -- DIC 2014
					-- (88,510 row(s) affected)  -- SET 2014
					-- (87,385 row(s) affected)  -- JUN 2014
					-- (84,915 row(s) affected)  -- MAR 2014

				SELECT count( distinct cNroDocIde) FROM #tab02	-- 97,036
				SELECT count( distinct CCODSBS) FROM #tab02		-- 97,036
				SELECT count( distinct NroDoc) FROM #tab02		-- 97,036
				Select * from #ClieNoExc -- (97,039 row(s) affected)

			*/

		CREATE NONCLUSTERED INDEX #tab02_cCodSbs ON #tab02 (cCodSbs)			

			/*
			-- REPETIDOS
			SELECT cCodSBS, COUNT(cCodSBS) 
			FROM #tab02
			group BY cCodSBS
			HAVING COUNT(cCodSBS) > 1
			ORDER BY COUNT(cCodSBS) DESC

			SELECT * FROM #tab02 WHERE cCodSBS = '0036432705' ORDER BY cCodOficin

			*/

		-- DROP TABLE #tab002
		Select * into #tab002 from (	
				SELECT cCodOficin ,cCodSBS,cNroDocIde,NroDoc 
					,CantEnt1  = case when COUNT(CCODEMP) = 1  then 1  else 0 end
					,CantEnt2  = case when COUNT(CCODEMP) = 2  then 1  else 0 end
					,CantEnt3  = case when COUNT(CCODEMP) = 3  then 1  else 0 end
					,CantEnt4  = case when COUNT(CCODEMP) = 4  then 1  else 0 end
					,CantEnt5  = case when COUNT(CCODEMP) = 5  then 1  else 0 end
					,CantEnt6  = case when COUNT(CCODEMP) = 6  then 1  else 0 end
					,CantEnt7  = case when COUNT(CCODEMP) = 7  then 1  else 0 end
					,CantEnt8  = case when COUNT(CCODEMP) = 8  then 1  else 0 end
					,CantEnt9  = case when COUNT(CCODEMP) = 9  then 1  else 0 end
					,CantEnt10 = case when COUNT(CCODEMP) = 10 then 1  else 0 end
				FROM #tab02
				--WHERE cCodSBS = '0099724943' -- '0052559570'  -- '0091946971' -- '0036432705'
				GROUP BY cCodOficin ,cCodSBS,cNroDocIde,NroDoc
				--ORDER BY cCodOficin ,cCodSBS
				) as TMP

			CREATE NONCLUSTERED INDEX #tab002_cCodSbs ON #tab002 (cCodSbs)			
			
			-- (97,448 row(s) affected) SET 2015
			
			/*
				SELECT * FROM #tab022
				ORDER BY cCodOficin ,cCodSBS
			*/

		-- DROP TABLE #tab021
		SELECT * into #tab021 from  (
			SELECT CodOficina = cCodOficin,	CantCliNoExc = COUNT(cCodSBS) 
				 ,CantEnt1  = SUM(CantEnt1),		CantEnt2 = SUM(CantEnt2),		CantEnt3 =  SUM(CantEnt3)
				 ,CantEnt4  = SUM(CantEnt4),	    CantEnt5 = SUM(CantEnt5),		CantEnt6 =  SUM(CantEnt6)
				 ,CantEnt7  = SUM(CantEnt7), 		CantEnt8 = SUM(CantEnt8),	    CantEnt9 =  SUM(CantEnt9)
				 ,CantEnt10 = SUM(CantEnt10)	 
			FROM #tab002
			GROUP BY cCodOficin
			--ORDER BY cCodOficin
			) AS TMP

		-- 05.1 -- ANTES DE AGREGAR CANTIDAD DE ENTIDADES
			-- AGRUPANDO POR AGENCIA CLIENTES NO EXCLUSIVOS
			-- Drop table #tab021
		/*
			SELECT * into #tab021 from  (
				SELECT CodOficina = cCodOficin, CantCliNoExc = COUNT(NroDoc) 				 				
				FROM #tab02 
				GROUP BY cCodOficin,NroDoc
				--ORDER BY cCodOficin
				) as tmp
		*/
--06
	/*
		Select COUNT (DISTINCT CCODSBS) from #codsbs
				-- (207,609 row(s) affected)  NOV 2015
				-- (203,301 row(s) affected)  SEP 2015
				-- (196,986 row(s) affected)  JUN 2015
				-- (188,526 row(s) affected)  MAR 2015
				-- (185,570 row(s) affected)  DIC 2014
				-- (179,497 row(s) affected)  SET 2014
				-- (175,319 row(s) affected)  JUN 2014
				-- (170,705 row(s) affected)  MAR 2014

		Select * from #CliExc     
		Select * from #ClieNoExc  
		
		Select COUNT(DISTINCT (CCODSBS)) from #CliExc     -- 86,146
		Select COUNT(DISTINCT (CCODSBS)) from #ClieNoExc  -- 84,559		

			Select 86146 + 84559	-- 170,705

		SELECT SUM(CantCliExc) FROM #tab011    -- 86,367 
		SELECT SUM(CantCliNoExc) FROM #tab021  -- 84,915

		SELECT * FROM #tab011 ORDER BY CodOficina
		SELECT * FROM #tab021 ORDER BY CodOficina

	*/	
		-- DROP TABLE #FINAL
		SELECT * INTO #FINAL FROM ( 	
			SELECT A.CodOficina, Oficina = O.cDesOficin, A.CantCliExc, B.CantCliNoExc
					,TotalClientes = A.CantCliExc + B.CantCliNoExc
					,CantEnt1 = A.CantEnt1 + B.CantEnt1,	CantEnt2 = A.CantEnt2 + B.CantEnt2
					,CantEnt3 = A.CantEnt3 + B.CantEnt3,	CantEnt4 = A.CantEnt4 + B.CantEnt4
					,CantEnt5 = A.CantEnt5 + B.CantEnt5,	CantEnt6 = A.CantEnt6 + B.CantEnt6
					,CantEnt7 = A.CantEnt7 + B.CantEnt7,	CantEnt8 = A.CantEnt8 + B.CantEnt8
					,CantEnt9 = A.CantEnt9 + B.CantEnt9,	CantEnt10 = A.CantEnt10 + B.CantEnt10
			FROM #tab011 A 
				LEFT JOIN #tab021 B
					ON B.CodOficina = A.CodOficina
				INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201511.dbo.[GENTOficinas] O 
					ON O.cCodOficin = A.CodOficina and O.lConEstado = '1'	
			-- ORDER BY A.CodOficina
			) AS TMP
					
			SELECT * FROM #FINAL ORDER BY CodOficina


			SELECT A.* 					
				,CE  = (Select COUNT(DISTINCT (CCODSBS)) from #CliExc)     -- 86,146
				,CNE = (Select COUNT(DISTINCT (CCODSBS)) from #ClieNoExc)  -- 84,559	
				,TC  = (Select COUNT (DISTINCT CCODSBS) from #codsbs)
			FROM #FINAL A		
			ORDER BY A.CodOficina
			/*
				212325
				SELECT * FROM #CliExc
				SELECT * FROM #ClieNoExc

				Select * from #codsbs
			*/

			-- DROP TABLE #CANTENT
			SELECT * INTO #CANTENT FROM (	
					SELECT DISTINCT A.CCODSBS, B.NroDoc
						,A.CCODEMP --, C.cCodOficin --, Oficina = O.cDesOficin
						-- , CantEnt = count(distinct A.CCODEMP)
						 -- A.CCODSBS , A.CCODEMP
					--FROM CRICMACHYO_DIARIO.dbo.URIRCCSAL A
					FROM URIRCCSAL808 A
					--FROM URIRCCSAL808_SET15 A
					--FROM URIRCCSAL808_JUN15 A
					--FROM URIRCCSAL808_MAR15 A
					--FROM URIRCCSAL808_DIC14 A
					--FROM URIRCCSAL808_SET14 A
					--FROM URIRCCSAL808_JUN14 A
					--FROM URIRCCSAL808_MAR14 A
						INNER JOIN #codsbs B
							ON A.CCODSBS = B.CCODSBS
						/*
						INNER JOIN [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera C
							ON C.cNroDocIde COLLATE SQL_Latin1_General_CP1_CI_AS = B.NroDoc						
						INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201509.dbo.[GENTOficinas] O 
							ON O.cCodOficin = C.cCodOficin and O.lConEstado = '1'					
						*/
					WHERE LEFT(A.Cctacon, 4) 
							IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')			
						AND A.CCODSBS IN (Select CCODSBS from #codsbs)
						-- AND C.CCODFECMES = '201509'			
						-- AND C.CCODESTADO <> 'K'	
					-- ORDER BY A.CCODSBS
					) AS TMP
					
		/*	 
			SELECT * FROM #CANTENT	
			WHERE CCODSBS IN ('0052559570','0099724943')
			ORDER BY CCODSBS		
			-- (353,115 row(s) affected)

			SELECT 				 
				 *
				 --DISTINCT 
				 --A.cNroDocIde  ,A.cCodOficin 				 
			FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera A				
			WHERE A.CCODFECMES = '201509'			
				AND A.CCODESTADO <> 'K'	
				AND A.cNroDocIde = '42387436'

		*/

		-- DROP TABLE #CANTENT01
		SELECT * INTO #CANTENT01 FROM ( 
				SELECT DISTINCT
					A.CCODSBS, A.NroDoc, A.CCODEMP , C.cCodOficin
				FROM #CANTENT A	 
					INNER JOIN [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera C
						ON C.cNroDocIde COLLATE SQL_Latin1_General_CP1_CI_AS = A.NroDoc	
				WHERE C.CCODFECMES = '201510'			
					  AND C.CCODESTADO <> 'K'	
					  --AND A.NroDoc = '20593009'
				--ORDER BY A.CCODSBS
				) AS TMP

			/*
			
				SELECT * FROM #CANTENT01
				ORDER BY CCODSBS
					-- (354,545 row(s) affected)
			*/

			-- DROP TABLE #CANTENT001
			SELECT * INTO #CANTENT001 FROM (
					SELECT 
						cCodOficin ,CCODSBS,NroDoc
						,CantEnt1  = case when COUNT(CCODEMP) = 1  then 1  else 0 end				
						,CantEnt2  = case when COUNT(CCODEMP) = 2  then 1  else 0 end
						,CantEnt3  = case when COUNT(CCODEMP) = 3  then 1  else 0 end
						,CantEnt4  = case when COUNT(CCODEMP) = 4  then 1  else 0 end
						,CantEnt5  = case when COUNT(CCODEMP) = 5  then 1  else 0 end
						,CantEnt6  = case when COUNT(CCODEMP) = 6  then 1  else 0 end
						,CantEnt7  = case when COUNT(CCODEMP) = 7  then 1  else 0 end
						,CantEnt8  = case when COUNT(CCODEMP) = 8  then 1  else 0 end
						,CantEnt9  = case when COUNT(CCODEMP) = 9  then 1  else 0 end
						,CantEnt10 = case when COUNT(CCODEMP) = 10 then 1  else 0 end
						--,CantEnt11 = case when COUNT(CCODEMP) = 11 then 1  else 0 end
						--,CantEnt12 = case when COUNT(CCODEMP) = 12 then 1  else 0 end
						--,CantEnt13 = case when COUNT(CCODEMP) = 13 then 1  else 0 end
						--,CantEnt14 = case when COUNT(CCODEMP) = 14 then 1  else 0 end
						--,CantEnt15 = case when COUNT(CCODEMP) = 15 then 1  else 0 end
					FROM #CANTENT01			
					GROUP BY cCodOficin ,CCODSBS,NroDoc
					--ORDER BY cCodOficin ,CCODSBS,NroDoc
					) AS TMP

			-- SELECT * FROM #CANTENT001
				-- (204,030 row(s) affected) -- SIN CON EXCLUSIVOS Y NO EXCLUISIVOS	
		
			SELECT cCodOficin,CantTotalCliente1 = COUNT(CCODSBS), CantTotalCliente2 = count(NroDoc)
				 ,CantEnt1  = SUM(CantEnt1),		CantEnt2 = SUM(CantEnt2),		CantEnt3 =  SUM(CantEnt3)
				 ,CantEnt4  = SUM(CantEnt4),	    CantEnt5 = SUM(CantEnt5),		CantEnt6 =  SUM(CantEnt6)
				 ,CantEnt7  = SUM(CantEnt7), 		CantEnt8 = SUM(CantEnt8),	    CantEnt9 =  SUM(CantEnt9)
				 ,CantEnt10 = SUM(CantEnt10)		
				 /*
				 ,CantEnt11 = SUM(CantEnt11),		CantEnt12 = SUM(CantEnt12)	 		
				 ,CantEnt13 = SUM(CantEnt13),		CantEnt14 = SUM(CantEnt14),		CantEnt15 = SUM(CantEnt15)	 		
				 */
			FROM #CANTENT001
			GROUP BY cCodOficin
			ORDER BY cCodOficin

			
			SELECT CantTotalCliente1 = COUNT(CCODSBS), CantTotalCliente2 = count(NroDoc)
				 ,CantEnt1  = SUM(CantEnt1),		CantEnt2 = SUM(CantEnt2),		CantEnt3 =  SUM(CantEnt3)
				 ,CantEnt4  = SUM(CantEnt4),	    CantEnt5 = SUM(CantEnt5),		CantEnt6 =  SUM(CantEnt6)
				 ,CantEnt7  = SUM(CantEnt7), 		CantEnt8 = SUM(CantEnt8),	    CantEnt9 =  SUM(CantEnt9)
				 ,CantEnt10 = SUM(CantEnt10)	 
			FROM #CANTENT001

		--TOTAL POR NUMERO DE ENTIDAD 

			-- SELECT * FROM #CANTENT	

			SELECT * INTO #CANTENTXX1 FROM (
					SELECT 
						CCODSBS,NroDoc
						,CantEnt1  = case when COUNT(CCODEMP) = 1  then 1  else 0 end				
						,CantEnt2  = case when COUNT(CCODEMP) = 2  then 1  else 0 end
						,CantEnt3  = case when COUNT(CCODEMP) = 3  then 1  else 0 end
						,CantEnt4  = case when COUNT(CCODEMP) = 4  then 1  else 0 end
						,CantEnt5  = case when COUNT(CCODEMP) = 5  then 1  else 0 end
						,CantEnt6  = case when COUNT(CCODEMP) = 6  then 1  else 0 end
						,CantEnt7  = case when COUNT(CCODEMP) = 7  then 1  else 0 end
						,CantEnt8  = case when COUNT(CCODEMP) = 8  then 1  else 0 end
						,CantEnt9  = case when COUNT(CCODEMP) = 9  then 1  else 0 end
						,CantEnt10 = case when COUNT(CCODEMP) = 10 then 1  else 0 end				
					FROM #CANTENT			
					GROUP BY CCODSBS,NroDoc
					--ORDER BY cCodOficin ,CCODSBS,NroDoc
					) AS TMP

			-- SELECT * FROM #CANTENTXX1		
				-- (203,301 row(s) affected)	 -- CON EXCLUSIVOS Y NO EXCLUISIVOS	
		
			SELECT CantTotalCliente1 = COUNT(CCODSBS), CantTotalCliente2 = count(NroDoc)
				 ,CantEnt1  = SUM(CantEnt1),		CantEnt2 = SUM(CantEnt2),		CantEnt3 =  SUM(CantEnt3)
				 ,CantEnt4  = SUM(CantEnt4),	    CantEnt5 = SUM(CantEnt5),		CantEnt6 =  SUM(CantEnt6)
				 ,CantEnt7  = SUM(CantEnt7), 		CantEnt8 = SUM(CantEnt8),	    CantEnt9 =  SUM(CantEnt9)
				 ,CantEnt10 = SUM(CantEnt10)						
			FROM #CANTENTXX1	

			---------------------------------------------------------------------------------------

			Select count(CCODSBS) from #codsbs
			-- 207,609	 -- OCT 2015
			-- 203,301   -- SEP 2015
			-- 196,986   -- JUN 2015
			-- 188,526   -- MAR 2015
			-- 185,570   -- DIC 2014
			-- 179,497   -- SET 2014
			-- 175,319   -- JUN 2014
			-- 170,705   -- MAR 2014
		
			Select * from #codsbs
			
			Select * from #tab011 --Totales
			Select * from #tab021 --Totales
			
			Select * from #CliExc    --Detalle		
			Select * from #ClieNoExc --Detalle      				
				
	/*
			Select CCODSBS, count(CCODSBS) from #ClieNoExc  group by CCODSBS having count(CCODSBS) > 1
			Order By count(CCODSBS) desc

			Select * from #tab01  --Detalle				-- (106,582 row(s) affected)
			Select * from #tab02  order by cNroDocIde	--	Detalle			-- ( 97,448 row(s) affected)

			Select cNroDocIde, count(cNroDocIde) from #tab02  group by cNroDocIde having count(cNroDocIde)>1
			Order By count(cNroDocIde) desc

			Select * From #tab02 Where CCODSBS = '0069809901'

		
			Select top 5 * From URIRCCMAE808_SET15 B 
		
			Select A.* 
				-- , B.*
				, C.*
			From URIRCCSAL808_SET15 A 
				/*
				INNER JOIN #tab01 B
					ON B.CCODSBS = A.CCODSBS
				*/
				inner JOIN #tab02 C
					ON C.CCODSBS = A.CCODSBS				
			Where LEFT(A.Cctacon, 4) 
					IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')															
					AND A.CCODSBS = '0069809901' 		

			Select * --top 5 * 
			FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera 
			where cNroDocIde = '41261728'

			Select * from #FINAL

	*/

--07 ELIMINANDO
	
		/*
			
			Drop table #codsbs
			Drop table #tab01
			Drop table #tab011
			Drop table #tab02	
			Drop table #tab021
			Drop table #CliExc
			Drop table #ClieNoExc
			Drop table #FINAL	
			Drop table #CANTENT01
			Drop table #CANTENTXX1
			Drop table #CANTENT
			Drop table #CANTENT001						


			SELECT * FROM KPYTEstCreCon EC 

			SELECT * --TOP 5 * 
			FROM CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C
			WHERE CCODSBS = '0000029769' 

		*/

		




