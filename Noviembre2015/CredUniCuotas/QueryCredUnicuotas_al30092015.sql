	/*
		CREDITOS UNICUOTA

		Se solicita data de los créditos unicuota con los siguientes campos:  
		POR PRODUCTOS SALDO VIGENTE SALDO VENCIDO RATIO DE MORA así  como 
		la PARTICIPACIÓN DEL SALDO DE CRÉDITOS UNICUOTA SOBRE LA CARTERA 
		TOTAL AL 30/09/2015


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
				and A.nNumCuoApr = 1

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
				and A.nNumRenKpr = 1
			) AS  tmp
			
			
		CREATE NONCLUSTERED INDEX #KPYMCreConven_cCodCtaCre_IXN ON #KPYMCreConven(cCodCtaCre)	
		CREATE NONCLUSTERED INDEX #KPYMCreConven_cCodCliente_IXN ON #KPYMCreConven(cCodCliente)	


		Select * from #KPYMCreConven	

		
	-- Consumo
		Select
				A.cCodTipCre 
		    , Producto = B.cDesTipCre
			, SaldoVigente = sum(A.nSaldoVig)
			, SaldoVencido = sum(A.nSaldoVen)
			, RatioMora = (sum(A.nSaldoVen) / sum(A.nSaldoVig)) * 100
		From #KPYMCreConven	A
			INNER JOIN [KPYTSUBTIPCRE] B
				ON A.cCodTipCre = B.cCodTipCre AND A.cCodProduc = B.cCodProduc 
					AND A.cCodSubPro = B.cCodSubPro and B.lEstado = '1'			
		Where A.cCodTipCre = '03'
		 Group By  A.cCodTipCre,B.cDesTipCre


	-- MicroEmpresa
		 Select
				A.cCodTipCre 
		    , Producto = B.cDesTipCre
			, SaldoVigente = sum(A.nSaldoVig)
			, SaldoVencido = sum(A.nSaldoVen)
			, RatioMora = (sum(A.nSaldoVen) / sum(A.nSaldoVig)) * 100
		From #KPYMCreConven	A
			INNER JOIN [KPYTSUBTIPCRE] B
				ON A.cCodTipCre = B.cCodTipCre AND A.cCodProduc = B.cCodProduc 
					AND A.cCodSubPro = B.cCodSubPro and B.lEstado = '1'			
		Where A.cCodTipCre = '02'
		 Group By  A.cCodTipCre,B.cDesTipCre
	

	-- PequeniaEmpresa
		 Select
				A.cCodTipCre 
		    , Producto = B.cDesTipCre
			, SaldoVigente = sum(A.nSaldoVig)
			, SaldoVencido = sum(A.nSaldoVen)
			, RatioMora = (sum(A.nSaldoVen) / sum(A.nSaldoVig)) * 100
		From #KPYMCreConven	A
			INNER JOIN [KPYTSUBTIPCRE] B 
				ON A.cCodTipCre = B.cCodTipCre AND A.cCodProduc = B.cCodProduc 
					AND A.cCodSubPro = B.cCodSubPro and B.lEstado = '1'			
		Where A.cCodTipCre = '13'
		 Group By  A.cCodTipCre,B.cDesTipCre
	

	-- MedianaEmpresa
		 Select
				A.cCodTipCre 
		    , Producto = B.cDesTipCre
			, SaldoVigente = sum(A.nSaldoVig)
			, SaldoVencido = sum(A.nSaldoVen)
			, RatioMora = (sum(A.nSaldoVen) / sum(A.nSaldoVig)) * 100
		From #KPYMCreConven	A
			INNER JOIN [KPYTSUBTIPCRE] B
				ON A.cCodTipCre = B.cCodTipCre AND A.cCodProduc = B.cCodProduc 
					AND A.cCodSubPro = B.cCodSubPro and B.lEstado = '1'			
		Where A.cCodTipCre = '12'
		 Group By  A.cCodTipCre,B.cDesTipCre
	

	-- TOTAL x producto
		
		 Select
			  A.cCodTipCre 
		    , Producto = B.cDesTipCre
			, SaldoCapital = sum(A.nSaldoCapi) 
			, SaldoVigente = sum(A.nSaldoVig)
			, SaldoVencido = sum(A.nSaldoVen)
			, SaldoJudicial = sum(A.nSaldoJud)
			, SaldoRefinanciado = sum(A.nSaldoRef)
			, RatioMora = ((sum(A.nSaldoVen) + sum(A.nSaldoJud)) / sum(A.nSaldoCapi)) * 100
		From #KPYMCreConven	A
			INNER JOIN [KPYTSUBTIPCRE] B
				ON A.cCodTipCre = B.cCodTipCre AND A.cCodProduc = B.cCodProduc 
					AND A.cCodSubPro = B.cCodSubPro and B.lEstado = '1'			
		Where A.cCodTipCre in ('02','03','12','13')
		Group By  A.cCodTipCre,B.cDesTipCre


	-- TOTAL 
		
		 Select
			--	A.cCodTipCre 
		   -- , Producto = B.cDesTipCre
              SaldoCapital = sum(A.nSaldoCapi) 
			, SaldoVigente = sum(A.nSaldoVig)
			, SaldoVencido = sum(A.nSaldoVen)
			, SaldoJudicial = sum(A.nSaldoJud)
			, SaldoRefinanciado = sum(A.nSaldoRef)
			, RatioMora = ((sum(A.nSaldoVen) + sum(A.nSaldoJud)) / sum(A.nSaldoCapi)) * 100
		From #KPYMCreConven	A
			INNER JOIN [KPYTSUBTIPCRE] B
				ON A.cCodTipCre = B.cCodTipCre AND A.cCodProduc = B.cCodProduc 
					AND A.cCodSubPro = B.cCodSubPro and B.lEstado = '1'			
		Where A.cCodTipCre in ('02','03','12','13')
		-- Group By  A.cCodTipCre,B.cDesTipCre

	----------------------------------------------------------------------------------

	/*

	SET LANGUAGE spanish;

	DECLARE @nTipCambio MONEY,	@dFecTipCam CHAR(7)	
	SET @nTipCambio =
	   (SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),7) = '2015-10' --left(cast(GETDATE() as date),7)			
		Group by left(cast(dFecTipCam as date),7),nTipCamFij )
	--SELECT @nTipCambio

	SET @dFecTipCam =
		(SELECT left(cast(dFecTipCam as date),7)
			--,nTipCambio = nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),7) = '2015-10' --left(cast(GETDATE() as date),7)			
		Group by left(cast(dFecTipCam as date),7),nTipCamFij )
	--SELECT @dFecTipCam			


	Select 		
			 ROW_NUMBER() 
			OVER(PARTITION BY year(CRE.DFECDESCRE)
					ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE),NombreMes =DATENAME(month, CRE.DFECDESCRE)
			--,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 --,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 --,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 			
			--Datos del Cliente
			,CLI.cCodCliente AS 'CodigoCliente'			
			,CLIM.cNomCliente AS 'NombreCliente'	
			--Datos del credito			
			,CRE.cCodCtaCre AS 'CodigoCredito'						
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,FechaTipoCambio = @dFecTipCam
			,TipoCambio = @nTipCambio			
			,MontoDesembolsadoSoles =
			case cre.cCodTipMon
			when '1' then CRE.nMonCapDes --'SOLES'
			when '2' then CRE.nMonCapDes * @nTipCambio --'DOLARES'
			end 
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
			,TEM=CRE.nTasintCom	
			,NumeroCuotas=CRE.nNumCuoApr				
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'
			,SaldoSoles =
			case cre.cCodTipMon
			when '1' then (CRE.nMonCapDes - CRE.nMonCapPag) --'SOLES'
			when '2' then (CRE.nMonCapDes - CRE.nMonCapPag) * @nTipCambio --'DOLARES'
			end 
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'
			,Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END cDesConCre																									
			,O.cCodOficin, O.cDesOficin			
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'				
			,ZON.nCodZona, ZON.cDesZona		
		
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			inner JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 				
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

		WHERE CRE.cEstCreCon in ('F','H')					
			and CRE.nNumCuoApr = 1
			--and (CRE.cCodTipCre = '04' and STC.cDesSubcRE in ('MIVIVIENDA','MICONSTRUCCION'))			
			--AND left(cast(CRE.dFecDesCre as date),10) >='2014-06-01'
			--AND left(cast(CRE.dFecDesCre as date),10) <='2015-06-30'			
		*/
		
		/*
		SELECT * FROM [KPYTSUBTIPCRE] STC
		WHERE STC.lEstado = '1'  AND cDesSubCre LIKE '%UNI%' 
		*/
				