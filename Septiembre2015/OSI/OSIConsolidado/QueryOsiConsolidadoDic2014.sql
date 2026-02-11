
	/*

	-- CONSOLIDADO
	1. Reporte detallado por cliente de las colocaciones al 31.12.2014, 
		de los créditos en estado: Normal, Saldo vencido, Saldo judicial, 
		Cartera atrasada, Cartera refinanciada y reprogramada													
													
	N° de Orden, Código de Crédito, Línea de Crédito, Producto, Monto Aprob.
	Fecha de Desemb., Moneda, Destino, Modalidad, Analista Solicitud, Plazo, Cuotas,
	Saldo Capital al 31-12-2014, Estado

	*/

	SET LANGUAGE spanish;
		--Tipo cambio 
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-01-01'				
				)			
					
	Select * into #tab01 from (

		Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY GEN.cCodCliente
					ORDER BY C.cNomCliente ) AS Secuencia, 			
			GEN.cCodCliente AS 'CodigoCliente'		
			,C.cNomCliente AS 'NombreCliente',	
			CRE.cCodCtaCre AS 'CodigoCredito'				
			,LineaCredito = GEN.cCodLinCre 						
			,STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito'			 
			,STC.cDesProCre AS 'ProductoCrediticio' 			 
			,STC.cDesSubcRE AS 'SubProductoCrediticio' 				
			,CRE.nMonCapDes as 'MontoAprobado'
			,TipoCambio = @nTipCambio 
			,MontoAprobadoenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN CRE.nMonCapDes
				WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
				END	
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
			,case cre.cCodTipMon
				when '1' then 'SOLES'
				when '2' then 'DOLARES'
				end AS 'Moneda'
			,Destino = ISNULL(D2.cDescriDes,'NO REGISTRA')		
			,Modalidad = M.cDesModCre	
			,Plazo = T.cDesPlazo
			,NumeroCuotas = CRE.nNumCuoApr							
			,CodAsesorSolicitud = CRE.cCodUsuAna
			,AsesorSolicitud = P.cNomPerson
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'																	 					
			,SaldoCapitalenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
				WHEN '2' THEN (@nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag))
				END						
			,EC.cDescriEst AS 'EstadoCredito'	
			,CondicionContable =
				 Case CRE.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END									
					
		FROM [KPYMCRECONVEN] CRE (NOLOCK)	
			INNER JOIN [GENMCRECLI] GEN 
				ON GEN.cCodCtaCre = CRE.cCodCtaCre	
			left JOIN CMACHYOCLI_201507.dbo.[CLIMCLIENTES] C 
				ON C.cCodCliente = GEN.cCodCliente				
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			LEFT join KPYTDesCreCon D2
				on D2.cCodDesCre = CRE.cCodDesCre	
			INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = GEN.cCondicCon			
			left join KPYTModCredit	M	
				ON CRE.cCodModCre = M.cCodModCre
					and M.lConEstado = 1	
			LEFT join [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.GENTTipPlazo T	
				on T.cCodPlazo = CRE.cCodPlazo
				
			left join sipmpersonal P 
				on P.cCodPerson = CRE.cCodUsuAna
			
		WHERE CRE.cEstCreCon in ('F','H')					
			--and CRE.cCodOficin = '009'	
		--Group By CRE.cCodCtaCre, C.cNomCliente, CRE.cCodTipMon 
		--	) as tmp
			
		/*
		CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01(CodigoCredito)				
		CREATE NONCLUSTERED INDEX #tab01_LineaCredito_IXN ON #tab01(LineaCredito)	
		CREATE NONCLUSTERED INDEX #tab01_CodigoCliente_IXN ON #tab01(CodigoCliente)						

		-- (209,437 row(s) affected)
		
		--Select * from #tab01
		Select CantCred = count(*) from #tab01
		Select SaldoCred = sum(SaldoCapitalenSoles) from #tab01
		
		-- 1,590,178,582.42
		-- 1,590,178,582.42
		*/
	-----------------------------------------------------------------------
	
	/*
	 Drop table #tab01
	 Drop table #tab02
	 Drop table #tab03
	*/	

	UNION ALL			
					
	-- Select * into #tab02 from (
		Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY GEN.cCodCliente
					ORDER BY C.cNomCliente ) AS Secuencia, 			
			GEN.cCodCliente AS 'CodigoCliente'		
			,C.cNomCliente AS 'NombreCliente'
			,PREN.cCodCtaKpr AS 'CodigoCredito'				
			,LineaCredito = GEN.cCodLinCre 						
			,TipoCredito = 'CONSUMO'				
			,SubTipoCredito = 'PIGNORATICIOS'			 
			,ProductoCrediticio = 'PRESTAMOS' 			 
			,SubProductoCrediticio = 'CREDIJOYAS' 		
			,PREN.nMonCreKpr as 'MontoAprobado'
			,TipoCambio = @nTipCambio 
			,MontoAprobadoenSoles = 
				case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonCreKpr
				WHEN '2' THEN @nTipCambio * PREN.nMonCreKpr
				END	
			,left(cast(PREN.dFecCreKpr as date),10) as 'FechaDesembolsoCredito'
			,case PREN.cCodTipMon
				when '1' then 'SOLES'
				when '2' then 'DOLARES'
				end AS 'Moneda'
			,Destino = ISNULL(D2.cDescriDes,'NO REGISTRA')		
			,Modalidad = 'PRINCIPAL'
			,Plazo = 'CORTO PLAZO'
			,NumeroCuotas = PREN.nNumRenKpr							
			,CodAsesorSolicitud = PREN.cCodUsuKpr
			,AsesorSolicitud = P.cNomPerson
			,PREN.nMonSalAct AS 'SaldoCapital'																	 					
			,SaldoCapitalenSoles = 
				case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonSalAct
				WHEN '2' THEN (@nTipCambio * PREN.nMonSalAct)
				END							
			,E.cDesEstKpr AS 'EstadoCredito'
			,CondicionContable =
				 Case PREN.cCodEstKpr
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END									
			
		FROM [KPRMCREPRENDA] PREN (NOLOCK)	
				INNER JOIN 	[GENMCRECLI] GEN 
					ON GEN.cCodCtaCre = PREN.cCodCtaKpr
				INNER JOIN CMACHYOCLI_201507.dbo.[CLIMCLIENTES] C 
					ON C.cCodCliente = GEN.cCodCliente									

				INNER JOIN KPRTEstCredito E 
					ON E.cCodEstKpr = PREN.cCodEstKpr
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = PREN.cCodEstKpr
				INNER JOIN [KPYTConCredit] D
					ON D.cCondicCon = GEN.cCondicCon							
			
				left join sipmpersonal P 
					on P.cCodPerson = PREN.cCodUsuKpr
			
		WHERE PREN.cCodEstKpr in ('D','A','R','G','H')	
			--and CRE.cCodOficin = '009'	
		--Group By CRE.cCodCtaCre, C.cNomCliente, CRE.cCodTipMon 
			) as tmp
		
		/*	
		CREATE NONCLUSTERED INDEX #tab02_CodigoCredito_IXN ON #tab02(CodigoCredito)				
		CREATE NONCLUSTERED INDEX #tab02_LineaCredito_IXN ON #tab02(LineaCredito)	
		CREATE NONCLUSTERED INDEX #tab02_CodigoCliente_IXN ON #tab02(CodigoCliente)				
		
		-- (1,399 row(s) affected)

		-- Select * from #tab02
		Select CantPignoraticio = count(*) from #tab02
		Select SaldoPignoraticio = sum(SaldoCapitalenSoles) from #tab02
		*/

		CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01(CodigoCredito)				
		CREATE NONCLUSTERED INDEX #tab01_LineaCredito_IXN ON #tab01(LineaCredito)	
		CREATE NONCLUSTERED INDEX #tab01_CodigoCliente_IXN ON #tab01(CodigoCliente)	
		
		/*
		Select * from #tab01 
		Order By NombreCliente
		*/
		Select CantPignoraticio = count(*) from #tab01
		Select SaldoPignoraticio = sum(SaldoCapitalenSoles) from #tab01

	--------------------CREDITOS PIGNORATICIOS-------------------------------------------

		/*
		Select 

		Select * from KPYTSUBTIPCRE
		Where lestado = '1' and cCodTipCre = '03' and cDesSubCre like '%joy%'					

			/*
			-- DISTINCT 
			GEN.cCodCliente
			,PREN.nMonSalAct
			,PREN.nMonCreKpr -- ok
			--,PREN.nMonNetKpr 			
			,PREN.cCodCtaKpr
			,PREN.cCodTipMon
			,SaldoenSoles = 
				Case PREN.cCodTipMon 
				when '1' then PREN.nMonSalAct
				when '2' then PREN.nMonSalAct * @nTipCambio1
				end 
			,dFecCreKpr = left(cast(PREN.dFecCreKpr as date),10)
			,PREN.cTipCreKpr
			*/
			/*
			PREN.cCodUsuKpr AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'				
			--Datos del credito			
			,PREN.cCodCtaKpr AS 'CodigoCredito'	
			,Expediente = E.cCodExpCli			
			,Pagare = ISNULL(RIGHT(RTRIM(LIN.CCODPAGARE),12), '')
			,C.cCodCliente 												
			,PREN.nMonCreKpr as 'MontoDesembolso' 
			,PREN.nMonSalAct AS 'SaldoCapital'
			,case PREN.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,TipoCambio = @nTipCambio1			
			,MontoDesembolsoenSoles = 
				case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonCreKpr
				WHEN '2' THEN @nTipCambio1 * PREN.nMonCreKpr
				END					
			*/
			SaldoCapitalenSoles = 
				case PREN.cCodTipMon
				WHEN '1' THEN sum(PREN.nMonSalAct)
				WHEN '2' THEN sum(@nTipCambio1 * PREN.nMonSalAct)
				END								
			/*
			,PREN.nTasIntKpr
			--,NumeroCuotas = CRE.nNumCuoApr				
			/*
			,DiasAtraso = 
				Case when CRE.nDiaAtrCre < 0 then 0
				else CRE.nDiaAtrCre end
			,EC.cDescriEst AS 'EstadoCredito'	
			,CondicionContable =
				 Case CRE.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END														 
			*/
			,left(cast(PREN.dFecCreKpr as date),10) as 'FechaDesembolsoCredito'
			,Anio= year(PREN.dFecCreKpr), Mes = MONTH (PREN.dFecCreKpr)
			,NombreMes =DATENAME(month, PREN.dFecCreKpr)	
			--,CRE.cEstCreCon			
			
			,GEN.cCodCliente AS 'CodigoCliente'		
			,C.cNomCliente AS 'NombreCliente'
			,NroDocumento = isnull(C.cNroDocIde, C.cNroDocTri)	
			,C.cCodSbs						
			--,DestinoCredito = ISNULL(D2.cDescriDes,'NO REGISTRA')		
			,CIUU = isnull(C.cCodCiiu,'9999')
			,Actividad = CI.cdesactivi
			,Ubicacion = ISNULL(DC.cDirCliRef,'NO INDICA')
			,DireccDomic = REPLACE(rtrim(DC.cDirCliente),'.','')				
			
			,ZonaDomic = ISNULL(Z.cNomZona,'NO INDICA')
			,DistDomic = DIS1.cNomDistri
			,ProvDomic = PRO1.cNomProvin 			
			,DepartDomic = DEP1.cNomDepart 				
			/*
			,CaliRCC = 
				Case when RCC.CCLAFIN = '0' then 'NORMAL' ELSE 'NO REGISTRA' END	
			*/													
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona		
			*/
		FROM [KPRMCREPRENDA] PREN (NOLOCK)		
				/*
				INNER JOIN 	[GENMCRECLI] GEN 
					ON GEN.cCodCtaCre = PREN.cCodCtaKpr

				INNER JOIN CMACHYOCLI_201507.dbo.[CLIMCLIENTES] C 
					ON C.cCodCliente = GEN.cCodCliente					
							
				LEFT JOIN KPYMLINCRECLI LIN  (NOLOCK)  
					 ON GEN.CCODLINCRE = LIN.CCODLINCRE  
						 AND GEN.CCODCLIENTE = LIN.CCODCLIENT  
			
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = PREN.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
				INNER JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = PREN.cCodUsuKpr	
				--condicion credito 
				INNER JOIN [KPYTConCredit] D
					ON D.cCondicCon = GEN.cCondicCon			 
			
				left join CMACHYOCLI_201507.dbo.[CLIMDirecc] DC				
					on DC.cCodCliente = C.CCODCLIENTE and DC.bDirPredet = '1'
			
				INNER join CMACHYOCLI_201507.DBO.CLIDExpediente E
					on E.cCodClient = C.cCodCliente	AND E.cTipExpCli = 'K'
						AND E.lConEstado = '1'

				/*
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = CRE.cCodDesCre
				*/
				left join GENTCodCiiu CI
					on CI.ccodciiu = C.cCodCiiu	
			
				left JOIN [GenTDepartame] DEP1
					ON DEP1.cCodDepart = DC.cCodDepart
				left JOIN [GentProvincia] PRO1
					ON pro1.cCodProvin = DC.cCodProvin and pro1.cCodDepart = DC.cCodDepart
				left JOIN [GentDistrito] DIS1
					ON dis1.cCodDistri = DC.cCodDistri	 and dis1.cCodProvin = DC.cCodProvin 
						and dis1.cCodDepart = DC.cCodDepart					
			
				left JOIN GENTZona Z
					ON Z.cCodZona = DC.cCodZona 
						and Z.cCodDepart = DC.cCodDepart
						and Z.cCodProvin = DC.cCodProvin
						and Z.cCodDistri = DC.cCodDistri							 						
				*/
		WHERE PREN.cCodEstKpr in ('D','A','R','G','H')		
				--and PREN.nMonSalAct > 0	
				--and PREN.cCodOficin = '009'		
		Group By PREN.cCodTipMon
		
		sELECT * FROM [sipmpersonal]
		WHERE cCodPerson = 'EPORTA'
		-- nMonSalAct	Monto de saldo actual
		-- nMonCreKpr	Monto de crédito
		-- nMonNetKpr	Monto neto		

		*/