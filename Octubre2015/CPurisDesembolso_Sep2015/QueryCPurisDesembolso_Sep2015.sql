
	/*
	
	Por el presente se solicita por favor nos puedan remitir segun archivo adjunto,
	información respecto a desembolsos realizados durante el mes de agosto del 2015.
	
		Año,Mes,NombreMes,CodigoCliente,CodigoCredito,TipoCredito,SubTipoCredito
		,ProductoCrediticio,SubProductoCrediticio,FechaDesembolsoCredito,MontoDesemb
		,Moneda,PlazoInicial,PlazoMeses,CuotasAprobadas,DiasGracia,FormaPago,TipoCambio
		,FechaTipoCambio,MontoDesembolsadoSoles,TEM,TipoTasa,DetalleTipoTasa,TasaEspecial
		,FechaCancelacionCredito,Saldo,PlazoHastaLaCanc,DescripcionMotivoSalidaOperacion
		,SaldoSoles,SituacionCredito,Oficina,Zona

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
			,MontoDesemb= CRE.nMonCapDes 		 			 
			,Moneda =
			 case cre.cCodTipMon
			 when '1' then  'SOLES'
			 when '2' then  'DOLARES'
			 end 			
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
			,FechaCancelacionCredito = isnull(left(cast(CRE.dFecCulCre as date),10),'') 	
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
			/*
			INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
			*/
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
										
		WHERE CRE.cEstCreCon in ('F','H','G','I')					
			and left(cast(CRE.dFecDesCre as date),10) >= '2015-09-01'
			and left(cast(CRE.dFecDesCre as date),10) <= '2015-09-30'						
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
			WHERE left(cast(dFecTipCam as date),7) >='2015-10'
				and left(cast(dFecTipCam as date),7) <='2015-10' 
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
			Declare @ccodcred varchar(18), @nTipCambio MONEY, @dFecTipCam char(7)
			, @fecdes char(7)
			--Set @ccodcred = '107007101005311781'			
			Declare cTC11 CURSOR FOR	
				Select DISTINCT CodigoCredito from #tab01 (NOLOCK) 					

			OPEN cTC11
				FETCH cTC11 into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN								
				
				Set @fecdes = ( Select dFecTipCam from #tc)
								/*
								Select 
								RTRIM(left(cast(FechaDesembolsoCredito as date),7)) 
								from #tab01 (NOLOCK) 	
								Where CodigoCredito = @ccodcred)
								*/			

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
		--	Select * from #tab01
		
		Select		
			Anio,	Mes,	NombreMes,	CodigoCliente,	CodigoCredito, TipoCredito
			,SubTipoCredito,ProductoCrediticio,SubProductoCrediticio
			,FechaDesembolsoCredito, MontoDesemb, Moneda, PlazoInicial
			,PlazoMeses = ((cast(FormaPago as decimal(10,2))) /30),CuotasAprobadas
			,DiasGracia, FormaPago	,TipoCambio = nTipCambio, FechaTipoCambio = dFecTipCam
			,MontoDesembolsadoSoles = 
				Case Moneda when 'SOLES' then MontoDesemb
							when 'DOLARES' then MontoDesemb * nTipCambio end
			,TEM, TipoTasa, DetalleTipoTasa
			,TasaEspecial = 
				Case DetalleTipoTasa when 'DE TABLA' then 'NO ESPECIAL'
				ELSE 'ESPECIAL' END
			,FechaCancelacionCredito, Saldo= SaldoSoles, PlazoHastaLaCanc
			,DescripcionMotivoSalidaOperacion
			,SaldoSoles = 
				Case Moneda when 'SOLES' then SaldoSoles
							when 'DOLARES' then SaldoSoles * nTipCambio end
			,SituacionCredito, Oficina = cDesOficin, Zona			
		from #tab01
		Order By Anio,Mes

		/*
				
		Drop table #tab01
		Drop table #tc

		*/

		-------------CUADRE EN PIGNORATICIOS -----------------------------------------
		
		SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
		DECLARE @nTipCambio1 MONEY,	@dFecTipCam1 DATE					
		set @nTipCambio1 = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-10-01'				
				)

		Select 
			/*
			-- DISTINCT 
			GEN.cCodCliente
			,PREN.nMonSalAct
			,PREN.nMonCreKpr -- ok
			--,PREN.nMonNetKpr 			
			,PREN.cCodCtaKpr
			,PREN.cCodTipMon
			,SaldoenSoles = 
				Case PREN.cCodTipMon 
				when '1' then PREN.nMonSalAct
				when '2' then PREN.nMonSalAct * @nTipCambio1
				end 
			,dFecCreKpr = left(cast(PREN.dFecCreKpr as date),10)
			,PREN.cTipCreKpr
			*/
			/*
			PREN.cCodUsuKpr AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'				
			--Datos del credito			
			,PREN.cCodCtaKpr AS 'CodigoCredito'	
			,Expediente = E.cCodExpCli			
			,Pagare = ISNULL(RIGHT(RTRIM(LIN.CCODPAGARE),12), '')
			,C.cCodCliente 												
			,PREN.nMonCreKpr as 'MontoDesembolso' 
			,PREN.nMonSalAct AS 'SaldoCapital'
			,case PREN.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,TipoCambio = @nTipCambio1
			*/
			MontoDesembolsoenSoles = 
				Case PREN.cCodTipMon
				WHEN '1' THEN sum(PREN.nMonCreKpr)
				WHEN '2' THEN sum(@nTipCambio1 * PREN.nMonCreKpr)
				END					
			/*
			,SaldoCapitalenSoles = 
				case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonSalAct
				WHEN '2' THEN @nTipCambio1 * PREN.nMonSalAct
				END								
			
			,PREN.nTasIntKpr
			*/
			--,NumeroCuotas = CRE.nNumCuoApr				
			/*
			,DiasAtraso = 
				Case when CRE.nDiaAtrCre < 0 then 0
				else CRE.nDiaAtrCre end
			,EC.cDescriEst AS 'EstadoCredito'	
			,CondicionContable =
				 Case CRE.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END														 
			*/
			/*
			,left(cast(PREN.dFecCreKpr as date),10) as 'FechaDesembolsoCredito'
			,Anio= year(PREN.dFecCreKpr), Mes = MONTH (PREN.dFecCreKpr)
			,NombreMes =DATENAME(month, PREN.dFecCreKpr)	
			--,CRE.cEstCreCon			
			
			,GEN.cCodCliente AS 'CodigoCliente'		
			,C.cNomCliente AS 'NombreCliente'
			,NroDocumento = isnull(C.cNroDocIde, C.cNroDocTri)	
			,C.cCodSbs						
			--,DestinoCredito = ISNULL(D2.cDescriDes,'NO REGISTRA')		
			,CIUU = isnull(C.cCodCiiu,'9999')
			,Actividad = CI.cdesactivi
			,Ubicacion = ISNULL(DC.cDirCliRef,'NO INDICA')
			,DireccDomic = REPLACE(rtrim(DC.cDirCliente),'.','')				
			
			,ZonaDomic = ISNULL(Z.cNomZona,'NO INDICA')
			,DistDomic = DIS1.cNomDistri
			,ProvDomic = PRO1.cNomProvin 			
			,DepartDomic = DEP1.cNomDepart 				
															
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona		
			*/		
		FROM [KPRMCREPRENDA] PREN (NOLOCK)		
				/*
				INNER JOIN 	[GENMCRECLI] GEN 
					ON GEN.cCodCtaCre = PREN.cCodCtaKpr

				INNER JOIN HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
					ON C.cCodCliente = GEN.cCodCliente					
							
				LEFT JOIN KPYMLINCRECLI LIN  (NOLOCK)  
					 ON GEN.CCODLINCRE = LIN.CCODLINCRE  
						 AND GEN.CCODCLIENTE = LIN.CCODCLIENT  
			
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = PREN.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
				INNER JOIN [sipmpersonal] SP 
					ON SP.cCodPerson = PREN.cCodUsuKpr	
				--condicion credito 
				INNER JOIN [KPYTConCredit] D
					ON D.cCondicCon = GEN.cCondicCon			 
			
				left join HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMDirecc] DC				
					on DC.cCodCliente = C.CCODCLIENTE and DC.bDirPredet = '1'
			
				INNER join HYO00402.CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					on E.cCodClient = C.cCodCliente	AND E.cTipExpCli = 'K'
						AND E.lConEstado = '1'
				
				left join GENTCodCiiu CI
					on CI.ccodciiu = C.cCodCiiu	
			
				left JOIN [GenTDepartame] DEP1
					ON DEP1.cCodDepart = DC.cCodDepart
				left JOIN [GentProvincia] PRO1
					ON pro1.cCodProvin = DC.cCodProvin and pro1.cCodDepart = DC.cCodDepart
				left JOIN [GentDistrito] DIS1
					ON dis1.cCodDistri = DC.cCodDistri	 and dis1.cCodProvin = DC.cCodProvin 
						and dis1.cCodDepart = DC.cCodDepart					
			
				left JOIN GENTZona Z
					ON Z.cCodZona = DC.cCodZona 
						and Z.cCodDepart = DC.cCodDepart
						and Z.cCodProvin = DC.cCodProvin
						and Z.cCodDistri = DC.cCodDistri
				*/					 						
		WHERE PREN.cCodEstKpr 
				in ('D','A','R','G','H')					
				--and PREN.nMonSalAct > 0	
				--and PREN.cCodOficin = '009'		
			and left(cast(PREN.dFecCreKpr as date),10) >= '2015-09-01'
			AND left(cast(PREN.dFecCreKpr as date),10) <= '2015-09-30'			
		Group By PREN.cCodTipMon	
		
				

		/*
		cCodEstKpr
				
			select * from KPRTEstCredito

			cCodEstKpr	cDesEstKpr	cDesCorta	lConEstado
			S	VENTA PARCIAL                 	VENTA     	1
 				RESCATADO                     	          	1
			A	AMORTIZADO                    	          	1
			C	CANCELADO                     	          	1
			D	DESEMBOLSADO                  	          	1
			E	DEVUELTO                      	          	1
			G	1ER. REMATE                   	          	1
			H	2DO.REMATE                    	          	1
			I	INACTIVO-HIS                  	          	1
			J	ADJUDICADO                    	          	1
			K	REMATADO                      	          	1
			P	EMITIDO                       	          	1
			R	RENOVADO                      	          	1
			X	EXTORNADO                     	          	1
			Z	CUENTAS POR COBRAR            	CTAS X COB	1
			M	CASTIGADO                     	          	1

		*/