
	/*
		cCodCliente,	cNomCliente,	cCodCtaCre,	nMonCapDes,	CCODSOLCRE,	nMonSalCap,	nplazo,	dFecDesCre,
		cDesTipMon,	cDesOficin,	cDesTipCre,	cDesProCre,	cDesSubCre,	cDesConven,	cCodUsuAna,	cDescriEst,	CapDes,
		cIndNueRep,	nMonCapPag,	nMonIntPag,	nMonMorPag,	nMonGasPag,	nMonIntPro,	cEstCreCon,	nDiaAtrCre,	cEstCreCon,
		nMonSalCap,	nMonVen,	nMonJud,	nMonCapPag,	cDescriDes,	CDESTIPDES,	NMONTIPDES,	nTasIntCom		
	
		Información de los créditos otorgados como Crediecológico, en adjunto te envío un ejemplo de los campos
		requeridos, se requiere todos los créditos otorgados tanto vigentes como cancelados, desde el 2012, 2013,
		2014 y 2015.	
	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-12-01'				
				)

	-- Select * into #tab01 from (

		Select 	Anio				=	year(CRE.DFECDESCRE)
				,Mes				=	MONTH (CRE.DFECDESCRE)
				,NombreMes			=	DATENAME(month, CRE.DFECDESCRE)	
				,CodigoCliente		=	CLI.cCodCliente		
				,NombreCliente		=	CLIM.cNomCliente								
				,CodigoCredito		=	CRE.cCodCtaCre																				
				,MontoDesembSoles	= 
					CASE cre.cCodTipMon
						WHEN '1' THEN CRE.nMonCapDes
						WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
					END						
				,CodigoSolicitud	=	BB.cCodSolCre

				,SaldoCapi = (CASE WHEN CRE.cEstCreCon IN ('F', 'H')
									THEN (CRE.nMonCapDes - CRE.nMonCapPag) 
										* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,SaldoVig = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.cCodRefina = 'N'
									THEN CRE.nMonSalNor * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoVen = (CASE WHEN CRE.cEstCreCon = 'F' and CRE.nMonSalVen > 0
									THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ElSE 1 END
										ELSE 0 END)
				,SaldoJud = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen 
										* CASE WHEN CRE.cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,SaldoRef = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 
										AND CRE.cCodRefina = 'S'
									THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)	
				,PlazoCuotaEnDias	= CRE.nNumDiaApr
				,CuotasAprobadas	= CRE.nNumCuoApr
				,DiasGracia			= CRE.nNumDiaGra
				,PlazoTotalEnDias	= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)	
				,FechaDesembolso	=	left(cast(CRE.dFecDesCre as date),10) 
				,TipoMoneda			=
					CASE CRE.cCodTipMon
						WHEN '1' THEN 'SOLES'
						WHEN '2' THEN 'DOLARES'
					END 	
				,Oficina = O.cDesOficin	
				,Zona = ZON.cDesZona									
				,TipoCredito			=	STC.cDesTipCre 
				,SubTipoCredito			=	STC.cDesSubTip 			 
				,ProductoCrediticio		=	STC.cDesProCre  			 
				,SubProductoCrediticio	=	STC.cDesSubcRE  										
				--	,C.cCodConven
				,DescripcionConvenio	=	C.cDesConven
				,CodAsesorActual		=	CRE.cCodUsuAna 
				,NombreAsesorActual		=	SP.cNomPerson 						
				,CRE.cEstCreCon
				,EstadoCredito			=
											 CASE CRE.cEstCreCon
												WHEN 'G' THEN 'CANCELADO' 
												ELSE D.cDesConCre
											 END
				,CRE.cIndNueRep					
				,DiasdeMora = CRE.nDiaAtrCre 
				,MontoCapitalPagado		=	CRE.nMonCapPag		
				,MontoInteresAprobado	=	CRE.nMonIntPro 
				,MontoInteresAlaFecha	=	CRE.nMonIntFec 
				,MontoInteresPagado		=	CRE.nMonIntPag				
				,MontoGastoAprobado		=	CRE.nMonGasPro		
				,MontoGastosPagados		=	CRE.nMonGasPag		
				,MontoMoraProgramada	=	CRE.nMonMorPro		
				,MontoMoraPagada		=	CRE.nMonMorPag																										 				
				,DestinoCredito			=	ISNULL(D2.cDescriDes,'NO REGISTRA')
				,DD.cDesTipDes	
				,BB.nMonProEco
				,TEM = CRE.nTasintCom																															
				--	,AA.dFecSolCre,
									
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
				INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
				INNER JOIN [KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
				LEFT JOIN KPYTEstCreCon EC 
					ON EC.cEstCreCon = CRE.cEstCreCon
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
				INNER JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna	
				--condicion credito 
				LEFT JOIN [KPYTConCredit] D
					ON D.cCondicCon = CLI.cCondicCon			 														
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = CRE.cCodDesCre										
				
				INNER JOIN KPYMSolicitud AA
					ON AA.cCodSolCre		=	CRE.cCodSolCre
				INNER JOIN KPYDProEcolog BB
					ON 	BB.cCodSolCre	=	 AA.cCodSolCre
				INNER JOIN KPYTTipDesCre DD
					ON DD.cCodDesCre		=	BB.cCodDesCre	AND		DD.lEstTipDes	=	'1'

				LEFT JOIN KPYMConvenios C
					ON C.cCodConven = CRE.cCodConven 					
				
			WHERE CRE.cEstCreCon in ('F','H','G','I')	
				AND DD.cDesTipDes LIKE '%ECO%'																
				/*
				AND C.cCodConven IN 
						(
						 SELECT cCodConven
							FROM KPYMConvenios
							WHERE dFecRegCon IS NOT NULL								
						)	
				*/
			ORDER BY year(CRE.DFECDESCRE), MONTH (CRE.DFECDESCRE)

			-- (358 row(s) affected)

	/*
			SELECT	C.cCodCtaCre, C.cCodSolCre,
					A.cCodSolCre, A.dFecSolCre,
					B.cCodSolCre, B.cCodDesCre, B.cCodTipDes, B.cCodTipEco, B.nMonProEco, B.lConEstado,
					D.cDesTipDes
			FROM KPYMCRECONVEN C
				INNER JOIN KPYMSolicitud A
					ON A.cCodSolCre		=	C.cCodSolCre
				INNER JOIN KPYDProEcolog B
					ON 	B.cCodSolCre	=	 A.cCodSolCre
				INNER JOIN KPYTTipDesCre D
					ON D.cCodDesCre		=	B.cCodDesCre	AND		D.lEstTipDes	=	'1'
			WHERE D.cDesTipDes LIKE '%ECO%'
			ORDER BY A.dFecSolCre							
			
							
			cCodDesCre	cCodTipDes	cCodTipEco	nMonProEco	lConEstado
			5 			69			05			180.00		1
			
			SELECT * FROM KPYTTipDesCre
			WHERE cDesTipDes LIKE '%ECO%'

			SELECT * FROM KPYTTipDesCre
			WHERE cCodDesCre	=	'5'

			SELECT * FROM KPYTTipDesCre WHERE cDesTipDes LIKE '%ECO%'						
			SELECT * FROM KPYDDesCreCon WHERE cDescriDes LIKE '%ECO%'						
			SELECT cCodDesCre,* FROM KPYMCRECONVEN WHERE cCodDesCre = '4' 			
			
			SELECT * FROM KPYMSolicitud		
			SELECT * FROM KPYDProEcolog						
				
			SELECT * FROM KPYDDesCreCon WHERE cDescriDes LIKE '%ECO%'
			ORDER BY dFecingDes

			SELECT * FROM KPYDTipDesCre					
				
			SELECT * FROM KPYTDesCreCon WHERE cDescriDes LIKE '%ECOL%'
			
			SELECT cCodDesCre,* FROM KPYTParOtoCre WHERE cCodDesCre = '4'
			SELECT cCodDesCre,* FROM KPYTTipCreEco

			SELECT * FROM KPYTSolSubTipDes A
			SELECT * FROM KPYDSubTipDes B	
			
	*/