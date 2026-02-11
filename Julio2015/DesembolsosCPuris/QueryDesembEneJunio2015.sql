		/*
		Segun archivo adjunto (DESEMBOLSOS), 
		esto para dar atención al Memorándum N° 06672-2015-G-CMACHYO (COGAP).
		La data solicitada es desde el mes de Enero 2013 hasta el 30 de junio del 2015,
		de manera mensual.		

		CodigoCliente	CodigoCredito	TipoCredito	SubTipoCredito	ProductoCrediticio
		SubProductoCrediticio	TipoCambio	FechaTipoCambio	Moneda	MontoDesemb
		MontoDesembSoles	TEM	TasaEspecial	FechaDesembolso	AñoDesem	FormaPago
		CuotasAprobadas	DiasGracia	PlazoInicial	PlazoInicialMeses	
		Situación del Crédito	Oficina		
		*/

	/*
	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-07-01'							
				)
	*/
	-- drop table #tab01
	SET LANGUAGE spanish;
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
			,Moneda =
			 case cre.cCodTipMon
			 when '1' then  'SOLES'
			 when '2' then  'DOLARES'
			 end 
			,MontoDesemb= CRE.nMonCapDes 		 			 
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
			,FechaCancelacionCredito = left(cast(CRE.dFecCulCre as date),10) 	
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
			 when '1' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'SOLES'
			 when '2' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'DOLARES'
			 end 		
			,SituacionCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END
			,EC.cDescriEst AS 'EstadoCredito'			
			,O.cDesOficin, Zona = ZON.cDesZona							
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
			
			 left join KPYDSalOpeCre S
				on S.cCodCtaCre = CRE.cCodCtaCre and S.lEstSalOpe = 1 
					and S.dFecRegOpe=left(cast(CRE.dFecCulCre as date),10)			
			 left join KPYTMotSalOpe M
				on M.cCodMotSalOpe = S.cCodMotSalOpe and M.lEstMotSalOpe = 1				 				
										
		WHERE CRE.cEstCreCon in ('F','H','I','G')					
			and left(cast(CRE.dFecDesCre as date),10) >= '2013-01-01'
			and left(cast(CRE.dFecDesCre as date),10) <= '2015-06-30'						
		) as tmp

		/*
		Select top 10 * FROM [KPYMCRECONVEN] CRE (NOLOCK)	
		
		Select * from KPYDSolTasEsp

		Select top 10 cTipTasCom,* from KPYDSolTasEsp											

		Select top 10 cTipTasCom,* from KPYHSolicitud			
		
		Select cTipTasCom from KPYMCRECONVEN
		Group By cTipTasCom	

		*/
	
			--03 SELECCIONAR EL TIPO DE CAMBIO POR CADA FECHA.
				
		--Select * from #tab01

		ALTER TABLE #tab01
		ADD nTipCambio MONEY, dFecTipCam char(7)
		--Drop column nTipCambio , dFecTipCam 
		------------------------------------------------------

			--DECLARE @nTipCambio MONEY,	@dFecTipCam DATE	
			-- Drop table #tc
			SELECT * INTO #tc from (
			SELECT dFecTipCam=rtrim(left(cast(dFecTipCam as date),7))
				,nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),7) >='2013-01'
				and left(cast(dFecTipCam as date),7) <='2015-06' 
			Group by left(cast(dFecTipCam as date),7),nTipCamFij
				) as tmp

			-- Select * from #tc
		------------------------------------------------------------
		
		--***************************INDEXANDO****************************************************
		CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01 (CodigoCredito)
		CREATE NONCLUSTERED INDEX #tab01_FechaDesembolsoCredito_IXN ON #tab01 (FechaDesembolsoCredito)	
		---****************************************************************************

		/*
		Select * from #tab01

		Select CodigoCredito,count(CodigoCredito) from #tab01
		Group By CodigoCredito
		Having count(CodigoCredito) > 1
		*/

		--------------CURSOR TIPO CAMBIO X FECHA-------------------------------
			Declare @ccodcred varchar(18), @nTipCambio MONEY, @dFecTipCam char(7), @fecdes char(7)
			--Set @ccodcred = '107007101005311781'			
			Declare cTC11 CURSOR FOR	
				Select DISTINCT CodigoCredito from #tab01 (NOLOCK) 					

			OPEN cTC11
				FETCH cTC11 into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
							
				Set @fecdes = (Select RTRIM(left(cast(FechaDesembolsoCredito as date),7)) from #tab01 (NOLOCK) 	
								Where CodigoCredito = @ccodcred)			

				Set @nTipCambio = (Select rtrim(nTipCambio) from #tc 
									where dFecTipCam = @fecdes)

				Set @dFecTipCam = (Select rtrim(dFecTipCam) from #tc 
									where dFecTipCam = @fecdes)				
								
				UPDATE #tab01
				SET nTipCambio = @nTipCambio, dFecTipCam = @dFecTipCam
				WHERE CodigoCredito = @ccodcred																	
				
				FETCH cTC11 INTO @ccodcred
				END
				CLOSE cTC11
				DEALLOCATE cTC11
				
		------------------------------------------------------------
		--Select * from #tab01
		
SELECT		
	Anio,	Mes,	NombreMes,	CodigoCliente,	CodigoCredito, TipoCredito,	SubTipoCredito,	ProductoCrediticio
	,SubProductoCrediticio, FechaDesembolsoCredito, MontoDesemb, Moneda, PlazoInicial,	CuotasAprobadas
	,DiasGracia, FormaPago	,TipoCambio = nTipCambio,	FechaTipoCambio = dFecTipCam
	,MontoDesembolsadoSoles = 
	CASE Moneda WHEN 'SOLES' THEN MontoDesemb
				WHEN 'DOLARES' THEN MontoDesemb * nTipCambio END
	,TEM,	TipoTasa,	DetalleTipoTasa
	, FechaCancelacionCredito, Saldo= SaldoSoles, PlazoHastaLaCanc,	DescripcionMotivoSalidaOperacion
	,SaldoSoles = 
	CASE Moneda WHEN 'SOLES' THEN SaldoSoles
				WHEN 'DOLARES' THEN SaldoSoles * nTipCambio END
	,SituacionCredito,	EstadoCredito,	cDesOficin,	Zona	
FROM #tab01
ORDER BY Anio,Mes

		/*
		
		Drop table #tab01
		Drop table #tc

		*/
				
		
		