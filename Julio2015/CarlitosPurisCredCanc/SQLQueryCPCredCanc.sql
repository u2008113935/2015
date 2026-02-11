	/*
	La información descrita en el archivo adjunto sobre créditos cancelados. 
	La información se reguiere del mes de julio 2010 al 30 de junio del 2015
		
	Cod. Cliente	Cod. Crédito	Tipo de Crédito	Producto	Sub Producto	
	Monto Desembolsado (Convertido a S/.)	TEM	Fecha de Desembolso	Plazo Inicial (días)
	Fecha de Cancelación	Plazo Transcurrido hasta la cancelación (días)	
	Motivo de Cancelación	Saldo Capital Cancelado (Convertido a S/.)
	*/

	/*
	SELECT dFecTipCam=left(cast(dFecTipCam as date),10),nTipCamFij
	FROM GENTTipCambio
	where left(cast(dFecTipCam as date),10) >='2010-07-01'
		and left(cast(dFecTipCam as date),10) <='2015-06-30'
	*/
	
	/*
	SELECT TOP 1 *
	FROM KPYDSalOpeCre

	SELECT *
	FROM KPYTMotSalOpe
	WHERE lEstMotSalOpe = 1

	-------------------------------------------------------------------------------
	
	*/
	
	-- 01 RELACION CREDITOS CANCELADOS 
	-- Drop table #tmp01
	Select * into #tmp01 from (
		Select 
			CodigoCliente = CLI.cCodCliente 	
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
			,CRE.nTasintCom
			,dFecDesCre=left(cast(CRE.dFecDesCre as date),10)
			,PlazoInicial = CRE.nNumDiaApr
			,CuotasAprobadas = CRE.nNumCuoApr
			,DiasGracia = CRE.nNumDiaGra
			,FormaPago= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)
			,dFecCulCre=left(cast(CRE.dFecCulCre as date),10)
			,PlazoHastaLaCanc=
			DATEDIFF(day,left(cast(CRE.dFecDesCre as date),10),left(cast(CRE.dFecCulCre as date),10))
			,M.cDesCotSalOpe
			,SaldoSoles=
			 case cre.cCodTipMon
			 when '1' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'SOLES'
			 when '2' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'DOLARES'
			 end 		
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'			
			,O.cCodOficin, O.cDesOficin			
		From [KPYMCRECONVEN] CRE (NOLOCK)
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'	
			
			left join KPYDSalOpeCre S
				on S.cCodCtaCre = CRE.cCodCtaCre and S.lEstSalOpe = 1 
					and S.dFecRegOpe=left(cast(CRE.dFecCulCre as date),10)
			left join KPYTMotSalOpe M
				on M.cCodMotSalOpe = S.cCodMotSalOpe and M.lEstMotSalOpe = 1	
			
		Where CRE.cEstCreCon = 'G'
			and left(cast(CRE.dFecDesCre as date),10) >= '2010-07-01'
			and left(cast(CRE.dFecDesCre as date),10) <= '2015-06-30'
		) as tmp
			-- (718,899 row(s) affected)

		--02 CONTROL DE DUPLICADOS Y ACTUALIZACION DE NULL cDesCotSalOpe

			/*

				Select * from #tmp01
				where CodigoCredito='107009101004424947'--'107049101000658243'--'107010101003053413'

				Select * from KPYDSalOpeCre
				Where cCodCtaCre= '107009101004424947'--'107049101000658243' -- '107010101003053413'--'107014101003137870' --'107019101002667256'--

				Select CodigoCredito, count(CodigoCredito)
				from #tmp01
				group by CodigoCredito
				having count(CodigoCredito) > 1
					-- CodigoCredito: 107009101004424947

			----------------------------------------------------------------------------
			*/
			SELECT * FROM #tmp01 WHERE cDesCotSalOpe IS NULL -- (89,228 row(s) affected)

			UPDATE #tmp01
			SET cDesCotSalOpe ='POR EXTINCIÓN DE DEUDA'
			WHERE cDesCotSalOpe IS NULL

			

		--03 SELECCIONAR EL TIPO DE CAMBIO POR CADA FECHA.
				
		Select * from #tmp01

		ALTER TABLE #tmp01
		ADD nTipCambio MONEY, dFecTipCam char(7)
		--drop column nTipCambio , dFecTipCam 
		------------------------------------------------------

			--DECLARE @nTipCambio MONEY,	@dFecTipCam DATE	
			-- Drop table #tc
			SELECT * INTO #tc from (
			SELECT dFecTipCam=rtrim(left(cast(dFecTipCam as date),7))
				,nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),7) >='2010-07'
				and left(cast(dFecTipCam as date),7) <='2015-06' 
			Group by left(cast(dFecTipCam as date),7),nTipCamFij
				) as tmp

			Select * from #tc
		------------------------------------------------------------
		

		Select A.* 
		from [#tmp01] A
		WHERE dFecDesCre = @dFecTipCam

		--***************************INDEXANDO****************************************************
		CREATE NONCLUSTERED INDEX #tmp01_CodigoCredito_IXN ON #tmp01(CodigoCredito)
		CREATE NONCLUSTERED INDEX #tmp01_dFecDesCre_IXN ON #tmp01(dFecDesCre)	
		---****************************************************************************

		--------------CURSOR TIPO CAMBIO X FECHA-------------------------------
			Declare @ccodcred varchar(18), @nTipCambio MONEY, @dFecTipCam char(7), @fecdes char(7)
			--Set @ccodcred = '107007101005311781'			
			Declare cTC CURSOR FOR	
				Select DISTINCT CodigoCredito from #tmp01 (NOLOCK) 					

			OPEN cTC
				FETCH cTC into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	
							
				Set @fecdes = (Select RTRIM(left(dFecDesCre,7)) from #tmp01 (NOLOCK) 	
								Where CodigoCredito = @ccodcred)			

				Set @nTipCambio = (Select rtrim(nTipCambio) from #tc 
									where dFecTipCam = @fecdes)

				Set @dFecTipCam = (Select rtrim(dFecTipCam) from #tc 
									where dFecTipCam = @fecdes)				
								
				UPDATE #tmp01
				SET nTipCambio = @nTipCambio, dFecTipCam = @dFecTipCam
				WHERE CodigoCredito = @ccodcred																	
				
				FETCH cTC INTO @ccodcred
				END
				CLOSE cTC
				DEALLOCATE cTC
				
		------------------------------------------------------------
			--VERIFICANDO
			Select * from #tmp01 (NOLOCK) Where CodigoCredito = '107009101004424947'
			Select * from #tc where dFecTipCam = '2013-03'

			Select * from #tmp01 (NOLOCK) -- (718,899 row(s) affected)

			Select * from #tmp01 (NOLOCK)
			Where dFecTipCam = left(dFecDesCre,7)

			/*
			Select * from #tmp01 (NOLOCK) 
			where dFecTipCam =''
			Select * from #tmp01 (NOLOCK) 
			where dFecTipCam is null

			Select * from #tmp01 (NOLOCK) 
			where nTipCambio is null
			Select * from #tmp01 (NOLOCK) 
			where nTipCambio = ''
			*/

	--04 HACIENDO EL CALCULO CON EL TIPO DE CAMBIO
	-- select * from #tmp01 (NOLOCK) 	

	Select  
		CodigoCliente,CodigoCredito,cCodTipCre,TipoCredito,SubTipoCredito,cCodProduc
		,ProductoCrediticio,cCodSubPro,SubProductoCrediticio,nTipCambio,dFecTipCam
		,Moneda,MontoDesemb
		,MontoDesembSoles =
		 case Moneda
		 when 'SOLES' then MontoDesemb
		 when 'DOLARES' then MontoDesemb * nTipCambio
		 end
		,nTasintCom,dFecDesCre,PlazoInicial,CuotasAprobadas, DiasGracia ,FormaPago
		,dFecCulCre,PlazoHastaLaCanc,cDesCotSalOpe
		,SaldoSoles=
		 case Moneda
		 when 'SOLES' then SaldoSoles
		 when 'DOLARES' then SaldoSoles * nTipCambio
		 end		
		,cEstCreCon,EstadoCredito,cCodOficin,cDesOficin
	from #tmp01 (NOLOCK) 	
	where --SaldoSoles != 0 and 
		 cCodOficin in ('063','064','065','066','067','068','069','070'
	,'071','072','073','074','075','076','077','078','079','080','081','082')
	order by CodigoCliente
	/*

	select cCodOficin from #tmp01 (NOLOCK) 
	group by cCodOficin
	'002','003','004','005','006','007','008' --OK
	,'009','010','011','012','013' --OK
	'014','015','016','017','018','019','020' --OK
	'021','022','023','024','025','030','031','034','035' --OK
	'036','037','038','039','040','041','042','043','044','045' --OK
	'046','047','048','049','050','051','052','053','054','055','056','057',
	'058','059','060','061','062' --OK
	
	,'063','064','065','066','067','068','069','070'
	,'071','072','073','074','075','076','077','078','079','080','081','082'

	select * from #tmp01 (NOLOCK) 
	where CodigoCredito = '107002102005591490'
	*/


