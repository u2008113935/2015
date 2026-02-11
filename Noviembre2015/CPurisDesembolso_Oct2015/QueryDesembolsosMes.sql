	/*
---------------------------------------------------------------------------------------
	SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
	* --nTipCambio = nTipCamFij
	FROM GENTTipCambio


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
			SELECT 
					MontoDesembolsoenSoles = 
						case A.cCodTipMon
						WHEN '1' THEN A.nMonCapDes
						WHEN '2' THEN @nTipCambio * A.nMonCapDes
						END					
			FROM KPYMCREconven A
				--INNER JOIN GENMCreCli B
					--ON A.cCodCtaCre = B.cCodCtaCre		
			WHERE 
					A.cEstCreCon in ('F','H','G','I')										
					and left(cast(A.dFecDesCre as date),10) >= '2015-10-01'
					and left(cast(A.dFecDesCre as date),10) <= '2015-10-31'	

			--Select * from #KPYMCreConven		-- drop table #KPYMCreConven
			UNION ALL		
			
			-- BASE DE DATOS DE CREDITOS PRENDARIOS
			SELECT
					MontoDesembolsoenSoles = 
						case A.cCodTipMon
						WHEN '1' THEN A.nMonCreKpr
						WHEN '2' THEN @nTipCambio * A.nMonCreKpr
						END					
			FROM KPRMCrePrenda A							    							 						
				--INNER JOIN GENMCreCli B
					--ON A.cCodCtaKpr = B.cCodCtaCre
			WHERE	A.cCodEstKpr IN ('A','D','G','H','R')										 
					and left(cast(A.dFecCreKpr as date),10) >= '2015-10-01'
					AND left(cast(A.dFecCreKpr as date),10) <= '2015-10-31'		
								
			) AS  tmp
			
			
		CREATE NONCLUSTERED INDEX #KPYMCreConven_cCodCtaCre_IXN ON #KPYMCreConven(cCodCtaCre)	
		CREATE NONCLUSTERED INDEX #KPYMCreConven_cCodCliente_IXN ON #KPYMCreConven(cCodCliente)	


		Select * from #KPYMCreConven	

		Select sum(MontoDesembolsoenSoles)
		From #KPYMCreConven
		
	----------------------------------------------------------------


	SET LANGUAGE spanish;
	
	
	DECLARE @nTipCambio11 MONEY,	@dFecTipCam11 DATE					
	set @nTipCambio11 = (
		SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),10) = '2015-11-01' )

	-- Drop table #tab03
	Select * into #tab03 from (
	
	Select 			
			MontoDesemb =
			 case cre.cCodTipMon
			 when '1' then  CRE.nMonCapDes 		 			 
			 when '2' then  CRE.nMonCapDes * @nTipCambio11 		 			 
			 end 						
	
	FROM [KPYMCRECONVEN] CRE (NOLOCK)			
	WHERE CRE.cEstCreCon in ('F','H','G','I')					
			and left(cast(CRE.dFecDesCre as date),10) >= '2015-10-01'
			and left(cast(CRE.dFecDesCre as date),10) <= '2015-10-31'						
		
	union all
	
	Select 			
			MontoDesemb = 
				Case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonCreKpr
				WHEN '2' THEN @nTipCambio11* PREN.nMonCreKpr
				END			
	FROM [KPRMCREPRENDA] PREN (NOLOCK)								 						
	WHERE PREN.cCodEstKpr 
			in ('D','A','R','G','H')									
		and left(cast(PREN.dFecCreKpr as date),10) >= '2015-10-01'
		AND left(cast(PREN.dFecCreKpr as date),10) <= '2015-10-31'			
	
	) as tmp
		
		------------------------------------------------------------------------
		
		Select * from #tab03
		Select sum(MontoDesemb) from #tab03

		/*
			Drop  table #tab01
			Drop  table #tab02
			Drop  table #tab03

		*/

	------------------------------------------------------------------------------------------
	*/

	SET LANGUAGE spanish;	
	
	DECLARE @nTipCamb MONEY
	set @nTipCamb = (
		SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),10) = '2015-11-01' )


	Select * into #tab01 from (
	
	Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY MONTH (CRE.DFECDESCRE)
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
			-------------------------------------------------------------
			,CodigoCliente = CLI.cCodCliente 	
			--Datos del credito
			,CodigoCredito = CRE.cCodCtaCre			
			,CRE.cCodTipCre
			,TipoCredito=STC.cDesTipCre
			,SubTipoCredito=STC.cDesSubTip 
			,CRE.cCodProduc
			,ProductoCrediticio=STC.cDesProCre 
			,CRE.cCodSubPro	
			,SubProductoCrediticio=STC.cDesSubcRE 						
			,MontoDesemb = 				
			 case cre.cCodTipMon
			 when '1' then CRE.nMonCapDes  
			 when '2' then CRE.nMonCapDes * @nTipCamb
			 end 					 			 
			,Moneda =
			 case cre.cCodTipMon
			 when '1' then  'SOLES'
			 when '2' then  'DOLARES'
			 end 			
			,TEM= CRE.nTasintCom
			,TipoTasa = CRE.cTipTasCom
			,DetalleTipoTasa =
				Case CRE.cTipTasCom
				When 'TM' THEN 'ESPECIAL MAYOR'
				When 'TT' THEN 'DE TABLA'
				When 'TM' THEN 'DE ADMINISTRAC'
				When 'TJ' THEN 'DE JEFATURA'
				When 'TG' THEN 'DE GERENCIA'
				When 'ES' THEN 'GER OPE/FINAN'
				ELSE CRE.cTipTasCom END			
			,FechaDesembolsoCredito = left(cast(CRE.dFecDesCre as date),10)
			,FechaCancelacionCredito = isnull(left(cast(CRE.dFecCulCre as date),10),'') 	
			,PlazoInicial = CRE.nNumDiaApr
			,CuotasAprobadas = CRE.nNumCuoApr
			,DiasGracia = CRE.nNumDiaGra
			,FormaPago= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)			
			,PlazoHastaLaCanc=
				ISNULL(
				DATEDIFF(day,left(cast(CRE.dFecDesCre as date),10),left(cast(CRE.dFecCulCre as date),10)),'')
			,DescripcionMotivoSalidaOperacion=ISNULL(M.cDesCotSalOpe,'')
			,SaldoSoles=
			 case cre.cCodTipMon
			 when '1' then (CRE.nMonCapDes - CRE.nMonCapPag) 
			 when '2' then (CRE.nMonCapDes - CRE.nMonCapPag) * @nTipCamb
			 end 		
			,SituacionCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END
			--,EC.cDescriEst AS 'EstadoCredito'			
			,O.cDesOficin, Zona = ZON.cDesZona	
			,cCodModCre = 'KPY'
					
		FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre		
			INNER JOIN KPYTSUBTIPCRE STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN GENTOficinas O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN Gentofizonas GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN GentZonas ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna	
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon			
			 left join KPYDSalOpeCre S
				on S.cCodCtaCre = CRE.cCodCtaCre and S.lEstSalOpe = 1 
					and S.dFecRegOpe=left(cast(CRE.dFecCulCre as date),10)			
			 left join KPYTMotSalOpe M
				on M.cCodMotSalOpe = S.cCodMotSalOpe and M.lEstMotSalOpe = 1				 				
										
		WHERE CRE.cEstCreCon in ('F','H','G','I')					
			and left(cast(CRE.dFecDesCre as date),10) >= '2015-10-01'
			and left(cast(CRE.dFecDesCre as date),10) <= '2015-10-31'						
	

	union all		

	Select 				
			ROW_NUMBER() 
			OVER(PARTITION BY MONTH (PREN.dFecCreKpr)
					ORDER BY left(cast(PREN.dFecCreKpr as date),10) ) AS Secuencia 
			,Anio= year(PREN.dFecCreKpr), Mes = MONTH (PREN.dFecCreKpr)
			,NombreMes =DATENAME(month, PREN.dFecCreKpr)	
			-------------------------------------------------------------
			,CodigoCliente = CLI.cCodCliente 	
			--Datos del credito
			,CodigoCredito = PREN.cCodCtaKpr							
			,cCodTipCre='03'
			,TipoCredito= 'CONSUMO '
			,SubTipoCredito= 'PIGNORATICIOS' --STC.cDesSubTip 
			,cCodProduc='13'			
			,ProductoCrediticio= 'PRESTAMOS' --STC.cDesProCre 			
			,cCodSubPro='16'		
			,SubProductoCrediticio= 'CREDIJOYAS' --STC.cDesSubcRE 						
			,MontoDesemb = 
				Case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonCreKpr
				WHEN '2' THEN @nTipCamb * PREN.nMonCreKpr
				END							 			 
			,Moneda =
			 case PREN.cCodTipMon
			 when '1' then  'SOLES'
			 when '2' then  'DOLARES'
			 end 			
			,TEM= PREN.nTasIntKpr
			,TipoTasa = 'TT'
			,DetalleTipoTasa = 'DE TABLA'				
			,FechaDesembolsoCredito = left(cast(PREN.dFecCreKpr as date),10)
			,FechaCancelacionCredito = isnull(left(cast(PREN.dFecVenKpr as date),10),'') 
				
			,PlazoInicial = PREN.nDiaPlaKpr
			,CuotasAprobadas = PREN.nNumRenKpr
			,DiasGracia = 0
			,FormaPago= (PREN.nDiaPlaKpr * PREN.nNumRenKpr) 
			,PlazoHastaLaCanc=
				ISNULL(
				DATEDIFF(day,left(cast(PREN.dFecCreKpr as date),10),left(cast(PREN.dFecVenKpr as date),10)),'')

			,DescripcionMotivoSalidaOperacion = ISNULL(M.cDesCotSalOpe,'')
			,SaldoSoles=
			 case PREN.cCodTipMon
			 when '1' then PREN.nMonSalAct 
			 when '2' then PREN.nMonSalAct * @nTipCamb
			 end 		
			,SituacionCredito = EC.cDesEstKpr			 						
			,O.cDesOficin
			,Zona = ZON.cDesZona		
			,cCodModCre = 'KPR'	
	
	FROM [KPRMCREPRENDA] PREN (NOLOCK)								 						
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = PREN.cCodCtaKpr
			INNER JOIN KPRTEstCredito  EC 			           
				ON EC.cCodEstKpr = PREN.cCodEstKpr
			INNER JOIN GENTOficinas O 
				ON O.cCodOficin = PREN.cCodOficin and O.lConEstado = '1'			
			INNER JOIN Gentofizonas GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN GentZonas ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			inner JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = PREN.cCodUsuKpr					
			left join KPYDSalOpeCre S
				on S.cCodCtaCre = PREN.cCodCtaKpr and S.lEstSalOpe = 1 
					and S.dFecRegOpe = left(cast(PREN.dFecVenKpr as date),10)			
			left join KPYTMotSalOpe M
				on M.cCodMotSalOpe = S.cCodMotSalOpe and M.lEstMotSalOpe = 1
	WHERE PREN.cCodEstKpr 
			in ('D','A','R','G','H')									
		and left(cast(PREN.dFecCreKpr as date),10) >= '2015-10-01'
		AND left(cast(PREN.dFecCreKpr as date),10) <= '2015-10-31'			

		)  as tmp


	-- Select * from #tab01

	-- Select sum(MontoDesemb) from #tab01
	
	-- drop table #tab01

	/*
	Select cCodEstKpr 
	FROM [KPRMCREPRENDA] PREN (NOLOCK)								 						
	Group By cCodEstKpr

	Select * from KPRTEstCredito

	Select * from KPYTSUBTIPCRE
	Where lEstado = '1' and cCodTipCre = '03' and cCodProduc = '13' and cCodSubPro = '16'


	Select top 50 * 
	FROM [KPRMCREPRENDA] PREN (NOLOCK)	
	

	*/