	/*
	cartera de créditos al cierre de junio (código del crédito, producto, importe, tasa, 
	garantías, plazo, situación, clasificación interna, clasificación SBS)
	*/

	DECLARE @nTipCambio MONEY
			
		Set @nTipCambio = (
			SELECT --dFecTipCam=left(cast(dFecTipCam as date),10),
				 nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-07-01'
			)
				-- dFecTipCam	nTipCamFij
				-- 2015-07-01	3.177
		--Select @nTipCambio

		-- Drop table #tmp01
	--Select * into #tmp01 from (
		Select 
			CodigoCliente = CLI.cCodCliente 	
			,CodigoSBS=isnull(CLIM.cCodSbs,'')
			,CalificacionSBS=
				CASE R.CCLAFIN
				WHEN 0 THEN 'NORMAL'
				WHEN 1 THEN 'CPP'
				WHEN 2 THEN 'DEFICIENTE'
				WHEN 3 THEN 'DUDOSO'
				WHEN 4 THEN 'PERDIDA'
				ELSE 'NO REGISTRA'
				END
			,CalificacionInterna=ISNULL(I.CDESQUECARF,'NO REGISTRA')			
			,CodigoCredito = CRE.cCodCtaCre			
			,CRE.cCodTipCre
			,TipoCredito=STC.cDesTipCre
			,SubTipoCredito=STC.cDesSubTip 
			,CRE.cCodProduc
			,ProductoCrediticio=STC.cDesProCre 
			,CRE.cCodSubPro	
			,SubProductoCrediticio=STC.cDesSubcRE 	
			,CRE.nMonCapDes
			,Moneda= case cre.cCodTipMon
					 when '1' then  'SOLES'
					 when '2' then  'DOLARES'
					 end 
			,Saldo=(CRE.nMonCapDes - CRE.nMonCapPag)
			,TEM=CRE.nTasintCom
			,dFecDesCre=left(cast(CRE.dFecDesCre as date),10)
			,Plazo = isnull(CRE.nNumDiaApr,0)
			,TipoCambio=@nTipCambio			
			,MontoDesembSoles=
			 case cre.cCodTipMon
			 when '1' then  CRE.nMonCapDes --'SOLES'
			 when '2' then  CRE.nMonCapDes * @nTipCambio --'DOLARES'
			 end 	
			--,dFecCulCre=left(cast(CRE.dFecCulCre as date),10)
			--,PlazoHastaLaCanc=
			--DATEDIFF(day,left(cast(CRE.dFecDesCre as date),10),left(cast(CRE.dFecCulCre as date),10))		
			,SaldoSoles=
			 case cre.cCodTipMon
			 when '1' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'SOLES'
			 when '2' then (CRE.nMonCapDes - CRE.nMonCapPag) * @nTipCambio --'DOLARES'
			 end 		
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'			
			,Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END cDesConCre
			 --GARANTIAS
			--,LC.cCodTipGar, G.cdestipgar
			,O.cCodOficin, O.cDesOficin			
		From [KPYMCRECONVEN] CRE (NOLOCK)			
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre						
			left JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente				
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'		
			left JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
			
			left JOIN [HYO00402].CRICMACHYO_DIARIO.DBO.urirccmae R
				ON R.CCODSBS = CLIM.cCodSbs		
			left JOIN [HYO00410].SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera] I
				ON I.CCODCLIENTE = CLI.cCodCliente AND I.CCODFECMES = '201506'				
			
			/*
			--GARANTIAS
			LEFT JOIN KPYDGARLINCRE GAR (NOLOCK) 
				ON GAR.CCODLINCRE = CLI.CCODLINCRE	
			LEFT JOIN KPYDGarLinCre LC	
				ON LC.cCodLinCre = GAR.CCODLINCRE 	
			LEFT JOIN GENDGarantia G
				ON G.ccodgarant = LC.cCodTipGar	
			*/				
		Where CRE.cEstCreCon in ('F','H')	
			--and CLI.cCodCliente in ()
		Order by CLI.cCodCliente
		
		--) as tmp		
		-- (222,073 row(s) affected)

		/*
		SELECT * FROM #tmp01 
		WHERE --CalificacionSBS = 'NO REGISTRA'
			CalificacionInterna = 'NO REGISTRA'
		ORDER BY CodigoCliente
		*/

		--SELECT sum(SaldoSoles) FROM #tmp01

		/* -- CALIFICACION INTERNA
		SELECT TOP 10 * FROM [HYO00410].SOFCMACHYO_RIESGOS.dbo.[URIHHisCartera]	
			WHERE CCODFECMES = '201506'
		*/

		/*
		----------------PRENDARIOS------------------------------------------------------------
			DECLARE @nTipCambio MONEY
			
			Set @nTipCambio = (
			SELECT --dFecTipCam=left(cast(dFecTipCam as date),10),
				 nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-07-01'
			)
		
		-- DATOS DE CREDITOS CONVENCIONALES

			SELECT cCodOficin, A.cCodCtaCre, B.cCodCliente, cCodTipMon, 
					nSaldoCapi = (CASE WHEN cEstCreCon IN ('F', 'H')
									THEN (nMonCapDes - nMonCapPag) * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVig = (CASE WHEN cEstCreCon = 'F' AND cCodRefina = 'N'
									THEN nMonSalNor * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVen = (CASE WHEN cEstCreCon = 'F' and nMonSalVen > 0
									THEN nMonSalVen * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
										ELSE 0 END),
					nSaldoJud = (CASE WHEN cEstCreCon = 'H' THEN nMonSalVen * CASE WHEN cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoRef = (CASE WHEN cEstCreCon = 'F' AND nMonSalNor > 0 AND cCodRefina = 'S'
									THEN nMonSalNor	* CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					cCodModCre = 'KPY'
			INTO #KPYMCreConven -- drop table #KPYMCreConven
			FROM KPYMCREconven A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaCre = B.cCodCtaCre
			WHERE CESTCRECON IN ('F','H')
				--AND cCodOficin = CASE WHEN @cCodOficin = '000' 
				--					THEN cCodOficin ELSE @cCodOficin END

					select sum(nSaldoCapi) 
					from #KPYMCreConven 
					where cCodTipMon=1 
					group by cCodTipMon

					select sum(nSaldoCapi) 
					from #KPYMCreConven 
					where cCodTipMon=2
					group by cCodTipMon

			UNION ALL

			-- BASE DE DATOS DE CREDITOS PRENDARIOS
			SELECT cCodOficin, A.cCodCtaKpr, B.cCodCliente, cCodTipMon,
					nSaldoCapi = (nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END),
					nSaldoVig = (CASE WHEN nDiaAtrCre <= 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoVen = (CASE WHEN nDiaAtrCre > 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoJud = 0,
					nSaldoRef = 0,
					cCodModCre = 'KPR'
			FROM	KPRMCrePrenda A
				INNER JOIN GENMCreCli B
					ON A.cCodCtaKpr = B.cCodCtaCre
			WHERE	cCodEstKpr IN ('A','D','G','H','R')
				--AND cCodOficin = CASE WHEN @cCodOficin = '000' 
				--					THEN cCodOficin ELSE @cCodOficin END		
		*/
									
		