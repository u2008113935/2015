
		/*
		Solicito la data de créditos vinculados a Colaboradores al 31.08.2015 		

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
			OVER(PARTITION BY CLIM.cNomPerson
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 									
			,CLI.cCodCliente AS 'CodigoCliente'		
			--,CLIM.cNomCliente AS 'NombreCliente'
			,CLIM.cNomPerson AS 'NombreCliente'
			,Cargo = C.cDesCarPer 
			,Area = AA.cDesAreaCmac 
			,FechaIngreso = LEFT(CAST(CLIM.dFecIngIns AS DATE),10)
			,FechaCese = ISNULL(LEFT(CAST(CLIM.dFecCesIns AS DATE),10),'')
			,EstadoLaboral =
				Case when CLIM.dFecCesIns is null then 'VIGENTE'
				ELSE 'CESADO' END
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
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'	
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona											
	FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			--INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
			INNER JOIN sipmpersonal CLIM 
				--ON CLIM.cCodCliente = CLI.cCodCliente
				ON CLIM.cCodCliPer = CLI.cCodCliente
			inner join SIPTCARGOPER C
				on C.cCodGruPer = CLIM.cCodGruPer 
			
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
				on DC.cCodCliente = CLIM.cCodCliPer and DC.bDirPredet = '1'
			
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

			left join SIPTAreaCmac AA
				on AA.cCodAreaCmac = CLIM.cCodAreaCmac
		WHERE CRE.cEstCreCon in ('F','H')					
			--and CRE.cCodOficin = '058'	
	
		
		------------------------------------------------------------------------------

		/*

		Select * from SIPTCARGOPER C

		select * from SIPTAreaCmac
		Select cCodAreaCmac,* from SIRTAreas

		Select cCodCliPer,cCodAreaCmac,* from sipmpersonal
		Where cNumDocIde = '43111949'

		Select *
		from [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		Where cCodCliente = '107012504683'

		*/