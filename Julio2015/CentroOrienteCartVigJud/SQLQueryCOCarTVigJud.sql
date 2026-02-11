	SELECT * into #tmpv02 FROM  (
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
			--Datos del Cliente	
			,CLI.cCodCliente AS 'CodigoCliente'	
			,CLIM.cNomCliente AS 'NombreCliente'																			
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'
			/*
			,SOLI.cCodUsuAna AS 'CodAnalistaOrigen'
			,SP1.cNomPerson AS 'NombreAnalistaOrigen'--NOMBRE ANALISTA 	
			*/
			--GARANTIAS			
			,ZON.nCodZona, ZON.cDesZona	
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_201505.dbo.[CLIMCLIENTES] CLIM 
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
			--ANALISTA ORIGEN
			 INNER JOIN [kpymsolicitud] SOLI	
				ON SOLI.cCodSolCre = CRE.cCodSolCre
			 Inner JOIN [sipmpersonal] SP1 
					ON SP1.cCodPerson = SOLI.cCodUsuAna
			*/
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon

		WHERE 	ZON.nCodZona = 3
				and CRE.cEstCreCon in ('F','H')	
				and left(cast(CRE.dFecDesCre as date),10) >='2015-05-01' --'2014-05-01'
				and left(cast(CRE.dFecDesCre as date),10) <='2015-05-30' --'2014-05-30'
		--ORDER BY cEstCreCon 			
		) as tmp99

		----------------------------------------------------------------------------------
		Select * from #tmpv01 where cCodOficin='005'
		----------------------------------------------------------------------------------

		SELECT 		
			cCodOficin,cDesOficin,EstadoCredito,CantClie=COUNT(DISTINCT CodigoCliente)
			,MontoDes=SUM(MontoDesembolso) 
		FROM #tmpv02-- #tmpv01
		GROUP BY cCodOficin,EstadoCredito,cDesOficin
		ORDER BY cCodOficin

		----------------------------------------------------------------------------------
		DROP TABLE #tmpv01
		DROP TABLE #tmpv02