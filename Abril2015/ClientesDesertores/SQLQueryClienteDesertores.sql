--drop table TMPCLIDESER
--USE TEST
SELECT * into #TMPCLIDESER FROM  (


SELECT TOP 10
	/*
	ROW_NUMBER() 
	OVER(PARTITION BY year(CRE.dFecDesCre)--CLI.cCodCliente 
	ORDER BY left(cast(CRE.dFecDesCre as date),10)) 
	AS Secuencia
	*/
	--Datos del Cliente
	CLIM.cCodSbs AS 'COD_SBS1'
	,CLIM.cNroDocIde as 'NroDocumento1'

	/*
	,CASE  
	WHEN A.CTIPPER = '1' THEN 'Persona Natural'
	WHEN A.CTIPPER = '2' THEN 'Persona Juridica'
	END as TipoPersona
	*/
	,CLI.cCodCliente AS 'CODIGO_CLIENTE'
	,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	,C.cDirCliente AS 'Direccion_Cliente' 
	,C.cDirCliRef as 'Direccion_Referencia_Cliente'
	,DEP.cNomDepart AS 'Departamento_Cliente'
	,pro.cNomProvin AS 'Provincia_Cliente'
	,dis.cNomDistri AS 'Distrito_Cliente'
	,CLIM.cNroTelPer AS 'Nro_Telefono_Personal'
	
	--CLASIFICACION DE CARTERA
	/*
	,CASE B.CCALEMP
	WHEN '0' THEN 'NORMAL'
	WHEN '1' THEN 'CPP'
	WHEN '2' THEN 'DEFICIENTE'
	WHEN '3' THEN 'DUDOSO'
	WHEN '4' THEN 'PERDIDA'
	WHEN '8' THEN 'SIN SALDOS EN LAS CUENTAS DE DEUDA DIRECTA, CONTINGENTES, CRÉDITOS CASTIGADOS'
	ELSE ' '
	END AS 'Clasificacion_del_Cliente'	
	*/
	,'' as 'Clasificacion_del_Cliente'

	--DATOS DEL CREDITO
	,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
	,left(cast(CRE.dFecDesCre as date),10) as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
	,isnull(left(cast(CRE.dFecCulCre as date),10),'') as 'Fecha_Culminacion_Credito'--FECHA DE CULMINACION DEL CREDITO
	,CRE.nDiaAtrCre as 'Nro_Dias_Atraso_Cuota'
	,CRE.nDiaAtrAcu as 'Nro_Dias_Atraso_Acumulado'
	,CRE.nDiaAtrMax as 'Nro_Dias_Atraso_Maximo'

	,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
	,case CRE.cCodTipMon 
	 When '1' then 'SOLES'
	 WHEN '2' THEN 'DOLARES'
	 END as 'MONEDA'
	,CRE.nMonCapPag as 'CAPITAL_PAGADO' 
	,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL'
	--,CRE.nSalCapDia AS 'SALDO_CAPITAL_AL_DIA'
	,CASE CRE.cEstCreCon
	  WHEN 'F' THEN 'VIGENTE'
	  WHEN 'H' THEN 'JUDICIAL'
	  WHEN 'I' THEN 'CASTIGADO'
	  WHEN 'G' THEN 'CANCELADO'
      WHEN 'E' THEN 'PENDIENTE'
	  END AS 'ESTADO_DEL_CREDITO'
	 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
	 ,STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
	 ,PROD.cDesProduct AS 'PRODUCTO' 
	 ,SPRO.cDesSubPro AS 'SUBPRODUCTO'

	 --DATOS AGENCIA
	,O.cDesOficin AS 'NOMBRE_AGENCIA'
	,O.cDirOficin AS 'DIRECCION_AGENCIA' 	
	,DEP1.cNomDepart AS 'Departamento_Agencia'			 
	,pro1.cNomProvin AS 'Provincia_Agencia' 
	,dis1.cNomDistri as 'Distrito_Agencia'
	,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
	,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
	,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA 	

	--,EMP.cNomEmpSisFin as 'Nombre_Entidad_Financiera'
	
FROM [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN [HYO00409\HISTORICO].CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	inner JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.dbo.[KPYDPRODUCTO] PROD
			ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYDSUBPRODUC] SPRO
			ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
			AND CRE.cCodProduc =  SPRO.cCodProduc
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.dbo.[KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'

	--UBIGEO DEL CLIENTE
	LEFT JOIN [HYO00409\HISTORICO].CMACHYOCLI.DBO.[CLIMDirecc] C
			ON CLI.cCodCliente = C.cCodCliente AND C.bDirPredet = 1	 
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GenTDepartame] dep
			ON DEP.cCodDepart = C.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GentProvincia] pro
			ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GentDistrito] dis
			ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
			and dis.cCodDepart = C.cCodDepart
		
	---UBIGEO DEL CREDITO
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GenTDepartame] dep1
		ON DEP1.cCodDepart = O.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GentProvincia] pro1
		ON pro1.cCodProvin = O.cCodProvin and pro1.cCodDepart = O.cCodDepart 
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GentDistrito] dis1
		ON dis1.cCodDistri = O.cCodDistri and dis1.cCodProvin = O.cCodProvin 
			and dis1.cCodDepart = O.cCodDepart
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201503.DBO.[GentZona] zo
		ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
		and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[Gentofizonas] goz
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201502.DBO.[GentZonas] zon
		ON goz.nCodZona = zon.nCodZona

	--calificacion rcc
	/*
	INNER join [HYO00410].URIESGOS.dbo.[URIRCCMAE808] A 
		ON A.CCODSBS collate SQL_Latin1_General_CP1_CI_AS = CLIM.cCodSbs
    INNER JOIN [HYO00410].URIESGOS.dbo.[URIRCCSAL808] B
        ON A.CCODSBS = B.CCODSBS
    INNER JOIN [HYO00410].URIESGOS.dbo.[GENCODSBSEMPSISFIN] EMP
        ON B.CCODEMP = EMP.ccodempsisfin
		*/
WHERE CRE.cEstCreCon IN ('G')  --ESTADO DEL CREDITO ES VIGENTE F
	  and STC.cCodTipCre in ('13','02','03','12') 
	  --and B.CCALEMP = '0'

) AS Tmp



 drop table #TMPCLIDESER

--SELECT * FROM TMPCLIDESER

--SELECT distinct (CODIGO_CREDITO), *  FROM TMPCLIDESER

--SELECT distinct (COD_SBS1), *  FROM TMPCLIDESER

--DROP TABLE TMPCLIDESER

--INDEXANDO
--CREATE NONCLUSTERED INDEX TMPCLIVIG_COD_SBS1_IXN ON TMPCLIVIG(COD_SBS1)

/*
SELECT TOP 5 *, 
	STC.cDesTipCre AS 'TIPO_DE_CREDITO', STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
*/

