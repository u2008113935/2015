
		-- INSERTANDO EEFF
		/*
		SELECT TOP 50 *
		FROM KpyMEvaSolMes	

		Select top 5 * from KPYAMEvaClient -- Almacena las evaluaciones por cliente
		Select * from KpyDBalCta0Agr -- DETALLE DE BALANCE DE NIVEL0
		
		Select top 10 * from KpyDBalCta0Sol 
		Select top 10 * from KpyDBalCta1Sol 
		Select top 10 * from KpyDBalCta2Sol 
		Select top 10 * from KpyDBalCta3Sol 
		Select top 10 * from KpyDBalCta4Sol 
		


		Select top 5 * from	KpyDBalCta1Agr -- DETALLE DE BALANCE DE NIVEL1.
		Select * from KpyDBalCta1Sol
		
		select top 5 * from	KpydEpgEvaSol1 --
		select top 5 * from KPYDEVABIEADQ -- Tabla evaluación bien Adquirir
		select top 5 * from KpyDEvaEstFin --
		select top 5 * from KpyDEvaSolici -- 
		select top 5 * from KpyDFotEvaSol --
		select top 5 * from KpydGarEvaSol -- Detalle de Garantías registradas para la evaluación del crédito
		select top 5 * from KpyDGasEPGEva1 --
		select top 5 * from KpyDIncFluMes --
		select top 5 * from KpyDIngDeuInt -- Detalle de Ingresos y Deudas del solicitante para la evaluación
		select top 5 * from KpyDObsDesemb -- Detalle de observaciones hechas a la evalulación
		select top 5 * from KPYDPteVehBal -- Tabla puente entre vehiculos y detalle de balance
		select top 5 * from KPYDRelGarEva -- Relacion de Evaluacion con Garantias
		select top 5 * from KPYDRelGarSol -- TABLA DETALLE DE RELACION DE GARANTIA CON LA SOLICITUD.
		select top 5 * from KPYDVehEvaSol -- Registra una Evaluación y su detalle vehicular
		select top 5 * from KpyHEvaClient -- Evaluacion Cliente Historico
		select top 5 * from KpyMEvaClient -- Maestro de Evaluacion Cliente
		select top 5 * from KpyMEvaSolCre -- Maestro de Evaluaciones. Se guarda una por cada solicitud de crédito
		select top 5 * from KpyMEvaSolMes --

		Select top 5 * from KpyMSolicitud
		SELECT TOP 5 nNumEvaMes,* FROM KpyMEvaSolMes
		
		Select top 5 * from KpyDEvaSolici --Tabla Intermedia
		
		Select *
		FROM KpyMSolicitud A 
		LEFT JOIN (SELECT TOP 1 cCodSolCre,nNumEvaMes FROM KpyDEvaSolici
					WHERE cCodSolCre = @x_cCodSol) EVA 
			ON A.cCodSolCre = EVA.cCodSolCre
		LEFT JOIN KpyMEvaClient EVC 
			ON EVC.nNumEvaMes = EVA.nNumEvaMes	
		LEFT JOIN KpyMEvaSolMes B
			ON EVC.nNumEvaMes = B.nNumEvaMes	
		LEFT JOIN KPYTTipBiepag TIPBIE	
			ON B.cCodbiepag = TIPBIE.cCodbiepag	


		Select top 5 * from KpyDEvaSolici
		Select top 5 * from KpyMEvaClient
		Select top 5 * from KpyMEvaSolMes
		-- Select top 5 * from KPYTTipBiepag		

		-- uniendo las tablas
		Select top 2 * from KpyDEvaSolici -- Intermedio
		Select top 2 * FROM KpyMSolicitud -- OK
		SELECT TOP 2 * FROM KpyMEvaSolMes -- Eval EEFF
		
				Select cCodEstEva from KpyDEvaSolici
				Group By cCodEstEva						

		Select top 2 * from #Tab08		
		*/
	---------------------------------------------------------------
	
	-- Drop table #tab09
	Select * into #tab09 from (
		Select A.*, B.cCodSolCre
		From #Tab08 A (nolock)
			inner join KPYMCRECONVEN B
				on A.CCODCTACRE = B.CCODCTACRE
			inner join KpyMSolicitud S
				on S.cCodSolCre = B.cCodSolCre			
			/*
			inner join KpyDEvaSolici DE
				on DE.cCodSolCre = B.cCodSolCre		
			left join KpyMEvaSolMes ES
				on ES.nNumEvaMes = DE.nNumEvaMes
			*/
		--Where A.CCODCLIENTE = '107021123264'				
		--Order By A.CCODCTACRE
		) as tmp
			
		CREATE NONCLUSTERED INDEX #tab09_CCODCLIENTE_IXN ON #tab09(CCODCLIENTE)
		CREATE NONCLUSTERED INDEX #tab09_CCODCTACRE_IXN ON #tab09(CCODCTACRE)
		CREATE NONCLUSTERED INDEX #tab09_cCodLinCre_IXN ON #tab09(cCodLinCre)		
		CREATE NONCLUSTERED INDEX #tab09_cCodSbs_IXN ON #tab09(cCodSbs)
		CREATE NONCLUSTERED INDEX #tab09_NumDoc_IXN ON #tab09(NumDoc)	
		CREATE NONCLUSTERED INDEX #tab09_cCodSolCre_IXN ON #tab09(cCodSolCre)			
		
		/*
		Select * from #tab09 (nolock)

			Select CCODCLIENTE, count(CCODCLIENTE) 
			from #tab09
			Group By CCODCLIENTE
			Having count(CCODCLIENTE) > 1
			Order By count(CCODCLIENTE) desc

		Select * from #tab09 Where CCODCLIENTE = '107021123264'
		Select * from #tab09 Where CCODCLIENTE = '107021841830'

		Select top 2 * FROM KpyMSolicitud A 
		
		Select * from #Tab08
		-- (313,189 row(s) affected)

	Select * from KpyDEvaSolici
	Where cCodSolCre =  '0590010509' --'0590007145'
		*/

		Select * into #DEvaSolici from (
			Select top 1 nNumEvaMes,cCodSolCre from KpyDEvaSolici			
			) as tmp
		-- Drop table #DEvaSolici
		-- Select * from #DEvaSolici
		Delete from #DEvaSolici

		-- Select len(cCodSolCre) from #tab09 (NOLOCK)

		----------------------------CURSOR EVALUACION-----------------------
			Declare @codsolcre char(10) 				
				Declare cE CURSOR FOR
					
				Select cCodSolCre from #tab09 (NOLOCK)					

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
		/*

		Select * from #DEvaSolici
		Order By nNumEvaMes asc

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

			-- drop table #EvaSolMes
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

	-- Select * from #DEvaSolici A

		----------------------------CURSOR EVALUACION-----------------------
			Declare @numeva char(7) 				
				Declare cEv CURSOR FOR
					
				Select nNumEvaMes from #DEvaSolici (NOLOCK)					

				OPEN cEv
				FETCH cEv into @numeva
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #EvaSolMes 					
					Select top 1
					B.nNumEvaMes
					,B.nLiqActPas, B.nSolPat, B.nRotCapTra, B.nRenAct, B.nRotInv, B.nAplFin	
					From KpyMEvaSolMes B
					Where B.nNumEvaMes = @numeva
			
				FETCH cEv INTO @numeva
				END
				CLOSE cEv
				DEALLOCATE cEv
		-------------------------------------------------------------------
		
			Select * from #EvaSolMes

			Select nNumEvaMes,count(nNumEvaMes) from #EvaSolMes
			Group By nNumEvaMes
			Having count(nNumEvaMes) > 1


	--Select * into #EvaSolMes from (
		Select top 1 			
			--A.*
			B.nNumEvaMes
			,B.nLiqActPas, B.nSolPat, B.nRotCapTra, B.nRenAct, B.nRotInv, B.nAplFin
		From #DEvaSolici A
			INNER join KpyMEvaSolMes B
				on B.nNumEvaMes = A.nNumEvaMes
		--		) as tmp

		Select top 1 * from #DEvaSolici
		Select top 1 * from #EvaSolMes
		
		---------------------------------------------------------------------------

		-- EEFF

			Create table #CLIMCtaEEFFCli (	 
			nCodEEFFCli	int,
			cCodCliente	char(12),
			dFecCiePer	datetime,
			dFecEEFF	datetime,
			nCodIntCont	int,
			cConAudita	char(1),
			cOpeMonExt	char(1),
			nTipcamFij	numeric(9),
			cCodRegEEFF	char(6),
			dFecRegEEFF	datetime,
			cCodModEEFF	char(6),
			dFecModEEFF	datetime,
			dFecAudEEFF	datetime )
			
			-- drop table #CLIMCtaEEFFCli
			----------------------------fECHA EEFF-----------------------
			Declare @codclie char(12) 				
				Declare cEEFF01 CURSOR FOR
					
					Select CCODCLIENTE from #tab08 (NOLOCK)			

				OPEN cEEFF01
				FETCH cEEFF01 into @codclie
				WHILE (@@FETCH_STATUS=0)
				BEGIN			
					  
				Insert Into #CLIMCtaEEFFCli 					
					Select top 1
						nCodEEFFCli,cCodCliente,dFecCiePer=left(cast(dFecCiePer as date),10)
						,dFecEEFF = left(cast(dFecEEFF as date),10),nCodIntCont,cConAudita
						,cOpeMonExt,nTipcamFij,cCodRegEEFF
						,dFecRegEEFF= left(cast(dFecRegEEFF as date),10)
						,cCodModEEFF,dFecModEEFF = left(cast(dFecModEEFF as date),10)
						,dFecAudEEFF = left(cast(dFecAudEEFF as date),10)
					FROM CMACHYOCLI_201507.dbo.CLIMCtaEEFFCli
					where CCODCLIENTE = @codclie
						and dFecEEFF in (Select max(dFecEEFF) 
											FROM CMACHYOCLI_201507.dbo.CLIMCtaEEFFCli
											where CCODCLIENTE = @codclie)												
			
				FETCH cEEFF01 INTO @codclie
				END
				CLOSE cEEFF01
				DEALLOCATE cEEFF01
				-------------------------------------------------------------------
				
				/*
				SELECT * FROM #CLIMCtaEEFFCli
				--where cCodCliente = '107011386352'
				oRDER bY nCodEEFFCli

				SELECT * FROM #CLIMCtaEEFFCli
				ORDER BY cCodCliente

				SELECT cCodCliente, Count(cCodCliente) FROM #CLIMCtaEEFFCli
				GROUP BY cCodCliente
				having count(cCodCliente) > 1
				*/			

			Select * into #CLIMCtaEEFFCli01 from (
				Select 
						nCodEEFFCli,cCodCliente,dFecCiePer=left(cast(dFecCiePer as date),10)
						,dFecEEFF = left(cast(dFecEEFF as date),10),nCodIntCont,cConAudita
						,cOpeMonExt,nTipcamFij,cCodRegEEFF
						,dFecRegEEFF= left(cast(dFecRegEEFF as date),10)
						,cCodModEEFF,dFecModEEFF = left(cast(dFecModEEFF as date),10)
						,dFecAudEEFF = left(cast(dFecAudEEFF as date),10)
				From #CLIMCtaEEFFCli
				--Where dFecEEFF < '2015-06-30' 
				--Order By dFecEEFF Desc
				) as tmp


				Select * from #CLIMCtaEEFFCli01
				Where cCodCliente = '107010013830'
				Order By cCodCliente

	/*
nCodEEFFCli	cCodCliente		dFecCiePer	dFecEEFF	nCodIntCont	cConAudita	cOpeMonExt	nTipcamFij	cCodRegEEFF	dFecRegEEFF	cCodModEEFF	dFecModEEFF	dFecAudEEFF
229			107010013830	2010-12-31	2010-12-31	9			2			2			3			PMARTI		2009-12-01	NULL		NULL		2009-12-01
	*/


		Select A.*,B.* 
		From #CLIMCtaEEFFCli01 A
			inner join CMACHYOCLI_201507.dbo.CLIDCtaEEFFCli B
				on A.cCodCliente = B.cCodCliente
		Where A.cCodCliente = '107010013830'
		Order By A.cCodCliente

	--------------------------------------------------------------------------------
				
		Select * From #tab08 (NOLOCK) where cCodCliente = '107010013830'	

		Select *
		From CMACHYOCLI_201507.dbo.CLIMCtaEEFFCli	

				SELECT *
				FROM CMACHYOCLI_201507.dbo.CLIDCtaEEFFCli					

				SELECT A.*
				FROM CMACHYOCLI_201507.dbo.CLIDCtaEEFFCli A
				where A.cCodCliente = '107010013830'
				Order By cCodCtaEEFF					
				
	/*
	nCodEEFFCli	cCodCliente		cCodNivEEFF	cCodCtaEEFF	nMonCtaEEFF
	9			107010013830	N1			A1			0.00
	*/

				Select A.*, B.* 
				from #CLIMCtaEEFFCli01 A
					inner join CMACHYOCLI_201507.dbo.CLIDCtaEEFFCli	B
						on B.cCodCliente = A.cCodCliente
				Order By A.cCodCliente
									
				-- Detalle
				SELECT *
				FROM CMACHYOCLI_201507..CLITSUBCTATIPESTFIN		
	/*
	cCodClaCtaCtb	cCodTipCtaEEFF	cCodSubCtaEEFF	cDesSubCtaEEFF				cCodCtaR28	lEstCtaEEFF
	A1				B1				C1				Caja y Bancos(Disponible)	001			1
	*/
					SELECT *
					FROM CMACHYOCLI_201507.dbo.CliTClaCtaEstFin
					--cCodClaCtaCtb	cDesClaCtaCtb	cDesImpR28			lEstClaCtaCtb
					--A1				ACTIVO			Cuentas del Activo	1

					Select *
					from CMACHYOCLI_201507.dbo.CliTTipCtaEstFin

					--cCodClaCtaCtb	cCodTipCtaEEFF	cDesTipCtaEEFF
					--A1				B1				ACTIVO CORRIENTE

			 --  armando detalle
					SELECT A.*, B.*, C.*
					FROM CMACHYOCLI_201507.dbo.CliTClaCtaEstFin A
						inner join CMACHYOCLI_201507.dbo.CliTTipCtaEstFin B
							on B.cCodClaCtaCtb = A.cCodClaCtaCtb
						inner join CMACHYOCLI_201507..CLITSUBCTATIPESTFIN C
							on C.cCodClaCtaCtb = A.cCodClaCtaCtb
								and C.cCodTipCtaEEFF = B.cCodTipCtaEEFF

	-------------------------------------------------------------------------