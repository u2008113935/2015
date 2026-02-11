		
	/*

		Información para la clasificadora CLASS:
		- Créditos vigentes a setiembre 2015(código del crédito, monto desembolsado, saldo capital
				,fecha de desembolso, plazo) todo convertido a soles
		- 100 principales clientes a setiembre 2015(código del cliente, código del crédito
				,monto desembolsado, saldo capital, fecha de desembolso, plazo) todo convertido a soles

	*/

	-- 01 
	
	/*
	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-10-01'				
				)				

	Select 		
			/*
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
			*/			
			--Datos del credito			
			CRE.cCodCtaCre AS 'CodigoCredito'									
			,MontoDesembolsoenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN CRE.nMonCapDes
				WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
				END					
			,SaldoCapitalenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
				WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
				END							
			,EstadoCredito = EC.cDescriEst
			,SituacionContable =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END														 
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolso'
			,PlazoCuotaEnDias = CRE.nNumDiaApr
			,CuotasAprobadas = CRE.nNumCuoApr
			,DiasGracia = CRE.nNumDiaGra
			,PlazoTotalEnDias = ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)	
			,STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito'			 
			,STC.cDesProCre AS 'ProductoCrediticio' 			 
			,STC.cDesSubcRE AS 'SubProductoCrediticio' 																				
												
	FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre		
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'	
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
			 INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'			 					 								
	WHERE CRE.cEstCreCon in ('F','H')
		--and D.cCondicCon = '01'
	Order By left(cast(CRE.dFecDesCre as date),10) asc


	-- Select * from [KPYTConCredit]

	-- 100 principales clientes a setiembre 2015(código del cliente, código del crédito
				--,monto desembolsado, saldo capital, fecha de desembolso, plazo) todo convertido a soles
	
	*/

	--02

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio1 MONEY,	@dFecTipCam1 DATE					
		set @nTipCambio1 = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-10-01'				
				)

	Select 	top 100	
			/*
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
			*/			
			--Datos del credito			
			CodigoCliente = CLI.cCodCliente
			,CRE.cCodCtaCre AS 'CodigoCredito'							
			,MontoDesembolsoenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN CRE.nMonCapDes
				WHEN '2' THEN @nTipCambio1 * CRE.nMonCapDes
				END					
			,SaldoCapitalenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
				WHEN '2' THEN @nTipCambio1 * (CRE.nMonCapDes - CRE.nMonCapPag)
				END							
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END														 
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolso'
			,PlazoCuotaEnDias = CRE.nNumDiaApr
			,CuotasAprobadas = CRE.nNumCuoApr
			,DiasGracia = CRE.nNumDiaGra
			,PlazoTotalEnDias = ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)															
			,STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito'			 
			,STC.cDesProCre AS 'ProductoCrediticio' 			 
			,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
	FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre		
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'	
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
			 INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'			 					 											 					 								

	WHERE CRE.cEstCreCon = 'F'
		--and D.cCondicCon = '01'
		
	Order By  
			(case cre.cCodTipMon
				WHEN '1' THEN CRE.nMonCapDes
				WHEN '2' THEN @nTipCambio1 * CRE.nMonCapDes
				END)  
			desc


	---------------------------------------------------------------------------------------

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-11-01'				
				)		
	
	-- Select @fecactual, @nTipCambio			
		-- Select @nTipCambio, @fecactual
		-- DATOS DE CREDITOS CONVENCIONALES				
		-- Drop table #KPYMCreConven

		SELECT * INTO #KPYMCreConven FROM (
			SELECT A.cCodCtaCre, B.cCodCliente,A.cEstCreCon,A.cCodRefina
					,MontoDesembolsoenSoles = 
						case A.cCodTipMon
						WHEN '1' THEN A.nMonCapDes
						WHEN '2' THEN @nTipCambio * A.nMonCapDes
						END,	
					nSaldoCapi = (CASE WHEN A.cEstCreCon IN ('F', 'H')
									THEN (A.nMonCapDes - A.nMonCapPag) * 
																	CASE WHEN A.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVig = (CASE WHEN A.cEstCreCon = 'F' AND A.cCodRefina = 'N'
									THEN A.nMonSalNor * CASE WHEN A.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVen = (CASE WHEN A.cEstCreCon = 'F' and A.nMonSalVen > 0
									THEN A.nMonSalVen * CASE WHEN A.cCodTipMon = '2' 
									THEN @nTipCambio ElSE 1 END
										ELSE 0 END),
					nSaldoJud = (CASE WHEN A.cEstCreCon = 'H' THEN A.nMonSalVen * 
																	CASE WHEN A.cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoRef = (CASE WHEN A.cEstCreCon = 'F' AND A.nMonSalNor > 0 
																	AND A.cCodRefina = 'S'
									THEN A.nMonSalNor	* CASE WHEN A.cCodTipMon = '2' 
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					cCodModCre = 'KPY'
					,A.cCodTipCre, A.cCodProduc, A.cCodSubPro
					,FechaDesembolso = left(cast(A.dFecDesCre as date),10) 
					,PlazoCuotaEnDias = A.nNumDiaApr
					,CuotasAprobadas = A.nNumCuoApr
					,DiasGracia = A.nNumDiaGra
					,PlazoTotalEnDias = ((A.nNumDiaApr * A.nNumCuoApr) + A.nNumDiaGra)	
			FROM KPYMCREconven A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaCre = B.cCodCtaCre		
			WHERE A.CESTCRECON IN ('F','H')	

			--Select * from #KPYMCreConven		-- drop table #KPYMCreConven
			UNION ALL		
			
			-- BASE DE DATOS DE CREDITOS PRENDARIOS
			SELECT  A.cCodCtaKpr, B.cCodCliente
					,A.cCodEstKpr,cCodRefina = ''					
					,MontoDesembolsoenSoles = 
						case A.cCodTipMon
						WHEN '1' THEN A.nMonNetKpr
						WHEN '2' THEN @nTipCambio * A.nMonNetKpr
						END,	
					nSaldoCapi = (nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END),
					nSaldoVig = (CASE WHEN nDiaAtrCre <= 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' 
								  THEN  @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoVen = (CASE WHEN nDiaAtrCre > 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' 
								  THEN @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoJud = 0,
					nSaldoRef = 0,
					cCodModCre = 'KPR'
					,cCodTipCre='03', cCodProduc='13', cCodSubPro='16'							
					,FechaDesembolso = left(cast(A.dFecCreKpr as date),10) 
					,PlazoCuotaEnDias = A.nDiaPlaKpr
					,CuotasAprobadas = A.nNumRenKpr
					,DiasGracia = 0
					,PlazoTotalEnDias = (A.nDiaPlaKpr * A.nNumRenKpr) 				
			FROM KPRMCrePrenda A				
				INNER JOIN GENMCreCli B
					ON A.cCodCtaKpr = B.cCodCtaCre
			WHERE	A.cCodEstKpr IN ('A','D','G','H','R')						
			) AS  tmp
			
			
		CREATE NONCLUSTERED INDEX #KPYMCreConven_cCodCtaCre_IXN ON #KPYMCreConven(cCodCtaCre)	
		CREATE NONCLUSTERED INDEX #KPYMCreConven_cCodCliente_IXN ON #KPYMCreConven(cCodCliente)	


		Select * from #KPYMCreConven	
			-- (230,236 row(s) affected)		
		
		
		Select * from #KPYMCreConven	
		Where -- 107001011008174206 , 107001012002720403
				-- PlazoCuotaEnDias is null

			Update #KPYMCreConven	
			Set PlazoCuotaEnDias = 30
			Where PlazoCuotaEnDias is null

		Select * from #KPYMCreConven	
		Where DiasGracia is null

			Update #KPYMCreConven	
			Set DiasGracia = 0
			Where DiasGracia is null

		Select * from #KPYMCreConven	
		Where PlazoTotalEnDias is null

			Update #KPYMCreConven	
			Set PlazoTotalEnDias = 900
			Where PlazoTotalEnDias is null


		Select sum(nSaldoVig)
		From #KPYMCreConven

		Select sum(nSaldoCapi)
		From #KPYMCreConven

	--------------------------------------------------------------
	
	Select * into #tab02 from (
		Select A.* 
			,B.cDesTipCre AS 'TipoCredito'
			,B.cDesSubTip AS 'SubTipoCredito'			 
			,B.cDesProCre AS 'ProductoCrediticio' 			 
			,B.cDesSubcRE AS 'SubProductoCrediticio' 	
			,EstadoCredito = ISNULL(EC.cDescriEst,'VIGENTE')
			,SituacionContable =
			 Case A.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END	
		From #KPYMCreConven A
			INNER JOIN [KPYTSUBTIPCRE] B
				ON A.cCodTipCre = B.cCodTipCre AND A.cCodProduc = B.cCodProduc 
					AND A.cCodSubPro = B.cCodSubPro and B.lEstado = '1'			
			LEFT JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = A.cCodCtaCre		
			LEFT JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = A.cEstCreCon			
			-- SITUACION CONTABLE
			LEFT JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon			
			) as tmp

		-- (230,236 row(s) affected)
		
		CREATE NONCLUSTERED INDEX #tab02_cCodCtaCre_IXN ON #tab02(cCodCtaCre)	
		CREATE NONCLUSTERED INDEX #tab02_cCodCliente_IXN ON #tab02(cCodCliente)	


		SELECT * FROM #tab02


		Drop table #tab02
		Drop table #KPYMCreConven

						