
		/*
			 Informacion historica con 02 años de antiguedad , sobre cliente compartidos , 
			 y exclusivos por agencia , y zona , de acuerdo al RCC.			 

		*/


		
		--/////////////////////////////////////////////////////////////////
		-- Extrae el número de clientes exclusivos y compartidos 
		-- por agencias de Caja Huancayo
		--/////////////////////////////////////////////////////////////////

		--Extrae todos los saldos de los clientes de la caja y otras ifis
		DECLARE @cFecMes CHAR(6) = '201509'

		DECLARE @DETCTA TABLE
			  (ccodcta CHAR(4)COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY)

		--No incluye créditos indirectos, ni castigados
		INSERT INTO @detcta
			  VALUES
			   ('1411'),
			   ('1413'),
			   ('1414'),
			   ('1415'),
			   ('1416'),
			   ('1421'),
			   ('1423'),
			   ('1424'),
			   ('1425'),
			   ('1426')

		-- Sólo créditos vigentes en la Caja Huancayo
		SELECT DISTINCT A.CCODSBS 
		INTO #tmpTotCliCMACHYO
		FROM [HYO00410].URIESGOS.dbo.URIRCCSAL808_AGO15 A
		INNER JOIN @detcta C ON LEFT(A.Cctacon, 4) = C.ccodcta COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE CCODEMP = '00107'		



		CREATE NONCLUSTERED INDEX #tmpTotCliCMACHYO_cCodSbs ON #tmpTotCliCMACHYO(cCodSbs)

		--/////////////////////////////////////////////////
		--/////////////////////////////////////////////////
		--Extrae documento de identidad de los clientes
		  SELECT DISTINCT A.CCODSBS, A.CTIPCRE, A.CCODEMP, B.CTIPPER, B.CNUDOCI, B.CNUDOTR
		  INTO #tmpRCC01
		  FROM [HYO00410].URIESGOS.dbo.URIRCCSAL808_AGO15 A
		  INNER JOIN [HYO00410].URIESGOS.dbo.URIRCCMAE808_AGO15 B 
			ON A.CCODSBS = B.CCODSBS
		  INNER JOIN #tmpTotCliCMACHYO C 
			ON A.CCODSBS = C.CCODSBS
		  INNER JOIN @detcta D ON LEFT(A.Cctacon, 4) = D.ccodcta COLLATE SQL_Latin1_General_CP1_CI_AS

		--Extrae la oficina del crédito desde la DB de riesgos al ultimo proceso
		SELECT CNRODOCIDE, CCODOFICIN
		INTO #tmpCreOficinas
		FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
		  WHERE CCODFECMES = @cFecMes
		   AND CCODESTADO <> 'K'

		--Extrae el Número de documento
		SELECT A.CCODSBS, A.CTIPCRE, A.CCODEMP, B.CCODOFICIN AS CCODOFI
		INTO #tmpRCC02
		FROM #tmpRCC01 A 
		   LEFT JOIN #tmpCreOficinas B ON A.CNUDOCI COLLATE SQL_Latin1_General_CP1_CI_AS = B.CNRODOCIDE
		WHERE A.CTIPPER = 1
		UNION
		SELECT A.CCODSBS, A.CTIPCRE, A.CCODEMP, B.CCODOFICIN AS CCODOFI
		FROM #tmpRCC01 A
		   LEFT JOIN #tmpCreOficinas B ON A.CNUDOTR COLLATE SQL_Latin1_General_CP1_CI_AS = B.CNRODOCIDE
		WHERE A.CTIPPER IN ('2','3')

		SELECT DISTINCT * INTO #tmpRCC
		FROM #tmpRCC02

		DROP TABLE #tmpRCC02

		--/////////////////////////////////////////////////////
		--/////////////////////////////////////////////////////

		--Clientes de otras IFIs, sin considerar la Caja Huancayo
		SELECT DISTINCT CCODSBS, CCODOFI, CCODEMP --, CTIPCRE
		INTO #tmpCliIFIS
		FROM #tmpRCC
		WHERE RTRIM(CCODEMP) != '00107';

		--Clientes exclusivos de la Caja Huancayo
		SELECT DISTINCT CCODSBS, CCODOFI, CCODEMP --, CTIPCRE
		INTO #tmpCliExcCMACHYO
		FROM #tmpRCC 
		WHERE CCODSBS NOT IN (SELECT DISTINCT CCODSBS FROM #tmpCliIFIS);

		--//////////////////////////////////////////////////////
		--Total clientes
		SELECT DISTINCT CCODOFI, CCODSBS
		  INTO #tmpTotCli01
		  FROM #tmpRCC

		SELECT CCODOFI, COUNT(*) AS nTotCli
		  INTO #tmpTotCli
		  FROM #tmpTotCli01
		  GROUP BY CCODOFI
		  ORDER BY CCODOFI;
		-----------------
		-- Número de clientes exclusivos en CmacHyo
		SELECT DISTINCT CCODOFI, CCODSBS
		  INTO #tmpNroCliExc01
		  FROM #tmpCliExcCMACHYO
  
		SELECT CCODOFI, COUNT(*) AS nTotCliExc
		  INTO #tmpNroCliExc
		  FROM #tmpNroCliExc01
		  GROUP BY CCODOFI
		  ORDER BY CCODOFI;
		---------------  
		--Numero de clientes compartidos
		SELECT DISTINCT CCODOFI, CCODSBS
		  INTO #tmpNroCliNoExc01
		  FROM #tmpCliIFIS

		SELECT CCODOFI, COUNT(*) AS nTotCliNoExc
		  INTO #tmpNroCliNoExc
		  FROM #tmpNroCliNoExc01
		  GROUP BY CCODOFI
		  ORDER BY CCODOFI
  
		--//////////////////////////////////
		--Determinando total de clientes compartidos
		--Extrae el número de empresas
		SELECT CCODOFI, CCODSBS, COUNT(*) AS nNroEmp
		INTO #tmpCliCom01
		FROM #tmpCliIFIS
		GROUP BY CCODOFI, CCODSBS

		--Extrae el Número de clientes por empresa
		SELECT CCODOFI, nNroEmp, COUNT(*) AS nNroCli
		INTO #tmpCliCom02
		FROM #tmpCliCom01
		GROUP BY ccodofi, nNroEmp

		SELECT CCODOFI, SUM(CASE WHEN nNroEmp = 1 THEN nNroCli ELSE 0 END) AS UNO,
						SUM(CASE WHEN nNroEmp = 2 THEN nNroCli ELSE 0 END) AS DOS,
						SUM(CASE WHEN nNroEmp = 3 THEN nNroCli ELSE 0 END) AS TRES,
						SUM(CASE WHEN nNroEmp = 4 THEN nNroCli ELSE 0 END) AS CUATRO,
						SUM(CASE WHEN nNroEmp = 5 THEN nNroCli ELSE 0 END) AS QUINCO,
						SUM(CASE WHEN nNroEmp = 6 THEN nNroCli ELSE 0 END) AS SEIS,
						SUM(CASE WHEN nNroEmp = 7 THEN nNroCli ELSE 0 END) AS SIETE,
						SUM(CASE WHEN nNroEmp = 8 THEN nNroCli ELSE 0 END) AS OCHO,
						SUM(CASE WHEN nNroEmp = 9 THEN nNroCli ELSE 0 END) AS NUEVE,
						SUM(CASE WHEN nNroEmp = 10 THEN nNroCli ELSE 0 END) AS DIEZ
		INTO #tmpCliCom
		FROM #tmpCliCom02
		GROUP BY CCODOFI
		ORDER BY CCODOFI
		-------
		--DROP TABLE #tmpCliCom
		--Consolidados de número de clientes. Total de clientes por agencias
		SELECT 
			   ZON.nCodZona, ZON.cDesZona,
			   A.CCODOFI, E.cDesOficin,
			   ISNULL(B.nTotCliExc, 0) AS nCliExc, 
			   ISNULL(C.nTotCliNoExc, 0) AS nCloNoExc,
			   ISNULL(A.nTotCli, 0) nTotCli,
			   D.*
		   FROM #tmpTotCli A 
			 LEFT JOIN #tmpNroCliExc B ON A.CCODOFI = B.CCODOFI
			 LEFT JOIN #tmpNroCliNoExc C ON A.CCODOFI = C.CCODOFI
			 LEFT JOIN #tmpCliCom D ON A.CCODOFI = D.CCODOFI
			 inner JOIN [HYO00409\HISTORICO].SOFCMACHYO_201510.dbo.GENTOficinas E
				ON A.CCODOFI = E.cCodOficin			 
			
			 inner JOIN [HYO00409\HISTORICO].SOFCMACHYO_201510.dbo.[Gentofizonas] GOZ
				ON GOZ.cCodOficin = E.cCodOficin and GOZ.lEstZonOfi = '1'
			 inner JOIN [HYO00409\HISTORICO].SOFCMACHYO_201510.dbo.[GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona
			 
		ORDER BY ZON.nCodZona,
				A.CCODOFI			 

		----------------------------------------------------------------------------------------------
		----Elimin Tablas
		/*
				DROP TABLE #tmpTotCliCMACHYO
				DROP TABLE #tmpRCC
				DROP TABLE #tmpRCC01
				DROP TABLE #tmpCliIFIS
				DROP TABLE #tmpCliExcCMACHYO
				DROP TABLE #tmpCreOficinas
				DROP TABLE #tmpTotCli01
				DROP TABLE #tmpTotCli
				DROP TABLE #tmpNroCliExc01
				DROP TABLE #tmpNroCliExc
				DROP TABLE #tmpNroCliNoExc01
				DROP TABLE #tmpNroCliNoExc
				DROP TABLE #tmpCliCom
				DROP TABLE #tmpCliCom01
				DROP TABLE #tmpCliCom02
		*/

		-----------------------------------------------------------------
		--------------- Tablas a utilizar -------------------------------
	 
	 /*

		SELECT CCODFECMES		
		FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
		GROUP BY CCODFECMES
		ORDER BY CCODFECMES DESC


		SELECT TOP 200 *
		FROM [HYO00410].URIESGOS.dbo.URIRCCSAL808_JUL15 A
		WHERE LEFT(A.Cctacon, 4) 
			IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
			AND A.CCODEMP = '00107'
		ORDER BY A.CCODSBS


		SELECT A.CCODSBS, CANT = COUNT(A.CCODSBS)
		FROM [HYO00410].URIESGOS.dbo.URIRCCSAL808_JUL15 A
		WHERE LEFT(A.Cctacon, 4) 
			IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
			AND A.CCODEMP = '00107'
		GROUP BY A.CCODSBS
		ORDER BY COUNT(A.CCODSBS) DESC


		SELECT *
		FROM [HYO00410].URIESGOS.dbo.URIRCCSAL808_JUL15 A
		WHERE LEFT(A.Cctacon, 4) 
			IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
			AND A.CCODEMP = '00107'
			AND CCODSBS = '0121552655'
		ORDER BY A.CCODSBS


		--Extrae todos los saldos de los clientes de la caja y otras ifis
		--No incluye créditos indirectos, ni castigados
		--Sólo créditos vigentes en la Caja Huancayo

	SELECT * INTO #tab01 from ( 	
		SELECT DISTINCT A.CCODSBS 
		FROM [HYO00410].URIESGOS.dbo.URIRCCSAL808_JUL15 A
		WHERE LEFT(A.Cctacon, 4) 
			IN ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')
			AND A.CCODEMP = '00107'
			-- CCODSBS = '0121552655'
			-- ORDER BY A.CCODSBS
			) as tmp

			-- (203,301 row(s) affected)
			-- (203,301 row(s) affected)			

	-- Drop table #tab01

	CREATE NONCLUSTERED INDEX #tab01_cCodSbs ON #tab01(cCodSbs)

	--Extrae documento de identidad de los clientes
	  SELECT DISTINCT A.CCODSBS, A.CTIPCRE, A.CCODEMP, B.CTIPPER, B.CNUDOCI, B.CNUDOTR
	  -- INTO #tmpRCC01
	  FROM [HYO00410].URIESGOS.dbo.URIRCCSAL808_JUL15 A
			INNER JOIN [HYO00410].URIESGOS.dbo.URIRCCMAE808 B 
				ON A.CCODSBS = B.CCODSBS
			INNER JOIN #tmpTotCliCMACHYO C 
				ON A.CCODSBS = C.CCODSBS
			INNER JOIN @detcta D 
				ON LEFT(A.Cctacon, 4) = D.ccodcta COLLATE SQL_Latin1_General_CP1_CI_AS

	-------------------------------------------------------
	
	SELECT * -- CNRODOCIDE, CCODOFICIN
		--INTO #tmpCreOficinas
	FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
	  WHERE CCODFECMES = '201301' -- @cFecMes
	   AND CCODESTADO <> 'K'
	ORDER BY cCodCliente


	SELECT CCODFECMES		
	FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
	gROUP BY CCODFECMES 
	   -- AND CCODESTADO <> 'K'
	ORDER BY CCODFECMES 


	SELECT * -- CNRODOCIDE, CCODOFICIN
		--INTO #tmpCreOficinas
	FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
	  WHERE CCODFECMES = '200305' -- @cFecMes
	   AND CCODESTADO <> 'K'
	ORDER BY cCodCliente


	SELECT -- CCODFECMES, cCodCliente--CantClientes = COUNT(cCodCliente)		
		cCodCliente, count(cCodCliente)
	FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
	gROUP BY cCodCliente 
	   -- AND CCODESTADO <> 'K'
	ORDER BY count(cCodCliente)

	
	SELECT * 					
	FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.URIMdetcartera
	--WHERE -- CCODFECMES = '201510' -- @cFecMes
		  -- and cCodCliente = '107010991407'
		  -- AND CCODESTADO <> 'K'
	ORDER BY cCodFecMes desc

		*/