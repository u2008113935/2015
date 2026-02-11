/* 
Se solicita información al cierre del mes de mayo del 2015, 
por tramos de la cartera vencida en saldo y cuentas así como clientes;
Por agencia( Chosica, Huaycan, Huachipa, Ate, Santa Anita, Abancay, Cto. Grande 
,San Juan de Lurigancho, Cañete, ica, Chincha, Wanchaq, Cerro Colorado, San Sebastian
,Parcona_Ica, Manchay.
*/
----------VARIABLES-------------------
			DECLARE @nTipCambio MONEY			
						-- select * from GENTTipCambio
			 Set @nTipCambio = (SELECT nTipCamFij
								FROM GENTTipCambio
								WHERE dFecTipCam = '2015-06-01') --@dFecTipCam	
				--select @nTipCambio

			-- DATOS DE CREDITOS CONVENCIONALES
			SELECT cCodOficin, cCodTipMon, nSaldoCapi = SUM(CASE WHEN cEstCreCon IN ('F', 'H')
									THEN (nMonCapDes - nMonCapPag) * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVig = SUM(CASE WHEN cEstCreCon = 'F' AND cCodRefina = 'N'
									THEN nMonSalNor * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoVen = SUM(CASE WHEN cEstCreCon = 'F' and nMonSalVen > 0
									THEN nMonSalVen * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
										ELSE 0 END),
					nSaldoJud = SUM(CASE WHEN cEstCreCon = 'H' THEN nMonSalVen * CASE WHEN cCodTipMon = '2'
									THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					nSaldoRef = SUM(CASE WHEN cEstCreCon = 'F' AND nMonSalNor > 0 AND cCodRefina = 'S'
									THEN nMonSalNor	* CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
									ELSE 0 END),
					cCodModCre = 'KPY'
				INTO #KPYMCreConven
			FROM [KPYMCREconven] 				
			WHERE CESTCRECON IN ('F','H')
				--AND cCodOficin = CASE WHEN @cCodOficin = '000' 
				--				THEN cCodOficin ELSE @cCodOficin END					 
			GROUP BY cCodOficin, cCodTipMon

			UNION ALL

			-- BASE DE DATOS DE CREDITOS PRENDARIOS

			SELECT cCodOficin, cCodTipMon,
					nSaldoCapi = SUM(nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END),
					nSaldoVig = SUM(CASE WHEN nDiaAtrCre <= 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN  @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoVen = SUM(CASE WHEN nDiaAtrCre > 30
								  THEN nMonSalAct * CASE WHEN cCodTipMon = '2' THEN @nTipCambio ELSE 1 END
								  ELSE 0 END),
					nSaldoJud = 0,
					nSaldoRef = 0,
					cCodModCre = 'KPR'
			FROM	KPRMCrePrenda
			WHERE	cCodEstKpr IN ('A','D','G','H','R')
				--AND cCodOficin = CASE WHEN @cCodOficin = '000' 
				--					THEN cCodOficin ELSE @cCodOficin END
			GROUP BY cCodOficin, cCodTipMon

				-- select * from #KPYMCreConven order by cCodOficin

			SELECT cCodOficin, cCodTipMon, nSaldoCapi = SUM(nSaldoCapi),nSaldoVig = SUM(nSaldoVig),
					nSaldoVen = SUM(nSaldoVen), nSaldoJud = SUM(nSaldoJud), nSaldoRef = SUM(nSaldoRef)
				INTO #TMPFINAL
			FROM #KPYMCreConven
			GROUP BY cCodOficin, cCodTipMon

				-- select * from #TMPFINAL order by cCodOficin

			SELECT C.cNomZonCom, Oficina = B.cCodOficin +	' - ' + B.cDesOficin, A.cCodTipMon, D.cDesTipMon,
				A.nSaldoVig, A.nSaldoVen, A.nSaldoJud, A.nSaldoRef, A.nSaldoCapi
			FROM #TMPFINAL A
				INNER JOIN GENTOficinas B
					ON A.cCodOficin = B.cCodOficin
				INNER JOIN GENTZonCom C
					ON B.cCodZonCom = C.cCodZonCom
				INNER JOIN GENTMoneda D
					ON A.cCodTipMon = D.cCodTipMon
			--WHERE C.cCodZonCom = '05'
			ORDER BY A.cCodOficin, A.cCodTipMon

			DROP TABLE #KPYMCreConven
			DROP TABLE #TMPFINAL

		END

		SELECT * FROM GENTZonCom C

		select --top 1 
			nDiaVenCuo,* 			
		from KPYDPlanPagCre
		where cCodCtaCre = '107001011000004003'
			--and nDiaVenCuo between 1 and 7
			and nDiaVenCuo between 8 and 15
		-- nDiaVenCuo

		/*
		Mora 1-7
		Mora 8-15
		Mora 16-30
		Mora mas de 30
		*/
