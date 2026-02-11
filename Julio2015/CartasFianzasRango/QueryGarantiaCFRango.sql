	
	/*
	Buenas tardes, por favor solicito la Base de Datos de todas las Cartas fianza 
	de Enero 2013 a Junio 2015 vigente y Canceladas. Filtradas con los campos: 
	1. Nombre de cliente 2. Sector economico 3. Giro de negocio 4. Modalidad o tipo 
	5. Monto otorgado 6. moneda 7. Comisión 8. Estado 9. Plazo 10. Garantia 
	11. Agencia 12. Zona 13. Fecha de emisión y Fecha de cancelación.
	
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
				 CodigoClienteSolicitante = GEN.CCODCLIENTE
				,NombreClienteSolicitante = CLITIT.CNOMCLIENTE 						 
				--SECTOR ECONOMICO
				--SE.cCodSecEco, 				
				,ActividadEconomicaSolicitante = isnull(SE.cDesSecEco,'No Registra')
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
				,AnioSolicitud = year(FIA.dFecSolFia) --YEAR(FIA.DFECINIFIA)
				,MesSolicitud = datename(month,FIA.dFecSolFia) -- DATENAME(MONTH,FIA.DFECINIFIA) 
				,FechaCancelacionCarta = left(cast(FIA.DFECCANFIA as date),10)
				,PlazoCartaFianza = FIA.NPLAOTOFIA
				,DescripcionModificaciónCarta = MODCF.CDESMODFIA
				,STC.cDesTipCre AS 'TipoCredito'
				,STC.cDesSubTip AS 'SubTipoCredito'				
				,STC.cDesProCre AS 'ProductoCrediticio' 				 
				,STC.cDesSubcRE AS 'SubProductoCrediticio' 				

				,CodigoClienteFavorable=FIA.CCODCLIENTE
				,NombreClienteFavorable =CLIFAV.CNOMCLIENTE 						
				--, S.cCodOficin
				,Oficina=O.cDesOficin--,ZON.nCodZona
				,Zona=ZON.cDesZona
				,FIA.cCodUSuAna AS 'CodAsesorActual'
				,SP.cNomPerson AS 'NombreAsesorActual'		
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
				INNER JOIN [KPYTSUBTIPCRE] STC
					ON S.cCodTipCre = STC.cCodTipCre AND S.cCodProduc = STC.cCodProduc 
						AND S.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'	
							
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
				INNER JOIN [sipmpersonal] SP 					
					ON SP.cCodPerson = FIA.cCodUSuAna --cCodUsuPro																		
			WHERE FIA.CESTCARFIA = 'K' -- in ('K','G')
				--and left(cast(FIA.DFECINIFIA as date),10) >= '2013-01-01'									
				and left(cast(FIA.dFecSolFia as date),10) >= '2013-01-01'
				--FIA.CCODCTACRE in  ('107070101000386780','107070101000384013')									
			) as tmp
			
			
			/*
			Select * from #tab01 order by FechaInicioCarta
			Select * from #tab01 order by FechaSolicitud 

			Select top 10 * from KPYMSolicitud

			*/

			-- (343 row(s) affected)
			-----------------------------------------------------------------------
			
			--02 insertando la ultima comision
			Alter table #tab01
			Add Comision money, FechaPag date		
			
					----------------------------cursor comision-----------------------
					Declare @cCodLinCre char(18) , @monpaggas money, @fechapag date							
				
					Declare cGarantiasUnion CURSOR FOR
						select CodigoCredito from #tab01 (NOLOCK)
					OPEN cGarantiasUnion
					FETCH cGarantiasUnion into @cCodLinCre
					WHILE (@@FETCH_STATUS=0)
					BEGIN		
		
					  set @monpaggas = ( 
							SELECT nMonPagGas
							FROM KPYDGasGenFia
							WHERE cCodCtaCre = @cCodLinCre
								   AND cCodTipGas = '11'
								   AND cCondicPag = 'N'
								   AND cCodEstGas = 'P'
								   and dFecPagGas in (
											SELECT max(dFecPagGas)
											FROM KPYDGasGenFia
											WHERE cCodCtaCre = @cCodLinCre
												   AND cCodTipGas = '11'
												   AND cCondicPag = 'N'
												   AND cCodEstGas = 'P'
													)
										)											  			
						
						set @fechapag =  (
											SELECT max(dFecPagGas)
											FROM KPYDGasGenFia
											WHERE cCodCtaCre = @cCodLinCre
												   AND cCodTipGas = '11'
												   AND cCondicPag = 'N'
												   AND cCodEstGas = 'P'
										  )
		  
					  Update #tab01							
					  Set Comision = @monpaggas , FechaPag = @fechapag
					  where CodigoCredito = @cCodLinCre		  

					FETCH cGarantiasUnion INTO @cCodLinCre
					END
					CLOSE cGarantiasUnion
					DEALLOCATE cGarantiasUnion
					-------------------------------------------------------------------
					
					/*
					Select * from #tab01					
					WHERE FechaPag is null or comision is null
					-- CodigoCredito: 107045101000866280

					Select * from #tab01
					Order By FechaInicioCarta

					*/
			/*		

			Select * from #tab01
			WHERE CodigoCredito =  '107045101000866280'--'107002101002901744'

			/*
			-- NO HAY REPETIDOS
			Select CodigoCredito,COUNT(CodigoCredito)
			from #tab01
			GROUP BY CodigoCredito
			HAVING COUNT(CodigoCredito) > 1			
			*/

			SELECT nMonGasGen, nMonPagGas,*
			FROM KPYDGasGenFia
			WHERE cCodCtaCre = '107045101000866280'
				   AND cCodTipGas = '11'
				   AND cCondicPag = 'N'
				   AND cCodEstGas = 'P'
				   --AND nMonGasGen <> nMonPagGas
			
			Select * from KPYHCreCarFia where cCodCtaCre = '107045101000866280' -- '107002101002901744'
			order by dFecIniFia

			Select * from KPYTEstCarFia

			*/ 

			--03 AGREGANDO GARANTIAS

		
			-- Drop table #tab02
			Select * into #tab02 from (
				Select FIA.CCODCTACRE, GARLIN.cCodLinCre, CodigoGarantia = GARLIN.CCODGARCLI 
				,CodCliente = GARLIN.CCODCLIENTE 
				,TipoGarantia = GARLIN.CCODTIPGAR
				--,GARLIN.CCODTIPMON 
				,DescripcionTipoGarantia = TIPGAR.CDESTIPGAR
				, Moneda=M.CDESCORTA
				,MontoGravamen=  sum(GARLIN.nMonGraGarSol) -- sum(GARLIN.nMonTasGar)
				,MontoGravamenSoles =  
					Case GARLIN.CCODTIPMON
					when '1'  then  sum(GARLIN.nMonGraGarSol) -- sum(GARLIN.nMonTasGar)
					when '2' then  sum(GARLIN.nMonGraGarSol) * GARLIN.nTipCamGar
					end 
				FROM KPYMCRECARFIA FIA (NOLOCK)
					inner JOIN GENMCRECLI GEN (NOLOCK) 
						ON (FIA.CCODCTACRE = GEN.CCODCTACRE)	
					inner join KPYDGARLINCRE GARLIN (NOLOCK) 
						on GARLIN.cCodLinCre = GEN.cCodLinCre
					inner JOIN GENDGARANTIA TIPGAR (NOLOCK)
						ON TIPGAR.CCODgarant = GARLIN.CCODTIPGAR and TIPGAR.lconestado = 1
					inner JOIN GENTMONEDA M (NOLOCK) 
						ON M.CCODTIPMON = GARLIN.CCODTIPMON
				WHERE FIA.CESTCARFIA in ('K') ---and FIA.CCODCTACRE = '107002101007704156'
					and left(cast(FIA.dFecSolFia as date),10) >= '2013-01-01'
				Group By FIA.CCODCTACRE, GARLIN.cCodLinCre , GARLIN.CCODGARCLI
				, GARLIN.CCODCLIENTE , GARLIN.CCODTIPGAR, GARLIN.CCODTIPMON	, GARLIN.nTipCamGar
				--, GARLIN.CCODTIPMON  
				,TIPGAR.CDESTIPGAR, M.CDESCORTA
				--Order by FIA.CCODCTACRE
				) as tmp
			
				----------------------------------------------------------------------------------------
				 /*
				 
				 Select * from KPYDGARLINCRE
				 Select * from GENDGARANTIA

				 */
				 				
				Select * from #tab01
				Select * from #tab02

				Select len(cCodLinCre) from #tab02

			--04 AGRUPANDO LAS GARANTIAS
					
					Select cCodLinCre, count(CodigoGarantia) from #tab02 
					Group By cCodLinCre
					Having count(CodigoGarantia) > 1

					Select cCodLinCre, count(CodigoGarantia) from #tab02 
					Group By cCodLinCre
					Having count(CodigoGarantia) = 1


					-- drop table #tab03
					Select * into #tab03 from 
							(select top 1 cCodLinCre,DescripcionTipoGarantia,MontoGravamenSoles 
							from #tab02 ) as tmp
					Select * from #tab03
					Delete from #tab03

					  --UNA SOLA GARANTIA
					  Insert Into #tab03							
					  Select cCodLinCre,DescripcionTipoGarantia,MontoGravamenSoles
					  from #tab02 
					  where cCodLinCre in (
									Select cCodLinCre --, count(CodigoGarantia) 
									from #tab02 
									Group By cCodLinCre
									Having count(CodigoGarantia) = 1
					  					  )
					 -- MAS DE 2 GARANTIAS
					 -- drop table #tab033
					 Select * into #tab033 from ( select top 1 * from #tab02 ) as tmp
					 Select * from #tab033
					 Delete from #tab033
					 -- drop table #tab033
					  Insert Into #tab033							
					  Select * from #tab02 
					  where cCodLinCre in (
									Select cCodLinCre --, count(CodigoGarantia) 
									from #tab02 
									Group By cCodLinCre
									Having count(CodigoGarantia) > 1
					  					  )

					SELECT * FROM #tab033					
					
					insert into #tab03
					Select 
					cCodLinCre,DescripcionTipoGarantia='GarantiasMixtas'
					,MontoGravamenSoles=sum(MontoGravamenSoles)
					from #tab033
					Group By cCodLinCre					
					--having  cCodLinCre = '0020094770' --CCODCTACRE = '107002101009179435'
					--Order By CCODCTACRE										

			--05 CRUCE
			--Select * into #tab04 from (
				Select A.*
					--,B.CodigoGarantia,B.TipoGarantia, B.Moneda
					,B.DescripcionTipoGarantia,B.MontoGravamenSoles
				from #tab01 A
					inner join #tab03 B
						on A.CodigoLineaCredito = B.cCodLinCre
					--	) as tmp

				
				Select * from #tab03
				Select * from #tab04				
						
				/*
				Drop table #tab01
				Drop table #tab02
				Drop table #tab03
				Drop table #tab04
				*/

			