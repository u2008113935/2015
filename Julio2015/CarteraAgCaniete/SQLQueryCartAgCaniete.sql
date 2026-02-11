

		--SELECT * into #tmpv01 FROM  (
		Select 		
			 O.cCodOficin, O.cDesOficin			
			,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 ,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 ,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 		
			--Datos del credito
			,CRE.cCodCtaCre AS 'CodigoCredito'	
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'
			,Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END cDesConCre			
			/*
			--Datos Castigado
			,nDiaAtrIni = isnull(CJ.nDiaAtrIni,0)
			,nMonCapCas = isnull(CJ.nMonCapCas,0)
			,nMonIntCas = isnull(CJ.nMonIntCas,0)
			,nMonMorCas = isnull(CJ.nMonMorCas,0)
			,nMonGasCas = isnull(CJ.nMonGasCas,0)			
			--, TotalCast = sum (CJ.nMonCapCas + CJ.nMonIntCas + CJ.nMonMorCas + CJ.nMonGasCas)
			,cCodUsuCas = isnull(CJ.cCodUsuCas, 'NO REGISTRA')
			,ISNULL(left(cast(CJ.dFecIngJud as date),10),'NO REGISTRA') as 'FechaCastigo'
			,ISNULL(DATENAME (MONTH, CJ.dFecIngJud),'NO REGISTRA') as 'MesCastigo'
			*/
			--Datos del Cliente	
			,CLI.cCodCliente AS 'CodigoCliente'	
			,CLIM.cNomCliente AS 'NombreCliente'																			
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'

			,SOLI.cCodUsuAna AS 'CodAnalistaOrigen'
			,SP1.cNomPerson AS 'NombreAnalistaOrigen'--NOMBRE ANALISTA 	
			--GARANTIAS
			,LC.cCodTipGar, G.cdestipgar
			,ZON.nCodZona, ZON.cDesZona	
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna	
		
			/*
			left join KJUMCreJudici CJ
				on CJ.cCodCtaCre = CRE.cCodCtaCre
			*/

			INNER JOIN KPYDGARLINCRE GAR (NOLOCK) 
				ON GAR.CCODLINCRE = CLI.CCODLINCRE	
			INNER JOIN KPYDGarLinCre LC	
				ON LC.cCodLinCre = GAR.CCODLINCRE 	
			INNER JOIN GENDGarantia G
				ON G.ccodgarant = LC.cCodTipGar

			--ANALISTA ORIGEN
			 INNER JOIN [kpymsolicitud] SOLI	
				ON SOLI.cCodSolCre = CRE.cCodSolCre
			 Inner JOIN [sipmpersonal] SP1 
					ON SP1.cCodPerson = SOLI.cCodUsuAna
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon

		WHERE --CRE.cCodUsuAna IN ('WCASTA','DPAZAR')	
				--SOLI.cCodUsuAna in ('WCASTA','DPAZAR')
				CRE.cCodOficin = '043'
				and CRE.cEstCreCon in ('F','H','I')		
			--and CRE.cCodCtaCre in	 ('107008101004104979','107008101003966762','107008101004266837','107008101003862622')
		ORDER BY cEstCreCon 			
			 --) as tmp99

		-- (3,846 row(s) affected)

	/*
		SELECT TOP 1 CCODGARCLI, CCODLINCRE,*
		FROM KPYDGARLINCRE GAR (NOLOCK) 
		WHERE cCodLinCre = '0010000032'


		SELECT  TOP 1  * 
		FROM [KPYMCRECONVEN] CRE (NOLOCK)

		SELECT  TOP 1  CCODLINCRE , cCodCtaCre, * 
		FROM GENMCRECLI GEN  (NOLOCK) 

		SELECT TOP 1 CCODGARCLI, *
		FROM CMACHYOCLI_MEDIODIA.DBO.CLIMGarCliente CLIMGAR (NOLOCK)  
		WHERE CCODGARCLI = '001'
	*/