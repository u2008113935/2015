/*
CARTERA POR ACTIVIDAD ECONOMICA

		Data de créditos con el sub producto agropecuario, y de ahí  
		considera el cultivo o actividad a setiembre 2015 con los siguientes campos.

		Zona
		agencia
		Cliente
		Tipo de crédito
		Sub producto
		Modalidad
		Grupo de crédito
		Estado del crédito
		Plazo en días
		N Cuotas
		Cultivo o actividad
		Provincia 
		Distrito
		Zona
		Garantía
*/

DECLARE		@lnTipCambio NUMERIC(14,4)	

SET @lnTipCambio = 3.3740 -- 3.285
/*
SELECT @lnTipCambio = nTipCamFij
FROM GENTTipCambio
--WHERE LEFT(CAST(dFecTipCam AS DATE),7)  = LEFT(CAST(GETDATE() AS DATE),7)			
WHERE LEFT(CAST(dFecTipCam AS DATE),7)  = '201511'			
GROUP BY nTipCamFij 					
*/
	
SELECT A.cCodCtaCre, B.cCodCliente, A.cEstCreCon, A.cCodRefina,
	   nSaldoCapi = (CASE 
						WHEN A.cEstCreCon IN ('F', 'H') THEN (A.nMonCapDes - A.nMonCapPag) * 
															CASE 
																WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
																ELSE 1 
															END
						ELSE 0 
					 END),
		nSaldoVig = (CASE 
						WHEN A.cEstCreCon = 'F' AND A.cCodRefina = 'N' THEN A.nMonSalNor * 
																		CASE 
																			WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
																			ELSE 1 
																			END
						ELSE 0 
					END),
		nSaldoVen = (CASE 
						WHEN A.cEstCreCon = 'F' and A.nMonSalVen > 0 THEN A.nMonSalVen * 
																		CASE 
																			WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
																			ElSE 1
																		END
						ELSE 0 END),
		nSaldoJud = (CASE 
						WHEN A.cEstCreCon = 'H' THEN A.nMonSalVen * 
													CASE 
														WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
														ELSE 1
													END
						ELSE 0 
					END),
		nSaldoRef = (CASE 
						WHEN A.cEstCreCon = 'F' AND A.nMonSalNor > 0 AND A.cCodRefina = 'S' THEN A.nMonSalNor	* 
																					CASE 
																						WHEN A.cCodTipMon = '2' 
																								THEN @lnTipCambio 
																						ELSE 1
																					END
						ELSE 0 
					END),
		cCodModCre = 'KPY', A.cCodTipCre, A.cCodProduc, A.cCodSubPro
	INTO #KPYMCreConven
FROM	KPYMCREconven A
			INNER JOIN GENMCreCli B
				ON A.cCodCtaCre = B.cCodCtaCre		
WHERE A.CESTCRECON IN ('F','H')		
UNION ALL							
SELECT cCodCtaCre = A.cCodCtaKpr, B.cCodCliente, A.cCodEstKpr, cCodRefina ='',
	   nSaldoCapi = (nMonSalAct * CASE 
										WHEN cCodTipMon = '2' THEN  @lnTipCambio 
										ELSE 1 
								  END),
	   nSaldoVig = (CASE 
						WHEN nDiaAtrCre <= 30 THEN nMonSalAct * 
													CASE 
														WHEN cCodTipMon = '2' THEN  @lnTipCambio 
														ELSE 1 
													END
						  ELSE 0
					END),
		nSaldoVen = (CASE 
						WHEN nDiaAtrCre > 30 THEN nMonSalAct * 
													CASE 
														WHEN cCodTipMon = '2' THEN @lnTipCambio 
														ELSE 1 
													END
						  ELSE 0 
					 END),
		nSaldoJud = 0, nSaldoRef = 0, cCodModCre = 'KPR', cCodTipCre='03', 
		cCodProduc='13', cCodSubPro='16'						
FROM KPRMCrePrenda A WITH(NOLOCK)
		INNER JOIN GENMCreCli B WITH(NOLOCK)
			ON A.cCodCtaKpr = B.cCodCtaCre
WHERE A.cCodEstKpr IN ('A','D','G','H','R')		
	
--	SELECT * FROM #KPYMCreConven

SELECT lnSaldoCapital = sum(nSaldoCapi)
FROM #KPYMCreConven
WHERE	nSaldoCapi > 0

SELECT	lnSaldovigente		= SUM(nSaldoVig),	
		lnTclientes			= COUNT(DISTINCT (cCodCliente)),
		lnTcreditos			= COUNT(cCodCtaCre)
FROM	#KPYMCreConven (NOLOCK)							
WHERE	nSaldoCapi > 0	

SELECT	lnSaldorefinanciado = SUM(nSaldoRef),
		lnSaldovencido		= SUM(nSaldoVen+nSaldoJud)
FROM	#KPYMCreConven										

-- DROP TABLE #KPYMCreConven

--					NOV					OCT
-- Clientes		:	212,325				207,615
-- Cuentas		:   239,810				234,432
-- Desembolsos  :	203,627,199			190,278,805
-- Saldo			:	1,905,733,314		1,839,803,828

