
	/*
	RELACIÓN DE TODOS LOS CRÉDITOS HIPOTECARIOS VIGENTES,JUDICIAL,CASTIGADO 
	QUE CONTEMPLEN LA SIGUIENTE INFORMACIÓN: ZONA, AGENCIA, ASESOR, NOMBRE DEL CLIENTE
	, , fecha aprobacion, fecha desembolso, MONTO DESEMBOLSADO, SALDO CAPITAL A JUNIO -15
	, NUMERO DE CUOTAS OTORGADAS
	, NUMERO DE CUOTAS PENDIENTES A JUNIO 2015, TASA OTORGADA
	, FECHA DE INSCRIPCIÓN DE HIPOTECA A RRPP. 
	*/

	-- Drop table #tab01
	--01 relacion de creditos hipotecarios

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01'				
				)
	Select * into #tab01 from (
	Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY year(CRE.DFECDESCRE)
					ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)
			--,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 --,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 --,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 							
			--Datos del credito			
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,SaldoCapitalenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
				WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
				END					
			,FechaAprobacion=left(cast(S.dFecAprCre as date),10)	
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
			,TEM=CRE.nTasintCom	
			,NumeroCuotas=CRE.nNumCuoApr										 

			--,CRE.cEstCreCon
			--,EC.cDescriEst AS 'EstadoCredito'
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END
			--,FechaConstitGarantRRPP = ISNULL(left(cast(C.dFecConsGar as date),10),'') 
			--,B.cCodGarCli
			--,O.cCodOficin
			,Oficina = O.cDesOficin							
			--,ZON.nCodZona
			,Zona = ZON.cDesZona			
			--Datos del Cliente			
			,CLI.cCodCliente AS 'CodigoCliente'		
			,CLIM.cNomCliente AS 'NombreCliente'
			,CRE.cCodCtaCre AS 'CodigoCredito'
			,CLI.cCodLinCre
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
			 inner join KPYMSolicitud S
				ON S.cCodSolCre = CRE.cCodSolCre			
										
		WHERE CRE.cEstCreCon = 'F' -- in ('F','H','I','G')					
			and (CRE.cCodTipCre = '04' and STC.lEstado = '1')			
		) as tmp
 			
		--
		select * from #tab01 
		Order By Anio,Mes

		 /*
		 Select CodigoCredito, count(CodigoCredito)
		 from #tab01
		 group by CodigoCredito
		 having count(CodigoCredito) > 1 


		 Select CodigoCliente, count(CodigoCliente)
		 from #tab01
		 group by CodigoCliente
		 having count(CodigoCliente) > 1 

		 select *
		 from #tab01
		 where CodigoCliente = '107012133207' --'107010025685'
		 */
		
		-- 02 Cuotas Pendientes
			ALTER TABLE #tab01
			Add CuotaPag INT , CuotaPend INT
			--Drop column CuotaPag, CuotaPend
		------------------------CURSOR-----------------------------------
		Declare @codlincre1 varchar(18), @CuotaPag INT, @CuotaPend INT, @CuotasAprob int 		
			
			Declare cGarRRPP CURSOR FOR	
				Select CodigoCredito from #tab01 (NOLOCK) 	

			OPEN cGarRRPP
				FETCH cGarRRPP into @codlincre1
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @CuotasAprob = (select NumeroCuotas from #tab01 
									where CodigoCredito=@codlincre1)
				set @CuotaPag = 
						(select count(distinct cNumCuoPla) from [KPYDPLANPAGCRE] 
									where cCodCtaCre = @codlincre1 and cCodEstCuo = 'P'
									AND cCodPlaPag in 
									(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
										WHERE cCodCtaCre = @codlincre1 and cCodEstCuo = 'P'))

				Set @CuotaPend = (@CuotasAprob - @CuotaPag )					
				
				UPDATE #tab01
				SET CuotaPag = @CuotaPag
				WHERE CodigoCredito = @codlincre1	
				
				UPDATE #tab01
				SET CuotaPend = @CuotaPend
				WHERE CodigoCredito = @codlincre1																				
				
				FETCH cGarRRPP INTO @codlincre1
				END
				CLOSE cGarRRPP
				DEALLOCATE cGarRRPP
		-------------------------------------------------------------------
		
		/*
		Select * from #tab01
		--where CodigoCredito = '107001102013777852' 
		--Where CuotaPend < 0
		Where EstadoCredito = 'CANCELADO' and CuotaPag != NumeroCuotas


				select * from [KPYDPLANPAGCRE] 
				where cCodCtaCre = '107008101002268035' 
						and cCodEstCuo = 'P'	
						AND cCodPlaPag in 
						(select max(cCodPlaPag) from [KPYDPLANPAGCRE] (NOLOCK)
						WHERE cCodCtaCre = '107008101002268035' and cCodEstCuo = 'P')															
				order by cCodPlaPag desc

				/*
				CodigoCredito
				107008101002268035
				107052101000071935
				107038102000874543
				*/
		*/
			
		-- 03 Garantias
		
		/*
		Select * from #tab01
		where CodigoCliente ='107010456484'
		*/

		-- Drop table #tab02
		/*
		Select * into #tab02 from (
				Select 
					A.Secuencia, A.Anio, A.Mes, A.NombreMes, A.TipoCredito, A.SubTipoCredito
					, A.ProductoCrediticio, A.SubProductoCrediticio, A.MontoDesembolso
					, A.SaldoCapital, A.Moneda, A.SaldoCapitalenSoles, A.FechaAprobacion 
					, A.FechaDesembolsoCredito, A.TEM, A.NumeroCuotas, A.CuotaPag,A.CuotaPend
					, A.EstadoCredito, B.cCodGarCli
					,FechaConstitGarantRRPP = ISNULL(left(cast(C.dFecConsGar as date),10),'')
					, A.Oficina
					, A.Zona, A.CodigoCliente, A.NombreCliente, A.CodigoCredito, A.cCodLinCre
					, A.CodAsesorActual	, A.NombreAsesorActual						
				from #tab01 A
					inner join KPYDGarLinCre B
						on A.cCodLinCre = B. cCodLinCre
					inner join CMACHYOCLI.DBO.CliMGarFisHipCli C
						on C.cCodCliente = A.CodigoCliente
							and C.cCodGarCli = B.cCodGarCli 
							and C.dFecConsGar is not NULL
				--Where A.CodigoCliente = '107010456484' and 
					--A.cCodLinCre = '0400016788'
				) as tmp		
			*/
		---------------------------------------------------------------------------
		
		 /*
		 Select CodigoCredito, count(CodigoCredito)
		 from #tab02
		 group by CodigoCredito
		 having count(CodigoCredito) > 1 
		 */

		 /*
			Select B.cCodCliente, B.cCodLinCre , B.cCodGarCli
				,FechaConstitGarantRRPP = ISNULL(left(cast(C.dFecConsGar as date),10),'')
			From KPYDGarLinCre B				
				left join CMACHYOCLI.DBO.CliMGarFisHipCli C
					on C.cCodCliente = B.cCodCliente
					and C.cCodGarCli = B.cCodGarCli 
					and C.dFecConsGar is not NULL
			WHERE B.cCodLinCre = '0080021881'
				AND B.cCodEstGar = 'A'

			Select * From KPYDGarLinCre B where cCodCliente = '107012133207'
				and cCodEstGar ='A'
			Select * from CMACHYOCLI.DBO.CliMGarFisHipCli C where cCodCliente = '107012133207' 
		*/
		------------------------------------------------------------------------------	
		Alter table #tab01
		Add FechaConstitGarantRRPP date, CodigoGarantiaCliente char(3)
		----------------------------------CURSOR--------------------------------------
		Declare @codlincre1 char(10), @fecharrpp date, @codgarCli char(3) 			
			Declare cGarRRPP CURSOR FOR	
				Select cCodLinCre from #tab01 (NOLOCK) 	

			OPEN cGarRRPP
				FETCH cGarRRPP into @codlincre1
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
				
				set @fecharrpp = 
				(
					Select left(cast(C.dFecConsGar as date),10)
					From KPYDGarLinCre B				
						inner join CMACHYOCLI.DBO.CliMGarFisHipCli C
							on C.cCodCliente = B.cCodCliente
							and C.cCodGarCli = B.cCodGarCli 
							and C.dFecConsGar is not NULL
					WHERE B.cCodLinCre = @codlincre1
					AND B.cCodEstGar = 'A'	
				)
			
				set @codgarCli = 
				(
					Select B.cCodGarCli					
					From KPYDGarLinCre B				
						left join CMACHYOCLI.DBO.CliMGarFisHipCli C
							on C.cCodCliente = B.cCodCliente
							and C.cCodGarCli = B.cCodGarCli 
							and C.dFecConsGar is not NULL
					WHERE B.cCodLinCre = @codlincre1
					AND B.cCodEstGar = 'A'
				)			
				
				UPDATE #tab01
				SET FechaConstitGarantRRPP = @fecharrpp
				WHERE cCodLinCre = @codlincre1	
				
				UPDATE #tab01
				SET CodigoGarantiaCliente = @codgarCli
				WHERE cCodLinCre = @codlincre1
				
				FETCH cGarRRPP INTO @codlincre1
				END
				CLOSE cGarRRPP
				DEALLOCATE cGarRRPP

		-----------------------------------------------------------------------------	
		/*
		
		Select * from #tab01

		Select * from #tab01 where -- FechaConstitGarantRRPP is null
			  CodigoGarantiaCliente = ''-- is null
		*/

		Update #tab01
		Set FechaConstitGarantRRPP = ''
		Where FechaConstitGarantRRPP is null

		----------------------------------------------------------------------------
		
		/* 
		 inner join KPYDGarLinCre B
						on A.cCodLinCre = B. cCodLinCre
					inner join CMACHYOCLI.DBO.CliMGarFisHipCli C
						on C.cCodCliente = A.CodigoCliente
							and C.cCodGarCli = B.cCodGarCli 
							and C.dFecConsGar is not NULL	 
		 
		 
		 select * from #tab02
		 where CodigoCredito ='107001101020415836'
		 -- 107012133207

		 Select *
		 from #tab02
		 where CodigoCliente = '107012133207' --'107010456484'
		 
		 Select *
		 from #tab02
		 where CodigoCliente = '107010025685'
		
		Select dFecConsGar,*
		from CMACHYOCLI.DBO.CliMGarFisHipCli A
		where cCodCliente = '107012133207' -- '107010456484' --'107010893306'
			and dFecConsGar is not NULL

		
		Select dFecConsGar,*
		from CMACHYOCLI.DBO.CliMGarFisHipCli A
		where cCodCliente =  '107012133207' -- '107010456484' --'107010893306'
			and dFecConsGar is not NULL
		
		Select * 
		FROM CMACHYOCLI.DBO.CliMGarFisHipCli A (NOLOCK)  
			inner join CMACHYOCLI.DBO.CLIMGARCLIENTE B 
				ON A.CCODCLIENTE = B.CCODCLIENTE   
					AND A.CCODGARCLI = B.CCODGARCLI  
		WHERE A.ccodcliente = '107012133207' -- '107010456484' -- '107010893306'


		Select * from CMACHYOCLI.DBO.CLIMGARCLIENTE B 
		where cCodCliente = '107010456484' --'107010893306'			
		
		Select * from KPYMSolicitud where cCodLinCre = '0400016788'
		
		Select * from KPYDAMPGARCRE
		where cCodCliente = '107010456484'

		Select * From GENDGarantia

		select * from GENTTIPRELCTA


	

		Select *
		from CMACHYOCLI.DBO.CLIMGARCLIENTE B 
		where cCodCliente = '107010456484'
			ON A.CCODCLIENTE = B.CCODCLIENTE   
					AND A.CCODGARCLI = B.CCODGARCLI 


			 inner join CMACHYOCLI.DBO.CliMGarFisHipCli A
				ON A.CCODCLIENTE = CLI.cCodCliente 	
			 INNER JOIN CMACHYOCLI.DBO.CLIMGARCLIENTE B  
				ON A.CCODCLIENTE = B.CCODCLIENTE   
					AND A.CCODGARCLI = B.CCODGARCLI  				 
			 			 
			 left JOIN KPYDGarLinCre AA					   
				ON AA.CCODCLIENTE = CLIM.CCODCLIENTE and AA.cCodEstGar = 'A'	
					--and AA.cCodGarCli = A.cCodGarCli		
					and CLI.cCodLinCre = AA.cCodLinCre
					and AA.ccodlincre = S.ccodlincre			 
			 left JOIN KPYDGarLinCre AA
				ON AA.CCODCLIENTE = CLIM.CCODCLIENTE and AA.cCodEstGar = 'A'	
					--and AA.cCodGarCli = A.cCodGarCli		
					and CLI.cCodLinCre = AA.cCodLinCre													 		
		
		--		
	
		 Select * from #tab01
		 where CodigoCliente = '107010456484'

		 Select * from #tab01
		 where CodigoCredito = '107024102000905624' -- '107040101001631503'		
		
		
			select top 5 *  from CMACHYOCLI.DBO.CliMGarFisHipCli A
			WHERE	cCodLinCre = '0010188459'--@cCodLinCre
			SELECT A.cCodCliente,A.cCodGarCli,B.nMonGraGar , B.nMonGarOri , B.nMonGarOriSol , B.nMonTasGar , B.nMonTasGarSol , B.nTipCamTas, B.cCodTipMon
			--AND left(cast(CRE.dFecDesCre as date),10) >='2013-06-01'
			--AND left(cast(CRE.dFecDesCre as date),10) <='2015-06-30'							
		
		----------------------------------------------------------------------------------
		SELECT A.ccodcliente, A.ccodgarcli,  
		  dactvalrea = ISNULL(A.dFecUltTasGar,'') ,  ccodrepev = ISNULL(A.cCodPerEva,''),   
		  dvigpolseg = ISNULL(A.dFecVigPol,''),  nmoncobpol = ISNULL(A.nmoncobpol,0.00),  
		  ccodficreg = ISNULL(A.ccodficreg,''),  dinsbloreg = ISNULL(A.dinsbloreg,0),  
		  cCodAsient = ISNULL(A.cCodAsient,''),  cCodTomo = ISNULL(A.cCodTomo,''),  
		  cCodFojas =  ISNULL(A.cCodFojas,''),  cCodFicha = ISNULL(A.cCodFicha,''),   
		  cCodFolio = ISNULL(A.cCodFolio,''),   cCodPredio = ISNULL(A.cCodPredio,''),   
		  cCodRubro = ISNULL(A.cCodRubro,''),   cNumPoliza = ISNULL(A.cNumPoliza,''),  
		  cCodComPol = ISNULL (A.cCodEmpPol,'000'), dFecConsGar = ISNULL(A.dFecConsGar,''),  
		  cCodDesPre = ISNULL (A.cCodDesPre,''),  cCodDetDes = ISNULL(A.cCodDetDes,''),  
		  cCodTipInm = ISNULL(A.cCodTipInm,''),  cNroManzan = ISNULL(A.cNroManzan,''),  
		  cDepartLot = ISNULL(A.cDepartLot,''),    
		  cCodClaGar = ISNULL(A.cCodClaGar,''),    
		  nRanGravam = ISNULL(A.nRanGravam,0.00),  dFecVenTas = ISNULL(A.dFecVenTas,''),    
		  dFecIniPol = ISNULL(A.dFecIniPol,''),  cIndSegpol = ISNULL(A.cIndSegpol,''),    
		  cCodSubOfi = ISNULL(A.cCodSubOfi,''),  cCodOfiReg = ISNULL(A.cCodOfiReg,''),   
		  cCodTipInmu = ISNULL(A.cCodTipInmu,''),  cCodEstCons  = ISNULL(A.cCodEstCons,''),   
		  cCodMatPar = ISNULL(A.cCodMatPar,''),  cCodMatTec = ISNULL(A.cCodMatTec,''),    
		  cCodMatPueVen = ISNULL(A.cCodMatPueVen,''), nNumPisos = ISNULL(A.nNumPisos,0),     
		  nAreTerren = ISNULL(A.nAreTerren,0.00),  nAreConstr = ISNULL(A.nAreConstr,0.00), 
		  cNumCerPol = ISNULL(A.cNumCerPol,''),    
		  cIndPref =	CASE   
							WHEN B.lindpripre = 1 THEN '1RA'   
							WHEN B.lindsegpre = 1 THEN '2DA'  
							ELSE 'NNN'  
						END  
		FROM CMACHYOCLI.DBO.CliMGarFisHipCli A (NOLOCK)  
		 INNER JOIN CMACHYOCLI.DBO.CLIMGARCLIENTE B  
		  ON A.CCODCLIENTE = B.CCODCLIENTE   
		   AND A.CCODGARCLI = B.CCODGARCLI  
		WHERE A.ccodcliente = '107010456484' -- '107010893306' -- @x_ccodcliente   
		  AND A.ccodgarcli = @x_ccodgarcli
		 */


