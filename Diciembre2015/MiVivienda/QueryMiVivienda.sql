	
	/*
		Se requiere el reporte de conciliación Enero a Noviembre 2015 de las operaciones 
		de créditos MI VIVIENDA - MI CONSTRUCCIÓN - MI CASA MAS desembolsados en la Caja , 
		dicho reporte de ser en Excel y debe considerar: nombre de cliente, fecha de desembolso,
		agencia, modalidad de bono (PBP o BBP en caso de BBP monto del bono), asesor.
	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-11-01'				
				)

		Select 		
				ROW_NUMBER() 
				OVER(PARTITION BY year(CRE.DFECDESCRE)
						ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 						
				,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
				,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
				,CLI.cCodCliente AS 'CodigoCliente'		
				,CLIM.cNomCliente AS 'NombreCliente'				
				--Datos del credito	
				,CRE.cCodSolCre		
				,CRE.cCodCtaCre AS 'CodigoCredito'				
				,STC.cDesTipCre AS 'TipoCredito'
				,STC.cDesSubTip AS 'SubTipoCredito'			 
				,STC.cDesProCre AS 'ProductoCrediticio' 			 
				,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
				,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
				,MontoBono  = ISNULL(DH.nMonBonCom,0)
				,TipoCambio = @nTipCambio
				,MontoDesembolsoenSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN CRE.nMonCapDes
					WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
					END						
				,nSaldoCapi = (CASE WHEN CRE.cEstCreCon IN ('F', 'H')
									THEN (CRE.nMonCapDes - CRE.nMonCapPag) 
										* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoVig = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.cCodRefina = 'N'
									THEN CRE.nMonSalNor * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoVen = (CASE WHEN CRE.cEstCreCon = 'F' and CRE.nMonSalVen > 0
									THEN CRE.nMonSalVen * CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ElSE 1 END
										ELSE 0 END)
				,nSaldoJud = (CASE WHEN CRE.cEstCreCon = 'H' THEN CRE.nMonSalVen 
										* CASE WHEN CRE.cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)
				,nSaldoRef = (CASE WHEN CRE.cEstCreCon = 'F' AND CRE.nMonSalNor > 0 
										AND CRE.cCodRefina = 'S'
									THEN CRE.nMonSalNor	* CASE WHEN CRE.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END)					
				,TEM = CRE.nTasintCom					
				,PlazoCuotaEnDias = CRE.nNumDiaApr
				,CuotasAprobadas = CRE.nNumCuoApr
				,DiasGracia = CRE.nNumDiaGra
				,PlazoTotalEnDias = ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)	
				,EstadoCredito =
				 Case CRE.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END
				,DiasdeMora = CRE.nDiaAtrCre 														 
				,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolso'				
				--,CRE.cEstCreCon
				--,EC.cDescriEst AS 'EstadoCredito'	
				,DestinoCredito = ISNULL(D2.cDescriDes,'NO REGISTRA')				
				,CRE.cCodUsuAna AS 'CodAsesorActual'
				,SP.cNomPerson AS 'NombreAsesorActual'			
				,Oficina = O.cDesOficin										
				,Zona = ZON.cDesZona
			INTO #TAB01 							
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
				INNER JOIN [GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
				INNER JOIN [KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
				left JOIN KPYTEstCreCon EC 
					ON EC.cEstCreCon = CRE.cEstCreCon
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
				inner JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna	
				--condicion credito 
				left JOIN [KPYTConCredit] D
					ON D.cCondicCon = CLI.cCondicCon			 		
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = CRE.cCodDesCre
				LEFT JOIN KPYDDatAdiHip DH
					ON DH.cCodSolCre = CRE.cCodSolCre								
			WHERE CRE.cEstCreCon in ('F','H')					
				AND	CRE.cCodTipCre   =		'04'				
				AND (STC.cDesSubCre   LIKE '%VIVIENDA%' OR STC.cDesSubCre   LIKE '%CONSTRUCCI%'
					 OR STC.cDesSubCre   LIKE '%MI%CASA%M%')
				AND left(cast(CRE.dFecDesCre as date),10) >= '2015-01-01' 												

		ALTER TABLE #TAB01
		ADD ModalidadBono CHAR(3)
	
		/*
			SELECT nMonBonCom,*
			FROM KPYDDatAdiHip 
					
			SELECT * FROM #TAB01
			DROP TABLE #TAB01

			SELECT *
			FROM [HYO00409\HISTORICO].SOFCMACHYO_201511.dbo.[KPYTSUBTIPCRE]
			WHERE lEstado = '1' AND cCodTipCre = '04'
			ORDER BY cCodTipCre			
		
			modalidad de bono (PBP o BBP en caso de BBP monto del bono)
		*/
		
		/*
			SELECT * 
			FROM KPYDPLANPAGCRE
			WHERE cCodCtaCre = '107060101000748761'
					AND cCodPlaPag = (SELECT MAX(cCodPlaPag) 
									  FROM KPYDPLANPAGCRE
									  WHERE cCodCtaCre = '107060101000748761')
					--AND cCodClaCuo =	'BP'
			ORDER BY cNumCuoPla
		*/
		--------------------DETERMINAR -------------------------------
			Declare @ccodcred char(18), @lcModo CHAR(4)
			Declare cPlan CURSOR FOR	
				
				SELECT CodigoCredito FROM #TAB01				

			OPEN cPlan
				FETCH cPlan into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN					
									
					SET @lcModo = 
						(SELECT TOP 1 cCodClaCuo
						 FROM KPYDPLANPAGCRE
						 WHERE cCodCtaCre = @ccodcred
						 		AND cCodPlaPag = (SELECT MAX(cCodPlaPag) 
						 						  FROM KPYDPLANPAGCRE
												  WHERE cCodCtaCre = @ccodcred)
								AND cCodClaCuo =	'BP')							 

					IF @lcModo IS NULL 
					BEGIN
							UPDATE #TAB01
							SET ModalidadBono	=	'BBP'	
							WHERE CodigoCredito = @ccodcred
					END 
					ELSE
												 
							UPDATE #TAB01
							SET ModalidadBono	=	'PBP'	
							WHERE CodigoCredito = @ccodcred
					
				FETCH cPlan INTO @ccodcred
				END
				CLOSE cPlan
				DEALLOCATE cPlan
		-------------------------------------------------------------

		--	SELECT * FROM #TAB01