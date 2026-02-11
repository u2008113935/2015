--/*
SELECT TOP 30
	   CASE  
	   WHEN A.CTIDOTR = '3' THEN A.CNUDOTR
	   WHEN A.CTIDOCI = '1' THEN A.CNUDOCI
	   END as NroDocumento,
	   B.CCODSBS as CodSBS,
	   (rtrim(A.CAPEPAT) + space(2) + rtrim(A.CAPEMAT) + space(2) + rtrim(A.CAPECAS) + space (2) 
	   + rtrim(A.CPRINOM) + space(2) + rtrim(A.CSEGNOM) ) as Apellidos_Nombres_Cliente,
	   --B.CCODEMP, 
	   CASE B.CTIPCRE
	   WHEN '01' THEN 'Créditos Soberanos' 
	   WHEN '02' THEN 'Créditos a Entidades del Sector Público' 
	   WHEN '03' THEN 'Créditos a Bancos Multilaterales de Desarrollo' 
	   WHEN '04' THEN 'Créditos a Empresas del Sistema Financiero' 
	   WHEN '05' THEN 'Créditos a Empresas de Valores' 
	   WHEN '06' THEN 'Créditos Corporativos' 	   
	   WHEN '07' THEN 'Créditos a Grandes Empresas' 
	   WHEN '08' THEN 'Créditos a Medianas Empresas' 
	   WHEN '09' THEN 'Créditos a Pequeña Empresas' 
	   WHEN '10' THEN 'Créditos a Microempresas' 
	   WHEN '11' THEN 'Créditos Consumo Revolventes' 
	   WHEN '12' THEN 'Créditos Consumo No Revolventes' 
	   WHEN '13' THEN 'Créditos Hipotecarios para Vivienda'
	   ELSE ' '
	   END AS 'Tipo_de_Credito',
	   CASE  
	   WHEN SUBSTRING(B.CCTACON,3,1) = '1' THEN 'Soles'
	   WHEN SUBSTRING(B.CCTACON,3,1) = '2' THEN 'Dólares'
	   END AS 'Moneda',
	   CASE  
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '1' 
	   THEN 'Créditos Vigente'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '3' 
	   THEN 'Créditos Reestructurados'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '4' 
	   THEN 'Créditos Refinanciados'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '5' 
	   THEN 'Créditos Vencidos'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '6' 
	   THEN 'Créditos en Cobranza Judicial'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '8' 
	   THEN 'Rendimientos Devengados de Créditos Vigentes'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '9' 
	   THEN 'Provisiones para Créditos'
	   ---72
	   WHEN SUBSTRING(B.CCTACON,1,2) = '72' AND SUBSTRING(B.CCTACON,4,1) = '5' 
	   THEN 'LÍNEAS DE CRÉDITO NO UTILIZADAS Y CRÉDITOS CONCEDIDOS NO DESEMBOLSADOS'
	   --81
	   WHEN SUBSTRING(B.CCTACON,1,2) = '81' AND SUBSTRING(B.CCTACON,4,3) = '923' 
	   THEN 'LÍNEAS DE CRÉDITO EN TARJETAS DE CRÉDITO DE CONSUMO'
	   --84
	   WHEN SUBSTRING(B.CCTACON,1,2) = '84' AND SUBSTRING(B.CCTACON,4,3) = '409' 
	   THEN 'OTRAS GARANTIAS NO PREFERIDAS'
	   --84
	   WHEN SUBSTRING(B.CCTACON,1,2) = '84' AND SUBSTRING(B.CCTACON,4,3) = '402' 
	   THEN 'GARANTIAS PREFERIDAS'
	   ELSE ''
	   END AS 'Estado_del_Credito',
	   B.CCTACON
	   , B.NCONDIA AS 'Dias', B.NSALDOS AS 'Saldo', 
	   B.CCALEMP AS 'Cod_Clasif_del_Cliente',
	   CASE B.CCALEMP
	   WHEN '0' THEN 'NORMAL'
	   WHEN '1' THEN 'CPP'
	   WHEN '2' THEN 'DEFICIENTE'
	   WHEN '3' THEN 'DUDOSO'
	   WHEN '4' THEN 'PERDIDA'
	   WHEN '8' THEN 'SIN SALDOS EN LAS CUENTAS DE DEUDA DIRECTA, CONTINGENTES, CRÉDITOS CASTIGADOS'
	   ELSE ' '
	   END AS 'Clasificacion_del_Cliente',
	   C.cNomEmpSisFin as 'Nombre_Entidad_Financiera' --,C.ccodempsisfin,C.cGruEmpSisFin, C.cConEmpSisFin
FROM URIRCCMAE808 A (NOLOCK)
       INNER JOIN URIRCCSAL808 B
             ON A.CCODSBS = B.CCODSBS
       INNER JOIN GENCODSBSEMPSISFIN C
             ON B.CCODEMP = C.ccodempsisfin
       --LEFT JOIN #TMP01 D
         --   ON SUBSTRING(B.CCTACON, 1, 6) = SUBSTRING(D.CTA, 1, 6)
WHERE --A.CCODSBS = '0076639469'--'0140542385'
		--C.ccodempsisfin = '00107'
		B.CCALEMP = '8'
		--and SUBSTRING(B.CCTACON,1,2) <> '81'
		--and SUBSTRING(B.CCTACON,1,2) = '14' 
		--and SUBSTRING(B.CCTACON,4,1) <> '8' 
	 --   and SUBSTRING(B.CCTACON,4,1) <> '9' 
ORDER BY B.CCODSBS
--*/

--SELECT TOP 10 *
--FROM URIRCCMAE808 --TABLA MAESTRO DE IDENTIFICACION (A)
/*
SELECT *
FROM URIRCCMAE808  --CONSULTA PERSONALIZADA
WHERE CNUDOCI = '43111949'
*/

--SELECT TOP 10 *
--FROM URIRCCSAL808 --TABLA MAESTRO DE SALDOS  (B)

--SELECT top 12 CCALEMP,* 
--FROM URIRCCSAL808 --TABLA MAESTRO DE SALDOS  (B)
--WHERE CCALEMP IN ('')--CCODSBS = '0076639469'

--SELECT  *
--FROM GENCODSBSEMPSISFIN --TABLA MAESTRO DE ENTIDADES FINANCIERAS (C)

--SELECT  *
--FROM GENCODSBSEMPSISFIN --TABLA MAESTRO DE ENTIDADES FINANCIERAS (C)
--WHERE CNOMEMPSISFIN LIKE '%HUANCAYO%'

--SELECT TOP 10 *
--FROM URIRCCTACTB --TABLA MAESTRO CUENTA CONTABLE
