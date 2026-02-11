	/*
	SET LANGUAGE spanish;
	
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-07-01'				
				)	
	SELECT 
				 CodigoClienteSolicitante = GEN.CCODCLIENTE
				,NombreClienteSolicitante = CLITIT.CNOMCLIENTE 						 
				--SECTOR ECONOMICO
				--SE.cCodSecEco, 				
				--,ActividadEconomicaSolicitante = isnull(SE.cDesSecEco,'No Registra')
				,CodigoCIIUSolicitante = CLITIT.cCodCiiu --,B.ccodciiu
				,CodigoLineaCredito = GEN.CCODLINCRE
				,DescripcionCIISolicitante =  B.cdesactivi
				,CodExpedienteCliente = ISNULL(EXPE.CCODEXPCLI, '') 
				,CodigoCredito=FIA.CCODCTACRE, NumeroCartaFianza=CNROCARFIA
				--,FIA.CESTCARFIA
				,EstadoCartaFianza = EC.cDesEstCar								
				,ValorCartaFianza = NVALCARFIA
				,MonedaCartaFianza = MON.CDESTIPMON			
				,ValorEnSoles = 
				case MON.cCodTipMon
				WHEN '1' THEN NVALCARFIA
				WHEN '2' THEN @nTipCambio * NVALCARFIA
				END 				
				,FechaProceso =  left(cast(FIA.dFecProces as date),10)
				,FechaSolicitud = left(cast(FIA.dFecSolFia as date),10)
				,FechaInicioCarta = left(cast(FIA.DFECINIFIA as date),10)
				,AnioInicio=YEAR(FIA.DFECINIFIA)
				,MesInicio=DATENAME(MONTH,FIA.DFECINIFIA) 
				,FechaCancelacionCarta = left(cast(FIA.DFECCANFIA as date),10)
				,PlazoCartaFianza = FIA.NPLAOTOFIA
				,DescripcionModificaciónCarta = MODCF.CDESMODFIA				
				,CodigoClienteFavorable=FIA.CCODCLIENTE
				,NombreClienteFavorable =CLIFAV.CNOMCLIENTE 						
				--, S.cCodOficin
				,Oficina=O.cDesOficin--,ZON.nCodZona
				,Zona=ZON.cDesZona		
				--,CLITIT.cCodCiuDet
				--,C.ccodciudet ,c.cdesactivi							
			FROM KPYMCRECARFIA FIA (NOLOCK)				 
				inner JOIN GENMCRECLI GEN (NOLOCK) 
					ON (FIA.CCODCTACRE = GEN.CCODCTACRE)
				LEFT JOIN KPYTMODCARFIA MODCF (NOLOCK) 
					ON (FIA.cCodModFia = MODCF.cCodModFia)
				inner JOIN [hyo00402].CMACHYOCLI_MANIANA.DBO.CLIMClienteS CLITIT (NOLOCK) 						
					ON (CLITIT.CCODCLIENTE = GEN.CCODCLIENTE)
				LEFT JOIN [hyo00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente EXPE (NOLOCK) 
					ON (EXPE.CCODCLIENT = CLITIT.CCODCLIENTE AND EXPE.CTIPEXPCLI = 'K'
						AND EXPE.LCONESTADO = 1) 
				inner JOIN [hyo00402].CMACHYOCLI_MANIANA.DBO.CLIMClienteS CLIFAV (NOLOCK) 
					ON (CLIFAV.CCODCLIENTE = FIA.CCODCLIENTE)			
				LEFT JOIN GENTMONEDA MON (NOLOCK) 
					ON(MON.CCODTIPMON  = FIA.CCODTIPMON)				
				left JOIN KPYMSolicitud S
					ON FIA.cCodSolCre = S.cCodSolCre 			
				INNER JOIN GENTOficinas O
					on O.cCodOficin = S.cCodOficin
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona				
				INNER JOIN KPYTEstCarFia EC
					ON EC.cEstCarFia = FIA.CESTCARFIA 
				--SECTOR ECONOMICO
				/*
				LEFT JOIN gentsececon SE
					ON SE.cCodSecEco = CLITIT.cCodSecEco
				*/				
				inner join GENTCodCiiu B
					on CLITIT.cCodCiiu = B.ccodciiu	
				--inner join GENDCodCiiu C
					--on C.ccodciudet = CLITIT.cCodCiuDet																		
			WHERE FIA.CESTCARFIA in ('K','G')
				and CLITIT.cNroDocTri in 
				(
				'20102297581',
				'20509925195',
				'20546279988',
				'20493832230',
				'20510051395',
				'20505018258'
				)
				
				/*
				(
				'08600331',
				'09179190',
				'25568257',
				'06601190',
				'000992855',
				'42327447',
				'09729770',
				'09729770',
				'40665080' ,
				'17868297'
				)
				*/
			*/


		
		SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
		DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-07-01'				
				)
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
		WHERE CRE.cEstCreCon in ('F','H','I','G')					
			and CLIM.cNroDocIde in 
				(
				'08600331',
				'09179190',
				'25568257',
				'06601190',
				--'000992855',
				'42327447',
				'09729770',
				'09729770',
				'40665080' ,
				'17868297'
				)
			/*
			and CLIM.cNroDocTri in 
				(
				'20102297581',
				'20509925195',
				'20546279988',
				'20493832230',
				'20510051395',
				'20505018258'
				)							

				select *  
				from [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				where --CLIM.cNomCliente like 'CARRO%REY%UAN%MANUEL%'
				CLIM.cNroDocIde like '%992855%'
				*/