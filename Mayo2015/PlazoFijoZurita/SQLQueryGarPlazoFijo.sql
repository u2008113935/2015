SELECT 
		--Datos del Cliente	
		CLIM.cNroDocIde as 'NroDocumento'
		,CLI.cCodCliente AS 'CodigoClienteE'
		,CLIM.cNomCliente AS 'NombreCliente'
		--DATOS DEL CREDITO
		,CRE.cCodCtaCre AS 'CodigoCredito'
		,CRE.nMonCapDes as 'MontoDesembolsado' 
		,CRE.nTasIntCom as 'TasaInteres'
		,CRE.nCosEfeAct as 'TasaCostoEfectivoAnual'
		,case CRE.cCodTipMon 
		 When '1' then 'SOLES'
		 WHEN '2' THEN 'DOLARES'
		 END as 'Moneda'
		,CRE.nMonintPro as 'MontoInteresAprobado'
		,CRE.nMonintFec as 'MontoInteresAlaFecha'
		,CRE.nMonintPag as 'MontoInteresPagado'
		,EC.cDescriEst AS 'EstadoCredito'
		,CRE.dFecDesCre as 'FechaDesembolsoCredito'
		,isnull(CRE.dFecCulCre,'') as 'FechaCulminacionCredito'
		,CRE.nNumCuoApr as 'NroCuotasAprobadas'
		,CRE.cTipPeriodo
		,case CRE.cCodPlazo				
		 when '1' then 'CORTO PLAZO'
		 when '2' then 'LARGO PLAZO'
		 END 
		 ,CRE.cCodTipCre
		 ,STC.cDesTipCre AS 'TipoCredito'
		 ,STC.cDesSubTip AS 'SubTipoCredito'
		 ,CRE.cCodProduc
		 ,STC.cDesProCre AS 'ProductoCrediticio' 
		 ,CRE.cCodSubPro	
		 ,STC.cDesSubcRE AS 'SubProductoCrediticio'
		,O.cDesOficin AS 'NombreAgencia'
		,CRE.cCodOficin
		,zo.cNomZona as 'DetalleZona', zon.cDesZona as 'Zona'
		,CRE.cCodUsuAna AS 'CodigoAanalista'--COD ANALISTA
		,SP.cNomPerson AS 'NombreAnalista'--NOMBRE ANALISTA  
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
	WHERE CRE.cCodCtaCre in ('107034221000042300','107020221000186712'
	,'107050221000094773','107050221000079423'
	,'10703822000675455','107038221000877831'
	,'107038221000862592','107038221000862491'
	,'107012221001158686')
			--AND CRE.cEstCreCon = 'F'
			--AND CRE.dFecDesCre >= '2015-04-01'
	ORDER BY CLI.cCodCliente