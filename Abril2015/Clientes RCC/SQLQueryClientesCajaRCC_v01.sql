/*
SELECT * into TMPCLICAJA FROM  (
SELECT --TOP 30
	   --ROW_NUMBER() 
	   --OVER(PARTITION BY year(CRE.dFecDesCre)--CLI.cCodCliente 
	   --ORDER BY left(cast(CRE.dFecDesCre as date),10)) AS Secuencia,
	   CASE  
	   WHEN A.CTIPPER = '1' THEN 'Persona Natural'
	   WHEN A.CTIPPER = '2' THEN 'Persona Juridica'
	   END as TipoPersona,
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
	   --B.CCALEMP AS 'Cod_Clasif_del_Cliente',
	   CASE B.CCALEMP
	   WHEN '0' THEN 'NORMAL'
	   WHEN '1' THEN 'CPP'
	   WHEN '2' THEN 'DEFICIENTE'
	   WHEN '3' THEN 'DUDOSO'
	   WHEN '4' THEN 'PERDIDA'
	   WHEN '8' THEN 'SIN SALDOS EN LAS CUENTAS DE DEUDA DIRECTA, CONTINGENTES, CRÉDITOS CASTIGADOS'
	   ELSE ' '
	   END AS 'Clasificacion_del_Cliente',
	   C.cNomEmpSisFin as 'Nombre_Entidad_Financiera' 
	   --,C.ccodempsisfin,C.cGruEmpSisFin, C.cConEmpSisFin
	   --,D.cDirCliente AS 'Direccion'
 --INTO #TMPCLICAJA
FROM HYO00410.URIESGOS.dbo.[URIRCCMAE808] A (NOLOCK)
       INNER JOIN HYO00410.URIESGOS.dbo.[URIRCCSAL808] B
             ON A.CCODSBS = B.CCODSBS
       INNER JOIN HYO00410.URIESGOS.dbo.[GENCODSBSEMPSISFIN] C
             ON B.CCODEMP = C.ccodempsisfin
       --INNER JOIN CLIMClientes D
		--	 ON A.CCODSBS = D.cCodSbs
WHERE --A.CCODSBS = '0076639469'--'0140542385'
		C.ccodempsisfin = '00107'
		and B.CCALEMP = '0'
		and SUBSTRING(B.CCTACON,1,2) = '14' 
		and SUBSTRING(B.CCTACON,4,1) <> '8' 
	    and SUBSTRING(B.CCTACON,4,1) <> '9' 
--ORDER BY B.CCODSBS
) AS Tmp
*/

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


SELECT * into TMPCLIVIG FROM  (
SELECT TOP 20
	/*
	ROW_NUMBER() 
	OVER(PARTITION BY year(CRE.dFecDesCre)--CLI.cCodCliente 
	ORDER BY left(cast(CRE.dFecDesCre as date),10)) 
	AS Secuencia
	*/
	--Datos del Cliente
	 CLIM.cCodSbs AS 'COD_SBS1'
	,CLIM.cNroDocIde as 'NroDocumento1'
	,CLI.cCodCliente AS 'CODIGO_CLIENTE'
	,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	,C.cDirCliente AS 'Direccion_Cliente', C.cDirCliRef as 'Direccion_Referencia_Cliente'
	,DEP.cNomDepart AS 'Departamento_Cliente', pro.cNomProvin AS 'Provincia_Cliente'
	,dis.cNomDistri AS 'Distrito_Cliente', CLIM.cNroTelPer AS 'Nro_Telefono_Personal'
	--,SC.cDesCarPer--CARGO ANALISTA                                                                                                                         
	--,CRE.cCodOficin--CODIGO OFICINA
	--,SP.cCodOficin--CODIGO OFICINA
	
	--DATOS DEL CREDITO
	,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
	,left(cast(CRE.dFecDesCre as date),10) as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
	,isnull(left(cast(CRE.dFecCulCre as date),10),'') as 'Fecha_Culminacion_Credito'--FECHA DE CULMINACION DEL CREDITO
	--,CRE.cIndNueRep--INDICADOR DE NUEVO O REPRESTAMO
	--,left(cast(CLI.dFecAsiCre as date),10) as FecAsigCred--FECHA DE ASIGNACION DEL CREDITO
	--,CLI.cCodUltDes--CODIGO DEL ULTIMO DESEMBOLSO REGISTRADO
	,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
	,case CRE.cCodTipMon 
	 When '1' then 'SOLES'
	 WHEN '2' THEN 'DOLARES'
	 END as 'MONEDA'
	,CRE.nMonCapPag as 'CAPITAL_PAGADO' 
	,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL_AL_DIA'
	,CASE CRE.cEstCreCon
	  WHEN 'F' THEN 'VIGENTE'
	  WHEN 'H' THEN 'JUDICIAL'
	  WHEN 'I' THEN 'CASTIGADO'
	  WHEN 'G' THEN 'CANCELADO'
      WHEN 'E' THEN 'PENDIENTE'
	  END AS 'ESTADO_DEL_CREDITO'
	 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO', STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
	 ,PROD.cDesProduct AS 'PRODUCTO' 
	 ,SPRO.cDesSubPro AS 'SUBPRODUCTO'

	 --DATOS AGENCIA
	,O.cDesOficin AS 'NOMBRE_AGENCIA'
	,O.cDirOficin AS 'DIRECCION_AGENCIA' 	
	,DEP1.cNomDepart AS 'Departamento_Agencia'			 
	,pro1.cNomProvin AS 'Provincia_Agencia', dis1.cNomDistri as 'Distrito_Agencia'
	,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
	,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
	,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA 	
	--,CRE.cEstCreCon
	--,CRE.dFecGenCre--FECHA ASIGNACION
	--,CRE.dFecDesRef--FECHA DESEMBOLSO REF
	--,year(CRE.dFecDesCre) as AÑO
	--,Case month(CRE.dFecDesCre) 
	-- when '1' then 'ENERO' 
	-- when '2' then 'FEBRERO' 
	-- when '3' then 'MARZO' 
	-- when '4' then 'ABRIL' 
	-- when '5' then 'MAYO' 
	-- when '6' then 'JUNIO' 
	-- when '7' then 'JULIO' 
	-- when '8' then 'AGOSTO' 
	-- when '9' then 'SEPTIEMBRE' 
	-- when '10' then 'OCTUBRE' 
	-- when '11' then 'NOVIEMBRE' 
	-- when '12' then 'DICIEMBRE' 
	-- END AS MES	 
	--,SPRO.cDesSubPro AS 'SUBPRODUCTO' 
	--,CLIM.dFecIniSisF
	--,CLIM.dFecIniCmac
FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	inner JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYDPRODUCTO] PROD
			ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYDSUBPRODUC] SPRO
			ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
			AND CRE.cCodProduc =  SPRO.cCodProduc
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'

	--UBIGEO DEL CLIENTE
	LEFT JOIN [HYO00409\HISTORICO].CMACHYOCLI.DBO.[CLIMDirecc] C
			ON CLI.cCodCliente = C.cCodCliente AND C.bDirPredet = 1	 
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GenTDepartame] dep
			ON DEP.cCodDepart = C.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentProvincia] pro
			ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentDistrito] dis
			ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
			and dis.cCodDepart = C.cCodDepart
		
	---UBIGEO DEL CREDITO
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GenTDepartame] dep1
		ON DEP1.cCodDepart = O.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentProvincia] pro1
		ON pro1.cCodProvin = O.cCodProvin and pro1.cCodDepart = O.cCodDepart 
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentDistrito] dis1
		ON dis1.cCodDistri = O.cCodDistri and dis1.cCodProvin = O.cCodProvin 
			and dis1.cCodDepart = O.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZona] zo
		ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
		and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[Gentofizonas] goz
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZonas] zon
		ON goz.nCodZona = zon.nCodZona		                     
WHERE CRE.cEstCreCon IN ('F')--ESTADO DEL CREDITO ES VIGENTE F
		--AND 
		--CRE.cIndNueRep = 'N'
		--AND CRE.dFecDesCre >= '20141101' 
		--AND CRE.dFecDesCre <= '20150228'
		--and CRE.cCodUsuAna = 'AHUAYN'
		--AND SC.cCodGruCar = 'NEG'
--ORDER BY CRE.dFecDesCre
) AS Tmp



--SELECT * FROM TMPCLIVIG
--DROP TABLE TMPCLIVIG

--INDEXANDO
--CREATE NONCLUSTERED INDEX TMPCLIVIG_COD_SBS1_IXN ON TMPCLIVIG(COD_SBS1)


---ubigeo cliente

/*
--SELECT TOP 2 * FROM [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
SELECT TOP 2 * FROM [HYO00409\HISTORICO].CMACHYOCLI.DBO.[CLIMDirecc] C
SELECT TOP 2 * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GenTDepartame] dep
SELECT TOP 2 * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentDistrito] dis
SELECT TOP 2 * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentProvincia] pro

SELECT TOP 2 C.cCodDirCli, C.cCodCliente, C.cCodDepart, C.cCodProvin, C.cCodDistri, 
             C.cCodZona, C.cDirCliente, C.cDirCliRef, DEP.cNomDepart, pro.cNomProvin
			 ,  dis.cNomDistri
FROM [HYO00409\HISTORICO].CMACHYOCLI.DBO.[CLIMDirecc] C
		INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GenTDepartame] dep
			ON DEP.cCodDepart = C.cCodDepart
		INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentProvincia] pro
			ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
		INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentDistrito] dis
			ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
			and dis.cCodDepart = C.cCodDepart
WHERE  C.bDirPredet = 1	
*/

---ubigeo credito x agencia
/*
SELECT * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[Gentofizonas] goz
SELECT * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZonas] zon
SELECT TOP 5 * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZona] zo
SELECT TOP 2 * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[GENTOficinas] O

SELECT * FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[GENTOficinas] O
where o.cCodOficin between '001' and '055'


SELECT cCodTipzon
FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZona] zo
group by cCodTipzon

SELECT cCodZona--cCodSubZon--cCodRegion--cCodZonCom 
FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GENTOficinas] O
group by cCodZona--cCodSubZon--cCodRegion--cCodZonCom


SELECT TOP 100 
	O.cDesOficin, O.cDirOficin
	,O.cCodDepart, DEP.cNomDepart 			 
	,O.cCodProvin, pro.cNomProvin, O.cCodDistri, dis.cNomDistri
	,O.cCodZona, zo.cNomZona, zon.cDesZona as 'Nomnre_Zona'
FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[GENTOficinas] O	
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GenTDepartame] dep
		ON DEP.cCodDepart = O.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentProvincia] pro
		ON pro.cCodProvin = O.cCodProvin and pro.cCodDepart = O.cCodDepart 
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentDistrito] dis
		ON dis.cCodDistri = O.cCodDistri and DIS.cCodProvin = O.cCodProvin 
			and dis.cCodDepart = O.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZona] zo
		ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
		and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[Gentofizonas] goz
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZonas] zon
		ON goz.nCodZona = zon.nCodZona
*/

--RESULTADO FINAL

--Select TOP 2 * from TMPCLICAJA A
--SELECT TOP 2 * FROM TMPCLIVIG B

---VERIFICACIONES PREVIAS.
/*
Select  
	CRE.cCodCtaCre AS 'CODIGO_CREDITO'
	,left(cast(CRE.dFecDesCre as date),10) as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
	,isnull(left(cast(CRE.dFecCulCre as date),10),'') as 'Fecha_Culminacion_Credito'--FECHA DE CULMINACION DEL CREDITO	
	,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
	,case CRE.cCodTipMon 
	 When '1' then 'SOLES'
	 WHEN '2' THEN 'DOLARES'
	 END as 'MONEDA'
	,CRE.nMonCapPag as 'CAPITAL_PAGADO' 
	,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL_AL_DIA'
	,CASE CRE.cEstCreCon
	  WHEN 'F' THEN 'VIGENTE'
	  WHEN 'H' THEN 'JUDICIAL'
	  WHEN 'I' THEN 'CASTIGADO'
	  WHEN 'G' THEN 'CANCELADO'
      WHEN 'E' THEN 'PENDIENTE'
	  END AS 'ESTADO_DEL_CREDITO'
	 --,STC.cDesTipCre AS 'TIPO_DE_CREDITO', STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
	 ,PROD.cDesProduct AS 'PRODUCTO' 
	 ,SPRO.cDesSubPro AS 'SUBPRODUCTO'
FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYDPRODUCTO] PROD
			ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYDSUBPRODUC] SPRO
			ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
			AND CRE.cCodProduc =  SPRO.cCodProduc
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
where CRE.cCodCtaCre = '107013101003663695'


Select * 
from [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYTSUBTIPCRE] STC
where STC.lEstado = '1'
		and cCodTipCre = '02'	
		and cCodProduc = '02'
		and cCodSubPro = '01'

select *
FROM [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYMCRECONVEN] CRE (NOLOCK)	
where CRE.cCodCtaCre = '107013101003663695'
*/

SELECT * FROM TMPCLICAJA A
WHERE CODSBS ='0099073730'

SELECT * FROM TMPCLIVIG B
WHERE COD_SBS1 ='0099073730'

SELECT * FROM TMPCLICAJA A
WHERE CODSBS ='0122412199'

SELECT * FROM TMPCLIVIG B
WHERE COD_SBS1 ='0122412199'

/*
107002101008773107
107002101008882077
107002101008947095
*/

--/* 
SELECT 
	B.*
	--,A.TipoPersona, A.Clasificacion_del_Cliente, A.Nombre_Entidad_Financiera
	,A.* 
FROM  TMPCLICAJA A ,TMPCLIVIG B 
WHERE rtrim(A.CodSBS)  = 
			rtrim(B.COD_SBS1) 
			--collate Modern_Spanish_CI_AS
			collate SQL_Latin1_General_CP1_CI_AS
	  --AND 
	  --rtrim(A.NroDocumento) COLLATE DATABASE_DEFAULT = rtrim(B.NroDocumento1)		   
	  and B.COD_SBS1 = '0099073730'--'0122412199'		--'0013557594'
--*/