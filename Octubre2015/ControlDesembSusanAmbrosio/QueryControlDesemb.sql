
	Select * from LC02
		-- (410 row(s) affected)

	Select * from LC01
		-- (660 row(s) affected)

	
		CREATE NONCLUSTERED INDEX LC01_CodigoCliente_IXN ON LC01(CodigoCliente)
		CREATE NONCLUSTERED INDEX LC02_CodigoCliente_IXN ON LC02(CodigoCliente)

		/*
			Drop table #tab01
			Drop table #tab02
		*/
		
		/*
		Select * into #tab01 from (
			Select C.cCodCliente, C.cNomCliente
			From [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
			Where cNomCliente COLLATE SQL_Latin1_General_CP1_CI_AS	
					in (Select rtrim(NombreCliente) from LC01)
			--Order By C.cCodCliente
			) as tmp


			Select cCodCliente, count(cCodCliente)
			From #tab01
			Group By cCodCliente
			Having count(cCodCliente) > 1
			Order By count(cCodCliente) desc



	Select * into #tab02 from (
			Select C.cCodCliente, C.cNomCliente
			From [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
			Where cNomCliente COLLATE SQL_Latin1_General_CP1_CI_AS	
					in (Select rtrim(NombreCliente1) from LC02)
			--Order By C.cCodCliente
			) as tmp


		Select * from #tab01	-- 665
		Select * from #tab02	-- 412

		CREATE NONCLUSTERED INDEX #tab01_cCodCliente_IXN ON #tab01(cCodCliente)
		CREATE NONCLUSTERED INDEX #tab02_cCodCliente_IXN ON #tab02(cCodCliente)
		*/
	-------------------------------------------------------------------------------

	SET LANGUAGE spanish;

	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
	set @nTipCambio = (
		SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
			nTipCambio = nTipCamFij
		FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.GENTTipCambio
		WHERE left(cast(dFecTipCam as date),10) ='2015-10-01')	

	-- Drop table #TmpSGN01
	SELECT * into #TmpSGN01 FROM  (
	
			SELECT 
				Desembolso = 'S'
				,Anio=DATENAME(year, left(cast(CRE.dFecDesCre as date),10))
				,Mes =DATENAME(month, left(cast(CRE.dFecDesCre as date),10))
				--Datos del Cliente	
				,isnull(CLIM.cNroDocIde,CLIM.cNroDocTri) as 'NroDocumento'
				,CLI.cCodCliente AS 'CodigoCliente'
				,CLIM.cNomCliente AS 'NombreCliente'
				--DATOS DEL CREDITO
				,CRE.cCodCtaCre AS 'CodigoCredito'
				,CRE.nMonCapDes as 'MontoDesembolso' 
				,CRE.nTasIntCom as 'TasaInteres'
				,CRE.nCosEfeAct as 'TasaCostoEfectivoAnual'
				,case CRE.cCodTipMon 
				 When '1' then 'SOLES'
				 WHEN '2' THEN 'DOLARES'
				 END as 'MONEDA'
				,CRE.nMonintPro as 'MontoInteresAprobado'
				,CRE.nMonintFec as 'MontoInteresAlaFecha'
				,CRE.nMonintPag as 'MontoInteresPagado'
				,EC.cDescriEst AS 'EstadoCredito'
				,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
				,ISNULL(left(cast(CRE.dFecCulCre as date),10),'') as 'FechaCulminacionCredito'
				,CRE.nNumCuoApr as 'NroCuotasAprobadas'
				
				,MontoDesembEnSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN CRE.nMonCapDes
					WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
					END										
				,SaldoCapEnSoles = 
					case cre.cCodTipMon
					WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
					WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
					END	
						
				,case CRE.cCodPlazo				
				 when '1' then 'CORTO PLAZO'
				 when '2' then 'LARGO PLAZO'
				 END as 'Plazo'
				 ,CRE.cCodTipCre
				 ,STC.cDesTipCre AS 'TipoCredito'
				 ,STC.cDesSubTip AS 'SubTipoCredito'
				 ,CRE.cCodProduc
				 ,STC.cDesProCre AS 'ProductoCrediticio' 
				 ,CRE.cCodSubPro	
				 ,STC.cDesSubcRE AS 'SubProductoCrediticio'		
	 			 ,CRE.cCodOficin, O.cDesOficin AS 'NombreAgencia' , ZON.cDesZona
				 ,CRE.cCodUsuAna AS 'CodigoAnalista'--COD ANALISTA
				 ,SP.cNomPerson AS 'NombreAnalista'--NOMBRE ANALISTA  
			FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
				INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
						ON CLIM.cCodCliente = CLI.cCodCliente
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTEstCreCon] EC 
						ON EC.cEstCreCon = CRE.cEstCreCon
				inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP 
						ON SP.cCodPerson = CRE.cCodUsuAna
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O 
						ON O.cCodOficin = CRE.cCodOficin
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
						ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
						AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'		
		
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[Gentofizonas] GOZ
						ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZonas] ZON
						ON ZON.nCodZona = GOZ.nCodZona			
			WHERE left(cast(CRE.dFecDesCre as date),10) >= '2015-09-30'
				and CLI.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS					  					
					in ( Select CodigoCliente from LC02 (nolock) )								
				) as tmp

	--	Select * from #TmpSGN01

	/*
	
		Select * from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.GENTOficinas
		where lconestado = '1'

		Select NOMBRE_AGENCIA, count()
		From CONSOLIDADOSA 
		Where cDesZona like '%ZONA%sur%'
		Group By NOMBRE_AGENCIA


	Select * from #TmpSGN01
	order by FechaDesembolsoCredito
		
	*/
		
	Select 
		/*
		ROW_NUMBER() 
		OVER(PARTITION BY cCodOficin
		ORDER BY FechaDesembolsoCredito) as 'Nro'
		*/
		* 
	from #TmpSGN01

	Union ALL	

	Select 
		Desembolso = 'N',Anio='',Mes='0'
		,NroDocumento= isnull(C.cNroDocIde,C.cNroDocTri)
		,CodigoCliente= C.cCodCliente
		,NombreCliente= C.cNomCliente
		,CodigoCredito='',MontoDesembolso=0.00,TasaInteres=0.00,TasaCostoEfectivoAnual=0.00
		,MONEDA='',MontoInteresAprobado=0.00,MontoInteresAlaFecha=0.00
		,MontoInteresPagado=0.00
		,EstadoCredito='',FechaDesembolsoCredito='',FechaCulminacionCredito=''
		,NroCuotasAprobadas=0.00,	MontoDesembEnSoles=0.00, SaldoCapEnSoles=0.00,Plazo =''
		,cCodTipCre='',	TipoCredito='',	SubTipoCredito='',cCodProduc=''	
		,ProductoCrediticio='',cCodSubPro='',SubProductoCrediticio=''	
		,cCodOficin  = O.cCodOficin
		,NombreAgencia = O.cDesOficin ,cDesZona=''	
		,CodigoAnalista=''	,NombreAnalista=''	
	From LC02 A		
		INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
			ON C.cCodCliente COLLATE SQL_Latin1_General_CP1_CI_AS = A.CodigoCliente
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O 
			ON O.cCodOficin COLLATE SQL_Latin1_General_CP1_CI_AS = A.CodOficina
	WHERE C.cCodCliente NOT IN (Select CodigoCliente from #TmpSGN01 NOLOCK)
