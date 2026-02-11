	
	-- select * from listasusan

	--SELECT * FROM #TMP
	--SELECT * into #TMP FROM  (

	SELECT 
		--Datos del Cliente	
		isnull(CLIM.cNroDocIde, CLIM.cNroDocTri) as 'NroDocumento'
		,CLI.cCodCliente AS 'CODIGO_CLIENTE'
		,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
		--DATOS DEL CREDITO
		,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
		,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
		,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'
		,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
		,case CRE.cCodTipMon 
		 When '1' then 'SOLES'
		 WHEN '2' THEN 'DOLARES'
		 END as 'MONEDA'
		,CRE.cCodTipCre
		,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
		,STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
		,CRE.cCodProduc
		,STC.cDesProCre AS 'PRODUCTO_CREDITICIO' 
		,CRE.cCodSubPro	
		,STC.cDesSubcRE AS 'SUBPRODUCTO_CREDITICIO'	
		,O.cDesOficin AS 'NOMBRE_AGENCIA'
		,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
		,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
		,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA  
	FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
		INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTEstCreCon] EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
		inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDPRODUCTO] PROD
				ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDSUBPRODUC] SPRO
				ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
				AND CRE.cCodProduc =  SPRO.cCodProduc
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZona] zo
			ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
			and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[Gentofizonas] goz
			ON goz.cCodOficin = O.cCodOficin
		INNER JOIN  [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZonas] zon
			ON goz.nCodZona = zon.nCodZona	
	WHERE CLIM.cNomCliente  COLLATE SQL_Latin1_General_CP1_CI_AS
			in (select NombreCliente from listasusan )					
			AND CRE.cEstCreCon = 'F'
	ORDER BY CLIM.cNomCliente
	--) as tmp