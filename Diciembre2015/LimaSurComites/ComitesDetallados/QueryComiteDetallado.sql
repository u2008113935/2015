
----------------------------------------------------------------------------------------
DECLARE		@lnTipCambio NUMERIC(14,4)								
					
SET @lnTipCambio = 3.2850
-- 3.374  NOV 
-- 3.2850 OCT
-- 3.222  SET

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
						ELSE 0 
					END),
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
		cCodModCre = 'KPY', A.cCodTipCre, A.cCodProduc, A.cCodSubPro, A.nTasintCom, A.cCodUsuAna, 
		A.cIndNueRep,		CreditosNuevos		  = CASE A.cIndNueRep										WHEN 'N' THEN 1									ELSE 0							    END,		CreditosReprestamo	  = CASE A.cIndNueRep									WHEN 'R' THEN 1									ELSE 0							    END,		
		CreditosPreferencial  = CASE A.cIndNueRep									WHEN 'P' THEN 1									ELSE 0								END,	
		A.cCodOficin, A.nDiaAtrCre, A.cCodSolCre		
	INTO #ListSaldosProducto 
FROM KPYMCREconven A
			INNER JOIN GENMCreCli B
				ON A.cCodCtaCre = B.cCodCtaCre		
WHERE A.CESTCRECON IN ('F','H')		
	-- AND cCodUsuAna = 'ACOAQU'

/*
UNION ALL							
SELECT cCodCtaCre = A.cCodCtaKpr, B.cCodCliente, cEstCreCon = A.cCodEstKpr, cCodRefina ='',
	   nSaldoCapi = (A.nMonSalAct * CASE 
										WHEN A.cCodTipMon = '2' THEN  @lnTipCambio 
										ELSE 1 
								  END),
	   nSaldoVig = (CASE 
						WHEN A.nDiaAtrCre <= 30 THEN A.nMonSalAct * 
													CASE 
														WHEN A.cCodTipMon = '2' THEN  @lnTipCambio 
														ELSE 1 
													END
						  ELSE 0
					END),
		nSaldoVen = (CASE 
						WHEN A.nDiaAtrCre > 30 THEN A.nMonSalAct * 
													CASE 
														WHEN A.cCodTipMon = '2' THEN @lnTipCambio 
														ELSE 1 
													END
						  ELSE 0 
					 END),
		nSaldoJud = 0, nSaldoRef = 0, cCodModCre = 'KPR', cCodTipCre='03', 
		cCodProduc='13', cCodSubPro='16', A.nTasIntCom, A.cCodUsuKpr, A.cCodOficin, A.nDiaAtrCre										
FROM KPRMCrePrenda A WITH(NOLOCK)
		INNER JOIN GENMCreCli B WITH(NOLOCK)
			ON A.cCodCtaKpr = B.cCodCtaCre
WHERE A.cCodEstKpr IN ('A','D','G','H','R')
*/
		
CREATE NONCLUSTERED INDEX #ListSaldosProducto_cCodCtaCre_IXN  ON #ListSaldosProducto(cCodCtaCre)
CREATE NONCLUSTERED INDEX #ListSaldosProducto_cCodCliente_IXN ON #ListSaldosProducto(cCodCliente)

----------------------------------------------------------------------------------------

	/*
		DROP TABLE #ListSaldosProducto
	*/

SELECT * 
FROM #ListSaldosProducto
WHERE nSaldoCapi > 0

	-- (233,093 row(s) affected)

SELECT	
		ZON.cDesZona, A.cCodOficin, O.cDesOficin, 
		A.cCodUsuAna, SP.cNomPerson,
		CodComite				=	S.cCodComite,
		DescripComite			=	ISNULL(TC.cDescriTip,'NO REGISTRA'),
		UltimoCargo				= 	CA.cDesCarPer, 						
		NivelAsesor				=	ISNULL(N.cDesClaSub,'NO REGISTRA'),					
		SaldoCapi				=	SUM(A.nSaldoCapi),
		SaldoVig				=	SUM(A.nSaldoVig),
		SaldoVen				=	SUM(A.nSaldoVen),
		SaldoJud				=	SUM(A.nSaldoJud),
		SaldoRef				=	SUM(A.nSaldoRef),
		NumeroClientes			=	COUNT(DISTINCT (A.cCodCliente)),
		NumeroColocaciones		=	COUNT(DISTINCT (A.cCodCtaCre)),
		CreditosNuevos			=	SUM(A.CreditosNuevos),
		CreditosReprestamo		=	SUM(A.CreditosReprestamo),
		CreditosPreferencial	=	SUM(A.CreditosPreferencial),
		RatioMora				=	(SUM(A.nSaldoVen) + SUM(A.nSaldoJud)) / SUM(A.nSaldoCapi)		
FROM #ListSaldosProducto A	
	INNER JOIN [GENTOficinas] O 
		ON O.cCodOficin		= A.cCodOficin and O.lConEstado = '1'			
	INNER JOIN [Gentofizonas] GOZ
		ON GOZ.cCodOficin	= O.cCodOficin and GOZ.lEstZonOfi = '1'
	INNER JOIN [GentZonas] ZON
		ON ZON.nCodZona		= GOZ.nCodZona	
	INNER JOIN [sipmpersonal] SP 
		ON SP.cCodPerson	= A.cCodUsuAna	
	
	INNER JOIN KPYMSolicitud	S
		ON S.cCodSolCre		=	A.cCodSolCre 				
	LEFT JOIN KPYTComite	TC
		ON TC.cCodComite	=	S.cCodComite	AND TC.lConEstado = 1
	INNER JOIN SIPTCARGOPER CA
		ON CA.cCodGruPer = SP.cCodGruPer 				
	
	LEFT JOIN [SIPDIncAsiPon] P 
		ON P.cCodPerson = SP.cCodPerson	AND P.cCodPeriodo = '2015/09'
			AND P.cCodSituac = 'A'						
	LEFT join [SIPTClaSubNiv] N
		ON	N.cCodNivel = P.cCodNivel AND N.cCodSubNiv = P.cCodSubNiv 
			AND N.cCodClaSub = P.cCodClaSub AND N.lConEstado = 1 
			AND N.nCodPAPApr	=	8				
	
WHERE A.nSaldoCapi > 0	AND O.lConEstado = '1'	AND	 ZON.nCodZona = '1'
GROUP BY ZON.cDesZona, A.cCodOficin, O.cDesOficin, A.cCodUsuAna, SP.cNomPerson ,S.cCodComite, TC.cDescriTip,
		 CA.cDesCarPer, N.cDesClaSub
ORDER BY A.cCodOficin,A.cCodUsuAna

-- ZONA LIMA SUR (234 row(s) affected)
-- COMITE (631 rows)


/*

SaldoCapi				NumeroClientes		NumeroColocaciones
1,839,803,827.93		207,615				234,432

--
Saldo					NumeroCLIENTES		NumeroColocaciones
1,839,803,828			207,615				234,432

*/
----------------------------------------------------------------------------------------------------

