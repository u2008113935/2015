
	/*
	
	Nº
	Asesor al 31-12-2014
	,Analista Solicitud (origen)
	,Cuenta, Expediente, Pagaré
	,Tipo de Crédito
	,Sub Producto	
	,Fecha Desemb
	,Monto Desembolsado
	,Cuotas
	,Saldo de Capital al 31-12-2014
	,Saldo de Capital en Soles al 31-12-2014
	,Estado, Condición Contable, Días de Atraso
	,CodCliente, Nombre, DNI/RUC,Actividad, Destino
	,Ubicación Domicilio (Referencia),Zona, Domicilio, Domicilio
		-- ,Ubicación Negocio, Zona Negocio, Dir Negocio	
	,Clasificación  al 31-12-2014

	*/


	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-01-01'				
				)

	/*
	 Drop table #tab01
	 Drop table #tab02
	 Drop table #tab03
	*/
	Select * into #tab01 from (
		Select 		
		/*
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 
		*/		
			CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'				
			--Datos del credito			
			,CRE.cCodCtaCre AS 'CodigoCredito'	
			,Expediente = E.cCodExpCli			
			,Pagare = ISNULL(RIGHT(RTRIM(LIN.CCODPAGARE),12), '')
			,C.cCodCliente 		
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
			,NumeroCuotas = CRE.nNumCuoApr				
			,DiasAtraso = 
				Case when CRE.nDiaAtrCre < 0 then 0
				else CRE.nDiaAtrCre end
			,EC.cDescriEst AS 'EstadoCredito'	
			,CondicionContable =
				 Case CRE.cEstCreCon
				 when 'G' then 'CANCELADO' 
				 ELSE D.cDesConCre
				 END														 
			
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
			--,CRE.cEstCreCon			
			
			,GEN.cCodCliente AS 'CodigoCliente'		
			,C.cNomCliente AS 'NombreCliente'
			,NroDocumento = isnull(C.cNroDocIde, C.cNroDocTri)	
			,C.cCodSbs						
			,DestinoCredito = ISNULL(D2.cDescriDes,'NO REGISTRA')		
			,CIUU = isnull(C.cCodCiiu,'9999')
			,Actividad = CI.cdesactivi
			,Ubicacion = ISNULL(DC.cDirCliRef,'NO INDICA')
			,DireccDomic = REPLACE(rtrim(DC.cDirCliente),'.','')				
			
			,ZonaDomic = ISNULL(Z.cNomZona,'NO INDICA')
			,DistDomic = DIS1.cNomDistri
			,ProvDomic = PRO1.cNomProvin 			
			,DepartDomic = DEP1.cNomDepart 				
			/*
			,CaliRCC = 
				Case when RCC.CCLAFIN = '0' then 'NORMAL' ELSE 'NO REGISTRA' END	
			*/										
			
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona	
			,B.cCodUsuAna AS 'CodAsesorOrigen'
			,SP1.cNomPerson AS 'NombreAsesorOrigen'	
			
		FROM [KPYMCRECONVEN] CRE (NOLOCK)			
			INNER JOIN [GENMCRECLI] GEN 
				ON GEN.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN CMACHYOCLI_201507.dbo.[CLIMCLIENTES] C 
				ON C.cCodCliente = GEN.cCodCliente			
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
							
			LEFT JOIN KPYMLINCRECLI LIN  (NOLOCK)  
                 ON GEN.CCODLINCRE = LIN.CCODLINCRE  
				     AND GEN.CCODCLIENTE = LIN.CCODCLIENT  
			
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
			INNER JOIN [Gentofizonas] GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN [GentZonas] ZON
				ON ZON.nCodZona = GOZ.nCodZona	
			INNER JOIN [sipmpersonal] SP 
				ON SP.cCodPerson = CRE.cCodUsuAna	
			--condicion credito 
			INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = GEN.cCondicCon			 
			
			left join CMACHYOCLI_201507.dbo.[CLIMDirecc] DC				
				on DC.cCodCliente = C.CCODCLIENTE and DC.bDirPredet = '1'
			
			INNER join CMACHYOCLI_201507.DBO.CLIDExpediente E
				on E.cCodClient = C.cCodCliente	AND E.cTipExpCli = 'K'
					AND E.lConEstado = '1'

			LEFT join KPYTDesCreCon D2
				on D2.cCodDesCre = CRE.cCodDesCre
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
			
			inner join KPYMSolicitud B
				on B.cCodSolCre = CRE.cCodSolCre
			Inner JOIN [sipmpersonal] SP1 
				ON SP1.cCodPerson = B.cCodUsuAna
		WHERE CRE.cEstCreCon in ('F','H')					
			and CRE.cCodOficin = '009'	
			) as tmp
		
		--(6,148 row(s) affected)

		-- Select * from #tab01

		CREATE NONCLUSTERED INDEX #tab01_CodigoCredito_IXN ON #tab01(CodigoCredito)	
		CREATE NONCLUSTERED INDEX #tab01_Expediente_IXN ON #tab01(Expediente)	
		CREATE NONCLUSTERED INDEX #tab01_Pagare_IXN ON #tab01(Pagare)	
		CREATE NONCLUSTERED INDEX #tab01_cCodCliente_IXN ON #tab01(cCodCliente)
		CREATE NONCLUSTERED INDEX #tab01_cCodSbs_IXN ON #tab01(cCodSbs)						
		

		/*

		Select top 10 * from HYO00402.CRICMACHYO_DIARIO.DBO.urirccmae_7 RCC
		--where CMESPRO = '20141231' 
		Order by CMESPRO asc

		SELECT * FROM CMACHYOCLI_201507.DBO.CLIDExpediente E
		WHERE E.cCodClient = '107090021437'
		
			SELECT * FROM SOFCMACHYO_201508..GENTTipExpCli

			cTipExpCli	cDescriExp			cDesCorta	lConEstado
			A			EXPEDIENTE AHORROS	EXP AHORRO	1
			K			EXPEDIENTE CREDITO	EXP CREDIT	1

		Select * 
		From [KPYTSUBTIPCRE] 
		Where lEstado = '1' and cCodTipCre = '03'
			and cDesSubCre like '%credi%'

		*/
						
		-- Select * from #tab01
		
	--09 FUENTES DE ingreso
		-- drop table #ficod
		Select * into #ficod from (
			Select distinct A.cCodCliente 			
			from CMACHYOCLI_201507.DBO.CLIDFUEINGRESO A(NOLOCK)	
				inner join #tab01 B
					on A.cCodCliente = B.CodigoCliente			
			) as tmp

		-- Select * from #ficod

		CREATE NONCLUSTERED INDEX #ficod_cCodCliente_IXN ON #ficod(cCodCliente)	

		-- Select * from #ficod order by cCodCliente
		-- drop table #tabfi
		Select * into #tabfi from (
			Select distinct A.cCodCliente
				,cCodFueIng = isnull(A.cCodFueIng,'0')
				,cCodTipFin = isnull(A.cCodTipFin,'0')
				,cDirEmp = isnull(A.cDirEmp,'NO INDICA')
				,cCodZona = isnull(A.cCodZona,'0')
				,cCodDistri = isnull(A.cCodDistri,'0')
				,cCodProvin = isnull(A.cCodProvin,'0')
				,cCodDepart = isnull(A.cCodDepart,'0')				
				,dFecModReg = isnull(left(cast(A.dFecModReg as date),10),'')  
			from CMACHYOCLI_201507.DBO.CLIDFUEINGRESO A(NOLOCK)
				inner join #tab01 B
					on A.cCodCliente = B.CodigoCliente
			--Order By A.cCodCliente
			) as tmp

		CREATE NONCLUSTERED INDEX #tabfi_cCodCliente_IXN ON #tabfi(cCodCliente)	

		-- Select * from #tabfi order by cCodCliente

		/*
		Select distinct A.cCodCliente
				,cCodFueIng = isnull(A.cCodFueIng,'0')
				,cCodTipFin = isnull(A.cCodTipFin,'0')
				,cDirEmp = isnull(A.cDirEmp,'NO INDICA')
				,cCodZona = isnull(A.cCodZona,'0')
				,cCodDistri = isnull(A.cCodDistri,'0')
				,cCodProvin = isnull(A.cCodProvin,'0')
				,cCodDepart = isnull(A.cCodDepart,'0')				
				,dFecModReg = isnull(left(cast(A.dFecModReg as date),10),'')  
			from CMACHYOCLI_201507.DBO.CLIDFUEINGRESO A(NOLOCK)
			WHERE A.cCodCliente = '107070011529'
		*/

		/*
		 Drop table #ficod
		 Drop table #tabfi
		 Drop table #fi
		*/

		Select * into #fi from (
			Select top 1 cCodCliente,cCodFueIng,cCodTipFin
					,cDirEmp,cCodZona,cCodDistri,cCodProvin,cCodDepart					
					,dFecModReg = left(cast(A.dFecModReg as date),10)   
			From CMACHYOCLI_201507.DBO.CLIDFUEINGRESO A	
			) as tmp

		Delete from #fi
		-- Drop table #fi			

		/*
		Select * from #fi

		Select * from #ficod
		Select * from #fi Where cCodCliente = '107022049394'

		Select *
		from CMACHYOCLI_201507.DBO.CLIDFUEINGRESO DFI
		Where cCodCliente = '107022049394'

		Select * from #fi
		
		Drop table #fi
		Delete from #fi

		*/	

	-----------------------------------------------------------------------
		Declare @codclient char(12)			  		
			
		Declare cFI CURSOR FOR	

			Select * from #ficod (NOLOCK) 								

			OPEN cFI
			FETCH cFI into @codclient
			WHILE (@@FETCH_STATUS=0)
			BEGIN	

			Insert Into #fi								
				Select top 1
				cCodCliente,cCodFueIng,cCodTipFin
				,cDirEmp,cCodZona,cCodDistri,cCodProvin,cCodDepart				
				,dFecModReg																			
				from #tabfi
				where cCodCliente = @codclient		
					and cCodFueIng = (Select max(cCodFueIng) 
										From #tabfi
										Where cCodCliente = @codclient)	
					and dFecModReg = (Select max(dFecModReg) 
										From #tabfi
										Where cCodCliente = @codclient)															
				
			FETCH cFI INTO @codclient
			END
			CLOSE cFI
			DEALLOCATE cFI	
	--------------------------------------------------------------------------------------
	
		CREATE NONCLUSTERED INDEX #fi_cCodCliente_IXN ON #fi(cCodCliente)	

	-------------------------------------------------------------------------------------
		/*
		Select A.* 
		from #tab01 A 

		Select * from #fi
		*/

	Select * into #tab02 from (
		Select A.* 
			,DireccNegocio = ISNULL(B.cDirEmp,'NO INDICA')
			,ZonaNegocio = ISNULL(Z.cNomZona,'NO INDICA')
			,DistNegocio = ISNULL(DIS1.cNomDistri,'NO INDICA')
			,ProvNegocio = ISNULL(PRO1.cNomProvin,'NO INDICA') 			
			,DepartNegocio = ISNULL(DEP1.cNomDepart,'NO INDICA') 	 
		from #tab01 A
			left join #fi B
				on A.cCodCliente = B.cCodCliente

			left JOIN [GenTDepartame] DEP1
				ON DEP1.cCodDepart = B.cCodDepart
			left JOIN [GentProvincia] PRO1
				ON pro1.cCodProvin = B.cCodProvin and pro1.cCodDepart = B.cCodDepart
			left JOIN [GentDistrito] DIS1
				ON dis1.cCodDistri = B.cCodDistri	 and dis1.cCodProvin = B.cCodProvin 
					and dis1.cCodDepart = B.cCodDepart					
			
			left JOIN GENTZona Z
				ON Z.cCodZona = B.cCodZona 
					and Z.cCodDepart = B.cCodDepart
					and Z.cCodProvin = B.cCodProvin
					and Z.cCodDistri = B.cCodDistri
		) as tmp
		
		-- Select * from #tab02

		CREATE NONCLUSTERED INDEX #tab02_CodigoCredito_IXN ON #tab02(CodigoCredito)	
		CREATE NONCLUSTERED INDEX #tab02_Expediente_IXN ON #tab02(Expediente)	
		CREATE NONCLUSTERED INDEX #tab02_Pagare_IXN ON #tab02(Pagare)	
		CREATE NONCLUSTERED INDEX #tab02_cCodCliente_IXN ON #tab02(cCodCliente)
		CREATE NONCLUSTERED INDEX #tab02_cCodSbs_IXN ON #tab02(cCodSbs)	


	-- drop table #tab03
	Select * into #tab03 from (
		Select A.* , Calificacion = 
						Case RCC.CCLAFIN 
						when '0' then 'NORMAL'
						when '1' then 'CPP'
						when '2' then 'DEFICIENTE'
						when '3' then 'DUDUSO'
						when '4' then 'PERDIDA'
						ELSE 'NORMAL' END
		from #tab02 A
			left join HYO00402.CRICMACHYO_DIARIO.DBO.urirccmae_7 RCC
				on RCC.cCodSBS = A.cCodSbs
				) as tmp

		Select * from #tab03
		Order By CodAsesorActual

		/*
		select *
		from HYO00402.CRICMACHYO_DIARIO.DBO.urirccmae_7 RCC
		where RCC.cCodSBS = '0043831143'

		*/

	---------------------------------------------------------------------------

		/*
		SELECT ---count(DISTINCT CLI1.cCodCliente)
			DISTINCT CLI1.cCodCliente
		FROM [KPRMCREPRENDA] PREN (NOLOCK)		
				INNER JOIN 	[GENMCRECLI] CLI1 
					ON CLI1.cCodCtaCre = PREN.cCodCtaKpr
		WHERE PREN.cCodEstKpr in ('D','A','R','G','H')		
				and PREN.nMonSalAct > 0	
						
	
		Select PREN.cCodTipMon  
		FROM [KPRMCREPRENDA] PREN (NOLOCK)		
		Group By PREN.cCodTipMon 
		*/

	--------------------CREDITOS PIGNORATICIOS-------------------------------------------

		SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
		DECLARE @nTipCambio1 MONEY,	@dFecTipCam1 DATE					
		set @nTipCambio1 = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-01-01'				
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
			,MontoDesembolsoenSoles = 
				case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonCreKpr
				WHEN '2' THEN @nTipCambio1 * PREN.nMonCreKpr
				END					
			,SaldoCapitalenSoles = 
				case PREN.cCodTipMon
				WHEN '1' THEN PREN.nMonSalAct
				WHEN '2' THEN @nTipCambio1 * PREN.nMonSalAct
				END								
			,PREN.nTasIntKpr
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
			/*
			,CaliRCC = 
				Case when RCC.CCLAFIN = '0' then 'NORMAL' ELSE 'NO REGISTRA' END	
			*/													
			,Oficina = O.cDesOficin										
			,Zona = ZON.cDesZona		

		FROM [KPRMCREPRENDA] PREN (NOLOCK)		
				INNER JOIN 	[GENMCRECLI] GEN 
					ON GEN.cCodCtaCre = PREN.cCodCtaKpr

				INNER JOIN CMACHYOCLI_201507.dbo.[CLIMCLIENTES] C 
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
			
				left join CMACHYOCLI_201507.dbo.[CLIMDirecc] DC				
					on DC.cCodCliente = C.CCODCLIENTE and DC.bDirPredet = '1'
			
				INNER join CMACHYOCLI_201507.DBO.CLIDExpediente E
					on E.cCodClient = C.cCodCliente	AND E.cTipExpCli = 'K'
						AND E.lConEstado = '1'

				/*
				LEFT join KPYTDesCreCon D2
					on D2.cCodDesCre = CRE.cCodDesCre
				*/
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

		WHERE PREN.cCodEstKpr in ('D','A','R','G','H')		
				--and PREN.nMonSalAct > 0	
				and PREN.cCodOficin = '009'		
		
		
		sELECT * FROM [sipmpersonal]
		WHERE cCodPerson = 'EPORTA'
		-- nMonSalAct	Monto de saldo actual
		-- nMonCreKpr	Monto de crédito
		-- nMonNetKpr	Monto neto		

		