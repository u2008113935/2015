--USE URIESGOS
--PASO 01
SELECT  COUNT (DISTINCT B.CCODEMP)						
FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B 
WHERE B.CCALEMP NOT IN  ('8')
		and SUBSTRING(B.CCTACON,1,2) = '14' 
		and SUBSTRING(B.CCTACON,4,1) <> '8' 
		and SUBSTRING(B.CCTACON,4,1) <> '9' 
		--AND B.CTIPCRE = '10'
		--and B.NCONDIA <= 8
		AND B.CCODSBS = '0027481469' --@ccodsbs

--PASO 02
DECLARE @DETCTA TABLE
       (ccodcta CHAR(4)COLLATE SQL_Latin1_General_CP1_CI_AS PRIMARY KEY)

--No incluye créditos indirectos, ni castigados
INSERT INTO @detcta
       VALUES
       ('1411'), --Credito Vigentes Soles
       ('1413'), --Credito Reestructurado Soles
       ('1414'), --Creditos Refinanciados Soles
       ('1415'), --Creditos Vencidos Soles
       ('1416'), --Cred Cobranza Judicial Soles
       ('1421'), --Credito Vigentes Dolares
       ('1423'), --Credito Reestructurado Dolares
       ('1424'), --Creditos Refinanciados Dolares
       ('1425'), --Creditos Vencidos Dolares
       ('1426')  --Cred Cobranza Judicial Dolares

-- SOLO VIGENTES EN CMAC HYO
SELECT COUNT (DISTINCT B.CCODEMP)							
FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B  (NOLOCK)	
		--INNER JOIN @detcta C ON LEFT(B.Cctacon, 4) = C.ccodcta COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE B.CCODSBS = '0027481469' and B.CCALEMP = '0'
		and LEFT(B.Cctacon, 4) in ('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')

--Consulta
SELECT  *--COUNT (DISTINCT B.CCODEMP) 
FROM HYO00410.URIESGOS.dbo.[URIRCCSAL808] B  
WHERE B.CCODSBS = '0027481469'
/*		
  
0012514336
0028312504  
0029451338
0028312539  
0013232121
*/