--USE URIESGOS
/*
--SELECT * into TMPCLIRCCDES FROM  (

SELECT TOP 500000
	   --ROW_NUMBER() 
	   --OVER(PARTITION BY year(CRE.dFecDesCre)--CLI.cCodCliente 
	   --ORDER BY left(cast(CRE.dFecDesCre as date),10)) AS Secuencia,
	   --CASE  
	   --WHEN A.CTIPPER = '1' THEN 'Persona Natural'
	   --WHEN A.CTIPPER = '2' THEN 'Persona Juridica'
	   --END as TipoPersona,
	   CASE  
	   WHEN A.CTIDOTR = '3' THEN A.CNUDOTR
	   WHEN A.CTIDOCI = '1' THEN A.CNUDOCI
	   END as NroDocumento,
	   B.CCODSBS,
	   (rtrim(A.CAPEPAT) + space(2) + rtrim(A.CAPEMAT) + space(2) + rtrim(A.CAPECAS) + space (2) 
	   + rtrim(A.CPRINOM) + space(2) + rtrim(A.CSEGNOM) ) as Apellidos_Nombres_Cliente
	   --B.CCODEMP, 
	   ,B.CTIPCRE AS 'Tipo_de_Credito'-- WHEN '10' THEN 'Créditos a Microempresas' 
	   --,CASE B.CTIPCRE
	   --WHEN '01' THEN 'Créditos Soberanos' 
	   --WHEN '02' THEN 'Créditos a Entidades del Sector Público' 
	   --WHEN '03' THEN 'Créditos a Bancos Multilaterales de Desarrollo' 
	   --WHEN '04' THEN 'Créditos a Empresas del Sistema Financiero' 
	   --WHEN '05' THEN 'Créditos a Empresas de Valores' 
	   --WHEN '06' THEN 'Créditos Corporativos' 	   
	   --WHEN '07' THEN 'Créditos a Grandes Empresas' 
	   --WHEN '08' THEN 'Créditos a Medianas Empresas' 
	   --WHEN '09' THEN 'Créditos a Pequeña Empresas' 
	   --WHEN '10' THEN 'Créditos a Microempresas' 
	   --WHEN '11' THEN 'Créditos Consumo Revolventes' 
	   --WHEN '12' THEN 'Créditos Consumo No Revolventes' 
	   --WHEN '13' THEN 'Créditos Hipotecarios para Vivienda'
	   --ELSE ' '
	   --END AS 'Tipo_de_Credito',
	   --CASE  
	   --WHEN SUBSTRING(B.CCTACON,3,1) = '1' THEN 'Soles'
	   --WHEN SUBSTRING(B.CCTACON,3,1) = '2' THEN 'Dólares'
	   --END AS 'Moneda',
	   ,SUBSTRING(B.CCTACON,1,2) AS 'ESTCRE01' , SUBSTRING(B.CCTACON,4,1)  AS 'ESTCRED02' 
		--SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '1'  THEN 'Créditos Vigente'
	   --CASE  
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '1' 
	   --THEN 'Créditos Vigente'
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '3' 
	   --THEN 'Créditos Reestructurados'
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '4' 
	   --THEN 'Créditos Refinanciados'
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '5' 
	   --THEN 'Créditos Vencidos'
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '6' 
	   --THEN 'Créditos en Cobranza Judicial'
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '8' 
	   --THEN 'Rendimientos Devengados de Créditos Vigentes'
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '9' 
	   --THEN 'Provisiones para Créditos'
	   -----72
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '72' AND SUBSTRING(B.CCTACON,4,1) = '5' 
	   --THEN 'LÍNEAS DE CRÉDITO NO UTILIZADAS Y CRÉDITOS CONCEDIDOS NO DESEMBOLSADOS'
	   ----81
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '81' AND SUBSTRING(B.CCTACON,4,3) = '923' 
	   --THEN 'LÍNEAS DE CRÉDITO EN TARJETAS DE CRÉDITO DE CONSUMO'
	   ----84
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '84' AND SUBSTRING(B.CCTACON,4,3) = '409' 
	   --THEN 'OTRAS GARANTIAS NO PREFERIDAS'
	   ----84
	   --WHEN SUBSTRING(B.CCTACON,1,2) = '84' AND SUBSTRING(B.CCTACON,4,3) = '402' 
	   --THEN 'GARANTIAS PREFERIDAS'
	   --ELSE ''
	   --END AS 'Estado_del_Credito'
	   ,B.CCTACON
	   --, B.NCONDIA AS 'Dias'
	   --,B.NSALDOS AS 'Saldo' 
	   --B.CCALEMP AS 'Cod_Clasif_del_Cliente',
	   --CASE B.CCALEMP
	   --WHEN '0' THEN 'NORMAL'
	   --WHEN '1' THEN 'CPP'
	   --WHEN '2' THEN 'DEFICIENTE'
	   --WHEN '3' THEN 'DUDOSO'
	   --WHEN '4' THEN 'PERDIDA'
	   --WHEN '8' THEN 'SIN SALDOS EN LAS CUENTAS DE DEUDA DIRECTA, CONTINGENTES, CRÉDITOS CASTIGADOS'
	   --ELSE ' '
	   --END AS 'Clasificacion_del_Cliente'
	   ,B.CCALEMP AS 'Clasificacion_del_Cliente'
	   ,B.CCODEMP, B.NCONDIA
	   --,C.cNomEmpSisFin as 'Nombre_Entidad_Financiera' 
	   --,C.ccodempsisfin,C.cGruEmpSisFin, C.cConEmpSisFin
	   --,D.cDirCliente AS 'Direccion'
 --INTO #TMPCLICAJA
FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
       INNER JOIN HYO00410.URIESGOS.dbo.[URIRCCSAL808] B
             ON A.CCODSBS = B.CCODSBS
       --INNER JOIN HYO00410.URIESGOS.dbo.[GENCODSBSEMPSISFIN] C
            --ON B.CCODEMP = C.ccodempsisfin
       --INNER JOIN CLIMClientes D
		--	 ON A.CCODSBS = D.cCodSbs
WHERE --A.CCODSBS = '0076639469'--'0140542385'
		--C.ccodempsisfin = '00107'
		B.CCALEMP NOT IN  ('8')
		and SUBSTRING(B.CCTACON,1,2) = '14' 
		and SUBSTRING(B.CCTACON,4,1) <> '8' 
	    and SUBSTRING(B.CCTACON,4,1) <> '9' 
		AND B.CTIPCRE = '10'
		and B.NCONDIA <= 8
	
--ORDER BY B.CCODSBS
--) AS Tmp
*/

/*
SELECT TOP 3 * FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
			SELECT CCLAFIN FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK) GROUP BY CCLAFIN ----CALIFICACION RCC
SELECT TOP 3 * FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B
			SELECT B.CCODEMP FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B group BY B.CCODEMP --CODIGO DE IFIS
			SELECT B.CCALEMP FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B group BY B.CCALEMP --CALIFICACION RCC}
			
--80519298    	0033823517	BARBA  PANTA    LILIANA  YVONNE	Créditos a Microempresas	Créditos Vigente	14110206020000	0	
SELECT * FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
where ccodsbs = '0033823517'

SELECT * FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B
where ccodsbs = '0038473565'--'0033823517'
		and SUBSTRING(B.CCTACON,1,2) = '14' 
		and SUBSTRING(B.CCTACON,4,1) <> '8' 
	    and SUBSTRING(B.CCTACON,4,1) <> '9' 
		AND B.CTIPCRE = '10'

SELECT TOP 3 * FROM HYO00410.URIESGOS.dbo.[GENCODSBSEMPSISFIN] C

SELECT TOP 3 * FROM URIRCCMAE808_DIC14



SELECT CAPEPAT,CAPEMAT,CAPECAS,CPRINOM,CSEGNOM,
             B.*, C.cNomEmpSisFin --D.cnomcnt
FROM URIRCCMAE808 A
       INNER JOIN URIRCCSAL808 B
             ON A.CCODSBS = B.CCODSBS
       INNER JOIN GENCODSBSEMPSISFIN C
             ON B.CCODEMP = C.ccodempsisfin
       --LEFT JOIN #TMP01 D
       --     ON SUBSTRING(B.CCTACON, 1, 6) = SUBSTRING(D.CTA, 1, 6)
WHERE A.CCODSBS = '0140542385'

Select      B.*, C.* --cNomEmpSisFin --D.cnomcnt
FROM URIRCCSAL808 B
         INNER JOIN GENCODSBSEMPSISFIN C
             ON B.CCODEMP = C.ccodempsisfin

--Select * from TMPCLICAJA

--INDEXANDO
--CREATE NONCLUSTERED INDEX TMPCLICAJA_CodSBS_IXN ON TMPCLICAJA(CodSBS)

------**************CREDITOS**************-------------
/*
SELECT DISTINCT B.cCodCliente
INTO #TMPCLI
FROM KPYMCRECONVEN A
       INNER JOIN GENMCreCli B
             ON A.cCodCtaCre = B.cCodCtaCre
       WHERE cEstCreCon IN ('F','H')
*/
*/


--------------****************
/*
SELECT TOP 3 * FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)

SELECT * FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
WHERE CCODSBS = '0053824676'

SELECT * FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B
where ccodsbs = '0009556940'--'0033823517'
		--and B.CTIPCRE = '10'
		and SUBSTRING(B.CCTACON,1,2) = '14' 
		and SUBSTRING(B.CCTACON,4,1) <> '8' 
	    and SUBSTRING(B.CCTACON,4,1) <> '9' 
		--and B.NCONDIA <= 8
		--and B.CCALEMP NOT IN  ('8')
	*/
-------------***********CLASIFICACION RCC **********----------------

USE SOFCMACHYO_RIESGOS

SELECT TOP 5 CCODCLIENTE,* FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)

SELECT TOP 20 * FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)
WHERE CCODFECMES <= '201502' AND CCODFECMES  >= '201409'
	AND CCODCLIENTE = '107020945508'
ORDER BY CCODFECMES ASC

---------------*******CURSOR CLASIFICACION RCC****************----------------------------------
				Declare @ccodcliente varchar(12)
				Declare cClienteRCC CURSOR FOR					
					SELECT --top 30 
					FROM  (NOLOCK) 
					
				OPEN cClienteRCC
				FETCH cClienteRCC into @ccodcliente
				WHILE (@@FETCH_STATUS=0)
				BEGIN						
					Update #CREMICROIFIS
					Set RCC_Enero_2015 = (SELECT CDESQUECARF
										  FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)
										  WHERE CCODFECMES = '201502' AND CCODCLIENTE = @ccodcliente )--'107012075756' )
					WHERE CODIGO_CLIENTE = @ccodcliente

					Update #CREMICROIFIS
					Set RCC_Diciembre_2014_ = ( SELECT CDESQUECARF
												FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)
												WHERE CCODFECMES = '201501' AND CCODCLIENTE = @ccodcliente )--'107012075756' )
					WHERE CODIGO_CLIENTE = @ccodcliente

					Update #CREMICROIFIS
					Set RCC_Noviembre_2014 = ( SELECT CDESQUECARF
											   FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)
											   WHERE CCODFECMES = '201412' AND CCODCLIENTE = @ccodcliente )--'107012075756' )
					WHERE CODIGO_CLIENTE = @ccodcliente

					Update #CREMICROIFIS
					Set RCC_Octubre_2014 = ( SELECT CDESQUECARF
												FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)
												WHERE CCODFECMES = '201411' AND CCODCLIENTE = @ccodcliente )--'107012075756' )
					WHERE CODIGO_CLIENTE = @ccodcliente

					Update #CREMICROIFIS
					Set RCC_Septiembre_2014 = ( SELECT CDESQUECARF
												FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)
												WHERE CCODFECMES = '201410' AND CCODCLIENTE = @ccodcliente )--'107012075756' ) 
					WHERE CODIGO_CLIENTE = @ccodcliente

					Update #CREMICROIFIS
					Set RCC_Agosto_2014 = ( SELECT CDESQUECARF
												FROM HYO00410.SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] Z (NOLOCK)
												WHERE CCODFECMES = '201409' AND CCODCLIENTE = @ccodcliente )--'107012075756' )
					WHERE CODIGO_CLIENTE = @ccodcliente
						 				
					END	 					

				FETCH cClienteRCC INTO @ccodcliente
				END
				CLOSE cClienteRCC
				DEALLOCATE cClienteRCC
            