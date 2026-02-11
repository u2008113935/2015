
		/*
		LISTA DE CLIENTES VINCULADOS A LA SIGUIENTE LINEA: 
			Línea de Crédito : CRED. CONSUMO 
			Producto : NO REVOLVENTES 
			SubProducto : ADMINISTRATIVOS - DIRECTORES

		*/

		/*
		Select * from [KPYTSUBTIPCRE] STC
		Where STC.lEstado = '1' and STC.cDesSubCre = 'ADMINISTRATIVO - DIRECTORES'
		*/
	
	SET LANGUAGE spanish;
	--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
	set @nTipCambio = (
		SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
			nTipCambio = nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),10) ='2015-08-01'				
				)
	
	--Select * into #tab01 from (
	Select 		
			/*
			ROW_NUMBER() 
			OVER(PARTITION BY year(CRE.DFECDESCRE)
					ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 			
			*/
			CLI.cCodCliente AS 'CodigoCliente'		
			,CLIM.cNomCliente AS 'NombreCliente'
			--Datos del credito	
			,CRE.cCodCtaCre AS 'CodigoCredito'
			,TEM=CRE.nTasintCom									 
			,CLI.cCodLinCre		
			--,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 --,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 --,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 			
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
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)			
			--,CRE.cEstCreCon
			--,EC.cDescriEst AS 'EstadoCredito'
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END
			 ,NumeroCuotas=CRE.nNumCuoApr
			,DiasAtraso = CRE.nDiaAtrCre	
			--,FechaConstitGarantRRPP = ISNULL(left(cast(C.dFecConsGar as date),10),'') 
			--,B.cCodGarCli
			--,O.cCodOficin
			,Oficina = O.cDesOficin							
			--,ZON.nCodZona
			,Zona = ZON.cDesZona	
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
										
		WHERE (CRE.cCodTipCre = '03' 
				 --and STC.cDesSubCre = 'ADMINISTRATIVO - DIRECTORES'
				 and CRE.cCodProduc = '03' and CRE.cCodSubPro ='09'
				 and STC.lEstado = '1') 	
		Order By CLI.cCodCliente 							 
		--) as tmp