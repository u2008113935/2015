/*
		Solicito la relacion de creditos vencidos de la agencia de Chupaca 
		al cierre del 31 de diciembre, ya que existe una inconsistencia 
		con el avance de metas enviadas Sub Gerencia.

*/

DECLARE		@lnTipCambio NUMERIC(14,4)														
			
SET @lnTipCambio = 3.411
-- 3.411  DIC
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
		cCodModCre = 'KPY', A.cCodTipCre, A.cCodProduc, A.cCodSubPro, 		
		A.cCodOficin									
	INTO #curLisSalPro 
FROM	KPYMCREconven A
			INNER JOIN GENMCreCli B
				ON A.cCodCtaCre = B.cCodCtaCre		
WHERE A.CESTCRECON IN ('F','H')	 AND 	A.cCodOficin = '013'
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
		nSaldoJud  = 0, nSaldoRef = 0, cCodModCre = 'KPR', cCodTipCre='03', 
		cCodProduc ='13', cCodSubPro='16', 		
		A.cCodOficin									
FROM KPRMCrePrenda A WITH(NOLOCK)
		INNER JOIN GENMCreCli B WITH(NOLOCK)
			ON A.cCodCtaKpr = B.cCodCtaCre
WHERE A.cCodEstKpr IN ('A','D','G','H','R') AND A.cCodOficin = '013'
		

CREATE NONCLUSTERED INDEX #curLisSalPro_cCodCtaCre_IXN  ON #curLisSalPro(cCodCtaCre)
CREATE NONCLUSTERED INDEX #curLisSalPro_cCodCliente_IXN ON #curLisSalPro(cCodCliente)

/*

	SELECT *
	FROM #curLisSalPro
	WHERE nSaldoCapi > 0

	DROP TABLE #curLisSalPro

*/

SELECT	A.cCodCtaCre,	A.cCodCliente, 
		SaldoCapital		=	A.nSaldoCapi,	
		SaldoVigente		=	A.nSaldoVig,
		SaldoVencido		=	A.nSaldoVen,
		SaldoJudicial		=	A.nSaldoJud,
		SaldoRefinanciado	=	A.nSaldoRef,
		--A.cCodTipCre,						 
		TipoCredito			=	B.cDesTipCre, 
		--A.cCodProduc,	
		ProductoCrediticio	=	B.cDesProCre,  			 
		--A.cCodSubPro,	
		SubProductoCredito	=	B.cDesSubCre,			
		--A.cCodOficin, 
		Agencia				=	O.cDesOficin
FROM #curLisSalPro A
	INNER JOIN [KPYTSUBTIPCRE] B
		ON B.cCodTipCre = A.cCodTipCre AND B.cCodProduc = A.cCodProduc 
			AND B.cCodSubPro = A.cCodSubPro and B.lEstado = '1'
	INNER JOIN [GENTOficinas] O 
		ON O.cCodOficin = A.cCodOficin and O.lConEstado = '1'	
WHERE A.nSaldoCapi > 0


SELECT lnTotalCv	=	SUM(nSaldoCapi),
	   lnTotalCa	=	SUM(nSaldoVen) + SUM(nSaldoJud),
	   lnTotalCli	=	COUNT(DISTINCT (cCodCliente)),
	   lnTotalCre	=	COUNT(DISTINCT (cCodCtaCre)),
	   lnCredProm   =   SUM(nSaldoCapi) / COUNT(DISTINCT (cCodCliente)),
	   lnRatioMora	=	(SUM(nSaldoVen) + SUM(nSaldoJud)) / SUM(nSaldoCapi)	   
FROM #curLisSalPro
WHERE nSaldoCapi > 0