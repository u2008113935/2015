
		/*
			Se requiere saber de la lista de asesores enviada, que créditos de 
			consumo/plazo fijo están dentro de sus carteras . Considerar los 
			siguientes campos (cliente, saldo desembolsado, fecha de desembolso, 
			asesor actual, asesor origen)

		*/

	/*
		Select * from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
		Where lEstado = 1 
			--and cCodTipCre = '03'
			and cDesSubCre like '%PLAZO%FIJO%'
	*/
		
		-- Drop Table #tab01
		Select * into #tab01 from (
				Select P.cCodPerson, P.cNomPerson 
				From [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] P 
				Where P.cNomPerson COLLATE SQL_Latin1_General_CP1_CI_AS 
						in ( Select NombreAsesor from CredAsesor )
				) as tmp

	/*
		Select * from #tab01

		Select A.* 
		from CredAsesor A
	*/
	
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
				Anio=DATENAME(year, left(cast(CRE.dFecDesCre as date),10))
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
				 ,B.cCodUsuAna AS 'CodAsesorOrigen'
				 ,SP1.cNomPerson AS 'NombreAsesorOrigen'
				 ,CRE.cCodSolCre , CRE.cCodCtaCre
				 ,cUsuariApr =	RTRIM(BB.cCodUsuReg) + ' - ' + PP.cNomPerson	
		
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
				inner join [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMSolicitud B
					on B.cCodSolCre = CRE.cCodSolCre
				Inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP1 
					ON SP1.cCodPerson = B.cCodUsuAna						
					
				inner join [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDComAprCre] BB
					ON BB.cCodSolCre	=	CRE.cCodSolCre
				INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[SIPMPersonal] PP
					ON PP.cCodPerson	=	BB.cCodUsuReg

			WHERE CRE.cEstCreCon in ('F','H')
				and CRE.cCodUsuAna COLLATE SQL_Latin1_General_CP1_CI_AS					  									
								in ( Select cCodPerson from #tab01 (nolock) )								
				and STC.cDesSubCre like '%PLAZO%FIJO%'
				) as tmp

	
	/*
		Select * from #TmpSGN01
			-- 105 
	
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
		ROW_NUMBER() 
		OVER(PARTITION BY CodigoAnalista
		ORDER BY FechaDesembolsoCredito) as 'Nro',
		* 
	from #TmpSGN01	


		