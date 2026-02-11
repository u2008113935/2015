
	/*
	
	Por el presente se solicita la cartera por asesor de negocios
	(CARTERA DE COLOCACIONES, N° DE CLIENTES Y CARTERA ATRASADA)
	de la agencia Huachipa segun zona (Dirección de cliente) al 31.08.2015. 
	Esto con la finalidad de distribuir la cartera que sera trasladad a la 
	agencia de Carapongo.

	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-09-01'				
				)

	--Select * into #tab01 from (

	Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'	
			,CLI.cCodCliente AS 'CodigoCliente'		
			,CLIM.cNomCliente AS 'NombreCliente'
			,DireccionDomicilio = REPLACE(rtrim(DC.cDirCliente),'.','')	
			,DireccionReferencia = DC.cDirCliRef
			,Zona = cNomZona
			,DIS1.cNomDistri as 'Distrito'		 					 			
			,PRO1.cNomProvin AS 'Provincia' 			
			,DEP1.cNomDepart AS 'Departamento'	
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
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END														 
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
			--,CRE.cEstCreCon
			--,EC.cDescriEst AS 'EstadoCredito'			
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona											
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

			left join HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC				
				on DC.cCodCliente = CLIM.CCODCLIENTE and DC.bDirPredet = '1'
			
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

		WHERE CRE.cEstCreCon in ('F','H')					
			and CRE.cCodOficin = '058'	
			--and CRE.cCodCtaCre = '107058101000057220'

		-- (2,229 row(s) affected)
		/*
		Select top 3 * from [GentDistrito]
		Select top 3 * from [GentProvincia]
		Select top 3 * from [GenTDepartame]

		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC
		
		Select * from GENTZona
		Order By cCodDepart,cCodProvin,cCodDistri
		
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDSolTraSin
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDSucEmpEmp
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDSucEmpEmpTMP
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.GenMAchataZon		
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.KJUTAdjudicado
		Select top 2 * from KPYHDetCliDes
		Select top 2 * from KPYHDetCliPar
		Select top 2 * from SERMCliGiros
		Select top 2 * from SIPDAccTraPer
		Select top 2 * from SIPDFamiliaPer
		Select top 2 * from SIPDFamiliPos
		Select top 2 * from SIPMDIRECC		
		
		--Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIAMDirecc
		--Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDDirCliCMa
		--Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDDirGarant
		--Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDFueIngreso
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDSucEmpEmp
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIDSucurCli
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIMDirecc
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.climdireccPasco
		Select top 2 * from HYO00402.CMACHYOCLI_MANIANA.dbo.CLIMEmpEmplea

		Select * from [GENTOficinas]
		Where cDesOficin like '%huachipa%'
		Order By cCodOficin asc
		*/