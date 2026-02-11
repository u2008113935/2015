
	/*
		Buenos Días, por favor se requiere la siguiente información:
		relación de clientes de créditos consumo y pequelña empresa que cuenten con:
					
					evaluación de crédito consumo con un ingreso bruto mayor a 3,000 					
					o empresarial con excedente mayor a 1,000 

			con créditos vigentes o cancelados y que contemplen la siguiente información:
				Nombre del cliente, DNI,teléfono, monto de ingreso, dirección zona, referencia, distrito,
				provincia (Huancayo), Distritos huancayo tambo y chilca
					
					con promedio de atraso en sus cuotas no mas de 05 días, 
					calificación normal, asesor de negocios, agencia, ESTADO (VIGENTE O CANCELADO).
		
	*/
	
	
	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-10-01'				
				)

	-- drop table #tab01
	Select * into #tab01 from (

			Select 		
					/*
					ROW_NUMBER() 
					OVER(PARTITION BY CRE.cCodUsuAna
							ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 												
					*/	
					CLI.cCodCliente AS 'CodigoCliente'	
					,CLIM.cNomCliente AS 'NombreCliente'
					,CLIM.cNroTelPer
					,TipoPersona = T.CdesCorta						
					
					,TipoDocumento = TD.cCodTipDocId
					,DescripTipDoc =  TD.cDesCorta					
					
					,NroDoc = isnull(CLIM.cNroDocIde,CLIM.cNroDocTri)
					,DireccionDomi = DC.cDirCliente	
					,CodZona = Z.cCodZona, ZonaNDomi = Z.cNomZona
					--,CodDistriDomi = isnull(DC.cCodDistri,'0')
					,DistriDomi = isnull(DIS1.cNomDistri,'NO INDICADO')					
					--,CodProvinDomi = isnull(DC.cCodProvin,'0')
					,ProvinDomi = isnull(PRO1.cNomProvin,'NO INDICADO')
					--,CodDepartDomi = isnull(DC.cCodDepart,'0')
					,DepartDomi = isnull(DEP1.cNomDepart,'NO INDICADO')					
					,CLIM.CCODSBS , CRE.cCodSolCre	
					--Datos del credito			
					,CRE.cCodCtaCre AS 'CodigoCredito'
					,CLI.cCodLinCre								
					,STC.cDesTipCre AS 'TipoCredito'
					,STC.cDesSubTip AS 'SubTipoCredito'			 
					,STC.cDesProCre AS 'ProductoCrediticio' 			 
					,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
					,CRE.nMonCapDes as 'MontoDesembolso' 
					,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
					,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,TipoCambio = @nTipCambio					
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
					,TEM=CRE.nTasintCom	
					,NumeroCuotas=CRE.nNumCuoApr					
					,CRE.cEstCreCon
					,EC.cDescriEst AS 'EstadoCredito'		
					,CondicionCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END					
					,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
					,left(cast(CRE.dFecCulCre as date),10) as 'FechaCancelacion'
					/*
					,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
					,NombreMes =DATENAME(month, CRE.DFECDESCRE)					
					*/
					,Oficina = O.cDesOficin										
					,Zona = ZON.cDesZona	
					,CRE.cCodUsuAna AS 'CodAsesorActual'
					,SP.cNomPerson AS 'NombreAsesorActual'	
		
			FROM [KPYMCRECONVEN] CRE (NOLOCK)		
					INNER JOIN [GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
					INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
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
					--condicion credito 
					 INNER JOIN [KPYTConCredit] D
						ON D.cCondicCon = CLI.cCondicCon	
					inner join [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC							
						on DC.cCodCliente = CLI.CCODCLIENTE and DC.bDirPredet = '1'
					
					INNER JOIN [GenTDepartame] DEP1
						ON DEP1.cCodDepart = DC.cCodDepart
					INNER JOIN [GentProvincia] PRO1
						ON pro1.cCodProvin = DC.cCodProvin and pro1.cCodDepart = DC.cCodDepart
					INNER JOIN [GentDistrito] DIS1
						ON dis1.cCodDistri = DC.cCodDistri	 and dis1.cCodProvin = DC.cCodProvin 
							and dis1.cCodDepart = DC.cCodDepart			
					INNER JOIN GENTZona Z
						ON Z.cCodZona = DC.cCodZona 
							and Z.cCodDepart = DC.cCodDepart
							and Z.cCodProvin = DC.cCodProvin
							and Z.cCodDistri = DC.cCodDistri	
					inner join GENTClaPersona T
						on T.cCodClaPer = CLIM.cCodClaPer						
					
					inner join SOFCMACHYO_DIARIO_NOCHE.dbo.GENTTipDocIde TD
						on TD.cCodTipDocId = CLIM.cCodTipDocId 
								
				WHERE CRE.cEstCreCon in ('F','G')					
					and CRE.cCodTipCre IN ('03','13')
					AND D.cCondicCon = '01'
					AND PRO1.cNomProvin like '%HUANCAYO%'
					and (DIS1.cNomDistri like '%HUANCAYO%' OR DIS1.cNomDistri like '%TAMBO%' 
							OR DIS1.cNomDistri like '%CHILCA%')
				--Order By CLI.cCodCliente
				) as tmp 

				-- (142,998 row(s) affected)
		
			/*
				Select * from [KPYTSUBTIPCRE] STC
				Where STC.lEstado = '1'
				Order By cCodTipCre

				select * from #tab01

			*/

		-- drop table #DEvaSolici
		Select * into #DEvaSolici from (
			Select top 1 nNumEvaMes,cCodSolCre from KpyDEvaSolici			
			) as tmp
		-- Drop table #DEvaSolici
		-- Select * from #DEvaSolici
		Delete from #DEvaSolici

		
		----------------------------CURSOR EVALUACION-----------------------
			Declare @codsolcre char(10) 				
				Declare cE CURSOR FOR
					
				Select distinct cCodSolCre from #tab01 (NOLOCK)									

				OPEN cE
				FETCH cE into @codsolcre
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #DEvaSolici 					
					Select top 1
						nNumEvaMes,cCodSolCre 	
					FROM KpyDEvaSolici
					where cCodSolCre = @codsolcre						
			
				FETCH cE INTO @codsolcre
				END
				CLOSE cE
				DEALLOCATE cE
		-------------------------------------------------------------------

			-- (170,209 row(s) affected)
	
		/*
				
		Select * From #tab01
			-- (107,270 row(s) affected)

		Select * from #DEvaSolici
		Order By nNumEvaMes asc
			-- (170,209 row(s) affected)

		Select * from #DEvaSolici
		Where nNumEvaMes = '1034104'
		1034104
		1080187

		nNumEvaMes	cCodSolCre
		1034104		0080051224
		1034104		0080050499
		1034104		0080047784
		1034104		0080048340

		Select  *
		FROM KpyDEvaSolici
		Where cCodSolCre = '0080051224'

		Select  *
		FROM KpyDEvaSolici
		Where cCodSolCre = '0080050499'

		Select  *
		FROM KpyDEvaSolici
		Where cCodSolCre = '0080047784'

		Select  *
		FROM KpyDEvaSolici
		Where cCodSolCre = '0080048340'

						Select * From #tab01
						where cCodSolCre in ('0080048340','0080047784','0080050499','0080051224')
						-- (108,898 row(s) affected)	



		-- cCodSolCre		
		Select cCodSolCre, count(cCodSolCre)	
		from #DEvaSolici
		Group By cCodSolCre
		Having count(cCodSolCre) > 1
		
		-- EXTRAYENDO LOS RATIOS
			Select * from KpyMEvaSolMes
			Where nNumEvaMes = '933090' --'1042185'

			Select top 1 * from KpyMEvaSolMes
			Where nNumEvaMes = '933090' --'1042185'

			Select len(nNumEvaMes) from KpyMEvaSolMes
			Order by len(nNumEvaMes) desc

			Select nNumEvaMes, count(nNumEvaMes) from KpyMEvaSolMes
			Group By nNumEvaMes
			Having count(nNumEvaMes) > 1
			Order By count(nNumEvaMes) desc

		  */
		
		/*
		
	
		Select * from #DEvaSolici
		Order By nNumEvaMes asc
			-- (107,854 row(s) affected)
				Select nNumEvaMes, count(nNumEvaMes) from #DEvaSolici
				Group By nNumEvaMes
				Having count(nNumEvaMes) > 1
				Order By count(nNumEvaMes) desc



		*/  

		-- Drop table #tab02
		Select * into #tab02 from (
			Select A.* , B.nNumEvaMes 			
			From #tab01 A
			inner join #DEvaSolici B
				on A.cCodSolCre = B.cCodSolCre
				) as tmp

			/*	
				 Select * from #tab02
				-- (138,800 row(s) affected)

				Select * from #tab02
				Where TipoCredito = 'CONSUMO' 
			*/

		CREATE NONCLUSTERED INDEX #tab02_CodigoCliente_IXN ON #tab02(CodigoCliente)
		CREATE NONCLUSTERED INDEX #tab02_CodigoCredito_IXN ON #tab02(CodigoCredito)	
		CREATE NONCLUSTERED INDEX #tab02_cCodSolCre_IXN ON #tab02(cCodSolCre)
		CREATE NONCLUSTERED INDEX #tab02_nNumEvaMes_IXN ON #tab02(nNumEvaMes)		
				
		/*
		Select * from #tab02			
		-- (106,298 row(s) affected)

			Select * from #tab02
			Where nNumEvaMes = ''

			Select cAspExpAct,* from KpyMEvaSolMes	
			Select top 5 * from KpydEpgEvaSol1								 

		*/

		-- Drop table #EvaSol
		Select * into #EvaSol from (
				Select top 1
					nMonVentas,nCosVenPro,nUtilidBru,nGasOpeNeg,nGasPerson,nGasServic,nUtilidOpe,nObligaNeg
					,nOblNetNeg,nOtrIngUef,cDesIngUef,nIngFueNeg,cDesOtrUef,nImpOtrUef,nTotOblFam,nGasFamili
					,nMonEventu,nPorcenEve,nNumPerDep,nResultUef,nCapacPago,nTotPorEpg,nNumEvaMes
				From KpydEpgEvaSol1 
				) as tmp

		-- Select * from #EvaSol
		Delete from #EvaSol
				

		/*

		Select -- top 1			
					nMonVentas,nCosVenPro,nUtilidBru,nGasOpeNeg,nGasPerson,nGasServic,nUtilidOpe,nObligaNeg
					,nOblNetNeg,nOtrIngUef,cDesIngUef,nIngFueNeg,cDesOtrUef,nImpOtrUef,nTotOblFam,nGasFamili
					,nMonEventu,nPorcenEve,nNumPerDep,nResultUef,nCapacPago,nTotPorEpg,nNumEvaMes
		From KpydEpgEvaSol1 
		Where nNumEvaMes = '1080187'

		nNumEvaMes
		1034104
		1080187
		


		Select * into #EvaSolMes from (
				Select top 1 			
					--A.*
					B.nNumEvaMes
					,B.nLiqActPas, B.nSolPat, B.nRotCapTra, B.nRenAct, B.nRotInv, B.nAplFin
				From #DEvaSolici A
					INNER join KpyMEvaSolMes B
						on B.nNumEvaMes = A.nNumEvaMes
						) as tmp
		Delete from #EvaSolMes
		-- Select * from #EvaSolMes
		*/
		

		---------------------------- CURSOR EVALUACION MICROEMPRESA -----------------------
			Declare @numeva char(7) 				
				Declare cEv CURSOR FOR					
				
				Select distinct nNumEvaMes from #tab02 (NOLOCK)					

				OPEN cEv
				FETCH cEv into @numeva
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #EvaSol 					
					Select top 1					
					nMonVentas,nCosVenPro,nUtilidBru,nGasOpeNeg,nGasPerson,nGasServic,nUtilidOpe,nObligaNeg
					,nOblNetNeg,nOtrIngUef,cDesIngUef,nIngFueNeg,cDesOtrUef,nImpOtrUef,nTotOblFam,nGasFamili
					,nMonEventu,nPorcenEve,nNumPerDep,nResultUef,nCapacPago,nTotPorEpg,nNumEvaMes
					From KpydEpgEvaSol1 
					Where nNumEvaMes = @numeva
			
				FETCH cEv INTO @numeva
				END
				CLOSE cEv
				DEALLOCATE cEv

		-------------------------------------------------------------------
		/*
			Select * from #EvaSol			
			-- (8,234 row(s) affected)
					
				
		Select * from #EvaSol
		Where nNumEvaMes = '1034104'
		order By nNumEvaMes
			-- (103,848 row(s) affected)
				Select nNumEvaMes, count(nNumEvaMes) from #EvaSol
				Group By nNumEvaMes
				Having count(nNumEvaMes) > 1
				Order By count(nNumEvaMes) desc

			Select * from #EvaSol
			Where nNumEvaMes = '11102'

		*/
			-- DROP TABLE #tab03
			Select * into #tab03 from (
				Select A.* 	
					,IngresosOVentas = isnull(B.nMonVentas,0) , CostoMerProd	= isnull(B.nCosVenPro,0)
					,UtilidadBruta = isnull(B.nUtilidBru,0), GastosOperativ = isnull(B.nGasOpeNeg,0)
					,UtilidadOperativa = isnull(B.nUtilidOpe,0), ObligNeg = isnull(B.nObligaNeg,0)
					,UtilidadNeta = isnull(B.nOblNetNeg,0), OtrosIngresosUef = isnull(B.nOtrIngUef,0)
					,B.cDesIngUef, Excedente = isnull(B.nResultUef,0), CapacidadPago = isnull(B.nCapacPago,0)
					,Porcent = isnull(B.nTotPorEpg,0)
				From #tab02 A
					inner join #EvaSol B
						on B.nNumEvaMes = A.nNumEvaMes
			
						) as tmp
										

				-- (11,649 row(s) affected)

		CREATE NONCLUSTERED INDEX #tab03_CodigoCliente_IXN ON #tab03(CodigoCliente)
		CREATE NONCLUSTERED INDEX #tab03_CodigoCredito_IXN ON #tab03(CodigoCredito)	
		CREATE NONCLUSTERED INDEX #tab03_cCodSolCre_IXN ON #tab03(cCodSolCre)
		CREATE NONCLUSTERED INDEX #tab03_nNumEvaMes_IXN ON #tab03(nNumEvaMes)	

		----------------------------------------- EVALUACION CONSUMO ---------------------------------------
		
		-- Drop table #EvaConsumo
		Select * into #EvaConsumo from (
				Select top 1
					cDesIngDeu, nMonIngDeu, nNumEvaMes					
				From KpyDIngDeuInt 
				) as tmp

		-- Select * from #EvaConsumo
		Delete from #EvaConsumo

		---------------------------- CURSOR EVALUACION MICROEMPRESA -----------------------
			Declare @numeva01 char(7) 				
				Declare cEv01 CURSOR FOR					
				
				Select distinct nNumEvaMes from #tab02 (NOLOCK)					

				OPEN cEv01
				FETCH cEv01 into @numeva01
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #EvaConsumo 					
					Select top 1					
						cDesIngDeu, nMonIngDeu, nNumEvaMes					
					From KpyDIngDeuInt 
					Where nNumEvaMes = @numeva01
			
				FETCH cEv01 INTO @numeva01
				END
				CLOSE cEv01
				DEALLOCATE cEv01

		-------------------------------------------------------------------
			/*
				Select * from #EvaConsumo
				Order by nNumEvaMes

				Select nNumEvaMes, count(nNumEvaMes) from #EvaConsumo
				Group By nNumEvaMes
				having count(nNumEvaMes) > 1				

			*/			

		-- DROP TABLE #tab031
			Select * into #tab031 from (
				Select A.* 	
					,IngresosOVentas = isnull(B.nMonIngDeu,0) , CostoMerProd	= 0
					,UtilidadBruta = 0, GastosOperativ = 0
					,UtilidadOperativa = 0, ObligNeg = 0
					,UtilidadNeta = 0, OtrosIngresosUef = 0
					,cDesIngUef = '', Excedente = isnull(B.nMonIngDeu,0), CapacidadPago = 0
					,Porcent = 0
				From #tab02 A
					inner join #EvaConsumo B
						on B.nNumEvaMes = A.nNumEvaMes
			
						) as tmp

			/*
				Select * from #tab031
					-- (94,814 row(s) affected)
			*/

		CREATE NONCLUSTERED INDEX #tab031_CodigoCliente_IXN ON #tab031(CodigoCliente)
		CREATE NONCLUSTERED INDEX #tab031_CodigoCredito_IXN ON #tab031(CodigoCredito)	
		CREATE NONCLUSTERED INDEX #tab031_cCodSolCre_IXN ON #tab031(cCodSolCre)
		CREATE NONCLUSTERED INDEX #tab031_nNumEvaMes_IXN ON #tab031(nNumEvaMes)	
		----------------------------------------------------------------------------------------------------
			/*
				Select top 5 * from #tab03
				Select top 5 * from #tab031	
			*/

		-- drop table #tab033
		Select * into #tab033 from (
				Select * from #tab03
					Union all
				Select * from #tab031		
			) as tmp	

			/*
				Select * from #tab033
					-- (106,463 row(s) affected)
			*/

		CREATE NONCLUSTERED INDEX #tab033_CodigoCliente_IXN ON #tab033(CodigoCliente)
		CREATE NONCLUSTERED INDEX #tab033_CodigoCredito_IXN ON #tab033(CodigoCredito)	
		CREATE NONCLUSTERED INDEX #tab033_cCodSolCre_IXN ON #tab033(cCodSolCre)
		CREATE NONCLUSTERED INDEX #tab033_nNumEvaMes_IXN ON #tab033(nNumEvaMes)	

			/*
				Select *
				From #tab033
				where nNumEvaMes = '256745'

				Select top 1 					
					*
				from #tab033
				where CodigoCliente = '107010248063'																			
					and nNumEvaMes = (Select max(nNumEvaMes) 										
									   from #tab033
										where CodigoCliente = '107010248063')	

				Select nNumEvaMes, COUNT(nNumEvaMes)
				From #tab033
				Group By nNumEvaMes
				Having COUNT(nNumEvaMes) > 1
				Order By COUNT(nNumEvaMes) desc
			*/

			-- drop table #tab0333
			Select * into #tab0333 from ( Select top 1 * From #tab033 ) as tmp 
			Delete from #tab0333

		------------------------ CURSOR ------------------------------------------------------------------

			Declare @nNumEva01 char(10), @codcliente char(12)			  		
			
			Declare cCur01 CURSOR FOR	
			
			Select distinct CodigoCliente from #tab033 (NOLOCK) 					

			OPEN cCur01
			FETCH cCur01 into @codcliente
			WHILE (@@FETCH_STATUS=0)
			BEGIN	

			Insert Into #tab0333				
				Select top 1 					
					*
				from #tab033
				where CodigoCliente = @codcliente																			
					and nNumEvaMes = (Select max(nNumEvaMes) 										
									   from #tab033
										where CodigoCliente = @codcliente)																			
				
			FETCH cCur01 INTO @codcliente
			END
			CLOSE cCur01
			DEALLOCATE cCur01	
			
		---------------------------------------------------------------------
			/*
				Select * from #tab0333
					-- (43,110 row(s) affected)

				Select nNumEvaMes, COUNT(nNumEvaMes)
				From #tab0333
				Group By nNumEvaMes
				Having COUNT(nNumEvaMes) > 1
				Order By COUNT(nNumEvaMes) desc

				Select CodigoCliente, COUNT(CodigoCliente)
				From #tab0333
				Group By CodigoCliente
				Having COUNT(CodigoCliente) > 1
				Order By COUNT(CodigoCliente) desc
			*/
		---------------------------------------------------------------------

		/*				
			evaluación de crédito consumo con un ingreso bruto mayor a 3,000 					
			o empresarial con excedente mayor a 1,000 
		*/

		-- drop table #tab04
		Select * into #tab04 from (
				Select * from #tab0333
				Where (Excedente >= 1000 or (IngresosOVentas + OtrosIngresosUef) >= 3000)
			) as tmp

			-- (28,261 row(s) affected)

		/*
			Select * from #tab04
		*/

		CREATE NONCLUSTERED INDEX #tab04_CodigoCliente_IXN ON #tab04(CodigoCliente)
		CREATE NONCLUSTERED INDEX #tab04_CodigoCredito_IXN ON #tab04(CodigoCredito)	
		CREATE NONCLUSTERED INDEX #tab04_CCODSBS_IXN ON #tab04(CCODSBS)	


		--  DROP TABLE #sbs01

		Select * into #sbs01 from (
				Select A.CCODSBS, A.CAPEPAT, A.CAPEMAT, A.CAPECAS,A.CPRINOM,A.CSEGNOM,A.CNUDOCI, A.NCANENT
					,A.NPORCAL0, A.NPORCAL1, A.NPORCAL2, A.NPORCAL3, A.NPORCAL4, A.CCLAFIN
					,B.CCODEMP, B.CTIPCRE, B.CCTACON, B.NSALDOS, B.CCALEMP				
					,C.cCodIFI, C.cNomIFI
				From [HYO00402].CRICMACHYO_DIARIO.dbo.urirccmae A	
					INNER JOIN [HYO00402].CRICMACHYO_DIARIO.dbo.urirccsal B	
						ON A.CCODSBS = B.CCODSBS
					inner join [HYO00402].CRICMACHYO_DIARIO.dbo.URIRCCMIFI C	
						on C.cCodIFI = B.cCodEmp and C.lConEstado = 1	
				Where LEFT(B.Cctacon, 4) 
						in ('1411','1413', '1414','1415','1416','1421','1423','1424','1425','1426')					
					and A.CCODSBS 
						in (Select distinct(CCODSBS) from #tab04 )	
					--and B.CCALEMP = 0  
					and A.CCLAFIN = 0	
				--Order by A.CCODSBS
				) as tmp

			CREATE NONCLUSTERED INDEX #sbs01_CCODSBS_IXN ON #sbs01(CCODSBS)

		/*
			Select * from #sbs01
			Order By CCODSBS
		*/
			--  DROP TABLE #sbs02
			Select * into #sbs02 from (Select top 1 * from #sbs01) as tmp
			Delete from #sbs02			


	--03 INSERTANDO UN SOLO CREDITO
	------------------------CURSOR SOLO UN CREDITO -----------------------------------
		Declare @CCODSBS char(10)			  		
			
			Declare cCursor01 CURSOR FOR	
			
			Select distinct CCODSBS from #sbs01 (NOLOCK) 					

			OPEN cCursor01
			FETCH cCursor01 into @CCODSBS
			WHILE (@@FETCH_STATUS=0)
			BEGIN	

			Insert Into #sbs02
				
				Select top 1 					
					*
				from #sbs01
				where CCODSBS = @CCODSBS																			
				
			FETCH cCursor01 INTO @CCODSBS
			END
			CLOSE cCursor01
			DEALLOCATE cCursor01

		-----------------------------------------------------------------------------
			
		CREATE NONCLUSTERED INDEX #sbs02_CCODSBS_IXN ON #sbs02(CCODSBS)

		/*
				Select * from #sbs02
				Order By CCODSBS

				Select CCODSBS,count(CCODSBS) from #sbs02
				Group By CCODSBS
				Having count(CCODSBS) > 1
				Order By CCODSBS
		*/

			--  drop table #tab02
			SELECT * into #tab05 from (
					Select A.* 
						,CantEnt = B.NCANENT, CalifSBS = 
													Case B.CCLAFIN
													When '0' then 'NORMAL' 
													ELSE 'NO REGISTRA' END 			
					From #tab04 A
						INNER join #sbs02 B
							on A.cCodSBS = B.cCodSBS
					--Order By CodigoCliente
						) as tmp

					-- (20,790 row(s) affected)
			
		/*
				Select * from #tab02
				-- Where CodigoCliente = '107022326790'
				Order By CodigoCliente

				Select CodigoCliente,count(CodigoCliente)
				From #tab02
				Group By CodigoCliente
				Having count(CodigoCliente) > 1
				Order By CodigoCliente desc

				SELECT A.* 				
				FROM [#tab02] A
		*/

			CREATE NONCLUSTERED INDEX #tab05_CodigoCliente_IXN ON #tab05(CodigoCliente)
			CREATE NONCLUSTERED INDEX #tab05_CodigoCredito_IXN ON #tab05(CodigoCredito)	

			/*
					Select * from #tab05
					-- (20,790 row(s) affected)
			*/

			Select * into #tab06 from	(
					Select 
						CodigoCliente,NombreCliente,Telefono =cNroTelPer,TipoPersona, TipoDocum = DescripTipDoc,
						NumeroDoc = NroDoc, DireccionDomi ,ZonaNDomi, DistriDomi, ProvinDomi,	DepartDomi
						,CodigoCredito,
						TipoCredito,SubTipoCredito,	ProductoCrediticio,SubProductoCrediticio,MontoDesembolso,
						SaldoCapital,Moneda,TipoCambio,MontoDesembolsoenSoles,SaldoCapitalenSoles,TEM,NumeroCuotas,
						CondicionCredito,FechaDesembolsoCredito,FechaCancelacion,Oficina,Zona,CodAsesorActual
						,NombreAsesorActual,nNumEvaMes,IngresosOVentas,CostoMerProd,UtilidadBruta,GastosOperativ
						,UtilidadOperativa,ObligNeg,UtilidadNeta,OtrosIngresosUef,cDesIngUef,Excedente,CapacidadPago
						,Porcent,CantEnt,CalifSBS
					from #tab05
					) as tmp

			/*
				Select * from #tab06
			*/

			CREATE NONCLUSTERED INDEX #tab06_CodigoCliente_IXN ON #tab06(CodigoCliente)
			CREATE NONCLUSTERED INDEX #tab06_CodigoCredito_IXN ON #tab06(CodigoCredito)	

			----------------CRUCE CON el PLANPAGOS--------------------------------------------------------
		-- Drop table #tab07
		Select * into #tab07 from (	
			SELECT A.* 
				  ,PcCodCtaCre=B.cCodCtaCre,B.cCodPlaPag,B.cNumCuoPla,B.dFecVenPag,B.dFecPagCuo,B.NDIAVENCUO
				  ,B.cCodEstCuo 
			FROM [#tab06] A
				INNER JOIN [KPYDPLANPAGCRE] B
					ON A.CodigoCredito = B.cCodCtaCre
			GROUP BY B.cCodCtaCre,B.cCodPlaPag,B.cNumCuoPla,B.dFecVenPag,B.dFecPagCuo,B.NDIAVENCUO,B.cCodEstCuo 
				,CodigoCliente,NombreCliente,Telefono ,TipoPersona, TipoDocum ,
						NumeroDoc ,DireccionDomi, ZonaNDomi, DistriDomi, ProvinDomi,	DepartDomi, CodigoCredito,
						TipoCredito,SubTipoCredito,	ProductoCrediticio,SubProductoCrediticio,MontoDesembolso,
						SaldoCapital,Moneda,TipoCambio,MontoDesembolsoenSoles,SaldoCapitalenSoles,TEM,NumeroCuotas,
						CondicionCredito,FechaDesembolsoCredito,FechaCancelacion,Oficina,Zona,CodAsesorActual
						,NombreAsesorActual,nNumEvaMes,IngresosOVentas,CostoMerProd,UtilidadBruta,GastosOperativ
						,UtilidadOperativa,ObligNeg,UtilidadNeta,OtrosIngresosUef,cDesIngUef,Excedente,CapacidadPago
						,Porcent,CantEnt,CalifSBS		
			--HAVING B.cCodPlaPag  = MAX (B.cCodPlaPag)
			--ORDER BY CCODCLIENTE 	
			) AS tmp		

				------------ACTUALIZANDO LOS NEGATIVOS A 0-----
				UPDATE #tab07
				SET NDIAVENCUO = 0
				WHERE NDIAVENCUO < 0

				--02 agregando columnas
				ALTER TABLE #tab07
				Add CuotaPag decimal(10,5), CuotaPend decimal(10,5), Porcentaje decimal(10,5)
				, DiasPromAtr decimal(10,5), CuotaMax decimal (10,5)




			CREATE NONCLUSTERED INDEX #tab07_CodigoCliente_IXN ON #tab07(CodigoCliente)
			CREATE NONCLUSTERED INDEX #tab07_CodigoCredito_IXN ON #tab07(CodigoCredito)	
			CREATE NONCLUSTERED INDEX #tab07_PcCodCtaCre_IXN ON #tab07(PcCodCtaCre)
			CREATE NONCLUSTERED INDEX #tab07_NDIAVENCUO_IXN ON #tab07(NDIAVENCUO)	


	-- 03 LLENAR CAMPOS 	
	------------------------CURSOR-----------------------------------
		Declare @ccodcred varchar(18), @CuotaPag decimal(10,5), @CuotaPend decimal(10,5), 
		        @Porcentaje decimal(10,5) , @DiasPromAtr decimal(10,5), @CuotasAprob decimal(10,5) 	
				,@CuotaMax decimal (10,5)	
			--Set @ccodcred = '107008101003765143'
			
			Declare cAmpl CURSOR FOR	
				Select distinct CodigoCredito from #tab07 (NOLOCK) 	

			OPEN cAmpl
				FETCH cAmpl into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @CuotasAprob = (select NumeroCuotas from #tab06 where CodigoCredito = @ccodcred)
				set @CuotaPag = 
						(select count(distinct cNumCuoPla) from #tab07 -- [KPYDPLANPAGCRE] 
							where PcCodCtaCre = @ccodcred and cCodEstCuo = 'P'
								AND cCodPlaPag in 
									(select max(cCodPlaPag) 
									 from #tab07 -- [KPYDPLANPAGCRE] (NOLOCK)
										WHERE cCodEstCuo = 'P'
											and PcCodCtaCre = @ccodcred))
			
						set @DiasPromAtr = 
							(Select 
								 ceiling(avg (NDIAVENCUO))
								from #tab07 
								where PcCodCtaCre = @ccodcred									
									and cCodEstCuo = 'P'
									AND cCodPlaPag in  
										(select max(cCodPlaPag) from #tab07 (NOLOCK)
											where cCodEstCuo = 'P'
												and PcCodCtaCre = @ccodcred))												
								
						set @CuotaPend = (@CuotasAprob - @CuotaPag )						
								
						set @Porcentaje = ((@CuotaPag / @CuotasAprob) * 100) 				
											
						
						If @DiasPromAtr is not null
							begin
								UPDATE #tab07
								SET DiasPromAtr = @DiasPromAtr
								WHERE CodigoCredito = @ccodcred															
							end
						Else
							begin
								UPDATE #tab07
								SET DiasPromAtr = 0
								WHERE CodigoCredito = @ccodcred															
							end		
							
							
						set @CuotaMax = 
						(Select 
								max(NDIAVENCUO)
							from #tab07 
							where PcCodCtaCre = @ccodcred									
								AND cCodPlaPag in  
									(select max(cCodPlaPag) from #tab07 (NOLOCK)
										where PcCodCtaCre = @ccodcred))
																						
						If @CuotaMax is not null
							begin
								UPDATE #tab07
								SET CuotaMax = @CuotaMax
								WHERE CodigoCredito = @ccodcred															
							end
						Else
							begin
								UPDATE #tab07
								SET CuotaMax = 0
								WHERE CodigoCredito = @ccodcred														
							end				

						UPDATE #tab07
						SET CuotaPag = @CuotaPag
						WHERE CodigoCredito = @ccodcred	

						UPDATE #tab07
						SET CuotaPend = @CuotaPend
						WHERE CodigoCredito = @ccodcred

						UPDATE #tab07
						SET Porcentaje = @Porcentaje
						WHERE CodigoCredito = @ccodcred									
				
				FETCH cAmpl INTO @ccodcred
				END
				CLOSE cAmpl
				DEALLOCATE cAmpl


		-- Select * from #tab07

	-- Drop table #tab04
		Select * into #tab08 FROM 
			(Select top 1  
					CodigoCliente,NombreCliente,Telefono ,TipoPersona, TipoDocum ,
					NumeroDoc , DireccionDomi,ZonaNDomi, DistriDomi, ProvinDomi,DepartDomi, CodigoCredito,
					TipoCredito,SubTipoCredito,	ProductoCrediticio,SubProductoCrediticio,MontoDesembolso,
					SaldoCapital,Moneda,TipoCambio,MontoDesembolsoenSoles,SaldoCapitalenSoles,TEM,NumeroCuotas,
					CondicionCredito,FechaDesembolsoCredito,FechaCancelacion,Oficina,Zona,CodAsesorActual
					,NombreAsesorActual,nNumEvaMes,IngresosOVentas,CostoMerProd,UtilidadBruta,GastosOperativ
					,UtilidadOperativa,ObligNeg,UtilidadNeta,OtrosIngresosUef,cDesIngUef,Excedente,CapacidadPago
					,Porcent,CantEnt,CalifSBS
					, CuotaPag, CuotaPend,Porcentaje, DiasPromAtr,CuotaMax
			 from #tab07 (NOLOCK)) as tmp
		DELETE FROM #tab08
		-- Select * from #tab04

			------------------------CURSOR SOLO UN CREDITO -----------------------------------
				Declare @codclie01 char(12), @codcred01 char(18)			  		
			
					Declare cFiltrando CURSOR FOR	
						Select distinct CodigoCredito from #tab07 (NOLOCK) 					

					OPEN cFiltrando
						FETCH cFiltrando into @codcred01
						WHILE (@@FETCH_STATUS=0)
						BEGIN	

						Insert Into #tab08
						Select top 1							
							CodigoCliente,NombreCliente,Telefono ,TipoPersona, TipoDocum ,
							NumeroDoc , DireccionDomi,ZonaNDomi, DistriDomi, ProvinDomi,DepartDomi, CodigoCredito,
							TipoCredito,SubTipoCredito,	ProductoCrediticio,SubProductoCrediticio,MontoDesembolso,
							SaldoCapital,Moneda,TipoCambio,MontoDesembolsoenSoles,SaldoCapitalenSoles,TEM,NumeroCuotas,
							CondicionCredito,FechaDesembolsoCredito,FechaCancelacion,Oficina,Zona,CodAsesorActual
							,NombreAsesorActual,nNumEvaMes,IngresosOVentas,CostoMerProd,UtilidadBruta,GastosOperativ
							,UtilidadOperativa,ObligNeg,UtilidadNeta,OtrosIngresosUef,cDesIngUef,Excedente,CapacidadPago
							,Porcent,CantEnt,CalifSBS
							, CuotaPag, CuotaPend,Porcentaje, DiasPromAtr,CuotaMax
							
							from #tab07
							where CodigoCredito = @codcred01																		

						FETCH cFiltrando INTO @codcred01
						END
						CLOSE cFiltrando
						DEALLOCATE cFiltrando
				------------------------------------------------------------------------------								
				
			CREATE NONCLUSTERED INDEX #tab08_CodigoCliente_IXN ON #tab08(CodigoCliente)
			CREATE NONCLUSTERED INDEX #tab08_CodigoCredito_IXN ON #tab08(CodigoCredito)		
		
			/*
					Select * from #tab04	-- (186,254 row(s) affected)

					where CodigoCredito = '107004101006441981'

					Select * from #tab04
					Where DiasPromAtr is null
					Order By FechaDesembolsoCredito desc
			*/

			Select A.* 
			From #tab08 A		
			where DiasPromAtr < 6
			Order By CodigoCliente desc

			/*
					Select CodigoCliente, COUNT(CodigoCliente) 
					From #tab08 A		
					Group by CodigoCliente
					Having COUNT(CodigoCliente) > 1
			*/

		--------------------------------
			


		/*
			Drop table #tab01
			Drop table #tab02
			Drop table #tab03
			Drop table #tab031			
			Drop table #tab033
			Drop table #tab0333
			Drop table #tab04
			Drop table #tab05
			Drop table #tab06
			Drop table #tab07
			Drop table #tab08
			Drop table #sbs01
			Drop table #sbs02
			Drop table #EvaSol
			Drop table #EvaConsumo
			drop table #DEvaSolici

		*/