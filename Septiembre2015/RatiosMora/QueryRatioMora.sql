	
	
	Declare  @x_nDiaKPR TINYINT , @x_dFecProces DATETIME
		Set @x_dFecProces = '2015-08-31'
		Set @x_nDiaKPR = 30
	
	-- Drop table #xx

	SELECT	A.cCodCtaCre, G.cCodCliente,
			A.cCodOficin as cCodOfi,
				A.cCodTipCre, A.cCodProduc, A.cCodSubPro, A.cCodTipMon,
				nMonNor = (CASE WHEN A.cestCreCon = 'F' AND A.cCodRefina = 'N'
								THEN A.nMonSalNor
								ELSE 0
								END),
				nMonRef = (CASE When A.cestCreCon = 'F' and A.cCodRefina = 'S'
								THEN A.nMonSalNor
								ELSE 0
								END),
				nMonven = (A.nMonSalVen),
				nMonPreJud = (CASE WHEN A.cEstCreCon = 'F' THEN A.nMonSalVen ELSE 0.00 END),
				nMonJud = (CASE WHEN A.cEstCreCon = 'H' THEN A.nMonSalVen ELSE 0.00 END),
				nPriRem = 0,
				nSegRem = 0
				-- dfecpro = @x_dFecProces
				INTO #xx
			FROM kpymcreconven A (nolock)
				INNER JOIN [GENMCRECLI] G 
					ON G.cCodCtaCre = A.cCodCtaCre
			WHERE A.cEstCreCon in ('F', 'H') and A.cCodOficin = '015' and A.cCodTipCre = '03'
			--GROUP BY cCodTipCre, cCodProduc, cCodSubPro, cCodTipMon, cCodOficin
			-- (2,660 row(s) affected)

		/*
		UNION
		
		SELECT	
				CRE.cCodCtaKpr, G.cCodCliente,
				cCodOfi = CRE.cCodOficin, CCODTIPCRE = '03',
				cCodProduc = '41', cCodSubPro = '00',
				CRE.cCodTipMon,
				nMonNor = (CASE WHEN CRE.cCodEstKpr IN ('D','A') AND CRE.dFecVenkpr + @x_nDiaKPR >= @x_dFecProces
								THEN CRE.nMonSalAct
								ELSE 0.0000
								END),
				nMonRef = (CASE WHEN CRE.cCodEstKpr = 'R' AND CRE.dFecVenkpr + @x_nDiaKPR >= @x_dFecProces
								THEN CRE.nMonSalAct
								ELSE 0.0000
								END),
				nMonVen = (CASE WHEN CRE.cCodEstKpr IN ('D', 'A', 'R') 
											AND CRE.dFecVenkpr + @x_nDiaKPR < @x_dFecProces
								THEN CRE.nMonSalAct
								ELSE 0.0000
								END),
				nMonPreJud = (CASE WHEN CRE.cCodEstKpr IN ('D','A','R') 
											AND CRE.dFecVenkpr + @x_nDiaKPR < @x_dFecProces
								THEN CRE.nMonSalAct
								ELSE 0.00
								END),
				nMonJud = (CASE WHEN CRE.cCodEstKpr IN ('G','H')
								THEN CRE.nMonSalAct
								ELSE 0.0000
								END),
				nPriRem = (CASE WHEN CRE.cCodEstKpr = 'G'
								THEN CRE.nMonSalAct
								ELSE 0.0000
								END),
				nSegRem = (CASE WHEN CRE.cCodEstKpr = 'H'
								THEN CRE.nMonSalAct
								ELSE 0.0000
								END)
				--dFecPro = @x_dFecProces	
			Select CRE.*			
			FROM KPRMCreprenda CRE (NOLOCK)
				INNER JOIN [GENMCRECLI] G 
					ON G.cCodCtaCre = CRE.cCodCtaKpr
			WHERE CRE.cCodCtaKpr <> '' and CRE.cCodOficin = '015'
			--GROUP BY cCodOficin, cCodTipMon
			*/
	-----------------------------------------------------------------------------------
			
			INSERT INTO dbo.KPYHRatMorNue
					(cCodOficin, cCodTipCre, cCodProduc, cCodSubPro, cCodTipMon,
					nSalCreNor, nSalCreRef, nSalCreVen, nSalCrePreJud, nSalCreJud,
					nSalPriRem, nSalSegRem, nIndiceMor, dFecProces, cCodUsuPro,
					dFecHorSis, nTipCamFij, lCodEstado)
				SELECT	cCodOfi, cCodTipCre, cCodProduc, cCodSubPro, cCodTipMon,
						nMonNor = SUM(nMonNor),
						nMonRef = SUM(nMonRef),
						nMonVen = SUM(nMonVen),
						nMonPreJud = SUM(nMonPreJud),
						nMonJud = SUM(nMonJud),
						nPriRem = SUM(nPriRem),
						nSegRem = SUM(nSegRem),
						nIndMor = SUM(CASE WHEN (nMonNor + nMonRef + nMonVen + nPriRem + nSegRem) = 0.00
										THEN 0.00
										ELSE (nMonVen + nPriRem + nSegRem)/
												(nMonNor + nMonRef + nMonVen + nPriRem + nSegRem)
										END),
						dFecPro = @x_dFecProces,
						cCodUsu = SUSER_SNAME(),
						dFecHor = GETDATE(),
						nTipCam = @x_TipCam,
						lConEstado = 1
					FROM #xx
					GROUP BY cCodOfi, cCodTipCre, cCodProduc, cCodSubPro, cCodTipMon
				UNION
				SELECT	cCodOfi, cCodTipCre, cCodProduc, cCodSubPro,
						cCodTipMon = '3',
						nMonNor = SUM(CASE WHEN cCodTipMon = '1'
										THEN nMonNor
										ELSE nMonNor * @x_TipCam
										END),
						nMonRef = SUM(CASE WHEN cCodTipMon = '1'
										THEN nMonRef
										ELSE nMonRef * @x_TipCam
										END),
						nMonVen = SUM(CASE WHEN cCodTipMon = '1'
										THEN nMonVen
										ELSE nMonVen * @x_TipCam
										END),
						nMonPreJud = SUM(CASE WHEN cCodTipMon = '1'
										THEN nMonPreJud
										ELSE nMonPreJud * @x_TipCam
										END),
						nMonJud = SUM(CASE WHEN cCodTipMon = '1'
										THEN nMonJud
										ELSE nMonJud * @x_TipCam
										END),
						nPriRem = SUM(CASE WHEN cCodTipMon = '1'
										THEN nPriRem
										ELSE nPriRem * @x_TipCam
										END),
						nSegRem = SUM(CASE WHEN cCodTipMon = '1'
										THEN nSegRem
										ELSE nSegRem * @x_TipCam
										END),
						nIndMor = SUM(CASE WHEN (nMonNor + nMonRef + nMonVen + nPriRem + nSegRem) = 0.00
										THEN 0.00
										ELSE CASE WHEN cCodTipMon = '1'
												THEN (nMonVen + nPriRem + nSegRem) /
														(nMonNor + nMonRef + nMonVen + nPriRem + nSegRem)
												ELSE (nMonVen + nPriRem + nSegRem) /
														(nMonNor + nMonRef + nMonVen + nPriRem + nSegRem) * @x_TipCam
												END
										END),
						dFecPro = @x_dFecProces,
						cCodUsu = SUSER_SNAME(),
						dFecHor = GETDATE(),
						nTipCam = @x_TipCam,
						lConEstado = 1
					FROM #xx
					GROUP BY cCodOfi, cCodTipCre, cCodProduc, cCodSubPro
					ORDER BY cCodOfi, cCodTipMon, cCodTipCre, cCodProduc, cCodSubPro			
			
			DROP TABLE #xx
			
		---------------------------------------------------------------------------------

			SELECT	cCodOfi = cCodOficin, cTipCre = ccodTipCre,
					cCodPro = cCodProduc, cSubPro = cCodSubPro,
					cMoneda = cCodTipMon, nMorNor = nSalCreNor,
					nMorRef = nSalCreRef, nMorVen = nSalCreVen,
					nMorPreJud = nSalCrePreJud, nMorJud = nSalCreJud,
					nPriRem = nSalPriRem, nSegRem = nSalSegRem,
					nIndMor = nIndiceMor, dFecPro = dFecProces,
					nTipCam = nTipCamFij
				FROM dbo.KPYHRatMorNue
				WHERE dFecProces = @x_dFecProces
					AND lCodEstado = 1
		--------------------------------------------------------------------------------

		Select * from #xx
		-- (1,141 row(s) affected)
		
		
			CREATE NONCLUSTERED INDEX #xx_cCodCtaCre_IXN ON #xx(cCodCtaCre)
			CREATE NONCLUSTERED INDEX #xx_cCodCliente_IXN ON #xx(cCodCliente)
			

				Select 							
					 AA.*
					,C.cNomCliente AS 'NombreCliente'						
					,NroDoc = isnull(C.cNroDocIde,C.cNroDocTri)				
					/*
					,NumEntRCC = ISNULL(B.NCANENT,'0'), CalificacionRCC = isnull(B.CCLAFIN,'0')
					,Porcen0 = isnull(B.NPORCAL0,'0.00') ,Porcen1 = isnull(B.NPORCAL1,'0.00')
					,Porcen2 = isnull(B.NPORCAL2,'0.00') ,Porcen3 = isnull(B.NPORCAL3,'0.00')
					,Porcen4 = isnull(B.NPORCAL4,'0.00')																
					*/
					,Moneda = 
						Case CRE.cCodTipMon
						when '1' then 'SOLES'
						when '2' then 'DOLARES'
						end									
					,STC.cDesTipCre AS 'TipoCredito'
					,STC.cDesSubTip AS 'SubTipoCredito'			 
					,STC.cDesProCre AS 'ProductoCrediticio' 			 
					,STC.cDesSubcRE AS 'SubProductoCrediticio' 																						
					,EC.cDescriEst AS 'EstadoCredito'								
					,CRE.cEstCreCon											
					,EstadoContable =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END						
					,CodOficina = CRE.cCodOficin
					,Oficina = O.cDesOficin										 				
								
			From #xx AA (NOLOCK)
					inner join [KPYMCRECONVEN] CRE (NOLOCK)		
						on CRE.cCodCtaCre = AA.cCodCtaCre
					INNER JOIN [GENMCRECLI] G 
						ON G.cCodCtaCre = CRE.cCodCtaCre
					INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
						ON C.cCodCliente = G.cCodCliente
					INNER JOIN [KPYTSUBTIPCRE] STC
						ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
						AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
					INNER JOIN KPYTEstCreCon EC 
						ON EC.cEstCreCon = CRE.cEstCreCon
					INNER JOIN [GENTOficinas] O 
						ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'	
					--condicion credito 
					INNER JOIN [KPYTConCredit] D
						ON D.cCondicCon = G.cCondicCon		
					
					--left join HYO00402.CRICMACHYO_DIARIO.dbo.urirccmae B			
						--on B.cCodSbs = C.CCODSBS
					
			WHERE CRE.cEstCreCon in ('F','H')	
					--and CRE.cCodTipCre in ('02','09','11','12','13')	
			Order By C.cCodCliente				


		------------------------------------------------------------
		Select cCodTipMon
		from #xx
		Group By cCodTipMon

		Select cCodTipCre,cCodProduc,cCodSubPro,
			nMonNor = sum(nMonNor), nMonRef = sum(nMonRef), nMonven = sum(nMonven), nMonPreJud = sum(nMonPreJud)
			, nMonJud = sum(nMonJud), nPriRem = sum(nPriRem), nSegRem = sum(nSegRem)
		From #xx
		Group By cCodTipCre,cCodProduc,cCodSubPro



		--------------------------------------------------------------------------------
		Select  *
		-- dFecHorSis,left(cast(dFecProces as date),10), 
		From KPYHRatNueCon
		Where cCodOficin = '015' and ccodTipCre = '03' and left(cast(dFecProces as date),10) = '2015-08-31'
			and cCodTipMon = '3' and cCodUsuPro = 'WSANTI' and dFecHorSis >= '2015-08-31 21:28:07.847'
		Order By dFecHorSis