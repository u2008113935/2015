
	SET LANGUAGE spanish;
		--Tipo cambio 
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-09-01'				
				)		
	
	sELECT * INTO #TAB01 FROM (
			Select 						
					PREN.cCodCtaKpr AS 'CodigoCredito'							
					,TipoCredito = 'CONSUMO'				
					,SubTipoCredito = 'PIGNORATICIOS'			 
					,ProductoCrediticio = 'PRESTAMOS' 			 
					,SubProductoCrediticio = 'CREDIJOYAS' 		
					,GEN.cCodCliente AS 'CodigoCliente'		
					,C.cNomCliente AS 'NombreCliente'			
					,PREN.nMonCreKpr as 'MontoAprobado'			
					,MontoAprobadoenSoles = 
						case PREN.cCodTipMon
						WHEN '1' THEN PREN.nMonCreKpr
						WHEN '2' THEN @nTipCambio * PREN.nMonCreKpr
						END				
					,case PREN.cCodTipMon
						when '1' then 'SOLES'
						when '2' then 'DOLARES'
						end AS 'Moneda'
					,TipoCambio = @nTipCambio 
					,PREN.nMonSalAct AS 'SaldoCapital'																	 					
					,SaldoCapitalenSoles = 
						case PREN.cCodTipMon
						WHEN '1' THEN PREN.nMonSalAct
						WHEN '2' THEN (@nTipCambio * PREN.nMonSalAct)
						END							
					,CodAsesorSolicitud = PREN.cCodUsuKpr
					,AsesorSolicitud = P.cNomPerson	
					,Agencia = O.cDesOficin
					,CodigoSolicitud = GEN.cCodLinCre
					,FechaSolicitud  = left(cast(GEN.dFecAsiCre as date),10)
					,left(cast(PREN.dFecCreKpr as date),10) as 'FechaDesembolsoCredito'									
					,PlazoAtencion = 
						datediff (DAY,left(cast(GEN.dFecAsiCre as date),10),left(cast(PREN.dFecCreKpr as date),10))
				FROM KPRMCREPRENDA PREN (NOLOCK)	
						INNER JOIN [GENMCRECLI] GEN 
							ON GEN.cCodCtaCre = PREN.cCodCtaKpr
						INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
							ON C.cCodCliente = GEN.cCodCliente													
			
						left join sipmpersonal P 
							on P.cCodPerson = PREN.cCodUsuKpr
						INNER JOIN [GENTOficinas] O 
							ON O.cCodOficin = PREN.cCodOficin and O.lConEstado = '1'			
																		
				WHERE PREN.cCodEstKpr in ('D','A','R','G','H')	
					--and CRE.cCodOficin = '009'	
				--Group By CRE.cCodCtaCre, C.cNomCliente, CRE.cCodTipMon 
			) AS TMP

			sELECT * FROM #TAB01

			SELECT Agencia, SaldoCapitalenSoles = SUM(SaldoCapitalenSoles) 
			FROM #TAB01
			GROUP BY Agencia

			-- drop table #TAB01
