	
	/*
	Select * from gentsececon
	Select * from gentsececonom

	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.CLIAMClientes
	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.CLIDFueIngreso
	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.CLIHFueIngreso
	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.CLIMClientes --
	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.DWTMPCli
	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.HISCLIDFueIngreso
	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.HISCLIMEmpleador

	Select top 5 cCodSecEco,* from [hyo00402].CMACHYOCLI_MANIANA.dbo.CLIMClientes --
	*/

	/*	
	GENTSecEcon
	GENTSecEconom
	KPYDLimRieActEco
	KPYDRegCliErr	
	KPYTMetLCRSecEco

	CLIAMClientes
	CLIAMEmpleador
	CLIDFueIngreso
	CLIHFueIngreso
	CLIMClientes
	CLIMEmpEmplea
	CLIMEmpleador
	CLIMPasco
	DWTMPCli
	HISCLIDFueIngreso
	HISCLIMEmpleador
	*/

	/*
	select *  from KPYAMCreCarFia
	select *  from KPYMCreCarFia
	select *  from KPYTEstCarFia
	*/

	--01 SOLO CARTAS FIANZAS
	-- Drop table #tab01
	SET LANGUAGE spanish;
	
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-07-01'				
				)					

	 select * into #tab01 from (
		SELECT 
				--SECTOR ECONOMICO
				--SE.cCodSecEco, 
				CodigoLineaCredito = GEN.CCODLINCRE
				,ActividadEconomicaSolicitante = SE.cDesSecEco
				,CodExpedienteCliente = ISNULL(EXPE.CCODEXPCLI, '') 
				,CodigoCredito=FIA.CCODCTACRE, NumeroCartaFianza=CNROCARFIA
				--,FIA.CESTCARFIA
				,EstadoCartaFianza = EC.cDesEstCar
				,CodigoClienteSolicitante = GEN.CCODCLIENTE
				,NombreClienteSolicitante = CLITIT.CNOMCLIENTE 				
				/*
				--Representantes 
				,CodigoRepresentante = isnull(RL.cCodCliRep,'NO REGISTRA')
				,DocumentoRepresentante = ISNULL(isnull(CC.cNroDocIde,CC.cNroDocTri),'NO REGISTRA')
				,NombreRepresentante = ISNULL(CC.cNomCliente,'NO REGISTRA')				
				--Accionistas
				,DocAccionista = ISNULL(AC.cDocIdeAcc,'NO REGISTRA')
				,NombreAccinosta = isnull(AC.cApeNomAcc,'NO REGISTRA')
				,PorcentAcciones = isnull(AC.cPorParAcc,'NO REGISTRA')				
				*/
				-------------------------
				,CodigoClienteFavorable=FIA.CCODCLIENTE
				,NombreClienteFavorable =CLIFAV.CNOMCLIENTE 
				--,MonedaCartaFianza=MON.CDESCORTA
				,MonedaCartaFianza = MON.CDESTIPMON, ValorCartaFianza = NVALCARFIA,
				ValorEnSoles = 
				case MON.cCodTipMon
				WHEN '1' THEN NVALCARFIA
				WHEN '2' THEN @nTipCambio * NVALCARFIA
				END 				
				,FechaInicioCarta = left(cast(FIA.DFECINIFIA as date),10)
				,AnioInicio=YEAR(FIA.DFECINIFIA)
				,MesInicio=DATENAME(MONTH,FIA.DFECINIFIA) 
				,FechaCancelacionCarta = left(cast(FIA.DFECCANFIA as date),10)
				,PlazoCartaFianza = FIA.NPLAOTOFIA
				,DescripcionModificaciónCarta = MODCF.CDESMODFIA
				--ISNULL(TIPOGAR.CCODGARCLI, '') AS CCODGARCLI
				--, ISNULL(TIPOGAR.CCODCUENTA, '') AS CCODCUENTA
				--,ISNULL(TIPOGAR.CDESTIPGAR, '') AS CDESTIPGAR
				--,ISNULL(TIPOGAR.CTIPMONGAR, '') AS CTIPMONGAR
				--,ISNULL(TIPOGAR.NMONGARORI, 0.00) AS NMONGARORI
				--, S.cCodOficin
				,Oficina=O.cDesOficin--,ZON.nCodZona
				,Zona=ZON.cDesZona
				,CodigoCIIUSolicitante = CLITIT.cCodCiiu --,B.ccodciiu
				,DescripcionCIISolicitante =  B.cdesactivi
				--,CLITIT.cCodCiuDet
				--,C.ccodciudet ,c.cdesactivi																
				/*
				,GARLIN.CCODLINCRE
				,GARLIN.CCODGARCLI , GARLIN.CCODCLIENTE, GARLIN.CCODTIPGAR, GARLIN.CCODTIPMON 								
				,TIPGAR.CDESTIPGAR
				,M.CDESCORTA AS CTIPMONGAR				
				,MontoTasacion= GARLIN.nMonTasGar												
				*/		
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
				LEFT JOIN gentsececon SE
					ON SE.cCodSecEco = CLITIT.cCodSecEco
				
				inner join GENTCodCiiu B
					on CLITIT.cCodCiiu = B.ccodciiu	
				--inner join GENDCodCiiu C
					--on C.ccodciudet = CLITIT.cCodCiuDet									
								
				/*
				--Representantes				
				left join [hyo00402].CMACHYOCLI_MANIANA.DBO.CLIDRepresCli RL
					on RL.cCodCliente = GEN.CCODCLIENTE
				left join [hyo00402].CMACHYOCLI_MANIANA.DBO.ClimClientes CC
					on CC.cCodCliente = RL.cCodCliRep			
				--Accionistas
				left join [hyo00402].CMACHYOCLI_MANIANA.DBO.clidactaccjur AC
					on AC.cCodCliente = GEN.CCODCLIENTE
				*/
				/*
				inner join KPYDGARLINCRE GARLIN (NOLOCK) 
					on GARLIN.cCodLinCre = GEN.cCodLinCre
				inner JOIN GENDGARANTIA TIPGAR (NOLOCK)
					ON TIPGAR.CCODgarant = GARLIN.CCODTIPGAR and TIPGAR.lconestado = 1
				inner JOIN GENTMONEDA M (NOLOCK) 
					ON M.CCODTIPMON = GARLIN.CCODTIPMON
				*/
			WHERE FIA.CESTCARFIA = 'K'
				--and YEAR(FIA.DFECINIFIA) = '2013'
				--and MONTH(FIA.DFECINIFIA) = '12' 
			--ORDER BY FIA.CCODTIPMON, FIA.CNROCARFIA
			) as tmp
			
			-----------------------------------------------------------------------
			/*	
			Select * from #tab01
			Where CodigoCredito = '107002101007704156'
			*/
			--02 AGREGANDO GARANTIAS

			-- Drop table #tab02
			Select * into #tab02 from (
				Select FIA.CCODCTACRE, GARLIN.cCodLinCre, CodigoGarantia = GARLIN.CCODGARCLI 
				,CodCliente = GARLIN.CCODCLIENTE 
				,TipoGarantia = GARLIN.CCODTIPGAR
				--,GARLIN.CCODTIPMON 
				,DescripcionTipoGarantia = TIPGAR.CDESTIPGAR
				, Moneda=M.CDESCORTA
				,MontoTasacion= sum(GARLIN.nMonTasGar)
				FROM KPYMCRECARFIA FIA (NOLOCK)
					inner JOIN GENMCRECLI GEN (NOLOCK) 
						ON (FIA.CCODCTACRE = GEN.CCODCTACRE)	
					inner join KPYDGARLINCRE GARLIN (NOLOCK) 
						on GARLIN.cCodLinCre = GEN.cCodLinCre
					inner JOIN GENDGARANTIA TIPGAR (NOLOCK)
						ON TIPGAR.CCODgarant = GARLIN.CCODTIPGAR and TIPGAR.lconestado = 1
					inner JOIN GENTMONEDA M (NOLOCK) 
						ON M.CCODTIPMON = GARLIN.CCODTIPMON
				WHERE FIA.CESTCARFIA = 'K' ---and FIA.CCODCTACRE = '107002101007704156'
				Group By FIA.CCODCTACRE, GARLIN.cCodLinCre , GARLIN.CCODGARCLI
				, GARLIN.CCODCLIENTE , GARLIN.CCODTIPGAR	
				--, GARLIN.CCODTIPMON  
				,TIPGAR.CDESTIPGAR, M.CDESCORTA
				--Order by FIA.CCODCTACRE
				) as tmp
			
				----------------------------------------------------------------------------------------
								
				Select * from #tab01
				Select * from #tab02

				
				Select A.*
					,B.CodigoGarantia,B.TipoGarantia, B.DescripcionTipoGarantia, B.Moneda, B.MontoTasacion
				from #tab01 A
					inner join #tab02 B
						on A.CodigoCredito = B.cCodCtaCre


				/*
				Drop table #tab01
				Drop table #tab02
				*/

			